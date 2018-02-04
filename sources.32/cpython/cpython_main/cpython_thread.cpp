#include <pthread.h>

/*
============================================================================================
*/

void * interpreter_thread(void *args) {
    interpreter_main( 1 , (char **)args );
abort_thread:
    pthread_exit(0);
}



/*
============================================================================================
*/

int interpreter_launch(int argc, char *argv[]){
#define CORES 2
    pthread_t thread_id[CORES];
    long thread_args[CORES] ;

    void* core = 0;

    char corepath[] = LIB_PYTHON;
    core = dlopen(corepath, RTLD_LAZY);

    if (core == 0) {
        const char* lasterr = dlerror();
        LOGP( "Fatal Python error: cannot load library :") ;
        LOGP( LIB_PYTHON );
    } else {
        LOGP("interpreter_launch: starting 1 python instance");
        pthread_create(&thread_id[0], NULL, interpreter_thread, &argv[0]);
    }
    return 0;
}




