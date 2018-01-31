if [ -f /data/data/u.r.tar.xz ]
then
    echo Using onboard cache file
    ./busybox tar xJf /data/data/u.r.tar.xz
    ./busybox rm /data/data/u.r.tar.xz
else
    if [ -f /data/data/DEV ]
    then
        echo Grabbing local cache rootfs
        ./busybox wget http://192.168.1.66/h3droid/u.r.tar -O- | ./busybox tar xf -
    else
        echo Grabbing online rootfs
        ./busybox wget http://194.71.225.160/sdk/uroot/u.r.tar.xz -O- | ./busybox tar xJf -
    fi
fi
