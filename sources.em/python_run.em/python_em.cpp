/*
    Pmp-P
*/

#include <emscripten.h>
#include <time.h>

extern void emscripten_force_exit(int status);

#define PANDA3D 1
#define PVIEW 0
#define PVIEW_STATIC 0
#define PYTHON 1


#include <stdlib.h>
#include <stdio.h>
#include <Python.h>

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

static PyObject *embed_select(PyObject *self, PyObject *args) {
    int fdnum = -1;
    if (!PyArg_ParseTuple(args, "i", &fdnum)) {
        return NULL;
    }
    return Py_BuildValue("i", EM_ASM_INT( {  return Module.kbd_has_io($0); }, fdnum) );
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
    {"select", embed_select, METH_VARARGS, "select on non blocking io stream"},
    {"exit", embed_exit, METH_VARARGS, "exit emscripten"},
    { NULL, NULL, 0, NULL }
};


extern void package_hook(const char *pn);

static struct PyModuleDef embed = {PyModuleDef_HEAD_INIT, "embed", NULL, -1, embed_funcs};


static PyObject *mod_embed;


PyMODINIT_FUNC initembed(void) {
    mod_embed = PyModule_Create(&embed);
    return mod_embed;
}


extern void EMSCRIPTEN_KEEPALIVE kbd_get_line(char *line)
{
// ** WORKING** but must check for OOM bombs.

// that *could* be some string like: allocate(intArrayFromString("{ 'json' : 'string' }"), 'i8', ALLOC_STACK);
    PyDict_SetItemString( PyModule_GetDict(mod_embed) , "readline", PyUnicode_FromString(line) );
}


PyMODINIT_FUNC PyInit_core(void);

PyMODINIT_FUNC PyInit_direct(void);



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


// PYTHONDEVMODE=1
// https://docs.python.org/dev/using/cmdline.html#id5


*/



void init_python(){
#if PYTHON

    chdir("/");
    setenv("PYTHONHOME", "/", 0);

    //init*() => Fatal Python error: Python import machinery not initialized

    PyImport_AppendInittab("embed", initembed);

    Py_InitializeEx(0);
#endif
}


static char *em_readline(FILE *sys_stdin, FILE *sys_stdout, const char *prompt){
    char *p;

    p = (char *)PyMem_RawMalloc(3);
    p[0] = '#';
    p[1] = '\n';  // <= that should go away mess with indent !
    p[2] = '\0';
    return p;
}

static long next_tick = 0;
static long step_tick = 1;
struct timespec tp;

void
py_iter_one(void){
    char *p;
    PyObject *module;

    //clock_gettime(CLOCK_MONOTONIC, &tp);
    clock_gettime(CLOCK_REALTIME, &tp);

    if (!next_tick){
            printf("Please wait a least 30 sec. Expect a long freeze while starting up, blinking cursor is good sign ...\r\n");
            printf("First Tick ! emscripten_get_now = %f, tv_nsec = %ld\r\n", emscripten_get_now(), tp.tv_nsec );
            next_tick = tp.tv_sec+1;
            return;
    }

    if (step_tick>=0){
        if ( next_tick < tp.tv_sec ){
            next_tick = tp.tv_sec+1;
            /*
            if (step_tick==) {
                fprintf(stderr,"beat %ld\n", step_tick);
                EM_ASM({  });
                step_tick++;
                return;
            }
            */

            if (step_tick==1) {
                fprintf(stderr, "%ld: dlopen(libpython)\r\n", step_tick);
                EM_ASM({ Module.loadDynamicLibrary('libpython.js'); });
                step_tick++;
                return;
            }

            if (step_tick==2) {
                fprintf(stderr, "%ld: dlopen(libpanda3d)\r\n", step_tick);
                EM_ASM({  Module.loadDynamicLibrary('libpanda3d.js'); });

                fprintf(stderr, "%ld: dlopen(libpanda3d)\r\n", step_tick);
                step_tick++;
                return;
            }

            if (step_tick==3) {
                fprintf(stderr, "%ld: init_python()\r\n", step_tick);
                init_python();
                step_tick++;
                return;
            }

            if (step_tick==4) {
                fprintf(stderr,"beat %ld\n", step_tick);

                PyRun_SimpleString(
                        "import sys\n"
                        "import embed\n"
                    );
                char *line = "<VIDE>";
                kbd_get_line(line);

                PyRun_SimpleString(
                        "print('='*30,embed.readline,'='*30, file=sys.stderr)\n"
                        "embed.log('    Testing python log redirection')\n"
                        "sys.argv=['em-cpython']\n"
                        "sys.path.extend(['/lib','/lib/python3'])\n"
                        "sys.path.insert(0,'lib/python3-em')\n"
                    );
                step_tick++;
                return;
            }

            if (step_tick==5){
                fprintf(stderr,"%ld: panda3d import\n", step_tick);
                PyRun_SimpleString(
                        "try:import panda3d\n"
                        "except Exception as e:print('ERROR:',e, file=sys.stderr)\n"
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

                step_tick++;
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
                        "embed.log('panda3d.direct == %s' % panda3d.direct)\n"
                        "embed.log('panda3d.direct.__name__ %s' % panda3d.direct.__name__)\n"

                        "print('='*80, file=sys.stderr)\n"
                    );
                step_tick++;
                return;
            }

            if (step_tick==7){
                fprintf(stderr,"%ld: repl prepare\n", step_tick);

                PyRun_SimpleString(
                        "import pouet\n"
                        "print(sys.version.replace(chr(10),chr(13)+chr(10)),end=\"\")\n"
                        "print(chr(13))\n"
                );

                step_tick++;
                return;
            }
        }
    }

    if (step_tick>7){

        PyRun_SimpleString("RunTime.aio.step()\n");

        int rx = EM_ASM_INT( {  return Module.kbd_has_line($0) } , 0 );
        //some line is ready, restore original call pathway.
        if (rx){
            //PyOS_ReadlineFunctionPointer = NULL;
            printf("RX : \n");
            PyRun_InteractiveOne( stdin , "stdin" );
            //PyOS_ReadlineFunctionPointer = em_readline ; // fake input will return non blocking
        }
    }
}


int
main(int argc, char *argv[]) {
    printf("You are likely to be eaten by a grue.\r\n");
    emscripten_set_main_loop( py_iter_one, 0, 1);  // <= this will exit to js now.
// will never run
    return 0;
}

