import os
import os.path
import sys
import time as Time
import traceback
import socket
import threading

sys.path.append('/data/data/u.root/usr/src/Roaming/lib/')
import xpy


HOME = os.getenv('HOME',"/data/data/u.r")


RunTime.__file__ = f"{HOME}/pyservice.py"
RunTime.__stderr__ = sys.stderr
RunTime.__stdout__ = sys.stdout

sys.path.insert(0, f'{HOME}/usr/lib/python3')

tmpdir = f"{HOME}/tmp"
os.system( f'rm {tmpdir}/*.in {tmpdir}/*.out' )


androidembed.log('PYAPK : pid=%s' % os.getpid() )
androidembed.log('PYAPK : CONSOLE=%s' % os.getenv('CONSOLE') )

mark_env = f'{tmpdir}/{os.getpid()}.env'

androidembed.log(f'Waiting env file [{mark_env}]')

while True:
    if os.path.exists(mark_env):
        break
    Time.sleep(.1)


RunTime.io = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
RunTime.io.bind( ('0.0.0.0',int( os.environ.get('TUIO_SOCKET','7000')), ) )
RunTime.io.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)


with open(mark_env, 'r') as fenv:
    for l in fenv.readlines():
        l=l.strip()
        if l.startswith('CONSOLE='):
            androidembed.log( l )
            pts_out = l.split('=')[-1]
            os.environ['CONSOLE'] = pts_out
        elif l.startswith('REPL_PID='):
            androidembed.log( l  )
            repl_pid = int( l.split('=')[-1] )

os.unlink(mark_env)


class Inputs(threading.Thread):

    kb = []

    def __init__(self,*argv,**kw):
        threading.Thread.__init__(self)
        self.setup(*argv,**kw)
        self.alive = None

    def setup_task(self,handler):
        import panda3d
        import panda3d.core
        import direct
        import direct.task
        import direct.task.Task
        import direct.task.TaskManagerGlobal

        self.mgr = panda3d.core.InputDeviceManager.get_global_ptr()

        RunTime.task_mgr = direct.task.TaskManagerGlobal.taskMgr

        try:
            #self.input_dev = base.win.get_input_device(0)
            #self.inj_kbd = self.input_dev.keystroke
            self.Task_cont = direct.task.Task.Task.cont
        except Exception as e:
            androidembed.log(' !! panda3d input service failure !! %s' % e)
            return False

        RunTime.task_mgr.add(handler, handler.__name__)
        androidembed.log(' == panda3d input service [%s ] launched ==' % handler)
        self.alive = True

    def awaitPandaIO(self,delay=.5):
        androidembed.log('awaiting panda3d')
        while True:
            try:
                messenger
                break
            except:
                Time.sleep(.2)
        Time.sleep(.5)
        androidembed.log(' == panda3d detected ==')
        RunTime.__base__ = base
        os.environ['RAW_INPUT']="1"
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
        #
        111 : 'escape',
        4   : 'escape',
        #
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

    def setup(self,*argv,**kw):
        androidembed.log('Begin: input thread ')


    def URoot_InputService(self,task):
        if len(self.kb):
            elems = self.kb.pop(0)
            keycode, keyuc, evtype, evcount, key = elems
            keycode = int(keycode)
            if evtype=='1':up='-up'
            else:up=''

            if keycode in self.KMAP:
                messenger.send(''.join( (self.KMAP[keycode],up,) ) )
            elif key in self.CMAP:
                messenger.send(''.join( (self.CMAP[key],up,) ) )
            else:
                messenger.send( ''.join( (key.lower(),up,) ) )
                #self.inj_kbd( int(keyuc) )
                androidembed.log("kbd %s" % elems )


        return self.Task_cont

    def run(self):
        while self.alive is None:
            Time.sleep(.1)

        if self.awaitPandaIO():
            while True:
                data, address = RunTime.io.recvfrom(32)
                if not self.alive:break
                if data.startswith(b'/kbd'):
                    self.kb.append( data.decode('utf-8')[5:].split(', ') )
                else:
                    androidembed.log("? %s : [%s]"% ( len(data),repr(data)) )

    def End(self):
        if self.alive:
            self.alive = False
            androidembed.log('End: input thread ')

            os.environ['RAW_INPUT']="0"
            os.environ.pop('RAW_INPUT',None)



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
def info(*argv,**kw):
    androidembed.log("PYLOG: %s" % repr(argv) )

builtins.info = info
builtins.log  = info
builtins.err  = info
builtins.dev  = info
builtins.fix  = info


DEFAULT='/data/data/u.r/pandamenu.py'
DEFAULT='/data/data/u.root/usr/src/Roaming/lib/pandatest.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/asteroids/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/carousel/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/roaming-ralph/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/music-box/main.py'

DEFAULT = "/data/data/u.root/sdk/panda3d/samples-bullet/bullet_problem/main.py"
DEFAULT = "/data/data/u.root/usr/src/Roaming/lib/utest.py"
#DEFAULT = "/data/data/u.root/sdk/panda3d/samples-bullet/bullet_problem/test2w.py"

def flush_io(restore=False):
    if restore:
        sys.stdout = sys.__stdout__
        sys.stderr = sys.__stderr__
    sys.stdout.flush()
    sys.stderr.flush()

def run(__file__=DEFAULT,*flags):
    __file__ = __file__.replace('>','/')
    cd = os.path.dirname(__file__)

    flush_io()

    androidembed.log(f"\r\nRunning {__file__} in {cd}\r\n")

    RunTime.tuio = Thread_TUIOService()

    RunTime.tuio.start()

    oldwd = os.getcwd()

    loadPrcFileData("", f"model-path {cd}:."  )
    loadPrcFileData("", "background-color 0 0 0 0")
    os.chdir( cd )


    androidembed.log("-----------------------------------------")
    androidembed.log("----------------------------------------")
    androidembed.log("---------------------------------------")

    if hasattr(RunTime,'__base__') and hasattr(builtins,'base'):
        androidembed.log("masking existing showbase")
        #delattr(builtins,'base')
        #RunTime.__camera__.reparent_to(render)
        #render.ls()
    else:
        import direct
        import direct.showbase
        import direct.showbase.ShowBase
        import direct.task
        import direct.task.Task
        import direct.task.TaskManagerGlobal
        RunTime.task_mgr = direct.task.TaskManagerGlobal.taskMgr

#        base = direct.showbase.ShowBase.ShowBase()
#
#        for c in render.findAllMatches('*'):
#            print(c)
#            RunTime.__camera__ = c
#            #RunTime.__camera__.detachNode()
#
#
#
#        base.camNode.getDisplayRegion(0).setActive(True)
#
#        for t in RunTime.task_mgr.getAllTasks():
#            androidembed.log("%s"%t)
#        RunTime.__base__ = getattr(builtins,'base',None)

    RunTime.tuio.setup_task(RunTime.tuio.URoot_InputService)
    androidembed.log("-----------------------------------------")


    try:
        #redir stdout to logcat
        if -1 in flags:
            sys.stdout = RunTime.__stdout__
        #redir stderr to logcat
        if -2 in flags:
            sys.stderr = RunTime.__stderr__

        with open(__file__, 'r') as fp:
            exec( fp.read(), globals(), globals() )
    except SystemExit as se:
        androidembed.log( f"Exit request from [{__file__}]" )
        try:
            RunTime.tuio.End()
            print(f"script {__file__} exiting...")
            render.node().removeAllChildren()


            base.setBackgroundColor(0.0, 0.0, 0.0, 1.0)
            RunTime.task_mgr.step()
            RunTime.task_mgr.step()

            base.setBackgroundColor(0.1, 0.1, 0.1, 0.0)
            #base.setBackgroundColor(0.1, 0.1, 0.8, 0)
            RunTime.task_mgr.step()
            RunTime.task_mgr.step() # need two ...
            for t in RunTime.task_mgr.getAllTasks():
                androidembed.log("%s"%t)
                RunTime.task_mgr.remove(t)


            RunTime.task_mgr.step()
            RunTime.task_mgr.step()


            #base.camNode.getDisplayRegion(0).setActive(False)
            #base.destroy()

            #RunTime.task_mgr.destroy()

            #base.graphicsEngine.remove_all_windows()

        except Exception as e:
            androidembed.log( f"panda clean up from [{__file__}] failed : {e}" )
    finally:
        os.chdir(oldwd)
        RunTime.tuio.End()

    flush_io(True)
    #FIXME: pause instead of destroy
    del RunTime.tuio
    androidembed.log('io restored')



def dry(__file__=DEFAULT,*flags):
    __file__ = __file__.replace('>','/')
    cd = os.path.dirname(__file__)

    flush_io()


    oldwd = os.getcwd()
    os.chdir( cd )

    androidembed.log(f"\r\nRunning {__file__} in {cd}\r\n")

    try:
        #redir stdout to logcat
        if -1 in flags:
            sys.stdout = RunTime.__stdout__
        #redir stderr to logcat
        if -2 in flags:
            sys.stderr = RunTime.__stderr__

        with open(__file__, 'r') as fp:
            exec( fp.read(), globals(), globals() )
    except SystemExit as se:
        print(f"script {__file__} exiting...")
    except Exception as e:
        androidembed.log( f"clean up from [{__file__}] failed : {e}" )
    finally:
        flush_io(restore=True)
        os.chdir(oldwd)


def dbg(__file__=DEFAULT):
    return run(__file__,-1,-2)


try:
    import panda3d
    import panda3d.core
    loadPrcFileData = panda3d.core.loadPrcFileData

    loadPrcFileData("", "tga-rle #t") # tga-grayscale
    #loadPrcFileData("", "threading-model Cull/Draw")

    loadPrcFileData("", "framebuffer-hardware #t")
    loadPrcFileData("", "framebuffer-software #t")

    #loadPrcFileData("", "win-origin -2 -2")
    loadPrcFileData("", "win-size 640 360")
    loadPrcFileData("", "window-type onscreen")
    loadPrcFileData("", "window-title none")

    #X loadPrcFileData("", "yield-timeslice #t")

    #loadPrcFileData("", "win-origin -2 -2")
    #loadPrcFileData("", "win-size 848 480")

    loadPrcFileData("", 'model-cache-dir %s' % f'{HOME}/XDG_CACHE_HOME/panda3d' )
    loadPrcFileData("", "model-cache-textures #f")
    loadPrcFileData("", "model-path /data/data/u.root/usr/share/panda3d/models:." )
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

def aloop(*args, **kargs):
    """ Ensure there is an opened event loop available and return it"""
    loop = asyncio.get_event_loop()
    if loop.is_closed():
        policy = asyncio.get_event_loop_policy()
        loop = policy.new_event_loop(*args, **kargs)
        policy.set_event_loop(loop)
    return loop



def arun(coro):
    """ Run this in a event loop """
    import inspect
    loop = aloop()
    if not inspect.isawaitable(coro):
        if not inspect.iscoroutinefunction(coro):
            coro = asyncio.coroutine(coro)
        coro = coro()
    future = asyncio.ensure_future(coro)
    return loop.run_until_complete(future)

def foo():
    for x in range(10):
        yield from asyncio.sleep(1)
        print(f'bar {x}')
        flush_io()

androidembed.log(' == Interactive (%s, %s) ==' % (repl_pid, pts_out) )

#

sys.stdout.flush()
sys.stderr.flush()














#
