#!/sbin/bb/busybox sh
#
# AK Boot Configurations
# Anarkia1976
#

bb=/sbin/bb/busybox;

#
# Disable mpDecision at boot
#
stop mpdecision

$bb mount -o rw,remount /system;

if [ ! -d /system/etc/init.d ]; then
  $bb echo "Making Init.d Directory ...";
  $bb mkdir /system/etc/init.d;
  $bb chown -R root.root /system/etc/init.d;
  $bb chmod -R 755 /system/etc/init.d;
else
 $bb echo "Init.d Directory Exist ...";
fi;

if [ ! -d /data/ak/backup ]; then
  $bb echo "Making Backup Directory ...";
  $bb mkdir /data/ak/backup;
  $bb chown -R root.root /data/ak/backup;
  $bb chmod -R 755 /data/ak/backup;
else
 $bb echo "Backup Directory Exist ...";
fi

$bb mount -o ro,remount /system;
