/*
    TUIO C++ Example - part of the reacTIVision project
    http://reactivision.sourceforge.net/

    Copyright (c) 2005-2011 Martin Kaltenbrunner <martin@tuio.org>

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files
    (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    Any person wishing to distribute modifications to the Software is
    requested to send the modifications to the original developer so that
    they can be incorporated into the canonical version.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
    ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "TuioDump.h"

void TuioDump::addTuioObject(TuioObject *tobj) {
    std::cout << "add obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << "/"<<  tobj->getTuioSourceID() << ") "<< tobj->getX() << " " << tobj->getY() << " " << tobj->getAngle() << std::endl;
}

void TuioDump::updateTuioObject(TuioObject *tobj) {
    std::cout << "set obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << "/"<<  tobj->getTuioSourceID() << ") "<< tobj->getX() << " " << tobj->getY() << " " << tobj->getAngle()
                << " " << tobj->getMotionSpeed() << " " << tobj->getRotationSpeed() << " " << tobj->getMotionAccel() << " " << tobj->getRotationAccel() << std::endl;
}

void TuioDump::removeTuioObject(TuioObject *tobj) {
    std::cout << "del obj " << tobj->getSymbolID() << " (" << tobj->getSessionID() << "/"<<  tobj->getTuioSourceID() << ")" << std::endl;
}

void TuioDump::addTuioCursor(TuioCursor *tcur) {
    std::cout << "+:" << tcur->getCursorID() << " (" <<  tcur->getSessionID() << "/"<<  tcur->getTuioSourceID() << ") " << tcur->getX() << " " << tcur->getY() << std::endl;
}

void TuioDump::updateTuioCursor(TuioCursor *tcur) {
    std::cout << "~:" << tcur->getCursorID() << " (" <<  tcur->getSessionID() << "/"<<  tcur->getTuioSourceID() << ") " << tcur->getX() << " " << tcur->getY()
                << " " << tcur->getMotionSpeed() << " " << tcur->getMotionAccel() << " " << std::endl;
}

void TuioDump::removeTuioCursor(TuioCursor *tcur) {
    std::cout << "-:" << tcur->getCursorID() << " (" <<  tcur->getSessionID() << "/"<<  tcur->getTuioSourceID() << ")" << std::endl;
}

void TuioDump::addTuioBlob(TuioBlob *tblb) {
    std::cout << "add blb " << tblb->getBlobID() << " (" << tblb->getSessionID() << "/"<<  tblb->getTuioSourceID() << ") "<< tblb->getX() << " " << tblb->getY() << " " << tblb->getAngle() << " " << tblb->getWidth() << " " << tblb->getHeight() << " " << tblb->getArea() << std::endl;
}

void TuioDump::updateTuioBlob(TuioBlob *tblb) {
    std::cout << "set blb " << tblb->getBlobID() << " (" << tblb->getSessionID() << "/"<<  tblb->getTuioSourceID() << ") "<< tblb->getX() << " " << tblb->getY() << " " << tblb->getAngle() << " "<< tblb->getWidth() << " " << tblb->getHeight() << " " << tblb->getArea()
    << " " << tblb->getMotionSpeed() << " " << tblb->getRotationSpeed() << " " << tblb->getMotionAccel() << " " << tblb->getRotationAccel() << std::endl;
}

void TuioDump::removeTuioBlob(TuioBlob *tblb) {
    std::cout << "del blb " << tblb->getBlobID() << " (" << tblb->getSessionID() << "/"<<  tblb->getTuioSourceID() << ")" << std::endl;
}

void  TuioDump::refresh(TuioTime frameTime) {
    //std::cout << "refresh " << frameTime.getTotalMilliseconds() << std::endl;
}

int main(int argc, char* argv[])
{
    if( argc >= 2 && strcmp( argv[1], "-h" ) == 0 ){
            std::cout << "usage: TuioDump [port]\n";
            return 0;
    }

    int port = 3333;
    if( argc == 2 ) port = atoi( argv[1] );
    else if( argc == 3 ) port = atoi( argv[2] );

    TuioDump dump;
    OscReceiver *receiver;
    receiver = new UdpReceiver(port);
    //if (argc<3) receiver = new TcpReceiver(port);
    //else if (argc==3) receiver = new TcpReceiver(argv[1], port);
    // receiver = new DevReceiver(0);
    TuioClient client(receiver);
    client.addTuioListener(&dump);
    client.connect(true);

    delete receiver;
    return 0;
}


