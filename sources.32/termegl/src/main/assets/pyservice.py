import os
import os.path
import sys
import time as Time
import traceback
import threading

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

#os.system('umask 0000;/data/data/u.r/busybox mkfifo %s.in;/data/data/u.r/busybox mkfifo %s.out' % (prefix,prefix) )

Time.sleep(1)

with open(env, 'r') as fenv:
    for l in fenv.readlines():
        l=l.strip()
        if l.startswith('CONSOLE='):
            androidembed.log( l )
            pts_out = l.split('=')[-1]
            os.environ['CONSOLE'] = pts_out
        elif l.startswith('REPL_PID='):
            androidembed.log( l  )
            repl_pid = int( l.split('=')[-1] )




import nanotui3.input

class Thread_InputService(threading.Thread, nanotui3.input.WASD):
    def __init__(self):
        nanotui3.input.WASD.__init__(self)
        threading.Thread.__init__(self)




    def InputService(self,task):
        key = self.get_key()
        while True:
            flush = self.get_key()
            if not flush:break

        if key==b'q':
            messenger.send('arrow_left')
        elif key==b'd':
            messenger.send('arrow_right')
        elif key==b'z':
            messenger.send('arrow_up')
        elif key==b's':
            messenger.send('arrow_down')
        elif key==b' ':
            messenger.send('space')
        else:
            messenger.send('arrow_left-up')
            messenger.send('arrow_right-up')
            messenger.send('arrow_up-up')
            messenger.send('arrow_down-up')

        Time.sleep(.001)

        return self.Task_cont

    def run(self):

        while True:
            try:
                messenger
                break
            except:
                Time.sleep(4)

        os.environ['RAW_INPUT']="1"

        androidembed.log("%s now feeding %s" % ( self, messenger.getEvents()) )

        import panda3d
        import panda3d.core
        self.mgr = panda3d.core.InputDeviceManager.get_global_ptr()

        androidembed.log("%s"%self.mgr)



        import direct
        import direct.task
        import direct.task.Task
        import direct.task.TaskManagerGlobal

        self.Task_cont = direct.task.Task.Task.cont

        try:
            self.input_dev = base.win.get_input_device(0)
            self.inj_kbd = self.input_dev.keystroke
            androidembed.log("KBD Injection : %s" % self.inj_kbd)
        except Exception as e:
            androidembed.log("ki failed %s" % e)


        self.Begin()
        self.ioTask = direct.task.TaskManagerGlobal.taskMgr.add(self.InputService, "InputService")
        render.setDepthTest(True)


def test():
    import time as t;tm=t.time(); import panda3d;print(t.time()-tm)

#def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/asteroids/main.py',*flags):
#def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/carousel/main.py',*flags):
def run(__file__='/data/data/u.root/usr/src/sdk-panda3d/samples/roaming-ralph/main.py',*flags):
    __file__ = __file__.replace('>','/')
    cd = os.path.dirname(__file__)

    androidembed.log(f"\r\nRunning {__file__} in {cd}\r\n")

    RunTime.io.start()

    oldwd = os.getcwd()

    loadPrcFileData("", "model-path %s:." % cd )
    loadPrcFileData("", "background-color 0 0 0 0")
    os.chdir( cd )
    try:
        #redir stderr to logcat
        if -2 in flags:
            sys.stderr = RunTime.__stderr__

        with open(__file__, 'r') as fp:
            exec( fp.read(), globals(), globals() )
    finally:
        sys.stderr = sys.__stderr__
        os.chdir(oldwd)
    RunTime.io.End()

def tui(__file__='/data/data/u.r/pandamenu.py'):
#def tui(__file__='/data/data/u.root/usr/src/Roaming/lib/nanotui_demo.py'):
    cd= os.path.dirname(__file__)
    print('\r\nRunning',__file__,'in',cd,"\r\n")

    RunTime.io.start()

    oldwd = os.getcwd()
    os.chdir( cd )
    try:
        sys.stderr = RunTime.__stderr__
        with open(__file__,'r') as fp:
            exec( fp.read(), globals(), globals() )
    finally:
        sys.stderr = sys.__stderr__
        __file__ = RunTime.__file__
        os.chdir(oldwd)
    RunTime.io.End()

sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__

RunTime.io = Thread_InputService()


from panda3d.core import loadPrcFileData

loadPrcFileData("", "default-model-extension .bam")

loadPrcFileData("", "textures-power-2 down")
loadPrcFileData("", "textures-square down")
loadPrcFileData("", "tga-rle #t") # tga-grayscale


loadPrcFileData("", "framebuffer-hardware #t")
loadPrcFileData("", "framebuffer-software #t")

androidembed.log(' == Interactive (%s, %s) ==' % (repl_pid, pts_out) )


sys.stdout.flush()
sys.stderr.flush()
