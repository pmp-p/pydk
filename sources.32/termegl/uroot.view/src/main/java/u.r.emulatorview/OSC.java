package u.r.emulatorview;

/*
import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;
import com.illposed.osc.OSCPortOut;

*/

import java.util.Arrays;
import java.util.List;


import java.net.InetAddress;
import android.os.StrictMode ;
import android.os.AsyncTask;

/*
public class OSC {
    private static OSCPortOut oscPortOut;
    private static OSCPortIn oscPortIn;

    protected OSC() { //Singleton
    }

    private static OSCPortOut getOscPortOut() {
        if(null == oscPortOut) {
            try {
                StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
                StrictMode.setThreadPolicy(policy);
                oscPortOut = new OSCPortOut(InetAddress.getByName("localhost"),7000);
            } catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
        return oscPortOut;
    }

    private static OSCPortIn getOscPortIn() {
        if (null == oscPortIn) {
            try {
                oscPortIn = new OSCPortIn(7001);
                oscPortIn.startListening();
            } catch (Exception e) {
                System.out.println(e);
            }
        }
        return oscPortIn;
    }

    public static void sendMsg(String address, Object message) {
        sendMsg(address, Arrays.asList((Object) message));
    }

    public static void sendMsg(String address, Object ... messages) {
        sendMsg(address, Arrays.asList(messages));
    }

    public static void sendMsg(String address, List<Object> messages) {
        OSCMessage msg = new OSCMessage(address, messages);
        try {
            getOscPortOut().send(msg);
        } catch (Exception e) {
            System.out.println("Couldn't send OSC with : " + e);
        }
    }

    public static void addListener(String address, OSCListener listener) {
        getOscPortIn().addListener(address, listener);
    }
}
*/

import java.io.*;
import java.net.*;
import android.util.Log;

public class OSC extends AsyncTask<String, Void, Void> {
    private final static String TAG = "u.r.crap";
    private static DatagramSocket clientSocket;
    private static InetAddress IPAddress;

    protected Void doInBackground(String ... msg){
        byte[] sendData = new byte[1024];
        sendData = msg[0].getBytes();
        try {
            if ( null== clientSocket ){
                //StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
                //StrictMode.setThreadPolicy(policy);
                System.setProperty("java.net.preferIPv4Stack", "true");
                clientSocket = new DatagramSocket();
                IPAddress = InetAddress.getByName("127.0.0.1");
            }

            DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, 7000);
            clientSocket.send(sendPacket);
        } catch (Exception e) {
            System.out.println("Couldn't send OSC with : " + e );
            e.printStackTrace();
        }
        return null;
    }

}


/*
    public static void main(String args[]) throws Exception
    {
      BufferedReader inFromUser = new BufferedReader(new InputStreamReader(System.in));
      byte[] receiveData = new byte[1024];
      String sentence = inFromUser.readLine();



      DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
      clientSocket.receive(receivePacket);
      String modifiedSentence = new String(receivePacket.getData());
      System.out.println("FROM SERVER:" + modifiedSentence);
      clientSocket.close();
   }*/
