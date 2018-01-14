#!/usr/bin/env python3.5
import os
import sys
import time

from toolbox import *

import websocket

os.system('reset')
print("""Tuio Tank
================
""")
ws = None
passw = open('/pass','r').read().strip()

print("ESP REPL WIFI Password : [%s]"%passw)


def recv():
    print('<',ws.recv())

while True:
    try:
        print('Connecting ...')
        ws = websocket.create_connection("ws://192.168.1.57:8266/"  )

        recv()
        ws.send("%s\r" % passw )

        recv()

        ws.send("hbL(0);hbR(0)\r")

        DBG=0

        upd = Lapse(.15)

        dmp = os.popen('./TuioDump')
        min = 220

        cR = 2
        trig = 900


        while True:
            l = dmp.readline()
            if l:
                l=l.strip()
                if l[0]=='~':
                    modcur, tup, x, y , dx, dy =  l.split(' ')
                    x= float(x)
                    y=  (float(y) * 2048) - 1024
                    if y>0:
                        y+=min
                        way = +1
                    if y<0:
                        y-=min
                        way = -1

                    x = x - .5

                    if abs(x) < .1:
                        x= 0
                    else:
                        delta = cR * way * x

                    if x<0:
                        rL = 1 + delta
                        rR = 1 - delta
                    elif x>0:
                        rL = 1 + delta
                        rR = 1 - delta
                    else:
                        rL = rR = 1.0

                    yL , yR = int(y*rL) ,int(y*rR)
                    if yL > trig:yL=1024
                    if yL < -trig:yL=-1024
                    if yR > trig:yR=1024
                    if yR < -trig:yR=-1024

                    if upd:
                        print( yL , yR )
                        if not DBG:ws.send("hbL(%s);hbR(%s)\r" % ( yL,yR ) )
                elif l[0]=="+":
                    #print("Start")
                    pass
                elif l[0]=="-":
                    print("Stop")
                    if not DBG:ws.send("hbL(0);hbR(0)\r")
                else:
                    print(l.strip())
            else:
                break
    except Exception as e:
        print(e)
        d = 10
        print('Retrying in %s seconds' % d)
        time.sleep(d)
