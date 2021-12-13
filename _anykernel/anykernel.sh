# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=VantomKernel Nethunter
do.devicecheck=1
do.modules=1
do.systemless=1
do.cleanup=1
do.cleanuponabort=1
device.name1=toco
device.name2=
supported.versions=11
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
dump_boot;

# begin ramdisk changes
#Remove Old Modules
ui_print " "
ui_print " "
ui_print "Removing Old Modules..."
rm -rf /data/adb/modules/AutoInsmodModules
rm -rf /data/adb/modules/NetHunterFW
rm -rf /data/adb/modules/ak3-helper
sleep 3

#Install Magisk Module
ui_print " "
ui_print " "
ui_print "Installing Magisk Module..."
cp -rf /tmp/anykernel/AutoInsmodModules /data/adb/modules
cp -rf /tmp/anykernel/NetHunterFW /data/adb/modules
sleep 3

# end ramdisk changes

write_boot;
## end install
