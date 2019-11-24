//PMPP API<21
#if __ANDROID__ && (__ANDROID_API__ < 21)
    #ifndef CRYSTAX
    // https://bugs.python.org/file38880/rjmatthews64_fixes2.patch

        #include <stdlib.h>
        #define wcstombs android_wcstombs
        #define mbstowcs android_mbstowcs
        extern size_t android_mbstowcs(wchar_t *dest, char * in, int maxlen);
        extern size_t android_wcstombs(char * dest, wchar_t *source, int maxlen);



        #include <locale.h>
        extern struct lconv *broken_localeconv(void);

    //Objects_obmalloc.c.diff
//        extern void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
    #include <sys/mman.h>

    // Modules_signalmodule.c.diff
//        extern ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);
    #include <sys/sendfile.h>

    //Modules_signalmodule.c.diff
        //#define SIGRTMIN 32
        //#define SIGRTMAX _NSIG

    #endif
#endif

