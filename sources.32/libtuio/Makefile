# should be either OSC_HOST_BIG_ENDIAN or OSC_HOST_LITTLE_ENDIAN
# Apple: OSC_HOST_BIG_ENDIAN
# Win32: OSC_HOST_LITTLE_ENDIAN
# i386 LinuX: OSC_HOST_LITTLE_ENDIAN

ENDIANESS=OSC_HOST_LITTLE_ENDIAN
PLATFORM=$(shell uname)

TUIO_DEMO = TuioDemo
TUIO_DUMP = TuioDump
SIMPLE_SIMULATOR = SimpleSimulator
TUIO_STATIC  = libTUIO.a
TUIO_SHARED  = libTUIO.so



INCLUDES = -I. -I./TUIO -I./oscpack
CFLAGS  = -g -Wall -O3 -fPIC -fPIE
CXXFLAGS = $(CFLAGS) $(INCLUDES) -D$(ENDIANESS)
SHARED_OPTIONS = -shared -Wl,-soname,$(TUIO_SHARED)



#CFLAGS+=  -Wno-multichar -funwind-tables
#SHARED_OPTIONS= -Wl,--no-merge-exidx-entries -shared -fPIE -lgnustl_shared -lc -lm -ldl

SHARED_OPTIONS= -shared -fPIE -lc -lm -ldl

DEMO_SOURCES = TuioDemo.cpp $(OBJC_SOURCES)
DEMO_OBJECTS = TuioDemo.o $(OBJC_OBJECTS)
DUMP_SOURCES = TuioDump.cpp
DUMP_OBJECTS = TuioDump.o
SIMULATOR_SOURCES = SimpleSimulator.cpp $(OBJC_SOURCES)
SIMULATOR_OBJECTS = SimpleSimulator.o $(OBJC_OBJECTS)

COMMON_TUIO_SOURCES = ./TUIO/TuioTime.cpp ./TUIO/TuioPoint.cpp ./TUIO/TuioContainer.cpp ./TUIO/TuioObject.cpp ./TUIO/TuioCursor.cpp ./TUIO/TuioBlob.cpp ./TUIO/TuioDispatcher.cpp ./TUIO/TuioManager.cpp
SERVER_TUIO_SOURCES = ./TUIO/TuioServer.cpp ./TUIO/UdpSender.cpp ./TUIO/TcpSender.cpp
#./TUIO/FlashSender.cpp
# ./TUIO/DevSender.cpp
CLIENT_TUIO_SOURCES = ./TUIO/TuioClient.cpp ./TUIO/OscReceiver.cpp ./TUIO/UdpReceiver.cpp ./TUIO/TcpReceiver.cpp
# ./TUIO/DevReceiver.cpp
OSC_SOURCES = ./oscpack/osc/OscTypes.cpp ./oscpack/osc/OscOutboundPacketStream.cpp ./oscpack/osc/OscReceivedElements.cpp ./oscpack/osc/OscPrintReceivedElements.cpp ./oscpack/ip/posix/NetworkingUtils.cpp ./oscpack/ip/posix/UdpSocket.cpp

COMMON_TUIO_OBJECTS = $(COMMON_TUIO_SOURCES:.cpp=.o)
SERVER_TUIO_OBJECTS = $(SERVER_TUIO_SOURCES:.cpp=.o)
CLIENT_TUIO_OBJECTS = $(CLIENT_TUIO_SOURCES:.cpp=.o)
OSC_OBJECTS = $(OSC_SOURCES:.cpp=.o)

all: dump static shared

static: $(COMMON_TUIO_OBJECTS) $(CLIENT_TUIO_OBJECTS) $(SERVER_TUIO_OBJECTS) $(OSC_OBJECTS)
	ar rcs $(TUIO_STATIC) $(COMMON_TUIO_OBJECTS) $(CLIENT_TUIO_OBJECTS) $(SERVER_TUIO_OBJECTS) $(OSC_OBJECTS)

shared: $(COMMON_TUIO_OBJECTS) $(CLIENT_TUIO_OBJECTS) $(SERVER_TUIO_OBJECTS)  $(OSC_OBJECTS)
	$(CXX) $+ $(SHARED_OPTIONS) -o $(TUIO_SHARED)

dump:   $(COMMON_TUIO_OBJECTS) $(CLIENT_TUIO_OBJECTS) $(OSC_OBJECTS) $(DUMP_OBJECTS)
	$(CXX) $+ -o $(TUIO_DUMP) libTUIO.a

clean:
	rm -f $(TUIO_DUMP) $(TUIO_DEMO) $(SIMPLE_SIMULATOR) $(TUIO_STATIC) $(TUIO_SHARED)
	rm -f $(COMMON_TUIO_OBJECTS) $(CLIENT_TUIO_OBJECTS) $(SERVER_TUIO_OBJECTS) $(OSC_OBJECTS) $(DUMP_OBJECTS) $(DEMO_OBJECTS) $(SIMULATOR_OBJECTS)
