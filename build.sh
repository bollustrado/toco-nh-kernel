#!/bin/sh

export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=dtc
export PATH="$HOME/dev/proton-clang/bin:${PATH}" #:$HOME/dev/aarch64-linux-gnu/bin:${PATH}"
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_COMPILER_STRING="$($HOME/dev/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

COMPRESSION="gz"
RELEASE="r1"
OUT_ZIP="toco-kernel.zip"
THREAD_COUNT=$(($(nproc --all)-1)) # Keep minus 1 for responsive desktop experience while building on relatively old systems.

#git fetch https://github.com/cyberknight777/android_kernel_nethunter main
#git merge -s ours --no-commit --allow-unrelated-histories --squash FETCH_HEAD
#git read-tree --prefix=nethunter -u FETCH_HEAD
#git commit -m "Imported nethunter/ from https://github.com/cyberknight777/android_kernel_nethunter"
#grep nethunter arch/arm64/Kconfig
#if ["$?" = 1 ]; then echo 'source "nethunter/Kconfig"' >> arch/arm64/Kconfig; fi

echo --CLEAN OUT
echo - cleaning out
rm -rf out
#PATH="$HOME/dev/proton-clang-14/bin:${PATH}" \
make O=out ARCH=arm64 mrproper
#PATH="$HOME/dev/proton-clang-14/bin:${PATH}" \
make ARCH=arm64 mrproper
echo - cleaning generated Image
rm _anykernel/Image.$COMPRESSION-dtb
rm _anykernel/dtbo.img
echo - cleaning generated zip
rm $OUT_ZIP
echo - generate out directory
mkdir out

echo DEFCONFIG
#PATH="$HOME/dev/proton-clang-14/bin:${PATH}" \
make  O=out ARCH=arm64 toco_nh3_defconfig
#make  O=out ARCH=arm64 toco_defconfig

echo MENUCONFIG
#PATH="$HOME/dev/proton-clang-14/bin:${PATH}" \ 
make O=out ARCH=arm64 menuconfig
#make O=out xconfig

PATH="$HOME/dev/proton-clang/bin:${PATH}" \ 
make -j$THREAD_COUNT O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      LD=ld.lld | tee kernel.log

cp out/arch/arm64/boot/Image.$COMPRESSION-dtb _anykernel/
cp out/arch/arm64/boot/dtbo.img _anykernel/

(cd _anykernel; zip -r ../toco-kernel.zip .)
#(cd /out/tmp/lib/modules; zip -r ../modules.zip .)
#kdeconnect-cli -d 05936cf28feb79fb --share toco-kernel.zip

