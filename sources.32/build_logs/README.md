*** Modules/signalmodule.c
```
/data/data/build.32/cpython-android_api19/Modules/signalmodule.c:1436:33: error: implicit declaration of function '__libc_current_sigrtmin' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
    if (PyModule_AddIntMacro(m, SIGRTMIN))
                                ^
/data/data/android/android-ndk-r14b/sysroot/usr/include/signal.h:79:19: note: expanded from macro 'SIGRTMIN'
#define SIGRTMIN (__libc_current_sigrtmin())
                  ^
/data/data/build.32/cpython-android_api19/Modules/signalmodule.c:1440:33: error: implicit declaration of function '__libc_current_sigrtmax' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
    if (PyModule_AddIntMacro(m, SIGRTMAX))
                                ^
/data/data/android/android-ndk-r14b/sysroot/usr/include/signal.h:80:19: note: expanded from macro 'SIGRTMAX'
#define SIGRTMAX (__libc_current_sigrtmax())
                  ^
/data/data/build.32/cpython-android_api19/Modules/signalmodule.c:1440:33: note: did you mean '__libc_current_sigrtmin'?
/data/data/android/android-ndk-r14b/sysroot/usr/include/signal.h:80:19: note: expanded from macro 'SIGRTMAX'
#define SIGRTMAX (__libc_current_sigrtmax())
                  ^
/data/data/build.32/cpython-android_api19/Modules/signalmodule.c:1436:33: note: '__libc_current_sigrtmin' declared here
    if (PyModule_AddIntMacro(m, SIGRTMIN))
                                ^
/data/data/android/android-ndk-r14b/sysroot/usr/include/signal.h:79:19: note: expanded from macro 'SIGRTMIN'
#define SIGRTMIN (__libc_current_sigrtmin())
                  ^
2 errors generated.
```
