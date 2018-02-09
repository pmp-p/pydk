import os
import os.path
import sys
import time as Time
import traceback

sys.path.append('/data/data/u.root/usr/src/Roaming/lib/')
import xpy


HOME = "/data/data/u.r"
RunTime.export('__ANDROID__',(sys.platform=='android'))

RunTime.__file__ = f"{HOME}/pyservice.py"
RunTime.__stderr__ = sys.stderr

sys.path.insert(0,f'{HOME}/usr/lib/python3')

tmpdir = "%s/tmp" % HOME
os.system( f'rm {tmpdir}/*.in {tmpdir}/*.out' )
prefix = f"{tmpdir}/%s" % os.getpid()




androidembed.log('PYAPK : pid=%s' % os.getpid() )
androidembed.log('PYAPK : CONSOLE=%s' % os.getenv('CONSOLE') )

env = '%s.env' % prefix

androidembed.log('Waiting env file [%s]'%env)

while True:
    if os.path.exists(env):
        break
    Time.sleep(1)
    #androidembed.log('waiting...')

#os.system('umask 0000;/data/data/u.r/busybox mkfifo %s.in;/data/data/u.r/busybox mkfifo %s.out' % (prefix,prefix) )

with open(env, 'r') as fenv:
    for l in fenv.readlines():
        l=l.strip()
        if l.startswith('CONSOLE='):
            androidembed.log( l )
            pts_out = l.split('=')[-1]
        elif l.startswith('REPL_PID='):
            androidembed.log( l  )
            repl_pid = int( l.split('=')[-1] )


os.environ['CONSOLE'] = pts_out

def test():
    import time as t;tm=t.time(); import panda3d;print(t.time()-tm)

#def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/asteroids/main.py',*flags):
def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/roaming-ralph/main.py',*flags):
    global __file__
    p = p.replace('>','/')
    try:__file__
    except:__file__=RunTime.__file__

    androidembed.log(f"{p} launched from {__file__}")
    __file__ = p
    oldwd = os.getcwd()
    os.chdir( os.path.dirname(__file__) )
    try:
        #redir stderr to logcat
        if -2 in flags:
            sys.stderr = RunTime.__stderr__

        with open(p,'r') as fp:
            exec( fp.read(), globals(), globals() )
    finally:
        sys.stderr = sys.__stderr__
        __file__ = RunTime.__file__
        os.chdir(oldwd)



sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__

#import direct

androidembed.log(' == Interactive (%s, %s) ==' % (repl_pid, pts_out) )

