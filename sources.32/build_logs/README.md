# Modules/signalmodule.c
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
Why ?  incomplete headers on API19, it is common for boundary constants MIN/MAX of Linux to be missing 

fix
```
#if __ANDROID_API__ < 20
    #define SIGRTMIN 32
    #define SIGRTMAX _NSIG
#endif
```


# Linker error 
```
/data/data/android/android-ndk-r14b/toolchains/llvm/prebuilt/linux-x86_64/bin/clang -target armv7-none-linux-androideabi -gcc-toolchain /data/data/android/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64 -L/data/data/build.32/cpython-android_api19/Android/build/python3.7-extlibs-android-19-armv7//data/local/tmp/python/lib --sysroot=/data/data/android/android-ndk-r14b/platforms/android-19/arch-arm -march=armv7-a -Wl,--fix-cortex-a8  -pie -Xlinker -export-dynamic -o python Programs/python.o -L. -lpython3.7dm -ldl    -lm  
./libpython3.7dm.so: error: undefined reference to 'localeconv'
clang: error: linker command failed with exit code 1 (use -v to see invocation)
Makefile:581: recipe for target 'python' failed
make[2]: *** [python] Error 1
make[2]: Leaving directory '/data/data/build.32/cpython-android_api19/Android/build/python3.7-android-19-armv7'
/data/data/build.32/cpython-android_api19/Android/build.mk:144: recipe for target 'host' failed
make[1]: *** [host] Error 2
```
Why ?
Header of ndk 10/14 api 19 defines localeconv() but it is not implemented except in C++ stdlib.

fix
```

#if defined(__ANDROID_API__) && __ANDROID_API__ < 20
/*
char    *currency_symbol
char    *decimal_point
char     frac_digits
char    *grouping
char    *int_curr_symbol
char     int_frac_digits
char     int_n_cs_precedes
char     int_n_sep_by_space
char     int_n_sign_posn
char     int_p_cs_precedes
char     int_p_sep_by_space
char     int_p_sign_posn
char    *mon_decimal_point
char    *mon_grouping
char    *mon_thousands_sep
char    *negative_sign
char     n_cs_precedes
char     n_sep_by_space
char     n_sign_posn
char    *positive_sign
char     p_cs_precedes
char     p_sep_by_space
char     p_sign_posn
char    *thousands_sep
*/

unsigned char const decimal_point[] =".";
unsigned char const thousands_sep[] = { 0, 0 };
static struct lconv lc_cache ;

//extern "C" {
extern struct lconv *localeconv(void){
//std::use_facet<std::numpunct<char> >(std::locale(std::setlocale(LC_ALL, NULL))).decimal_point();
        lc_cache.decimal_point = &decimal_point;

//std::use_facet<std::numpunct<char> >(std::locale(std::setlocale(LC_ALL, NULL))).thousands_sep();
        lc_cache.thousands_sep = &thousands_sep ;
        return &lc_cache;
    }
//}
#endif
```

# ref:
```
/*

Thanks to:

  crystax ndk : python 3.5
  kivy : https://github.com/inclement/python-for-android
  python-for-android : https://code.google.com/archive/p/python-for-android/wikis/CrossCompilingPython.wiki
  Chih-Hsuan Yen (yan12125) : https://github.com/yan12125/python3-android
  xdegaye : https://github.com/xdegaye/cpython/tree/bpo-30386
  localeconv c++ fix :
        https://github.com/nlohmann/json/pull/687/files
        https://gist.github.com/dpantele/d2e2aec8ff23b0208245c8a6e882f7fe
*/
```
