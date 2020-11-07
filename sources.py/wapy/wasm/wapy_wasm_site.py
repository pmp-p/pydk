import sys
import embed
import builtins

builtins.vars = embed.builtins_vars

sys.modules['aio_suspend'] = sys

def aio_suspend():
    import aio_suspend

builtins.aio_suspend = aio_suspend

import pythons

