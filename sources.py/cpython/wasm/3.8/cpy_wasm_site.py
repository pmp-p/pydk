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


import rlcompleter


class ReadInput(pyreadline.ReadLine, ReadTouch, aio.runnable):

    completer = rlcompleter.Completer().complete

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
    LF = "\n"
    ESC = "\x1b[C"

    def putc(self, c):
        extra = 0
        b = byte(c)

        if b == b"\x09":
            if len(self.line):
                rlc = self.completer(self.line, 0) or self.line
                if rlc == self.line:
                    return
            self.reset()
            self.process_str(rlc)
            out = f"{self.CR}T>> {self.line}"
            return
        else:

            if b == b"\x08":
                extra = 1

            # clear old line including prompt
            oldbuf = len(self.line)
            oldpos = self.caret
            out = f'{self.CR}{" " * (oldbuf + 4 + extra)}{self.CR}'
            embed.demux_fd(1, out)

            # overwrite cleaned space
            if b == pyreadline.LF:
                res = self.process_char(c)
                self.reset()

                embed.demux_fd(1, f"+-> {res}{self.CR}{self.LF}")
                embed.stdio_append(0, res + "\n")  # ; + ";print('pouet');sys.stdout.flush();embed.demux_fd(1,'++> ')")

                # TODO: set a prompt display to be set after exec in next loop
                embed.prompt_request()
                return

            # add the new char
            self.process_char(c)

        # or just display completion

        out = f">>> {self.line}{self.CR}{self.ESC * (self.caret + 4)}"

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
                # sys.stdout.flush()


aio.inputs = {}

aio.service(ReadInput(), 0)
