#!/sbin/bb/busybox sh
#
# AK Boot Configurations
# Anarkia1976
#

bb=/sbin/bb/busybox;

# Stop mpDecision at boot
stop mpdecision

$bb mount -o rw,remount /system;

# create init.d folder
if [ ! -d /system/etc/init.d ]; then
  $bb echo "Making Init.d Directory ...";
  $bb mkdir /system/etc/init.d;
  $bb chown -R root.root /system/etc/init.d;
  $bb chmod -R 755 /system/etc/init.d;
else
 $bb echo "Init.d Directory Exist ...";
fi;

$bb mount -o ro,remount /system;

# disable sysctl.conf to prevent ROM interference
if [ -e /system/etc/sysctl.conf ]; then
  $bb mount -o remount,rw /system;
  $bb mv /system/etc/sysctl.conf /system/etc/sysctl.conf.fkbak;
  $bb mount -o remount,ro /system;
fi;

# disable debugging
echo "0" > /sys/module/wakelock/parameters/debug_mask;
echo "0" > /sys/module/userwakelock/parameters/debug_mask;
echo "0" > /sys/module/earlysuspend/parameters/debug_mask;
echo "0" > /sys/module/alarm/parameters/debug_mask;
echo "0" > /sys/module/alarm_dev/parameters/debug_mask;
echo "0" > /sys/module/binder/parameters/debug_mask;

# vm tweaks
echo 5 > /proc/sys/vm/dirty_background_ratio;
echo 200 > /proc/sys/vm/dirty_expire_centisecs;
echo 20 > /proc/sys/vm/dirty_ratio;
echo 500 > /proc/sys/vm/dirty_writeback_centisecs;
echo 2884 > /proc/sys/vm/min_free_kbytes;
echo 4 > /proc/sys/vm/min_free_order_shift;
echo 3 > /proc/sys/vm/page-cluster;
echo 0 > /proc/sys/vm/swappiness;
echo 100 > /proc/sys/vm/vfs_cache_pressure;

# lmk tweaks
minfree=6144,8192,12288,16384,24576,40960;
lmk=/sys/module/lowmemorykiller/parameters/minfree;
minboot=`cat $lmk`;
while sleep 1; do
  if [ `cat $lmk` != $minboot ]; then
    [ `cat $lmk` != $minfree ] && echo $minfree > $lmk || exit;
  fi;
done&

# fs tweaks
echo 10 > /proc/sys/fs/lease-break-time;

# entropy tweaks
echo 128 > /proc/sys/kernel/random/read_wakeup_threshold;
echo 256 > /proc/sys/kernel/random/write_wakeup_threshold;

# general queue tweaks
for i in /sys/block/*/queue; do
  echo 512 > $i/nr_requests;
  echo 512 > $i/read_ahead_kb;
  echo 2 > $i/rq_affinity;
  echo 0 > $i/nomerges;
  echo 0 > $i/add_random;
  echo 0 > $i/rotational;
done;

# decrease dalvik vm heapgrowthlimit by altering the equation
hs=`getprop dalvik.vm.heapsize | cut -dm -f1`;
htu=`getprop dalvik.vm.heaptargetutilization`;
hgl=`awk -v htu=$htu -v hs=$hs 'BEGIN { print (htu / 3) * hs }'`;
setprop dalvik.vm.heapgrowthlimit $hgl'm';

# wait for systemui and increase its priority
while $bb sleep 1; do
  if [ `$bb pidof com.android.systemui` ]; then
    systemui=`pidof com.android.systemui`;
    $bb renice -18 $systemui;
    $bb echo -17 > /proc/$systemui/oom_adj;
    $bb chmod 100 /proc/$systemui/oom_adj;
    exit;
  fi;
done&

# lmk whitelist for common launchers and increase launcher priority
list="com.android.launcher org.adw.launcher org.adwfreak.launcher com.anddoes.launcher com.android.lmt com.chrislacy.actionlauncher.pro com.cyanogenmod.trebuchet com.gau.go.launcherex com.mobint.hololauncher com.mobint.hololauncher.hd com.teslacoilsw.launcher com.tsf.shell org.zeam";
while $bb sleep 60; do
  for class in $list; do
    if [ `$bb pgrep $class` ]; then
      launcher=`$bb pgrep $class`;
      $bb echo -17 > /proc/$launcher/oom_adj;
      $bb chmod 100 /proc/$launcher/oom_adj;
      $bb renice -18 $launcher;
    fi;
  done;
  exit;
done&
