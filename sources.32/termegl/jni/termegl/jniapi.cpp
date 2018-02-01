#include <stdio.h>
#include <stdint.h>
#include <jni.h>


#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>
//#include <GLES/gl.h>

#include "logger.h"



static char *app_folder = "/data/data/u.r.p3d";
static int PyAPI_Ready = 0;


/* version selector */
#define PY_INTERPRETER 0
#define PY_REPL 0
#define PY_PREPARE 1

static char *root_folder = "/data/data/u.r";


#define PYTHONPATH "/data/data/u.r/usr/lib/python3.7/lib-dynload:/data/data/u.r/usr/lib/python3.7:/data/data/u.r/usr/lib/python3"
#define LIB_PYTHON "libpython3.7m.so"

#define PY_PATH "/data/data/u.r/usr/lib/python3.7"
//could be zip if change dir/file test to check trailing /
#define PY_LIB "/data/data/u.r/usr/lib/python3.7/"
#define PY_LIBS "/data/data/u.r/usr/lib/python3.7:/data/data/u.r/usr/lib/python3"

#define PYVER 37
#define PY_LOG "Python3.7m"

/* standard python3+ skeleton for an interpreter */
#include "cpython_main/cpython3xm.cpp"


/** support for faking a main() for interpreter and use pthread to run it
  * just before entering Py_Initialize "interpreter_prepare" will be called from thead
  *
  */

//#include "/data/data/u.root/usr/src/projects/python-cffi/cpython_thread.cpp"

#include "cpython_main/cpython_thread.cpp"



#undef LOG_TAG
#define LOG_TAG "PythonAPI-EGL"


static ANativeWindow *window = 0;
static char app_ptr[32]= {0};
static char *argv[] = {"/data/data/u.root/main.py"};

static EGLDisplay display;
static EGLSurface surface;
static EGLContext context;


// tuio
#include "tuio_listener.h"
#include "tuio_client.h"
#include "tuio_udp_receiver.h"
#include <math.h>



extern "C" {

    JNIEXPORT void JNICALL Java_u_r_Term_nativeOnStart(JNIEnv* jenv, jobject obj)
    {
        LOG_INFO("    ===================  nativeOnStart ==================== ");
        //renderer = new Renderer();
        if (!PyAPI_Ready){
            LOG_INFO("py_not_ready");
            return;
        }
        return;
    }

    JNIEXPORT void JNICALL Java_u_r_Term_nativeOnResume(JNIEnv* jenv, jobject obj)
    {
        LOG_INFO("    ===================  nativeOnResume ==================== ");
        if (!PyAPI_Ready){
            LOG_INFO("py_not_ready");
            return;
        }
        //renderer_instance->start();
        return;
    }

    JNIEXPORT void JNICALL Java_u_r_Term_nativeOnPause(JNIEnv* jenv, jobject obj)
    {
        LOG_INFO("    ===================  nativeOnPause ==================== ");
        if (!PyAPI_Ready){
            LOG_INFO("py_not_ready");
            return;
        }

        //renderer_instance->stop();
        return;
    }

    JNIEXPORT void JNICALL Java_u_r_Term_nativeOnStop(JNIEnv* jenv, jobject obj)
    {
        LOG_INFO("    ===================  nativeOnStop ==================== ");
        if (!PyAPI_Ready){
            LOG_INFO("py_not_ready");
            return;
        }
        //delete renderer_instance;
        //renderer_instance = 0;
        return;
    }

    JNIEXPORT void JNICALL Java_u_r_Term_nativeSetSurface(JNIEnv* jenv, jobject obj, jobject surface)
    {
        LOG_INFO("    ===================  nativeSetSurface ==================== ");
        if (surface != 0) {

            window = ANativeWindow_fromSurface(jenv, surface);
            LOG_INFO("   @@@@@@@@@@@@ Got window %p  @@@@@@@@@@@", window);

            snprintf(app_ptr, 16, "%p", (void * )window );
            setenv("PANDA_NATIVE_WINDOW", app_ptr, 1);
            //interpreter_prepare();
            interpreter_launch(1,argv);

        } else {
            LOG_INFO("Releasing window");
            ANativeWindow_release(window);
        }

        return;
    }

    int interpreter_prepare()
    {
        void* window=0;
        char app_ptr[32]= {0};

        LOG_ERROR("#FIXME: PANDA_PRC_DIR / PANDA_PRC_PATH have not effect !");
        setenv("PANDA_PRC_DIR", "/data/data/u.r/etc", 1);
        setenv("PANDA_PRC_PATH", "/data/data/u.r/etc", 1);

        //RECEIVE
        sscanf( getenv("PANDA_NATIVE_WINDOW"), "%p", &window );
        LOG_INFO(" >>>>> PANDA_NATIVE_WINDOW pointer [ %p ] <<<<< ", window);

        EGLNativeWindowType _window = (EGLNativeWindowType)window;
        if ( window ){

            //renderer_instance->setWindow( (ANativeWindow*) window);
            LOG_INFO("Initializing context");
            const EGLint attribs[] = {
                EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
                EGL_BLUE_SIZE, 8,
                EGL_GREEN_SIZE, 8,
                EGL_RED_SIZE, 8,
                EGL_NONE
            };

            EGLConfig config;
            EGLint numConfigs;
            EGLint format;
            EGLint width;
            EGLint height;
            //GLfloat ratio;

            ANativeWindow_setBuffersGeometry(_window, 0, 0, format);

            if ((display = eglGetDisplay(EGL_DEFAULT_DISPLAY)) == EGL_NO_DISPLAY) {
                LOG_ERROR("eglGetDisplay() returned error %d", eglGetError());
                return -1;
            }

            if (!eglInitialize(display, 0, 0)) {
                LOG_ERROR("eglInitialize() returned error %d", eglGetError());
                return -1;
            }

            LOG_INFO(" >>>>> display pointer set to %p <<<<< ", display);


            if (!eglChooseConfig(display, attribs, &config, 1, &numConfigs)) {
                LOG_ERROR("eglChooseConfig() returned error %d", eglGetError());
                return -1;
            }

            if (!eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format)) {
                LOG_ERROR("eglGetConfigAttrib() returned error %d", eglGetError());
                return -1;
            }


            //TRANSMIT
            snprintf(app_ptr, 16, "%p", (void * )display );
            setenv("PANDA_NATIVE_DISPLAY", app_ptr, 1);

            if (!(surface = eglCreateWindowSurface(display, config, _window, 0))) {
                LOG_ERROR("eglCreateWindowSurface() returned error %d", eglGetError());
                goto fail;
            }

            //TRANSMIT
            snprintf(app_ptr, 16, "%p", (void * )surface );
            setenv("PANDA_NATIVE_SURFACE", app_ptr, 1);

            if (!(context = eglCreateContext(display, config, 0, 0))) {
                LOG_ERROR("eglCreateContext() returned error %d", eglGetError());
                goto fail;
            }

            if (!eglMakeCurrent(display, surface, surface, context)) {
                LOG_ERROR("eglMakeCurrent() returned error %d", eglGetError());
                goto fail;
            }

            if (!eglQuerySurface(display, surface, EGL_WIDTH, &width) ||
                !eglQuerySurface(display, surface, EGL_HEIGHT, &height)) {
                LOG_ERROR("eglQuerySurface() returned error %d", eglGetError());
                goto fail;
            }

            //TRANSMIT
            snprintf(app_ptr, 16, "%p", (void * )context );
            setenv("PANDA_NATIVE_CONTEXT", app_ptr, 1);

            /*
            glDisable(GL_DITHER);
            glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
            glClearColor(0, 0, 0, 0);
            glEnable(GL_CULL_FACE);
            glShadeModel(GL_SMOOTH);
            glEnable(GL_DEPTH_TEST);

            glViewport(85, 60, width-85, height-60);

            ratio = (GLfloat) width / height;
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glFrustumf(-ratio, ratio, -1, 1, 1, 10);
*/
            //PyAPI_Ready = 1;

            /**
             * Initializes the library.  This must be called at least once before any of
             * the functions or classes in this library can be used.  Normally, this is
             * called by JNI_OnLoad.
             */
            /*
              PNMFileTypeRegistry *tr = PNMFileTypeRegistry::get_global_ptr();
              PNMFileTypeAndroid::init_type();
              PNMFileTypeAndroid::register_with_read_factory();
              tr->register_type(new PNMFileTypeAndroid);
            */

            return 1;
fail:
        LOG_INFO("Destroying context");
        if (display){
            eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
            if (context)
                eglDestroyContext(display, context);
            if (surface)
                eglDestroySurface(display, surface);
            eglTerminate(display);
        }
        return -1;

        }
    }
};
