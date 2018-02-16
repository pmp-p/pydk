package u.r.emulatorview;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;
import com.illposed.osc.OSCPortOut;

import java.util.Arrays;
import java.util.List;


import java.net.InetAddress;
import android.os.StrictMode ;



public class OSC {
    private static OSCPortOut oscPortOut;
    private static OSCPortIn oscPortIn;

    protected OSC() { /*Singleton*/ }

    private static OSCPortOut getOscPortOut() {
        if(null == oscPortOut) {
            try {
                StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
                StrictMode.setThreadPolicy(policy);
                oscPortOut = new OSCPortOut(InetAddress.getByName("127.0.0.1"),7000);
            } catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
        return oscPortOut;
    }

    private static OSCPortIn getOscPortIn() {
        if (null == oscPortIn) {
            try {
                oscPortIn = new OSCPortIn(7000);
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
