/*

ref:

  crystax ndk :
  kivy :
  python-for-android : https://code.google.com/archive/p/python-for-android/wikis/CrossCompilingPython.wiki
  Chih-Hsuan Yen (yan12125) : https://github.com/yan12125/python3-android
  xdegaye : https://github.com/xdegaye/cpython/tree/bpo-30386
  localeconv c++ fix :
        https://github.com/nlohmann/json/pull/687/files
        https://gist.github.com/dpantele/d2e2aec8ff23b0208245c8a6e882f7fe
*/


#define PY_SSIZE_T_CLEAN
#include "Python.h"

#ifdef PY_REPL
    extern int Py_Main(int argc, wchar_t **argv);
#endif

#include <dlfcn.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>
#include <jni.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

#include "android/log.h"
#define LOG(n, x) __android_log_write(ANDROID_LOG_INFO, (n), (x))
#define LOGP(x) LOG( PY_LOG, (x))

#define ENTRYPOINT_MAXLEN 128

#include <locale.h>

#if PY_PREPARE > 0
    extern "C" int interpreter_prepare();
#endif

static PyObject *androidembed_log(PyObject *self, PyObject *args) {
    char *logstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &logstr)) {
        return NULL;
    }
    LOG(getenv("PYTHON_NAME"), logstr);
    Py_RETURN_NONE;
}

static PyObject *androidembed_run(PyObject *self, PyObject *args) {
    char *runstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &runstr)) {
        return NULL;
    }

    PyRun_SimpleString(runstr);

    //LOG(getenv("PYTHON_NAME"), logstr);
    Py_RETURN_NONE;
}


static PyMethodDef AndroidEmbedMethods[] = {
    {"log", androidembed_log, METH_VARARGS, "Log on android platform"},
    {"run", androidembed_run, METH_VARARGS, "Run on android platform"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef androidembed = {PyModuleDef_HEAD_INIT, "androidembed", NULL, -1, AndroidEmbedMethods};

PyMODINIT_FUNC initandroidembed(void) {
    return PyModule_Create(&androidembed);
}

int dir_exists(char *filename) {
    struct stat st;
    if (stat(filename, &st) == 0) {
        if (S_ISDIR(st.st_mode))
          return 1;
        }
    return 0;
}

int file_exists(const char *filename) {
    FILE *file = fopen(filename, "r") ;
    if (file) {
        fclose(file);
        return 1;
    }
    return 0;
}

int interpreter_main(int argc, char *argv[] ){
    char *env_logname = PY_LOG;
    char str_cp[513];
    char main_py[256];
    int ret = 0;
    FILE *fd = NULL;
    main_py[255]=0;
    str_cp[512]=0;

#ifndef PY_PREPARE
    #error sorry, i need PY_PREPARE set to 0 or 1 to set callback mode or not
#endif

#ifndef PY_REPL
       #error sorry, i need PY_REPL set to 0 or 1 to choose python mode
#endif

#ifndef PY_INTERPRETER
    #error sorry, i need PY_INTERPRETER set to 0 or 1 to set standalone mode or not
#endif


#if PY_PREPARE
    LOGP("Preparing Python3 for Android embedding");
    if (interpreter_prepare()<0){
        LOGP("FATAL: ------- > interpreter_prepare() <0");
        return -1;
    }
#endif

    LOGP("Initializing Python3 for Android");

    setenv("XDG_CONFIG_HOME", "/data/data/u.r/XDG_CONFIG_HOME", 1);
    setenv("XDG_CACHE_HOME", "/data/data/u.r/XDG_CACHE_HOME", 1);
    setenv("PYTHONDONTWRITEBYTECODE","1",1);
    setenv("PYTHON_NAME", "python-main", 1);
    setenv("LD_LIBRARY_PATH","/data/data/u.root/lib-armhf:/data/data/u.r/lib-armhf:/vendor/lib:/system/lib",1);
    setenv("PYTHON_HOME", "/data/data/u.r/usr", 1);
    setenv("PYTHONPATH",PYTHONPATH,1);
    setenv("PYTHONCOERCECLOCALE","1",1);

    Py_SetProgramName(L"./python3");

 /* our logging module for android */

#if PYVER > 36
    setlocale(LC_ALL, "C.UTF-8");
#endif

    LOGP("ADDING: PyImport_AppendInittab(androidembed, initandroidembed);");
    PyImport_AppendInittab("androidembed", initandroidembed);


    LOGP("Preparing to initialize python");

    if (!dir_exists(PY_LIB)) {
        LOGP("FATAL: ------- > stdlib not found in:");
        LOGP( PY_LIB );
        return -1;
    }

    LOGP("Python stdlib folder found at :");
    LOGP(PY_LIB);
    char paths[256];

    snprintf(paths, sizeof(str_cp),
         "%s/stdlib.zip:%s:%s/lib-dynload:%s/site-packages:%s",
         PY_PATH,PY_PATH, PY_PATH, PY_PATH, PY_PATH, PY_LIBS);

    LOGP("calculated paths to be...");
    LOGP(paths);

    wchar_t *wchar_paths = Py_DecodeLocale(paths, NULL);
    LOGP("Setting wchar paths...");
    Py_SetPath(wchar_paths);

    LOGP("Initialize python");
    Py_Initialize();

    LOGP("Initialized python");

    /* ensure threads will work. */
    LOGP("<InitThreads>");
    PyEval_InitThreads();
    LOGP("</InitThreads>");

    LOGP("<LogTest>");
    PyRun_SimpleString("import androidembed\nandroidembed.log('    testing python print redirection')");
    LOGP("</LogTest>");

    /* inject our bootstrap code to redirect python stdin/stdout replace sys.path with our path */

    PyRun_SimpleString(
        "import sys\n"
        "sys.path.insert(0,'.')\n"
        "sys.argv=[]\n"
    );

    snprintf(str_cp,  sizeof(str_cp),"sys.path.append('''%s/usr/lib/python3''')", root_folder);
    PyRun_SimpleString(str_cp);

    snprintf(str_cp, sizeof(str_cp), "sys.path.append('''%s/site-packages''')", PY_PATH );
    PyRun_SimpleString(str_cp);

    int i;
    for (i=0;i<argc;i++){
        snprintf(str_cp, sizeof(str_cp), "sys.argv.append('''%s''')", argv[i]);
        PyRun_SimpleString(str_cp);
    }


    /* run python !   */

    LOGP("about to enter pymain");

#if PY_REPL > 0
    LOGP("     as interpreter");
    setenv("PANDA_NATIVE_WINDOW","0",1);
    PyCompilerFlags cf;
    cf.cf_flags = 0;
    Py_InspectFlag = 0;
    if (argc<2){

        printf("Python 3.7.0a3+ (default, Jan 31 2018, 06:01:49)\n[Clang 3.8.275480 ] on android\n");
        printf("Type \"help\", \"copyright\", \"credits\" or \"license\" for more information.\n");
        int sts = PyRun_AnyFileFlags(stdin, "<stdin>", &cf) != 0;
    } else {
        fd = fopen( argv[1], "r");
        if (fd == NULL) {
            LOGP("faild to open the entrypoint :");
            LOGP(argv[1]);
            return -1;
        }

        ret = PyRun_SimpleFile(fd, "__main__" );

    }

#else
    snprintf(str_cp, sizeof(str_cp), "     as service [%s]", argv[0]);
    LOGP(str_cp);

    chdir(root_folder);

    PyRun_SimpleString(
      "sys.argv = ['notaninterpreter']\n"
      "class LogFile(object):\n"
      "    def __init__(self):\n"
      "        self.buffer = ''\n"
      "    def write(self, s):\n"
      "        s = self.buffer + s\n"
      "        lines = s.split(\"\\n\")\n"
      "        for l in lines[:-1]:\n"
      "            androidembed.log(l)\n"
      "        self.buffer = lines[-1]\n"
      "    def flush(self):\n"
      "        return\n"
      "sys.stdout = sys.stderr = LogFile()\n"
      "print('Android path', sys.path)\n"
      "import os\n"
      "print('os.environ is', os.environ)\n"
      "print('python bootstrap done. __name__ is', __name__)");



    LOGP("Run user program, change dir and execute entrypoint :");
    snprintf(main_py, 512, "%s", argv[0] );

    LOGP( main_py);
    if ( (int)main_py[0]==45){
        LOGP("FIFO interactive");

        snprintf(str_cp, sizeof(str_cp), "print('pid=%i')", getpid() );
        PyRun_SimpleString( str_cp );

        snprintf(main_py, sizeof(main_py),"/data/data/u.r/tmp/pin");

        LOGP("Running entry point :"); LOGP(main_py);
        LOGP(" ////////// TODO INTERACTIVE ////////////");
        goto done;
    }

    if (!file_exists(main_py)) {
        LOGP("entrypoint script not found !");
        LOGP( main_py);
        ret = 1;

        //default
        LOGP("WARNING: Running default program, change dir and execute entrypoint :");
        snprintf(main_py,  sizeof(main_py), "%s/%s", root_folder , "main.py");

        LOGP( main_py);

        if (!file_exists(main_py)) {
            LOGP("entrypoint script not found !");
            LOGP( main_py);
            ret = 1;
            goto done;
        }
    }

    /* Insert the script entrypoint in argv */
    snprintf(str_cp, sizeof(str_cp), "sys.argv.insert(1,'''%s''')", main_py );
    PyRun_SimpleString( str_cp );

    /* exec the file */
    fd = fopen( main_py, "r");
    if (fd == NULL) {
        LOGP("failed to open the entrypoint :");
        LOGP(main_py);
        ret = 1;
        goto done;
    }

    LOGP("Running entry point :"); LOGP(main_py);
    ret = PyRun_SimpleFile(fd, main_py );

#endif

    if (PyErr_Occurred() != NULL) {
        ret = 1;
        PyErr_Print(); /* This exits with the right code if SystemExit. */
        PyObject *f = PySys_GetObject("stdout");

         /* python2 used Py_FlushLine, but this no longer exists */
        if (PyFile_WriteString("\n", f))
            PyErr_Clear();
    }

done:

  /* close everything  */
    Py_Finalize();
    if (fd)
        fclose(fd);

    LOGP("Python for android ended.");

    return ret;

}


#if PY_INTERPRETER > 0
int main(int argc,char *argv[]){
    return interpreter_main(argc,argv);
}
#endif











