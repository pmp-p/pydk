/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package u.r;

import android.os.Handler;
import android.os.Message;
import android.os.ParcelFileDescriptor;
import android.util.Log;
//import u.r.compat.FileCompat;
import u.r.util.TermSettings;



import java.io.*;

import java.util.ArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;



/**
 * A terminal session, controlling the process attached to the session (usually
 * a shell). It keeps track of process PID and destroys it's process group
 * upon stopping.
 */
public class ShellTermSession extends GenericTermSession {
    private int mProcId;
    private Thread mWatcherThread;

    private String mInitialCommand;

    private InputStream _zipFileStream;
    private static final String ROOT_LOCATION = "/data/data/u.r";
    private static final String TAG = "Term-STS";

    private static final int PROCESS_EXITED = 1;
    private Handler mMsgHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (!isRunning()) {
                return;
            }
            if (msg.what == PROCESS_EXITED) {
                onProcessExit((Integer) msg.obj);
            }
        }
    };

    public ShellTermSession(TermSettings settings, String initialCommand) throws IOException {
        super(ParcelFileDescriptor.open(new File("/dev/ptmx"), ParcelFileDescriptor.MODE_READ_WRITE),
                settings, false);

        initializeSession();

        setTermOut(new ParcelFileDescriptor.AutoCloseOutputStream(mTermFd));
        setTermIn(new ParcelFileDescriptor.AutoCloseInputStream(mTermFd));

        mInitialCommand = initialCommand;

        mWatcherThread = new Thread() {
            @Override
            public void run() {
                Log.i(TermDebug.LOG_TAG, "waiting for: " + mProcId);
                int result = TermExec.waitFor(mProcId);
                Log.i(TermDebug.LOG_TAG, "Subprocess exited: " + result);
                mMsgHandler.sendMessage(mMsgHandler.obtainMessage(PROCESS_EXITED, result));
            }
        };
        mWatcherThread.setName("Process watcher");
    }

    private void _dirChecker(String dir) {
        File f = new File(dir);
        Log.i(TAG, "creating dir " + dir);

        if(dir.length() >= 0 && !f.isDirectory() ) {
            f.mkdirs();
        }
    }

    private int unzip_support_assets(){
        _dirChecker( ROOT_LOCATION + "/assets" );
        try  {
            Log.i(TAG, "Starting to unzip");
            InputStream fin = _zipFileStream;
            if(fin == null) {
                //android 5+
                if (  new File("/data/app/u.r-1/base.apk").isFile() ){
                    fin = new FileInputStream("/data/app/u.r-1/base.apk");
                } else{
                    // kitkat
                    fin = new FileInputStream("/data/app/u.r-1.apk");
                }
            }
            ZipInputStream zin = new ZipInputStream(fin);
            ZipEntry ze = null;
            while ((ze = zin.getNextEntry()) != null) {

                Log.v(TAG, "Unzipping " + ze.getName());
                if ( ze.getName().startsWith("assets") ) {
                    if(ze.isDirectory()) {
                        _dirChecker(ROOT_LOCATION + "/" + ze.getName());
                    } else {

                        FileOutputStream fout = new FileOutputStream(new File(ROOT_LOCATION, ze.getName()));
                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        byte[] buffer = new byte[1024];
                        int count;

                        // reading and writing
                        while((count = zin.read(buffer)) != -1)
                        {
                            baos.write(buffer, 0, count);
                            byte[] bytes = baos.toByteArray();
                            fout.write(bytes);
                            baos.reset();
                        }

                        fout.close();
                        zin.closeEntry();
                    }
                }
            }
            zin.close();
            Log.i(TAG, "Finished unzip");
        } catch(Exception e) {
            Log.e(TAG, "(expected) Unzip Error", e);
            mInitialCommand = "Exception: " + e ;
            return -1;
        }
        return 1;
    }

    private void initializeSession() throws IOException {
        TermSettings settings = mSettings;

        String path = System.getenv("PATH");
        if (settings.doPathExtensions()) {
            String appendPath = settings.getAppendPath();
            if (appendPath != null && appendPath.length() > 0) {
                path = path + ":" + appendPath;
            }

            if (settings.allowPathPrepend()) {
                String prependPath = settings.getPrependPath();
                if (prependPath != null && prependPath.length() > 0) {
                    path = prependPath + ":" + path;
                }
            }
        }
        if (settings.verifyPath()) {
            path = checkPath(path);
        }

        String[] env = new String[7];
        env[0] = "LD_LIBRARY_PATH=/vendor/lib:/system/lib";
        env[1] = "TERM=xterm-256color";
        env[2] = "HOME=" + ROOT_LOCATION;
        env[3] = "XDG_CACHE_HOME=" + ROOT_LOCATION + "/XDG_CACHE_HOME";
        env[4] = "XDG_CONFIG_HOME=" + ROOT_LOCATION + "/XDG_CONFIG_HOME";
        env[5] = "PATH=/vendor/bin:/system/bin:/sbin:" + path;
        env[6] = "APK_MODE=terminal";
    //**************
    Log.i(TAG, "  == Shell Term Sesssion ==");
    if (new File("/data/data/FAST").isFile() ){
        mProcId = createSubprocess("/system/bin/sh /data/data/u.r/pp",env);
    } else {
        if ( new File("/data/data/u.r/bin/bash").isFile() ) {
            env[5] = "PATH=/data/data/u.r/bin:" + path;
            mProcId = createSubprocess("/data/data/u.r/bin/bash --login",env);

        } else {
            PrintWriter script = new PrintWriter( new File("/data/data/u.r/urootrc") );
            script.println("#!/system/bin/sh");
            script.println("export PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin");
            script.println("umask 022");
            script.println("cd /data/data/u.r");
            script.println("mkdir -p tmp XDG_CACHE_HOME XDG_CONFIG_HOME");

            if ( unzip_support_assets()>0 ){
                script.println("echo  -n \"Extracting GNU/Linux support files into ${HOME} : \"");
                script.println("/system/bin/mv assets/* ./;rmdir assets");
                script.println("rm -rf ${HOME}/tmp");
                script.println("mkdir -p ${HOME}/tmp;chmod 777 ${HOME}/tmp;cd ${HOME}");
                script.println("/system/bin/chmod 777 busybox update.sh");
                script.println("./busybox bash ${HOME}/update.sh");

                script.println("./busybox chmod 755 urootrc 386 *.so bin/* etc/* lib-*/lib*");
                script.println("./busybox chmod 755 -R lib-*/bash lib-*/transcript1 X11");
                script.println("./busybox chmod 755 micropython/site-packages/*/* micropython/lib-dynload/*");

                script.println("./bin/busybox --install -s bin/");
                script.println("cd bin");
                script.println("rm reboot");
                script.println("rm ping");
                script.println("ln 386 ndk-depends");
                script.println("cd ..");

                script.println("echo 'Done, press <Enter> to enter bash'");
                script.println("read");
                script.println("./bin/bash --login");
            } else {
                script.println("echo \"  ----------------------------- ");
                script.println( mInitialCommand );
                script.println("  -----------------------------\"");
                script.println("Master, i have failed ( again ) ...");
                script.println("press <Enter> and go complain for: failure unzipping busybox helper");
                script.println("read");
            }

            script.close();
            mProcId = createSubprocess("/system/bin/sh "+ROOT_LOCATION+"/urootrc",env);

        }

    }

    }


    private String checkPath(String path) {
        String[] dirs = path.split(":");
        StringBuilder checkedPath = new StringBuilder(path.length());
        for (String dirname : dirs) {
            File dir = new File(dirname);
            //if (dir.isDirectory() && FileCompat.canExecute(dir)) {
            if (dir.isDirectory() && dir.canExecute()) {
                checkedPath.append(dirname);
                checkedPath.append(":");
            }
        }
        return checkedPath.substring(0, checkedPath.length()-1);
    }

    @Override
    public void initializeEmulator(int columns, int rows) {
        super.initializeEmulator(columns, rows);

        mWatcherThread.start();
        sendInitialCommand(mInitialCommand);
    }

    private void sendInitialCommand(String initialCommand) {
        if (initialCommand.length() > 0) {
            write(initialCommand + '\r');
        }
    }

    private int createSubprocess(String shell, String[] env) throws IOException {
        ArrayList<String> argList = parse(shell);
        String arg0;
        String[] args;

        try {
            arg0 = argList.get(0);
            File file = new File(arg0);
            if (!file.exists()) {
                Log.e(TermDebug.LOG_TAG, "Shell " + arg0 + " not found!");
                throw new FileNotFoundException(arg0);
            //} else if (!FileCompat.canExecute(file)) {
            } else if (!file.canExecute()) {
                Log.e(TermDebug.LOG_TAG, "Shell " + arg0 + " not executable!");
                throw new FileNotFoundException(arg0);
            }
            args = argList.toArray(new String[1]);
        } catch (Exception e) {
            argList = parse(mSettings.getFailsafeShell());
            arg0 = argList.get(0);
            args = argList.toArray(new String[1]);
        }

        return TermExec.createSubprocess(mTermFd, arg0, args, env);
    }

    private ArrayList<String> parse(String cmd) {
        final int PLAIN = 0;
        final int WHITESPACE = 1;
        final int INQUOTE = 2;
        int state = WHITESPACE;
        ArrayList<String> result =  new ArrayList<String>();
        int cmdLen = cmd.length();
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < cmdLen; i++) {
            char c = cmd.charAt(i);
            if (state == PLAIN) {
                if (Character.isWhitespace(c)) {
                    result.add(builder.toString());
                    builder.delete(0,builder.length());
                    state = WHITESPACE;
                } else if (c == '"') {
                    state = INQUOTE;
                } else {
                    builder.append(c);
                }
            } else if (state == WHITESPACE) {
                if (Character.isWhitespace(c)) {
                    // do nothing
                } else if (c == '"') {
                    state = INQUOTE;
                } else {
                    state = PLAIN;
                    builder.append(c);
                }
            } else if (state == INQUOTE) {
                if (c == '\\') {
                    if (i + 1 < cmdLen) {
                        i += 1;
                        builder.append(cmd.charAt(i));
                    }
                } else if (c == '"') {
                    state = PLAIN;
                } else {
                    builder.append(c);
                }
            }
        }
        if (builder.length() > 0) {
            result.add(builder.toString());
        }
        return result;
    }

    private void onProcessExit(int result) {
        onProcessExit();
    }

    @Override
    public void finish() {
        Exec.hangupProcessGroup(mProcId);
        super.finish();
    }
}
