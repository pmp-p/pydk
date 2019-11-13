//PMPP API<21
#if __ANDROID__ && (__ANDROID_API__ < 21)
    #ifndef CRYSTAX
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
