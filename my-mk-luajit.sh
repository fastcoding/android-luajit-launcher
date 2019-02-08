#!/bin/bash
# see http://luajit.org/install.html for details
# there, a call like one of the following is recommended

# NDKABI=21  # Android 5.0+
# NDKABI=19  # Android 4.4+
NDKABI=${NDKABI:-19} # Android 4.4+
DEST=$(cd "$(dirname "$0")" && pwd)/jni/luajit-build/$1
# might be linux-x86_64 or darwin-x86-64
HOST_ARCH="*"

case "$1" in
    clean)
        make -C luajit-2.0 clean
        ;;
    aarch64)
        NDKABI=21 
        NDKP=$PWD/toolchain/bin/aarch64-linux-android-
        NDKP2=$PWD/toolchain/bin/aarch64-linux-android$NDKABI-
        NDKF="--sysroot $PWD/toolchain/sysroot"
        if ! [ -x  ${NDKP}gcc ]; then
          if [ -x ${NDKP2}clang ]; then
              echo create gcc link
              ln -s ${NDKP2}clang ${NDKP}gcc
          fi
        fi
        rm -rf "$DEST"
        make -C luajit-2.0 install HOST_CC="gcc -m64" CROSS="$NDKP" TARGET_FLAGS="$NDKF" TARGET_SYS=Linux DESTDIR="$DEST" PREFIX=
        ;;
    armeabi)
        # Android/ARM, armeabi (ARMv5TE soft-float)
        TCVER=("${NDK}"/toolchains/arm-linux-androideabi-4.*)
        NDKP=$PWD/toolchain/bin/arm-linux-androideabi-
        #NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
        NDKF="--sysroot $PWD/toolchain/sysroot"
        rm -rf "$DEST"
        make -C luajit-2.0 install HOST_CC="gcc -m32" CROSS="$NDKP" TARGET_FLAGS="$NDKF" TARGET_SYS=Linux DESTDIR="$DEST" PREFIX=
        ;;
    armeabi-v7a)
        # Android/ARM, armeabi-v7a (ARMv7 VFP)
        TCVER=("${NDK}"/toolchains/arm-linux-androideabi-4.*)
        NDKP=$PWD/toolchain/bin/arm-linux-androideabi-
        #NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
        NDKF="--sysroot $PWD/toolchain/sysroot"
        rm -rf "$DEST"
        #NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
        NDKARCH="-march=armv7-a -mfloat-abi=hard -mfpu=vfp3 -Wl,--no-warn-mismatch"
        make -C luajit-2.0 install HOST_CC="gcc -m32" CROSS="$NDKP" TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux DESTDIR="$DEST" PREFIX=
        ;;
    x86)
        # Android/x86, x86 (i686 SSE3)
        TCVER=("${NDK}"/toolchains/x86-4.*)
#        NDKP=${TCVER[0]}/prebuilt/$HOST_ARCH/bin/i686-linux-android-
        NDKP=$PWD/toolchain/bin/i686-linux-android-
        #NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
        NDKF="--sysroot $PWD/toolchain/sysroot"
        rm -rf "$DEST"
        make -C luajit-2.0 install HOST_CC="gcc -m32" CROSS="$NDKP" TARGET_FLAGS="$NDKF" TARGET_SYS=Linux DESTDIR="$DEST" PREFIX=
        ;;
    *)
        echo 'specify one of "armeabi", "armeabi-v7a", "aarch64", "x86" or "clean" as first argument'
        exit 1
        ;;
esac
