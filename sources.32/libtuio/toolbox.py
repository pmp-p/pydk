import os,sys
import cffi
import time

ffi = cffi.FFI()
def ticks_us(): return int(time.time() * 1000000)
NaN = float('nan')


# add cycle
class Lapse:
    def __init__(self,intv=1.0,oneshot=None):
        self.cunit = intv
        self.intv = int( intv * 1000000 )
        self.next = self.intv
        self.last = ticks_us()
        self.count = 1.0
        self.__ticks = 0
        if oneshot:
            self.shot = False
            return
        self.shot = None

#FIXME: pause / resume(reset)

    def __bool__(self):
        if self.shot is True:
            return False

        t = ticks_us()
        self.next -= ( t - self.last )
        self.last = t
        self.__ticks += 1

        if self.next <= 0:
            if self.shot is False:
                self.shot = True
            self.count+= self.cunit
            self.next = self.intv
            return True


        return False


    def ticks(self,reset=False):
        try:
            return int(self.__ticks / self.count)
        finally:
            if reset:
                self.__ticks = 0




def SI(dl,bw=0):
    u = 'B/s'
    dl = float(dl)
    if bw:
        dl = dl/float(bw)
        for u in ['KB/s','MB/s','GB/s']:
            dl = dl/1024
            if dl<1024:
                return '%0.2f %s' % (dl,u )
        return '%s %s' %( dl,u )

    for u in ['K','M','G']:
        dl = dl/1024
        if dl<1024:
            return '%0.2f %sB' % (dl,u )
    return '%s %s' %( dl,u )


Cdecls = {}


def codeC(decl,code,name="toolbox"):

    global ffi, Cdecls

    Cdecls.setdefault(name,{})

    cname =  decl.split('(',1)[0].strip().split(' ')[-1]

    Cdecls[name].setdefault(cname,[decl,code])


class ToolBox:
    pass


def buildC(tb='toolbox'):
    #for tb in Cdecls:
    if 1:
        cbox = ToolBox()
        with open( "lib%s.c" % tb,'w') as fcode:
            fcode.write("""/* AOT CODE */

#include "stdio.h"

        """)
            for cname in Cdecls[tb]:
                header =  Cdecls[tb][cname][0]
                ffi.cdef("%s;"% header )
                fcode.write("%s;"% header )

            for cname in Cdecls[tb]:
                fcode.write("%s"% Cdecls[tb][cname][0] )
                fcode.write("%s"% Cdecls[tb][cname][1] )


        os.system('gcc -O3 -fPIC -shared -o lib%s.so lib%s.c -lc' % (tb,tb) )
        lib = ffi.dlopen("./lib%s.so" % tb )
        for cname in Cdecls[tb]:
            setattr( cbox , cname , getattr(lib,cname) )
        return cbox


