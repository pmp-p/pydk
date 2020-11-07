import pythons
import pyreadline
import embed

try:
    from pyreadtouch import ReadTouch
except Exception as e:
    pdb("19: no touch support from pyreadtouch : {}".format((e)))

    class ReadTouch:
        def process_touch(self, *a, **k):
            pass


class ReadInput(pyreadline.ReadLine, ReadTouch, aio.runnable):
    MB = {
        "B": "",
        "C": 0,
        0: "L",
        1: "M",
        2: "R",
        3: "",
        "D": {"": ""},
    }
    CR = "\r"
    ESC = "\x1b[C"

    def putc(self, c):
        oldbuf = len(self.line)
        oldpos = self.caret
        out = f'{" " * (oldbuf + 4)}\r'
        embed.demux_fd(1, out)
        #if c == pyreadline.CR:
        #    embed.log("CR!")

        if c == pyreadline.LF:
            res = self.process_char(pyreadline.LF)
            self.reset()

            embed.demux_fd(1, f'+-> {res}\r\n')
            embed.stdio_append(0,res+"\n") #; + ";print('pouet');sys.stdout.flush();embed.demux_fd(1,'++> ')")

            #TODO: set a prompt display to be set after exec in next loop
            embed.prompt_request()

        else:
            self.process_char(c)

            out = f"$>> {self.line}"
            if oldpos > self.caret:
                # embed.log('cursor move left %s > %s' % (oldpos,self.caret) )
                out += f'{out}{self.CR}{self.ESC * (self.caret + 4)}'
            elif self.caret < len(self.line):
                # embed.log('cursor move right %s > %s %s' % (oldpos,self.caret,len(self.line)) )
                out += f'{out}{self.CR}{self.ESC * (self.caret + 4)}'
            sys.stdout.flush()
            embed.demux_fd(1, out)


    if __EMSCRIPTEN__:

        def getc(self):
            return embed.getc()

    else:

        def getc(self):
            key = b""
            if select.select([sys.__stdin__,], [], [], 0.0)[0]:
                if self.kbuf:
                    key = self.kbuf[0:1]
                    self.kbuf = self.kbuf[1:]
                else:
                    key = os.read(0, 32)
            return key

    async def run(self, fd, **kw):
        aio.inputs[fd] = self
        self.kbuf = []
        aio.proc(self).rt(0.010)

        c = 0
        ubuf = []
        while c or not (await self):
            c = self.getc()
            if c:
                ubuf.append(c)
                # unicode ? then probably we have another in queue
                if c >= 127:
                    continue
            elif len(ubuf):
                for c in bytes(ubuf).decode():
                    self.putc(c)
                ubuf.clear()
                #sys.stdout.flush()


aio.inputs = {}

aio.service(ReadInput(), 0)
