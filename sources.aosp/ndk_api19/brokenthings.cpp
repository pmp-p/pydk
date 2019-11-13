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

#include "jni.h"

JNIEnv *java = NULL;

#ifndef __cplusplus
#pragma message "dirty C hack"
#include <locale.h>
struct lconv *broken_localeconv(void){
        //std::use_facet<std::numpunct<char> >(std::locale(std::setlocale(LC_ALL, NULL))).decimal_point();

    static char decimal_point[] =".";
    static char thousands_sep[] = { 0, 0 };
    static char grouping = {127};
    static struct lconv lc_cache ;

    lc_cache.decimal_point = &decimal_point[0];

    //std::use_facet<std::numpunct<char> >(std::locale(std::setlocale(LC_ALL, NULL))).thousands_sep();
    lc_cache.thousands_sep = &thousands_sep[0] ;

    lc_cache.grouping = &grouping[0];
    return &lc_cache;
}
#else
#pragma message "localeconv from C++ lib exported to C"
#include <locale>
#include <iostream>

using namespace std;

extern "C" {
    struct lconv *broken_localeconv(void){
        static lconv lc_cache ;
        std::cout << "\nBegin:broken_localeconv()\n";
        static char decimal_point = std::use_facet<std::numpunct<char> >(std::locale(setlocale(LC_ALL, NULL))).decimal_point();
        lc_cache.decimal_point = &decimal_point;

        static char thousands_sep = std::use_facet<std::numpunct<char> >(std::locale(setlocale(LC_ALL, NULL))).thousands_sep();
        lc_cache.thousands_sep = &thousands_sep ;

        static std::string groupchar = std::use_facet<std::moneypunct<char> >(std::locale(setlocale(LC_ALL, NULL))).grouping();
        static char grouping[] = {127};

        if (groupchar.length())
            grouping[0] = groupchar[0];

        lc_cache.grouping = &grouping[0];
        std::cout << "\nEnd:broken_localeconv()\n";
        return &lc_cache;
    }


    //JNIEnv * JNI_GetCreatedJavaVMs
    jint JNI_GetDefaultJavaVMInitArgs(void*){
        return 0;
    }

    jint JNI_CreateJavaVM(JavaVM**, JNIEnv**, void*){
        return 0;
    }

    jint JNI_GetCreatedJavaVMs(JavaVM**, jsize, jsize*){
        return 0;
    }
}


#endif
