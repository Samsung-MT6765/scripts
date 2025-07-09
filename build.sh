#!/bin/bash

echo "Building Started"
rm -rf device/samung/a04e
rm -rf kernel/samsung/a04e
rm -rf vendor/samsung/lpm-p35
rm -rf hardware/samsung
rm -rf vendor/samsung/hq-camera
rm -rf device/mediatek/sepolicy_vndr

# Rom source repo
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs
echo "========================================================================="
echo "----------------------------- Repo init success ---------------------------"
echo "========================================================================="

# Device Specific trees
git clone https://github.com/ZxroxXm/android_device_samsung_a04e -b fifteen device/samsung/a04e
git clone https://github.com/ZxroxXm/android_device_samsung_mt6765-jdm -b fifteen device/samsung/mt6765-jdm
git clone https://github.com/ZxroxXm/vendor_samsung_hq-camera -b fifteen vendor/samsung/hq-camera
git clone https://github.com/ZxroxXm/vendor_samsung_lpm-p35 -b fifteen vendor/samsung/lpm-p35
git clone https://github.com/ZxroxXm/android_hardware_samsung -b fifteen hardware/samsung
git clone https://github.com/ZxroxXm/android_device_mediatek_sepolicy_vndr -b fifteen device/mediatek/sepolicy_vndr
echo "============================================================================================="
echo "--------------------- All Repositrories Cloned Successfully -------------------"
echo "============================================================================================="

# Sync the repositories
/opt/crave/resync.sh
echo "============= Repo Sync Done =============="

# Selinux Patches
#!/bin/bash

#selinux patch

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

#sysbta patch

wget https://raw.githubusercontent.com/ZxroxXm/patches/refs/heads/main/bt-15-qpr1.patch 
wget https://raw.githubusercontent.com/ZxroxXm/patches/refs/heads/main/frame-1-15.patch
wget https://raw.githubusercontent.com/ZxroxXm/patches/refs/heads/main/frame-2-15.patch
wget https://raw.githubusercontent.com/ZxroxXm/patches/refs/heads/main/proc.patch
wget https://raw.githubusercontent.com/ZxroxXm/patches/refs/heads/main/sms-15.patch

git apply bt-15-qpr1.patch
echo "------------------------------------------------"
echo " bt-15-qpr1 patch "
echo "------------------------------------------------"

git apply frame-1-15.patch
echo "------------------------------------------------"
echo " frame-1-15.patch "
echo "------------------------------------------------"

git apply frame-2-15.patch
echo "------------------------------------------------"
echo " frame-2-15.patch "
echo "------------------------------------------------"

git apply proc.patch
echo "------------------------------------------------"
echo " proc.patch "
echo "------------------------------------------------"

git apply sms-15.patch
echo "------------------------------------------------"
echo " sms-15.patch "
echo "------------------------------------------------"

 echo "------------------------------------------------"
 echo "=========ALL PATCHES DONE SUCCESFULLY==========="
 echo "------------------------------------------------"

# Must remove this else cause conflicts
rm -rf build/soong/fsgen

# Export
export BUILD_USERNAME=ZxroxXm
export BUILD_HOSTNAME=crave
export TZ=Asia/India
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
echo "======= Export Done ======"

# Start building
source build/envsetup.sh
lunch lineage_a04e-ap4a-userdebug
mka bacon

