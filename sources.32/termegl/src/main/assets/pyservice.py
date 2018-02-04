import os
import sys
import time
loop=0
_=''

__ANDROID__ = (sys.platform=='android')

if __ANDROID__:
    data= "/data/data/u.r/tmp/p"
    sys.path.insert(0,'/data/data/u.root/usr/src/Roaming/lib/')
    sys.path.insert(0,'/data/data/u.r/usr/lib/python3')

else:
    data = '/tmp/p'
    sys.path.insert(0,'/Volumes/Roaming/lib/')

os.system('umask 0000;/data/data/u.r/busybox mkfifo %s.in;/data/data/u.r/busybox mkfifo %s.out' % (data,data) )


p_o = os.open( '%s.out' % data , os.O_WRONLY )
print("OUT ready")
p_i = os.open( '%s.in' % data, os.O_RDONLY )
print("IN ready")

while True:
    data = os.read(p_i,128)
    if data:
        data = data.decode('utf-8')
        print(">>> %s" % data )

        if data.startswith('quit'):
            break
        exec(data,globals(),locals())
        try:
            print( bytes('%s [%s]' % (data,_),'utf-8') )
            os.write(p_o, bytes('%s [%s]' % (data,_),'utf-8') )
        except:
            pass


os.close(p_o)
os.close(p_i)
os.system('( sleep 1 && kill -9 %s)&' % os.getpid() )
print('Bye')
