#!/sbin/bb/busybox sh
#
# AK Boot Configurations
# Anarkia1976
#

bb=/sbin/bb/busybox;

#
# Disable mpDecision at boot
#
#stop mpdecision

$bb mount -o rw,remount /system;

if [ ! -d /system/etc/init.d ]; then
  $bb echo "Making Init.d Directory ...";
  $bb mkdir /system/etc/init.d;
  $bb chown -R root.root /system/etc/init.d;
  $bb chmod -R 755 /system/etc/init.d;
else
 $bb echo "Init.d Directory Exist ...";
fi;

$bb mount -o ro,remount /system;

# disable debugging
echo "0" > /sys/module/wakelock/parameters/debug_mask;
echo "0" > /sys/module/userwakelock/parameters/debug_mask;
echo "0" > /sys/module/earlysuspend/parameters/debug_mask;
echo "0" > /sys/module/alarm/parameters/debug_mask;
echo "0" > /sys/module/alarm_dev/parameters/debug_mask;
echo "0" > /sys/module/binder/parameters/debug_mask;

# general queue tweaks
for i in /sys/block/*/queue; do
  echo 512 > $i/nr_requests;
  echo 512 > $i/read_ahead_kb;
  echo 2 > $i/rq_affinity;
  echo 0 > $i/nomerges;
  echo 0 > $i/add_random;
  echo 0 > $i/rotational;
done;

# increase systemui process priority
$bb sleep 10;

loopcount=1

while [ $loopcount -le 18 ]; do
if [ $($bb pgrep com.android.systemui) ] ; then
    $bb renice -17 $($bb pgrep com.android.systemui);
    break;
else
    (( loopcount++ ));
    $bb sleep 5;
  fi;
done;

# lmk whitelist for common launchers
list="com.android.launcher org.adw.launcher org.adwfreak.launcher com.anddoes.launcher com.gau.go.launcherex com.mobint.hololauncher com.mobint.hololauncher.hd com.teslacoilsw.launcher com.cyanogenmod.trebuchet org.zeam";
$bb sleep 10;
for class in $list; do
  pid=`pidof $class`;
  if [ $pid != "" ]; then
    echo "-17" > /proc/$pid/oom_adj;
    chmod 100 /proc/$pid/oom_adj;
  fi;
done;
