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

//embed configure
extern "C" int interpreter_prepare();

static PyObject *embed_log(PyObject *self, PyObject *args) {
    char *logstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &logstr)) {
        return NULL;
    }
    LOG(getenv("PYTHON_NAME"), logstr);
    Py_RETURN_NONE;
}

static PyObject *embed_run(PyObject *self, PyObject *args) {
    char *runstr = NULL;
    if (!PyArg_ParseTuple(args, "s", &runstr)) {
        return NULL;
    }
    PyRun_SimpleString(runstr);
    Py_RETURN_NONE;
}


static PyMethodDef embedMethods[] = {
    {"log", embed_log, METH_VARARGS, "Log on android platform"},
    {"run", embed_run, METH_VARARGS, "Run on android platform"},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef embed = {PyModuleDef_HEAD_INIT, "embed", NULL, -1, embedMethods};

PyMODINIT_FUNC init_embed(void) {
    return PyModule_Create(&embed);
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
    const char *env_logname = PY_LOG;
    char str_cp[513];
    char main_py[256];
    int ret = 0;
    FILE *fd = NULL;
    main_py[255]=0;
    str_cp[512]=0;



    LOGP("Preparing Python3-async for embedding");
    if (interpreter_prepare()<0){
        LOGP("FATAL: ------- > interpreter_prepare() <0");
        return -1;
    }

    LOGP("Initializing Python3");

    setenv("XDG_CONFIG_HOME", APK_HOME, 1);
    setenv("XDG_CACHE_HOME", APK_HOME, 1);
    setenv("PYTHONDONTWRITEBYTECODE","1",1);
    setenv("PYTHON_NAME", "python-apk", 1);
    setenv("LD_LIBRARY_PATH", LD_LIBRARY_PATH,1);
    setenv("PYTHONHOME", PYTHONHOME, 1);
    setenv("PYTHONPATH", PYTHONPATH, 1);
    setenv("PYTHONCOERCECLOCALE","1",1);
    setenv("PYTHONUNBUFFERED","1",1);

    LOGP("Preparing PATH to initialize python");

    // wait main thread
    while ( !file_exists("/data/data/u.root.kit/assets/setup_done") ){
        sleep(1);
        LOGP("  ... still waiting for ./assets/setup_done mark ...");
    }

    #ifdef PY_LIBZ
        LOGP("WARNING: ------- > stdlib zip expected as:");
        LOGP(PY_LIBZ);

    #else
    if (!dir_exists((char*)PYTHONPATH)) {
        LOGP("FATAL: ------- > stdlib not found in:");
        LOGP( PYTHONPATH );
        return -1;
    }
    #endif

    char paths[1024];

    snprintf(paths, sizeof(str_cp), "%s:%s/lib-dynload:%s/site-packages", PY_PATH, PY_PATH, PY_PATH);

    LOGP("Calculated paths to be...");
    LOGP(paths);

    Py_SetProgramName(PY_NAME);

    setlocale(LC_ALL, "C.UTF-8");

    LOGP("ADDING: PyImport_AppendInittab(embed, init_embed);");
    PyImport_AppendInittab("embed", init_embed);

    wchar_t *wchar_paths = Py_DecodeLocale(paths, NULL);

    LOGP("Setting wchar paths... ");
    LOGP((const char *)paths);
    LOGP((const char *)wchar_paths);
    Py_SetPath( (wchar_t *)paths);

    LOGP("Initializing python... ");
    Py_Initialize();

    /* ensure threads will work. */
    LOGP("<InitThreads>");
    PyEval_InitThreads();
    LOGP("</InitThreads>");

    LOGP("Python onitialized");

    LOGP("<LogTest>");
    PyRun_SimpleString("import embed\nembed.log('    Testing python print redirection')");
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

    snprintf(str_cp, sizeof(str_cp), "     as service [%s]", argv[0]);
    LOGP(str_cp);

    chdir(root_folder);

    PyRun_SimpleString(
      "sys.argv = ['embedded']\n"
      "class LogFile(object):\n"
      "    def __init__(self):self.buffer = ''\n"
      "    def write(self, s):\n"
      "        s = self.buffer + s\n"
      "        lines = s.split(\"\\n\")\n"
      "        for l in lines[:-1]:\n"
      "            embed.log(l)\n"
      "        self.buffer = lines[-1]\n"
      "    def flush(self):return\n"
      "sys.stdout = sys.stderr = LogFile()\n");

    //int  priority = getpriority(0, 0);
    //return setpriority( PRIO_PROCESS, 0, priority+increment);
    //snprintf(str_cp, sizeof(str_cp), "prio=%i", priority );
    //LOGP( str_cp );

    LOGP("Run user program, change dir and execute entrypoint :");
    snprintf(main_py, 512, "%s", argv[0] );

    LOGP( main_py);

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

    LOGP("Reopening std fds and running entry point :"); LOGP(main_py);

    ret = PyRun_SimpleFile(fd, main_py );

    freopen( getenv("CONSOLE") , "rw", stdin );
    freopen( getenv("CONSOLE") , "w", stdout );
    freopen( getenv("CONSOLE") , "w", stderr );
    LOGP("pong");
    PyRun_SimpleString(
        "print(sys.version)\n"
        "print('>>> ',end='')\n"
    );

    //setbuf(stdout, NULL);
    setvbuf (stdout, NULL, _IONBF, BUFSIZ);
    //setbuf(stdin, NULL);
    setvbuf (stdin, NULL, _IONBF, BUFSIZ);

    fflush(NULL);

    PyCompilerFlags cf;
    cf.cf_flags = 0;
    Py_InspectFlag = 1;
    PyRun_AnyFileFlags(stdin, "<stdin>", &cf);

/*
    PyRun_SimpleString(
        "while True:\n"
        "    aioL=RunTime.aio.loop\n"
        "    aioL.call_soon(aioL.stop)\n"
        "    aioL.run_forever()\n"
    );
*/

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











