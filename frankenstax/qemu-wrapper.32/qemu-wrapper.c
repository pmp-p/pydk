#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>


ssize_t readlink(const char *pathname, char *buf, size_t bufsiz);

#define MAX_PATH 512

static void GetExecutablePath(char* path)
{
  int size = readlink("/proc/self/exe", path, MAX_PATH);
  if (size < 0)
    size = 0;
  path[size] = 0;
}

#define DEBUG 0

int main(int argc, char **argv, char **envp) {
    char **newargv;
    char target[MAX_PATH];
    char exe[MAX_PATH];

    int patchstart = 6 ;
    int gpp = 0;
    int gcc = 0;

    GetExecutablePath(exe);

    snprintf(target,MAX_PATH, "%s.386", exe );

    if ( strstr(exe,"/u.root/bin/gcc")  ){
        gcc = 1;
#if DEBUG        
        printf("patching gcc cmdline : %s with %s \n", exe, "--sysroot=/data/data/u.root/arm-linux-androideabi/sysroot");                
#endif        
    }

    if ( strstr(exe,"/u.root/bin/g++")  ){
        gpp = 1;
#if DEBUG        
        printf("patching g++ cmdline : %s with %s \n", exe, "--sysroot=/data/data/u.root/arm-linux-androideabi/sysroot");                
#endif        
    }


    if ( gcc | gpp ){

        patchstart = 8;   
    }

    newargv = (char **)malloc((argc + patchstart + 1) * sizeof(*newargv));

    newargv[0] = argv[0];
    newargv[1] = "-cpu";
    newargv[2] = "n270";
    newargv[3] = "-0";
    newargv[4] = argv[0];
    newargv[5] = target;
    
    if (patchstart>6){
        // newargv[patchstart-1] = "--sysroot=/data/data/u.root/arm-linux-androideabi/sysroot";
        
        if (gcc){
            newargv[patchstart-2] = "-std=gnu11";        
            newargv[patchstart-1] = "--sysroot=/data/data/u.root";
        }
        
        if (gpp){
            newargv[patchstart-2] = "-std=c++11";                
            newargv[patchstart-1] = "--sysroot=/data/data/u.root";        
        }
    }

    if (argc > 0)
    {
	    memcpy(&newargv[patchstart], &argv[1], sizeof(*argv) * (argc - 1));
    }
    newargv[argc + patchstart -1] = NULL;
#if DEBUG
    if (gpp|gcc) {
        if (patchstart>6){
            for (int i = 0; i < argc + patchstart-1; ++i)
            {
	            printf("\"%s\", ", newargv[i]);
            }
            printf("\n");
        }
    }
#endif

    return execve("/data/data/u.r/bin/qemu-i386-static", newargv, envp);
}

