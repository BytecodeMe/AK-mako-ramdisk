#!/sbin/bb/busybox ash
bb="/sbin/bb/busybox"

$bb mount -o rw,remount /system

if $bb [ ! -d /system/etc/init.d ]; then
 $bb echo "Making Init.d Directory ..."
 $bb mkdir /system/etc/init.d
 $bb chmod 777 /system/etc/init.d
else
 $bb echo "Init.d Directory Exist ..."
fi

if $bb [ ! -d /data/ak/backup ]; then
 $bb echo "Making Backup Directory ..."
 $bb mkdir /data/ak/backup
 $bb chmod 777 /data/ak/backup
else
 $bb echo "Backup Directory Exist ..."
fi

$bb mount -o ro,remount /system
