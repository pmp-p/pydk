/*
    Pmp-P
*/

#include <emscripten.h>
#include <time.h>

extern void emscripten_force_exit(int status);

#define PANDA3D 0
#define PVIEW 0
#define REPL 1

#define LIBPYTHON_SIZE 2400000
#define LIBPP3D_SIZE 4500000

#include <stdlib.h>
#include <stdio.h>
#include <Python.h>


#define NO_HTML 0

#define REPL_INPUT_SIZE 1024
#define REPL_INPUT_MAX 1023

char *global_readline = NULL;

extern void readline_hook();

int status_busy = 1;

static long next_tick = 0;
static long step_tick = 0;
struct timespec tp;

void step_tick_toc();



static PyObject *embed_log(PyObject *self, PyObject *args) {
    char *logstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &logstr)) {
        return NULL;
    }
    int rx = EM_ASM_INT( {  return Module.printErr( Pointer_stringify($0) ); }, logstr );
    Py_RETURN_NONE;
}

static PyObject *embed_kbd_set_line(PyObject *self, PyObject *args) {
    char *thestr = NULL;
    if (!PyArg_ParseTuple(args, "s", &thestr)) {
        return NULL;
    }
    EM_ASM( {  return Module.kbd_set_line(0, Pointer_stringify($0) ); }, thestr );
    Py_RETURN_NONE;
}


static PyObject *embed_kbd_hook_line(PyObject *self, PyObject *args) {
    char *thestr = NULL;
    if (!PyArg_ParseTuple(args, "s", &thestr)) {
        return NULL;
    }
    //MARK REPL BUSY
    status_busy = 1;

    int stl = strlen(thestr);
    if (stl>REPL_INPUT_SIZE){
        stl=REPL_INPUT_SIZE;
        fprintf( stderr, "REPL Buffer overflow: %i > %i", stl, REPL_INPUT_SIZE);
    }
    //global_readline = (char *)PyMem_RawMalloc( stl+1 );
    strncpy(global_readline, thestr, stl);
    global_readline[stl]= 0;
    fprintf( stderr, "HOOK:%s\n", global_readline);
    Py_RETURN_NONE;
}

static PyObject *embed_select(PyObject *self, PyObject *args) {
    int fdnum = -1;
    if (!PyArg_ParseTuple(args, "i", &fdnum)) {
        return NULL;
    }
    return Py_BuildValue("i", EM_ASM_INT( {  return Module.kbd_has_io($0); }, fdnum) );
}

static PyObject *embed_busy(PyObject *self, PyObject *args) {
    int fdnum = -1;
    if (!PyArg_ParseTuple(args, "i", &fdnum)) {
        return NULL;
    }
    return Py_BuildValue("i", status_busy );
}

static PyObject *embed_getch_i(PyObject *self, PyObject *args) {
    int fdnum = -1;
    if (!PyArg_ParseTuple(args, "i", &fdnum)) {
        return NULL;
    }
    return Py_BuildValue("i", EM_ASM_INT( {  return kbd_getch_i($0); }, fdnum) );
}



static PyObject *embed_exit(PyObject *self, PyObject *args) {
    int ec = 1;
    if (!PyArg_ParseTuple(args, "i", &ec)) {
        return NULL;
    }
    emscripten_force_exit(ec);
    Py_RETURN_NONE;
}

static PyMethodDef embed_funcs[] = {
    {"log", embed_log, METH_VARARGS, "Log on browser console only"},
    {"kbd_set_line", embed_kbd_set_line, METH_VARARGS, "fill readline Q"},
    {"kbd_hook_line", embed_kbd_hook_line, METH_VARARGS, "fill readline with malloc char"},
    {"getch_i", embed_getch_i, METH_VARARGS, "simulate raw stdin"},
    {"busy", embed_busy, METH_VARARGS, "repl action in progress"},
    {"select", embed_select, METH_VARARGS, "select on non blocking io stream"},
    {"exit", embed_exit, METH_VARARGS, "exit emscripten"},
    { NULL, NULL, 0, NULL }
};


//extern void package_hook(const char *pn);

static struct PyModuleDef embed = {PyModuleDef_HEAD_INIT, "embed", NULL, -1, embed_funcs};


static PyObject *mod_embed;


PyMODINIT_FUNC initembed(void) {
    mod_embed = PyModule_Create(&embed);
    return mod_embed;
}


extern void EMSCRIPTEN_KEEPALIVE kbd_set_line(char *line)
{
// ** WORKING** but maybe check for OOM bombs.
// also *could* be some C string like: allocate(intArrayFromString("{ 'json' : 'string' }"), 'i8', ALLOC_STACK);
    PyDict_SetItemString( PyModule_GetDict(mod_embed) , "readline", PyUnicode_FromString(line) );
}

#if PANDA3D
    PyMODINIT_FUNC PyInit_core(void);

    PyMODINIT_FUNC PyInit_direct(void);
#endif



/*
There's no support for async reading char by char, and no line handler at python level.


note: PyOS_InputHook would block because it does not override the readline blocking call.

    while (1) {
        if (PyOS_InputHook != NULL)
            (void)(PyOS_InputHook)();

 https://github.com/python/cpython/blob/master/Parser/myreadline.c
   my_readline() has a different return value from GNU readline():
   - NULL if an interrupt occurred or if an error occurred
   - a malloc'ed empty string if EOF was read
   - a malloc'ed string ending in \n normally

Solutions:

     use asyncio  [work]
        no indent input, need to rework whole repl loop.

     use a PyRun_SimpleString hook for some readline emulation.


// PYTHONDEVMODE=1
// https://docs.python.org/dev/using/cmdline.html#id5

*/


void init_python(){
    chdir("/");
    setenv("PYTHONHOME", "/", 0);

    //init*() => Fatal Python error: Python import machinery not initialized

    PyImport_AppendInittab("embed", initembed);

    Py_InitializeEx(0);
}


static char *PyOS_ReadlineFunctionPointer_Impl(FILE *sys_stdin, FILE *sys_stdout, const char *prompt){
    char *p;
    if (global_readline){
        fprintf( stderr, "PyOS_ReadlineFunctionPointer_Impl[%s]", global_readline);
        return global_readline;
    }

    p = (char *)PyMem_RawMalloc(2);
    //p[0] = '#';
    p[0] = '\n';  // <= that should go away mess with indent !
    p[1] = '\0';
    return p;
}



void
py_iter_one(void){
    char *p;

    if (step_tick>10){

        if (global_readline[0]){

            //fprintf( stderr, "READLINE:%s\n", global_readline);
            EM_ASM_( {  return window.kbL.push( Pointer_stringify($0));} , global_readline );

            fprintf(stderr, "PIO: %i '%s'\n", PyRun_InteractiveOne( stdin , "stdin" ), global_readline );
            global_readline[0]=0;
            status_busy = 0;
            PyRun_SimpleString("pass\n");
            return;
        }

        PyRun_SimpleString("RunTime.aio.step()\n");

        return;
    }

    step_tick_toc();
}


void dyld_lzma(const char *lib, long hint_size){
EM_ASM({
        dyld_lzma(Pointer_stringify($0)+".js.lzma",Pointer_stringify($0), $1);
}, lib, hint_size);
}


int
await(const char *def){
    return EM_ASM_INT( { return undef(Pointer_stringify($0)); }, def );
}

/* init menu , table of content must be carefully ordered
    - including .js => need one cycle

    - loading lib*.js => need one cycle

    - loading lib*.js.lzma => need async. + one cycle

    - accessing globals in freshly loaded lib => one cycle.

    Some globals like PyOS_ReadlineFunctionPointer need wrapper function helpers  + one cycle
*/


void step_tick_toc(){
    PyObject *module;

//TODO: store this clock and give it to panda_src_express_trueClock.cxx.diff
    //clock_gettime(CLOCK_MONOTONIC, &tp);
    clock_gettime(CLOCK_REALTIME, &tp);

    //first set the next timer. warn before whole is frozen.
    if (!next_tick){
            printf("Please wait a least 30 sec. Expect a long freeze while starting up, blinking cursor is good sign ...\r\n");
            //printf("First Tick ! emscripten_get_now = %f, tv_nsec = %ld\r\n", emscripten_get_now(), tp.tv_nsec );
            next_tick = tp.tv_sec;
            return;
    }

    //not yet
    if ( next_tick > tp.tv_sec )
        return ;

    step_tick++;
    next_tick = tp.tv_sec+1;



    if (step_tick==1) {
        fprintf(stderr, "%ld: dyld_lzma\r\n", step_tick);
EM_ASM({
        console.log("filesystem+dyld_lzma(begin)");
            //include("./pp/kbd.js");
            include("./pp/afsapi.js");
            include("./pp/lzma_worker.js");
        console.log("filesystem+dyld_lzma(end)");
});
        return;
    }

    if (step_tick==2) {
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
            printf( "%ld: awaiting libpython.\r\n", step_tick );
            step_tick--;
            return;
        }

        fprintf(stderr, "%ld: init_python()\r\n", step_tick);
        printf( "%ld: CPython initialising.\r\n", step_tick );
        init_python();
#if PANDA3D
        fprintf(stderr,"%ld: loading python panda3d support\n", step_tick);
        dyld_lzma("libpp3d", LIBPP3D_SIZE);
#endif

#if PVIEW
        fprintf(stderr, "%ld: dlopen(libpanda3d)\r\n", step_tick);
        EM_ASM({  Module.loadDynamicLibrary('libpanda3d.js'); });
#endif
        return;
    }

    if (step_tick==4) {
#if PANDA3D
        if (await("libpp3d")){
            printf( "%ld: awaiting libpp3d.\r\n", step_tick );
            step_tick--;
            return;
        }
#endif
        fprintf(stderr,"%ld: prepare __main__\n", step_tick);

        PyRun_SimpleString(
                "import sys\n"
                "import embed\n"
                "import builtins\n"
                "builtins.embed = embed\n"
            );

        char *line = "<VIDE>";
        kbd_set_line(line);

        PyRun_SimpleString(
                "print('='*30,embed.readline,'='*30, file=sys.stderr)\n"
                "embed.log('    Testing python log redirection')\n"
                "sys.argv=['em-cpython']\n"
                "sys.path.extend(['.','/lib','/lib/python3'])\n"
                "sys.path.insert(0,'lib/python3-em')\n"
            );
#if PANDA3D

#else
        step_tick = 6;
#endif
                return;
            }


#if PANDA3D
    if (step_tick==5){
        fprintf(stderr,"%ld: panda3d import\n", step_tick);
        PyRun_SimpleString(
                "try:import panda3d\n"
                "except Exception as e:print('ERROR: panda3d stdlib not found')\n"
                "print(sys.modules['panda3d'], file=sys.stderr)\n"
            );

        fprintf(stderr, "%ld: PyInit_(panda3d.core)\r\n", step_tick);

        module = PyInit_core();
        if (module)
            PyDict_SetItemString(PyImport_GetModuleDict(),"panda3d.core",module);
        else fprintf(stderr, "%ld: module *is* NULL\r\n", step_tick);

        //PyDict_SetItemString( PyModule_GetDict(module) , "__name__", PyUnicode_FromString("panda3d.core") );


        PyRun_SimpleString(
                "print(sys.modules['panda3d.core'],file=sys.stderr)\n"
                "panda3d.core = sys.modules['panda3d.core']\n"
                "embed.log('panda3d.core == %s' % panda3d.core)\n"
                "embed.log('panda3d.core.__name__ %s' % panda3d.core.__name__)\n"
            );

        return;
    }


    if (step_tick==6){
        fprintf(stderr, "%ld: PyInit_(panda3d.direct)\r\n", step_tick);
        module = PyInit_direct();
        if (module)
            PyDict_SetItemString(PyImport_GetModuleDict(),"panda3d.direct",module);
        else fprintf(stderr, "%ld: module *is* NULL\r\n", step_tick);

        PyRun_SimpleString(
                "print(sys.modules['panda3d.direct'],file=sys.stderr)\n"
                "panda3d.direct = sys.modules['panda3d.direct']\n"
                "embed.log('panda3d.direct == %s' % panda3d.direct)\n"
                "embed.log('panda3d.direct.__name__ %s' % panda3d.direct.__name__)\n"
                "print('='*80, file=sys.stderr)\n"
            );

        return;
    }
#endif


    if (step_tick==7){
        fprintf(stderr,"%ld: repl prepare\n", step_tick);
        global_readline = (char *)PyMem_RawMalloc(REPL_INPUT_SIZE);
        global_readline[REPL_INPUT_MAX]=0;
        global_readline[0]=0;

        EM_ASM( { window.prompt = window_prompt ; } );

        PyRun_SimpleString(
                "import pouet\n"
                "print(chr(27)+'[2J'+chr(27)+'[1;1H')\n"
                "print(sys.version.replace(chr(10),chr(13)+chr(10)),end=\"\")\n"
                "print(chr(13))\n"
        );

        return;
    }

}


int
main(int argc, char *argv[]) {
    printf("Press ctrl+shift+i to see debug logs, or go to Menu / [more tools] / [developpers tools]\r\n");

//include some tools for further inclusion
#if NO_HTML
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
#endif

EM_ASM({
    // CLOCK ! https://github.com/kripken/emscripten/issues/5893
    //chromium clock is 5x slower to call.
    console.log("clockpatch(begin)");
    //performance.now = Date.now;
    console.log("clockpatch(end)");
});

    emscripten_set_main_loop( py_iter_one, 0, 1);  // <= this will exit to js now.
// will never run
    return 0;
}


