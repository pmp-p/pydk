/*
 * Copyright (C) 2007, 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "common.h"

#define LOG_TAG "Exec"

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <signal.h>

#include "jni.h"

int init_Exec(JNIEnv *env);





static const char *classPathName = "u/r/Exec";
static JNINativeMethod method_table[] = {
/*    { "setPtyWindowSizeInternal", "(IIIII)V",
        (void*) android_os_Exec_setPtyWindowSize},
    { "setPtyUTF8ModeInternal", "(IZ)V",
        (void*) android_os_Exec_setPtyUTF8Mode}
*/
};

int init_Exec(JNIEnv *env) {
    if (!registerNativeMethods(env, classPathName, method_table,
                 sizeof(method_table) / sizeof(method_table[0]))) {
        return JNI_FALSE;
    }

    return JNI_TRUE;
}
