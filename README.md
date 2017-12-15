# droid-pydk


An android python framework assistant. 
While helping to cross-compile, the script also try to prepare a onboard sdk (armv7 currently).



Usage for cross compile i like "/data/data" path so it matches devices layout :


sudo mkdir /data
sudo chown $(whoami) /data
bash ./frankenstax/frankenbuild.sh /data/data 192.168.0.xxx*

*The ip addr is for targeting an adb networked device such as an h3droid board no IP means use classic adb over usb.


