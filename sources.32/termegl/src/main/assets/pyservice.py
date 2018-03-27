import os
import os.path
import sys
import time as Time
import traceback
import socket
import threading
from collections import namedtuple

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

RunTime.sbc = None

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

lspam = RunTime.Lapse(2)


class Inputs(threading.Thread):

    kb = []
    ev = []

    def __init__(self,*argv,**kw):
        threading.Thread.__init__(self)
        self.setup(*argv,**kw)
        self.alive = None
        self.data = '<null>'
        self.pressed = []

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
        androidembed.log('waiting for panda3d taskMgr')
        while not RunTime.task_mgr.running:
            Time.sleep(delay)
        Time.sleep(delay)
        androidembed.log(' == panda3d detected ==')
        os.environ['RAW_INPUT']="1"
        os.environ['RAW_TOUCH_DBG']="1"
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

    BUTTON_PRIMARY = 'BUTTON_PRIMARY'
    BUTTON_BACK = 'BUTTON_BACK'
    BUTTON_TERTIARY = 'BUTTON_TERTIARY'

    #vnc
    TOOL_TYPE_FINGER = 'TOOL_TYPE_FINGER'

    def setup(self,*argv,**kw):
        androidembed.log('Begin: input thread ')


    def get_event(self,data,hint=0):
        ev  = {'buttonState':0}
        if hint:
            data = data[hint:-2]
        else:
            data = data[:-2].split('{ ',1)[-1]

        for data in data.replace('[','').replace(']','').split(', '):
            data = data.split('=')
            ev[data[0]] = data[1]

        return  namedtuple('GenericDict', ev.keys())(**ev)

    def mouse_move(self,ev):
        global lspam
        x = float(ev.x0)
        y = float(ev.y0)
        self.mouse_dev.setPointerInWindow( int( x )  ,int( y ) )
        if lspam:
            self.dirty = f'mouse_move({x}, {y})'
            return
        self.dirty = True


    def mouse_buttons(self, ev,down=0,up=0):
        if down:
            mhandle  = self.mouse_dev.button_down
        elif up:
            mhandle  = self.mouse_dev.button_up


        if (self.BUTTON_PRIMARY in ev.buttonState) or (self.TOOL_TYPE_FINGER in ev.toolType0):
            mhandle( panda3d.core.MouseButton.one() )
            self.pressed.append( self.BUTTON_PRIMARY )
            self.dirty = f'mouse_buttons(1, down={down}, up={up})'

        if self.BUTTON_BACK in ev.buttonState:
            mhandle( panda3d.core.MouseButton.two() )
            self.pressed.append( self.BUTTON_BACK )
            self.dirty = f'mouse_buttons(2, down={down}, up={up})'

        if self.BUTTON_TERTIARY in ev.buttonState:
            mhandle( panda3d.core.MouseButton.three() )
            self.pressed.append( self.BUTTON_TERTIARY )
            self.dirty = f'mouse_buttons(3, down={down}, up={up})'

        if up:
            if self.BUTTON_PRIMARY in self.pressed:
                self.pressed.remove(self.BUTTON_PRIMARY)
                mhandle( panda3d.core.MouseButton.one() )
                self.dirty = f'mouse_buttons(1, down={down}, up={up})'

            if self.BUTTON_BACK in self.pressed:
                self.pressed.remove(self.BUTTON_BACK)
                mhandle( panda3d.core.MouseButton.one() )
                self.dirty = f'mouse_buttons(2, down={down}, up={up})'

            if self.BUTTON_TERTIARY in self.pressed:
                self.pressed.remove(self.BUTTON_TERTIARY)
                mhandle( panda3d.core.MouseButton.three() )
                self.dirty = f'mouse_buttons(3, down={down}, up={up})'

    def URoot_InputService(self,task):
        elems = []
        try:
            self.dirty = ''
            if len(self.ev):
                ev = self.ev.pop(0)
                if ('ACTION_HOVER_MOVE' in ev.action):
                    self.mouse_move(ev)
                elif ('ACTION_MOVE' in ev.action):
                    self.mouse_move(ev)

                elif ('ACTION_DOWN' in ev.action):
                    # finger, vnc do no hover
                    self.mouse_move(ev)
                    self.mouse_buttons(ev,down=1)

                elif ('ACTION_UP' in ev.action):
                    # finger, vnc do no hover
                    self.mouse_move(ev)
                    self.mouse_buttons(ev,up=1)


                if self.dirty is not True:
                    if not self.dirty:
                        androidembed.log("%s : %s" %( self.data[:3], ev) )
                    else:
                        androidembed.log("u.r.input : %s" %( self.dirty) )

            if len(self.kb):
                elems = self.kb.pop(0)
                keycode, keyuc, evtype, evcount, key, tc = elems
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

        except Exception as e:
            logstr = "URoot_InputService.ERROR %s : %s : %s" % (e,self.data,elems)
            androidembed.log( logstr.replace( chr(0), '') )
            traceback.print_exc()


        return self.Task_cont


    def run(self):

        if self.awaitPandaIO():
            Time.sleep(1)
            self.mouse_ptr = RunTime.sbc.sb.win.movePointer
            self.mouse_dev = RunTime.sbc.sb.win.getInputDevice(0)
            self.setup_task(self.URoot_InputService)

            while True:
                data, address = RunTime.io.recvfrom(1024)
                if not self.alive:
                    break

                self.data = data.decode('utf-8').strip()
                try:
                    if self.data.startswith('/kbd '):
                        self.kb.append( self.data[5:].split(', ') )

                    elif self.data.startswith('/kpi '):
                        androidembed.log(self.data)

                    else:
                        ev = self.get_event(self.data)
                        self.ev.append( ev )

                except Exception as e:
                    androidembed.log( "run.ERROR %s : %s" %( e,self.data ) )
                    traceback.print_exc()


    def End(self):
        if self.alive:
            self.alive = False
            androidembed.log('End: input thread ')

            os.environ['RAW_INPUT']="0"
            os.environ.pop('RAW_INPUT',None)
            os.environ.pop('RAW_TOUCH_DBG',None)

def flush_io(restore=False):
    if restore:
        sys.stdout = sys.__stdout__
        sys.stderr = sys.__stderr__
    sys.stdout.flush()
    sys.stderr.flush()

def flush_hook(*argv,**kw):
    flush_io()
    return sys.__excepthook__(*argv,**kw)

sys.excepthook = flush_hook


def info(*argv,**kw):
    androidembed.log("PYLOG: %s" % repr(argv) )

builtins.info = info
builtins.log  = info
builtins.err  = info
builtins.dev  = info
builtins.fix  = info
builtins.exc  = info
builtins.trace  = info
builtins.flush_io = flush_io


DEFAULT='/data/data/u.r/pandamenu.py'
DEFAULT='/data/data/u.root/usr/src/Roaming/lib/pandatest.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/asteroids/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/carousel/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/music-box/main.py'
DEFAULT='/data/data/u.root/sdk/panda3d/samples/roaming-ralph/main.py'

DEFAULT = "/data/data/u.root/sdk/panda3d/samples-bullet/bullet_problem/main.py"
DEFAULT = "/data/data/u.root/usr/src/Roaming/lib/utest.py"
DEFAULT = "/data/data/u.root/sdk/panda3d/samples-next/test2w.py"

#DEFAULT = "/data/data/u.root/sdk/panda3d/LUI/Demos/01_MinimalExample.py"
#DEFAULT = "/data/data/u.root/sdk/panda3d/LUI/Demos/02_SimpleConsole.py"
DEFAULT = '/data/data/u.root/sdk/panda3d/samples-next/hello.py'
#DEFAULT = '/data/data/u.root/sdk/panda3d/samples-next/shader_text.py'
#DEFAULT = '/data/data/u.root/sdk/panda3d/samples-next/shader_test.py'




def run(__file__=DEFAULT,*flags):
    __file__ = __file__.replace('>','/')
    cd = os.path.dirname(__file__)

    flush_io()

    androidembed.log(f"\r\nRunning {__file__} in {cd}\r\n")



    oldwd = os.getcwd()

    load_prc_file_data("", f"model-path {cd}:."  )
    load_prc_file_data("", "background-color 0 0 0 0")
    os.chdir( cd )

    androidembed.log("-----------------------------------------")

    if RunTime.sbc is None:
        import direct
        import direct.showbase
        import direct.showbase.ShowBase
        import direct.task
        import direct.task.Task
        import direct.task.TaskManagerGlobal

        RunTime.task_mgr = direct.task.TaskManagerGlobal.taskMgr
        RunTime.sbc = sbc = direct.showbase.ShowBase.AppContext()


    androidembed.log("-----------------------------------------")

    RunTime.tuio = Thread_TUIOService()

    RunTime.tuio.start()





    #redir stdout to logcat
    if -1 in flags:
        sys.stdout = RunTime.__stdout__
    #redir stderr to logcat
    if -2 in flags:
        sys.stderr = RunTime.__stderr__


    RunTime.sbc.Begin()
    try:
        with open(__file__, 'r') as fp:
            exec( fp.read(), globals(), globals() )
    finally:
        os.chdir(oldwd)
        RunTime.sbc.End()
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
    load_prc_file_data = panda3d.core.load_prc_file_data

    load_prc_file_data("", "tga-rle #t") # tga-grayscale
    #load_prc_file_data("", "threading-model Cull/Draw")

    load_prc_file_data("", "framebuffer-hardware #t")
    load_prc_file_data("", "framebuffer-software #f")

    #load_prc_file_data("", "win-origin -2 -2")
    load_prc_file_data("", "win-size 640 360")
    load_prc_file_data("", "window-type onscreen")
    load_prc_file_data("", "window-title none")
    load_prc_file_data("", "undecorated #t")

    #X load_prc_file_data("", "yield-timeslice #t")
    load_prc_file_data("", "gl-debug #t")

    #load_prc_file_data("", "win-origin -2 -2")
    #load_prc_file_data("", "win-size 848 480")

    load_prc_file_data("", 'model-cache-dir %s' % f'{HOME}/XDG_CACHE_HOME/panda3d' )
    load_prc_file_data("", "model-cache-textures #f")
    load_prc_file_data("", "model-path /data/data/u.root/usr/share/panda3d" )

    load_prc_file_data("", "yield-timeslice #t")
    load_prc_file_data("", "default-model-extension .bam")
    #load_prc_file_data("", "textures_power_2 down")
    #load_prc_file_data("", "textures-square down")

    load_prc_file_data("", "textures-power-2 down")

    load_prc_file_data("", "background-color .5 .5 .5 1")
    load_prc_file_data("", "audio-library-name p3openal_audio")
    load_prc_file_data("", 'notify-level-lui warning')
    #load_prc_file_data("", 'notify-level-gles2gsg spam')
    #load_prc_file_data("", 'force-parasite-buffer 1 1')

    androidembed.log("pandarc complete")
except Exception as e:
    androidembed.log("!!!! pandarc failed %s"%e)



sys.stdout = sys.__stdout__
sys.stderr = sys.__stderr__


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
