if [ -f /data/local/tmp/u.r.tar ]
then
    echo Using onboard cache file
    ./busybox tar xJf /data/local/tmp/u.r.tar
    if [ -f /data/local/tmp/DEV ]
    then
        echo "devmode keeping cache file /data/data/u.r.tar"
    else
       ./busybox rm /data/local/tmp/u.r.tar
    fi
else
    if [ -f /data/local/tmp/DEV ]
    then
        ./busybox chmod 755 -R .
        echo Grabbing local cache rootfs
        ./busybox wget http://192.168.1.66/h3droid/u.r.tar -O- | ./busybox tar xf -
    else
        echo Grabbing online rootfs
        ./busybox wget http://194.71.225.160/sdk/uroot/u.r.tar.xz -O- | ./busybox tar xJf -
    fi
fi
