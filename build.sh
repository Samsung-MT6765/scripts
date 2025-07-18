#!/bin/bash

echo "Building Started"
rm -rf device/samung/a04e
rm -rf kernel/samsung/a04e
rm -rf vendor/samsung/a04e
rm -rf device/samsung/a04e-kernel
rm -rf hardware/samsung
rm -rf hardware/mediatek
rm -rf device/mediatek/sepolicy_vndr
rm -rf prebuilts/clang/host/linux-x86

# Rom source repo
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs
echo "========================================================================="
echo "----------------------------- Repo init success ---------------------------"
echo "========================================================================="

# Device Specific trees
git clone https://github.com/Galaxy-MTK-JDM/android_device_samsung_a04e -b lineage-21 device/samsung/a04e
git clone https://github.com/Galaxy-MTK-JDM/android_vendor_samsung_a04e -b lineage-22.2 vendor/samsung/a04e
git clone https://github.com/Galaxy-MTK-JDM/android_kernel_samsung_a04e -b lineage-22.2 kernel/samsung/a04e
git clone https://github.com/Galaxy-MTK-JDM/android_device_samsung_a04e-kernel -b lineage-22.2 device/samsung/a04e-kernel
git clone https://github.com/LineageOS/android_hardware_samsung -b lineage-22.2 hardware/samsung
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-22.2 device/mediatek/sepolicy_vndr
echo "============================================================================================="
echo "--------------------- All Repositrories Cloned Successfully -------------------"
echo "============================================================================================="

# Sync the repositories
/opt/crave/resync.sh
echo "============= Repo Sync Done =============="

# Selinux Patch

echo "------------------------------------------------"
echo " We dont need selinux from Ram boost,iso,udf,aux "
echo "------------------------------------------------"

# Define search paths
SYSTEM_PRIVATE_DIR="system/sepolicy/private/"
DEVICE_DIR="device/"

# Define the patterns to search and comment out
SYSTEM_PATTERNS=(
  "genfscon proc /sys/kernel/sched_nr_migrate u:object_r:proc_sched:s0"
  "genfscon proc /sys/vm/compaction_proactiveness u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/extfrag_threshold u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/swap_ratio u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/swap_ratio_enable u:object_r:proc_drop_caches:s0"
  "genfscon proc /sys/vm/page_lock_unfairness u:object_r:proc_drop_caches:s0"
)

DEVICE_PATTERNS=(
  "vendor.camera.aux.packageexcludelist   u:object_r:vendor_persist_camera_prop:s0"
  "vendor.camera.aux.packagelist          u:object_r:vendor_persist_camera_prop:s0"
)

ISO_UDF_PATTERNS=(
  "type iso9660, sdcard_type, fs_type, mlstrustedobject;"
  "type udf, sdcard_type, fs_type, mlstrustedobject;"
  "genfscon iso9660 / u:object_r:iso9660:s0"
  "genfscon udf / u:object_r:udf:s0"
)

# Function to search and comment lines in files
comment_lines() {
  local dir=$1
  local patterns=("${!2}")
  local msg=$3
  local found=0
  
  for pattern in "${patterns[@]}"; do
    # Find files containing the pattern
    files=$(grep -rl "$pattern" "$dir")
    
    for file in $files; do
      # Comment the line if found
      sed -i "s|$pattern|# $pattern|" "$file"
      found=1
    done
  done
  
  if [ $found -eq 1 ]; then
    echo "$msg found"
  fi
}

# Search in system/private/ and comment if found
comment_lines "$SYSTEM_PRIVATE_DIR" SYSTEM_PATTERNS[@] "ram boost"

# Search in device/ and comment if found
comment_lines "$DEVICE_DIR" DEVICE_PATTERNS[@] "aux cam"

# Search for ISO and UDF patterns
comment_lines "$DEVICE_DIR" ISO_UDF_PATTERNS[@] "iso and udf"

echo "------------------------------------------------"
echo "Selinux Patching Done"
echo "------------------------------------------------"

# Patches 

echo "------------------------------------------------"
echo "Cloning All the patches"
echo "------------------------------------------------"


wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/build/soong/0001-soong-add-vendor-niigo-priv-keys-to-allowlist.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/av/0001-media-Import-codecs-omx-changes-from-t-alps-q0.mp1-V.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/av/0002-media-Import-extractor-changes-from-t-alps-q0.mp1-V9.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/av/0003-selene-media-libstagefright-Limit-max-width-height-t.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/av/0004-Revert-mp3dec-Check-if-input-buffer-contains-valid-d.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/base/0001-Restore-getSimStateForSlotIndex-in-SubscriptionManag.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/base/0002-Replace-strings-with-strings.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/base/0003-BootReceiver-Return-early-if-trace-pipe-doesnt-exists.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/frameworks/base/0004-core-jni-add-a-separate-prop-to-activate-ART-LowMemo.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/hardware/interfaces/0001-interfaces-kill-android.hardware.audio.sounddose-ven.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/packages/modules/Bluetooth/0001-gd-hci-Allow-disabling-erroneous-data-reporting.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/packages/modules/Bluetooth/0002-gd-hci-Ignore-unexpected-status-events.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/selinux/bt-15-qpr1.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/selinux/frame-1-15.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/selinux/frame-2-15.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/selinux/proc.patch
wget https://raw.githubusercontent.com/Galaxy-MTK-JDM/android_device_samsung_a04e/refs/heads/lineage-21/patches/selinux/sms-15.patch

echo "------------------------------------------------"
echo "Cloning Done"
echo "------------------------------------------------"

git apply 0001-soong-add-vendor-niigo-priv-keys-to-allowlist.patch
git apply 0001-media-Import-codecs-omx-changes-from-t-alps-q0.mp1-V.patch
git apply 0002-media-Import-extractor-changes-from-t-alps-q0.mp1-V9.patch
git apply 0003-selene-media-libstagefright-Limit-max-width-height-t.patch
git apply 0004-Revert-mp3dec-Check-if-input-buffer-contains-valid-d.patch
git apply 0001-Restore-getSimStateForSlotIndex-in-SubscriptionManag.patch
git apply 0002-Replace-strings-with-strings.patch
git apply 0003-BootReceiver-Return-early-if-trace-pipe-doesnt-exists.patch
git apply 0004-core-jni-add-a-separate-prop-to-activate-ART-LowMemo.patch
git apply 0001-interfaces-kill-android.hardware.audio.sounddose-ven.patch
git apply 0001-gd-hci-Allow-disabling-erroneous-data-reporting.patch
git apply 0002-gd-hci-Ignore-unexpected-status-events.patch
git apply bt-15-qpr1.patch
git apply frame-1-15.patch
git apply frame-2-15.patch
git apply proc.patch
git apply sms-15.patch

echo "------------------------------------------------"
echo "Applying Patches done"
echo "------------------------------------------------"

# IMP
rm -rf build/soong/fsgen

# Build
export BUILD_USERNAME=ZxroxXm
export BUILD_HOSTNAME=crave
export TZ=Asia/India
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
source build/envsetup.sh
lunch lineage_a04e-bp1a-userdebug
mka bacon

rm -rf device/samsung/a04e
git clone https://github.com/ZxroxXm/device_samsung_a04e -b test-org device/samsung/a04e
source build/envsetup.sh
lunch lineage_a04e-ap2a-userdebug
mka bacon

# Making Recovery IMAGE
source build/envsetup.sh
breakfast a04e userdebug || lunch lineage_a04e-userdebug
mka recoveryimage

# Making AOSP Recovery Image
rm -rf device/samsung/a04e
git clone https://github.com/xcitty2029x/twrp_device_samsung_a04e device/samsung/a04e
source build/envsetup.sh
breakfast a04e userdebug || breakfast a04e || lunch lineage_a04e-eng || lunch lineage_a04e-userdebug
mka recoveryimage
