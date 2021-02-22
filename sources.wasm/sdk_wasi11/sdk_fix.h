#include <time.h>
#include <sched.h>
#include <stdio.h>
#include <string.h>


extern struct timeval wa_tv;
extern unsigned int wa_ts_nsec;

static int wasi_clock_gettime(clockid_t clockid, struct timespec *ts) {
    sched_yield();
    ts->tv_sec = wa_tv.tv_sec;
    ts->tv_nsec = wa_ts_nsec;
//fprintf(stderr,"[\"clock_gettime\", %d, %d, %lu, %u]\n", (int)clockid, (int)&ts, ts->tv_nsec, wa_ts_nsec);
    return 0;
}


static int wasi_gettimeofday(struct timeval *tv) {
    sched_yield();
    tv->tv_sec = wa_tv.tv_sec;
    tv->tv_usec = wa_tv.tv_usec;

//fprintf(stderr,"[\"gettimeofday\",%d , %lld, %lld, %u ]\n", (int)&tv, tv->tv_sec, tv->tv_usec, wa_ts_nsec);
    return 0;
}


#undef clock_gettime
#undef gettimeofday

#define wa_clock_gettime(clockid, timespec) wasi_clock_gettime(clockid, timespec)
#define wa_gettimeofday(timeval, tmz) wasi_gettimeofday(timeval)

