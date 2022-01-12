#!/bin/sh

export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=dtc
export PATH="$HOME/dev/clang-14/bin:$HOME/dev/aarch64-linux-gnu/bin:${PATH}"
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_COMPILER_STRING="$($HOME/dev/clang-14/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

COMPRESSION="gz"
RELEASE="r1"
OUT_ZIP="toco-kernel.zip"
THREAD_COUNT=$(($(nproc --all)-0)) # Keep minus 1 for responsive desktop experience while building on relatively old systems.

echo --CLEAN OUT
echo - cleaning out
rm -rf out
#make O=out CC=clang ARCH=arm64 mrproper
echo - cleaning generated Image
rm _anykernel/Image.$COMPRESSION-dtb
rm _anykernel/dtbo.img
rm -rf _anykernel/modules/system/lib/modules/*
echo - cleaning generated zip
rm $OUT_ZIP
echo - generate out directory
mkdir out

echo DEFCONFIG
PATH="$HOME/dev/clang-14/bin:$HOME/dev/aarch64-linux-gnu/bin:${PATH}" \
make CROSS_COMPILE=aarch64-linux-gnu- O=out CC=clang ARCH=arm64 toco_nh_defconfig
#make  O=out ARCH=arm64 toco_defconfig

echo MENUCONFIG
PATH="$HOME/dev/clang-14/bin:$HOME/dev/aarch64-linux-gnu/bin:${PATH}" \
make O=out CC=clang menuconfig
#make O=out xconfig
PATH="$HOME/dev/clang-14/bin:$HOME/dev/aarch64-linux-gnu/bin:${PATH}" \
make O=out CC=clang savedefconfig
PATH="$HOME/dev/clang-14/bin:$HOME/dev/aarch64-linux-gnu/bin:${PATH}" \
make -j16 O=out \
                      ARCH=arm64 \
                      CC=clang \
		      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
		      USE_CCACHE=1 \
		      CCACHE_DIR=~/.ccache \
                      LD=ld.lld | tee kernel.log

make modules_install -j16 O=out \
                      ARCH=arm64 \
                      CC=clang \
		      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      USE_CCACHE=1 \
                      CCACHE_DIR=~/.ccache \
                      LD=ld.lld

make headers_install -j16 O=out \
                      ARCH=arm64 \
                      CC=clang \
		      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      USE_CCACHE=1 \
                      CCACHE_DIR=~/.ccache \
                      LD=ld.lld


cp out/arch/arm64/boot/Image.$COMPRESSION-dtb _anykernel/
cp out/arch/arm64/boot/dtbo.img _anykernel/
for mod in $(find out/ -name *.ko)
    do cp $mod _anykernel/modules/system/lib/modules/
done

(cd _anykernel; zip -r ../toco-kernel.zip .)
