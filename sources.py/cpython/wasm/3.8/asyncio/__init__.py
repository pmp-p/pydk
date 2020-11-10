"""The asyncio package, tracking PEP 3156."""
#https://github.com/giampaolo Giampaolo Rodola'
#https://github.com/1st1 Yury Selivanov
#https://github.com/asvetlov Andrew Svetlov

import sys
import io

try:
    from . import base_events
    from . import coroutines
    from . import events
    from . import futures
    from . import locks
    from . import protocols
    from . import queues
    from . import streams
except Exception as e:
    out = io.StringIO()
    sys.print_exception(e, out)
    out.seek(0)
    embed.log(f"asyncio {out.read()}")

from .base_events import *
from .coroutines import *
from .events import *
from .futures import *
from .locks import *
from .protocols import *
from .queues import *
from .streams import *

#from .subprocess import *

from .tasks import *
from .transports import *

# This relies on each of the submodules having an __all__ variable.
__all__ = (base_events.__all__ +
           coroutines.__all__ +
           events.__all__ +
           futures.__all__ +
           locks.__all__ +
           protocols.__all__ +
           queues.__all__ +
           streams.__all__ +
 #          subprocess.__all__ +
           tasks.__all__ +
           transports.__all__)
import os


from .emscripten_events import *
__all__ += emscripten_events.__all__


