#!/bin/bash

set -e 
set -x

echo "Clean: ${CLEAN}"
if [ -z "${RPI}" ] ; then
  echo "\$RPI missing, exting"
  exit 1
fi

if [ "${RPI}" -gt "2" ]; then
    export TOOLCHAIN_PREFIX="aarch64-none-elf-"
else
    export TOOLCHAIN_PREFIX="arm-none-eabi-"
fi

# Define system options
OPTIONS="-o USE_PWM_AUDIO_ON_ZERO -o SAVE_VFP_REGS_ON_IRQ -o REALTIME -o SCREEN_DMA_BURST_LENGTH=1"
if [ "${RPI}" -gt "1" ]; then
    OPTIONS="${OPTIONS} -o ARM_ALLOW_MULTI_CORE"
fi

# Build circle-stdlib library
cd circle-stdlib/
if [ ! -z "${CLEAN}" ] ; then
make mrproper || true
fi
./configure -r ${RPI} --prefix "${TOOLCHAIN_PREFIX}" ${OPTIONS} -o KERNEL_MAX_SIZE=0x400000
make -j

# Build additional libraries
cd libs/circle/addon/display/
if [ ! -z "${CLEAN}" ] ; then
make clean || true
fi
make -j
cd ../sensor/
if [ ! -z "${CLEAN}" ] ; then
make clean || true
fi
make -j
cd ../Properties/
if [ ! -z "${CLEAN}" ] ; then
make clean || true
fi
make -j
cd ../../../..

cd ..

# Build MiniDexed
echo "Build MiniDexed"
cd src
if [ ! -z "${CLEAN}" ] ; then
make clean || true
fi
make -j
ls *.img
cd ..
