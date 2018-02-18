import os
import os.path
import sys
import time as Time
import traceback
import socket
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
    Time.sleep(.5)

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



#import nanotui3.input
import queue

class Inputs(threading.Thread):

    kb = []

    def __init__(self,*argv,**kw):
        threading.Thread.__init__(self)
        self.setup(*argv,**kw)

    def awaitPandaIO(self,iohandler, delay=.5):
        androidembed.log('awaiting panda3d')
        while True:
            try:
                messenger
                break
            except:
                Time.sleep(.5)
        Time.sleep(4)
        androidembed.log(' == panda3d detected ==')
        os.environ['RAW_INPUT']="1"
        import panda3d
        import panda3d.core
        self.mgr = panda3d.core.InputDeviceManager.get_global_ptr()

        import direct
        import direct.task
        import direct.task.Task
        import direct.task.TaskManagerGlobal

        self.input_dev = base.win.get_input_device(0)
        self.inj_kbd = self.input_dev.keystroke
        self.Task_cont = direct.task.Task.Task.cont

        direct.task.TaskManagerGlobal.taskMgr.add(iohandler, "InputService")

        androidembed.log(' == panda3d input service [%s ] launched ==' % iohandler)
        return True


class Thread_TUIOService(Inputs):

    KMAP = {
        19  : 'arrow_up',
        21  : 'arrow_left',
        22  : 'arrow_right',
        20  : 'arrow_down',
        66  : 'enter',
        160 : 'enter',
        67  : 'backspace',
        111 : 'escape',
        112 : 'delete',
        121 : 'pause',
        131 : 'f1',
        132 : 'f2',
        133 : 'f3',
        134 : 'f4',
        135 : 'f5',
        136 : 'f6',
        137 : 'f7',
        138 : 'f8',
        139 : 'f9',
        140 : 'f10',
        141 : 'f11',
        142 : 'f12',

    }
    CMAP = {
        ' ' : 'space',
        '\t': 'tab',
    }
    def setup(self,port=7000):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind( ('0.0.0.0',int(port),) )

    def InputService(self,task):
        if len(self.kb):
            elems = self.kb.pop(0)
            keycode, evtype, evcount, key = elems
            keycode = int(keycode)
            if evtype=='1':up='-up'
            else:up=''

            if keycode in self.KMAP:
                messenger.send(''.join( (self.KMAP[keycode],up,) ) )
            elif key in self.CMAP:
                messenger.send(''.join( (self.CMAP[key],up,) ) )
            else:
                messenger.send( ''.join( (key.lower(),up,) ) )
                androidembed.log("kbd %s" % elems )


        return self.Task_cont

    def run(self):
        if self.awaitPandaIO(self.InputService):
            while True:
                data, address = self.sock.recvfrom(32)
                if data.startswith(b'/kbd'):
                    self.kb.append( data.decode('utf-8')[5:].split(', ') )
                else:
                    androidembed.log("? %s : [%s]"% ( len(data),repr(data)) )


#class Thread_InputService(threading.Thread, nanotui3.input.WASD):
#    def __init__(self):
#        nanotui3.input.WASD.__init__(self)
#        threading.Thread.__init__(self)
#
#
#    def InputService(self,task):
#        key = self.get_key()
#        while True:
#            flush = self.get_key()
#            if not flush:break
#
#        if key==b'q':
#            messenger.send('arrow_left')
#        elif key==b'd':
#            messenger.send('arrow_right')
#        elif key==b'z':
#            messenger.send('arrow_up')
#        elif key==b's':
#            messenger.send('arrow_down')
#        elif key==b' ':
#            messenger.send('space')
#        else:
#            messenger.send('arrow_left-up')
#            messenger.send('arrow_right-up')
#            messenger.send('arrow_up-up')
#            messenger.send('arrow_down-up')
#
#        Time.sleep(.001)
#
#        return self.Task_cont
#
#    def run(self):
#        if self.awaitPandaIO(self.InputService):
#            androidembed.log("%s now feeding %s" % ( self, messenger.getEvents()) )
#
#            androidembed.log("%s"%self.mgr)
#
#            try:
#                self.input_dev = base.win.get_input_device(0)
#                self.inj_kbd = self.input_dev.keystroke
#                androidembed.log("KBD Injection : %s" % self.inj_kbd)
#            except Exception as e:
#                androidembed.log("ki failed %s" % e)
#
#            self.Begin()



def test():
    import time as t;tm=t.time(); import panda3d;print(t.time()-tm)

#def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/asteroids/main.py',*flags):
#def run(p='/data/data/u.root/usr/src/sdk-panda3d/samples/carousel/main.py',*flags):
#def run(__file__='/data/data/u.root/usr/src/sdk-panda3d/samples/roaming-ralph/main.py',*flags):
#def run(__file__='/data/data/u.root/usr/src/sdk-panda3d/samples/music-box/main.py',*flags):
def run(__file__="/data/data/u.root/usr/src/sdk-panda3d/samples-bullet/bullet_problem/main.py",*flags):
    __file__ = __file__.replace('>','/')
    cd = os.path.dirname(__file__)

    androidembed.log(f"\r\nRunning {__file__} in {cd}\r\n")


    RunTime.tuio.start()


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

    RunTime.tuio.start()

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


#RunTime.io = Thread_InputService()
RunTime.tuio = Thread_TUIOService()

try:
    import panda3d
    import panda3d.core
    loadPrcFileData = panda3d.core.loadPrcFileData

    loadPrcFileData("", "default-model-extension .bam")

    loadPrcFileData("", "textures-power-2 down")
    loadPrcFileData("", "textures-square down")
    loadPrcFileData("", "tga-rle #t") # tga-grayscale
    #loadPrcFileData("", "threading-model Cull/Draw")

    loadPrcFileData("", "framebuffer-hardware #t")
    loadPrcFileData("", "framebuffer-software #t")

    loadPrcFileData("", "win-origin -2 -2")
    loadPrcFileData("", "win-size 640 360")

    #loadPrcFileData("", "win-origin -2 -2")
    #loadPrcFileData("", "win-size 848 480")

    CACHE_DIR='/data/data/u.r/XDG_CACHE_HOME/panda3d'
    loadPrcFileData("", 'model-cache-dir %s' % CACHE_DIR )
    loadPrcFileData("", "model-cache-textures #f")

    loadPrcFileData("", "undecorated #t")
    loadPrcFileData("", "background-color   0.5 0.5 0.5 1")
    loadPrcFileData("", "audio-library-name p3openal_audio")
    androidembed.log("pandarc complete")
except Exception as e:
    androidembed.log("!!!! pandarc failed %s"%e)

sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__


#
#"""
#
#if __ANDROID__:
#    loadPrcFileData("", "load-display pandagles")
#    loadPrcFileData("", "load-display pandagles2")
#    loadPrcFileData("", "load-display p3android")
#    loadPrcFileData("", "load-file-type p3ptloader")
#    loadPrcFileData("", "load-file-type egg pandaegg")
#    loadPrcFileData("", "load-audio-type * p3ffmpeg")
#    loadPrcFileData("", "load-video-type * p3ffmpeg")
#    loadPrcFileData("", "egg-object-type-portal          <Scalar> portal { 1 }")
#    loadPrcFileData("", "egg-object-type-polylight       <Scalar> polylight { 1 }")
#    loadPrcFileData("", "egg-object-type-seq24           <Switch> { 1 } <Scalar> fps { 24 }")
#    loadPrcFileData("", "egg-object-type-seq12           <Switch> { 1 } <Scalar> fps { 12 }")
#    loadPrcFileData("", "egg-object-type-indexed         <Scalar> indexed { 1 }")
#    loadPrcFileData("", "egg-object-type-seq10           <Switch> { 1 } <Scalar> fps { 10 }")
#    loadPrcFileData("", "egg-object-type-seq8            <Switch> { 1 } <Scalar> fps { 8 }")
#    loadPrcFileData("", "egg-object-type-seq6            <Switch> { 1 } <Scalar>  fps { 6 }")
#    loadPrcFileData("", "egg-object-type-seq4            <Switch> { 1 } <Scalar>  fps { 4 }")
#    loadPrcFileData("", "egg-object-type-seq2            <Switch> { 1 } <Scalar>  fps { 2 }")
#    loadPrcFileData("", "egg-object-type-binary          <Scalar> alpha { binary }")
#    loadPrcFileData("", "egg-object-type-dual            <Scalar> alpha { dual }")
#    loadPrcFileData("", "egg-object-type-glass           <Scalar> alpha { blend_no_occlude }")
#    loadPrcFileData("", "egg-object-type-model           <Model> { 1 }")
#    loadPrcFileData("", "egg-object-type-dcs             <DCS> { 1 }")
#    loadPrcFileData("", "egg-object-type-notouch         <DCS> { no_touch }")
#    loadPrcFileData("", "egg-object-type-barrier         <Collide> { Polyset descend }")
#    loadPrcFileData("", "egg-object-type-sphere          <Collide> { Sphere descend }")
#    loadPrcFileData("", "egg-object-type-invsphere       <Collide> { InvSphere descend }")
#    loadPrcFileData("", "egg-object-type-tube            <Collide> { Tube descend }")
#    loadPrcFileData("", "egg-object-type-trigger         <Collide> { Polyset descend intangible }")
#    loadPrcFileData("", "egg-object-type-trigger-sphere  <Collide> { Sphere descend intangible }")
#    loadPrcFileData("", "egg-object-type-floor           <Collide> { Polyset descend level }")
#    loadPrcFileData("", "egg-object-type-dupefloor       <Collide> { Polyset keep descend level }")
#    loadPrcFileData("", "egg-object-type-bubble          <Collide> { Sphere keep descend }")
#    loadPrcFileData("", "egg-object-type-ghost           <Scalar> collide-mask { 0 }")
#    loadPrcFileData("", "egg-object-type-glow            <Scalar> blend { add }")
#    loadPrcFileData("", "egg-object-type-direct-widget   <Scalar> collide-mask { 0x80000000 } <Collide> { Polyset descend }")
#    loadPrcFileData("", "cull-bin gui-popup 60 unsorted")
#
#
#
#"""


androidembed.log(' == Interactive (%s, %s) ==' % (repl_pid, pts_out) )

#

sys.stdout.flush()
sys.stderr.flush()














#
