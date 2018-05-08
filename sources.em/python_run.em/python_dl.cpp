/*
 */
#include <emscripten.h>
#include <time.h>


#define PYTHON 1
#define DYLDZ 1

#define LIBPYTHON_SIZE 1156394


#if PYTHON
    #include <stdlib.h>
    #include <stdio.h>
    #include <Python.h>
#endif


#ifdef EMSCRIPTEN
    extern void emscripten_force_exit(int status);
#endif




/*
There's no support for async reading char by char, and no line handler at python level.


note: PyOS_InputHook would block because it does not override the readline blocking call.

    while (1) {
        if (PyOS_InputHook != NULL)
            (void)(PyOS_InputHook)();

 https://github.com/python/cpython/blob/master/Parser/myreadline.c
   Readline interface for tokenizer.c and [raw_]input() in bltinmodule.c.
   By default, or when stdin is not a tty device, we have a super
   simple my_readline function using fgets.
   Optionally, we can use the GNU readline library.
   my_readline() has a different return value from GNU readline():
   - NULL if an interrupt occurred or if an error occurred
   - a malloc'ed empty string if EOF was read
   - a malloc'ed string ending in \n normally


Solutions:

     use asyncio  [work]
      no indent input, need to rework whole repl loop.

     use a PyRun_SimpleString hook for some readline emulation.


*/


#define REPL_INPUT_SIZE 1024
#define REPL_INPUT_MAX 1023


char *global_readline = NULL;
static int status_busy = 1;

// CLOCK ! https://github.com/kripken/emscripten/issues/5893
struct timespec tp;
static long next_tick = 0;
static long step_tick = 0;
static long frame_rate = 0;
void step_tick_toc();

void python_prompt(){
    printf(" \n");
}

static PyObject *
embed_log(PyObject *self, PyObject *args) {
    char *logstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &logstr)) {
        return NULL;
    }
    int rx = EM_ASM_INT( {  return Module.printErr( Pointer_stringify($0) ); }, logstr );
    Py_RETURN_NONE;
}

static PyObject *
embed_select(PyObject *self, PyObject *args) {
    int fdnum = -1;
    if (!PyArg_ParseTuple(args, "i", &fdnum)) {
        return NULL;
    }
    //LOG(getenv("PYTHON_NAME"), logstr);
    return Py_BuildValue("i", EM_ASM_INT( {  return Module.has_io($0); }, fdnum) );
}


static PyObject*
embed_exit(PyObject *self, PyObject *args) {
    int ec = 1;
    if (!PyArg_ParseTuple(args, "i", &ec)) {
        return NULL;
    }
    emscripten_force_exit(ec);
    Py_RETURN_NONE;
}

static PyMethodDef embed_funcs[] = {
    {"log", embed_log, METH_VARARGS, "Log on browser console only"},
    {"select", embed_select, METH_VARARGS, "select on non blocking io stream"},
    {"exit", embed_exit, METH_VARARGS, "exit emscripten"},
    { NULL, NULL, 0, NULL }
};


static struct PyModuleDef embed = {PyModuleDef_HEAD_INIT, "embed", NULL, -1, embed_funcs};

PyMODINIT_FUNC init_embed(void) {
    return PyModule_Create(&embed);
}


extern "C" {

    EMSCRIPTEN_KEEPALIVE int
    kbd_set_line(char *line)
    {
        status_busy = 1;
        int stl = strlen(line);
        if (stl>REPL_INPUT_SIZE){
            stl=REPL_INPUT_SIZE;
            fprintf( stderr, "REPL Buffer overflow: %i > %i", stl, REPL_INPUT_SIZE);
        }

        //global_readline = (char *)PyMem_RawMalloc( stl+1 );
        strncpy(global_readline, line, stl);
        //fprintf( stderr,"kbd_set_line(%s)\n", global_readline );
        global_readline[stl]= 0;
        return stl;
    }
}

int
await(const char *def){
    return !EM_ASM_INT( { return defined(Pointer_stringify($0)); }, def );
}


#if DYLDZ
void dyld_lzma(const char *lib, long hint_size){
EM_ASM({
        dyld_lzma(Pointer_stringify($0)+".js.lzma",Pointer_stringify($0), $1);
}, lib, hint_size);
}
#endif

void
init_python(){

#if DYLDZ
#else
    EM_ASM({ Module.loadDynamicLibrary('libpython.js'); });
#endif

    //  PYTHONDEVMODE=1
    // https://docs.python.org/dev/using/cmdline.html#id5

    chdir("/");
    setenv("PYTHONHOME", "/", 0);

    //init_embed() => Fatal Python error: Python import machinery not initialized

    fprintf(stderr, "PyImport_AppendInittab\n");
        PyImport_AppendInittab("embed", init_embed);

    fprintf(stderr, "Py_InitializeEx\n");
        Py_InitializeEx(0);

    fprintf(stderr, "PyRun_SimpleString\n");
        PyRun_SimpleString(
                "import embed\n"
                "embed.log('    Testing python log redirection')\n"
                "import sys\n"
                "sys.argv=['em-cpython']\n"
                "sys.path.extend(['/lib','/lib/python3'])\n"
                "print(sys.version)\n"
            );

}



void
py_iter_one(void){
    char *p;

    if (step_tick>10){

        if (global_readline[0]){

            //fprintf( stderr, "READLINE:%s\n", global_readline);
            //history
            EM_ASM_( {  return window.kbL.push( Pointer_stringify($0));} , global_readline );

            PyRun_InteractiveOne( stdin , "stdin" );
            global_readline[0]=0;
            status_busy = 0;
            python_prompt();
            return;
        }

        //PyRun_SimpleString("RunTime.aio.step()\n");

        return;
    }

    step_tick_toc();
}


void
step_tick_toc(void){
    clock_gettime(CLOCK_MONOTONIC, &tp);

    frame_rate++;

    if (!next_tick){
        fprintf(stderr, "First tick\n");
        next_tick = tp.tv_sec+1;
        return ;
    }


    if (next_tick>tp.tv_sec)
        return;

    step_tick++;
    next_tick = tp.tv_sec+1;

    fprintf(stderr, "step_tick %ld  framerate = %ld\n", step_tick, frame_rate);

    frame_rate = 0;

    if (step_tick==1){
EM_ASM({
        console.log("filesystem(begin)");
            include("./pp/kbd.js");
            include("./pp/afsapi.js");
            include("./pp/lzma_worker.js");
        console.log("filesystem(end)");
        window.C_kbd_set_line = Module.cwrap('kbd_set_line', 'number', ['number']);
});
        return ;
    }


    if (step_tick==2) {
#if DYLDZ
        if (await("dyld_lzma")){
            fprintf(stderr, "%ld: dyld_lzma await == %i.\n", step_tick, await("dyld_lzma") );
            step_tick--;
            return;
        }

        fprintf(stderr, "%ld: dlopen(libpython)\r\n", step_tick);
        dyld_lzma("libpython", LIBPYTHON_SIZE);
        return;
    }

    if (step_tick==3) {
        if (await("libpython")){
            printf( "%ld: awaiting libpython.js.lzma.\r\n", step_tick );
            step_tick--;
            return;
        }
#endif
        fprintf(stderr, "%ld: init_python()\r\n", step_tick);
        //printf( "%ld: CPython initialising.\r\n", step_tick );
        init_python();
        step_tick = 5;
        return;
    }

    if (step_tick==6){
        python_prompt();
        EM_ASM( { window.prompt = window_prompt ; } );
        return;
    }

    if (step_tick==8){
        fprintf(stderr, "tick test\n");
        const char *pv = "print(sys.version.replace(chr(10),chr(13)+chr(10)),end=\"\");print(chr(13))";
        global_readline = (char *)PyMem_RawMalloc(REPL_INPUT_SIZE);
        global_readline[REPL_INPUT_MAX]=0;
        global_readline[0]=0;

    }

}


int
main(int argc, char *argv[]) {

EM_ASM({
    console.log("include(begin)");
    var fileref=document.createElement('script');
    fileref.setAttribute("type","text/javascript");
    fileref.setAttribute("src", "./pp/tools.js");
    fileref.setAttribute('async',false);
    fileref.defer = false;
    document.getElementsByTagName("head")[0].appendChild(fileref);
    console.log("include(end)");

});

EM_ASM({
    performance.now = Date.now;
});

/*
    PyCompilerFlags cf;
    cf.cf_flags = 0;
    int ret =  PyRun_AnyFileFlags( stdin, "<stdin>", &cf);
    printf(" exit: %i\n", ret);

*/
    emscripten_set_main_loop( py_iter_one, 0, 1);  // <= this will exit to js now.

    //emscripten_force_exit(0);

    return 0;                   // success
}

