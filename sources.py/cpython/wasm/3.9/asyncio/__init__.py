"""The asyncio package, tracking PEP 3156."""
# https://github.com/giampaolo Giampaolo Rodola'
# https://github.com/1st1 Yury Selivanov
# https://github.com/asvetlov Andrew Svetlov

# import sys
# import io
# import os


from . import base_events
from . import coroutines
from . import events
from . import futures
from . import locks
from . import protocols
from . import queues
from . import streams
from . import emscripten_events

# This relies on each of the submodules having an __all__ variable.
__all__ = []
__all__.extend(base_events.__all__)
__all__.extend(coroutines.__all__)
__all__.extend(events.__all__)
__all__.extend(futures.__all__)
__all__.extend(locks.__all__)
__all__.extend(protocols.__all__)
__all__.extend(queues.__all__)
__all__.extend(streams.__all__)

# __all__.extend(subprocess.__all__)

__all__.extend(tasks.__all__)
__all__.extend(transports.__all__)
__all__.extend(emscripten_events.__all__)

# print(__all__)

from .base_events import *
from .coroutines import *
from .events import *
from .futures import *
from .locks import *
from .protocols import *
from .queues import *
from .streams import *

# from .subprocess import *

from .tasks import *
from .transports import *
from .emscripten_events import *
