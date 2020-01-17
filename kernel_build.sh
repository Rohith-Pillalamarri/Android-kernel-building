##############################################
#   SebaUbuntu custom kernel build script    #
##############################################

# Set defaults directory's
ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/out
ANYKERNEL_DIR=$ROOT_DIR/anykernel3
KERNEL_DIR=$ROOT_DIR/kernel
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")
# Export ARCH and SUBARCH <arm, arm64, x86, x86_64>
export ARCH=arm
export SUBARCH=arm
# Set kernel name
export LOCALVERSION=SebaUbuntu-Stock-U5
# Export Username
export KBUILD_BUILD_USER=SebaUbuntu
# Export Machine name
export KBUILD_BUILD_HOST=Seba-PC
# Export what defconfig you want to use
export DEFCONFIG=j4primelte_sea_open_defconfig

# Color definition
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

# Set kernel source workspace
cd $KERNEL_DIR

# Compiler String
if [ $ARCH = arm ]
	then
		# Export ARM from the given directory
		export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
	elif [ $ARCH = arm64 ]
		then
			# Export ARM64 and ARM cross-compliers from the given directory
			export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
			export CROSS_COMPILE_ARM32=${ROOT_DIR}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
# x86_32 toolchain wrong, please change it manually
	elif [ $ARCH = x86 ]
		then
			# Export ARM64 and ARM cross-compliers from the given directory
			export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
	elif [ $ARCH = x86_64 ]
		then
			# Export ARM64 and ARM cross-compliers from the given directory
			export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
			export CROSS_COMPILE_X86=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
fi

echo -e "*****************************************************"
echo    "            Compiling kernel using GCC               "
echo -e "*****************************************************"
echo -e "-----------------------------------------------------"
echo    " Architecture: $ARCH                                 "
echo    " Output directory: $OUT_DIR                          "
echo    " Kernel version: $LOCALVERSION                       "
echo    " Build user: $KBUILD_BUILD_USER                      "
echo    " Build machine: $KBUILD_BUILD_HOST                   "
echo    " Build started on: $BUILD_START                      "
echo    " Toolchain: GCC                                      "
echo -e "-----------------------------------------------------"

# Make and Clean
make O=$OUT_DIR clean
make O=$OUT_DIR mrproper

# Make your device device_defconfig
make O=$OUT_DIR ARCH=$ARCH $DEFCONFIG

# Build Kernel
make O=$OUT_DIR ARCH=$ARCH -j$(nproc --all)
# Save build result (failed or not)
BUILD_SUCCESS=$?
# Find how much build has been long
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

if [ $BUILD_SUCCESS = 0 ]
	then
		clear
		echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds. $reset"
		echo -e "Making Flashable Template using anykernel3"
		# Clean anykernel2 directory
		rm -f ${ANYKERNEL_DIR}/Image.gz*
		rm -f ${ANYKERNEL_DIR}/zImage*
		rm -f ${ANYKERNEL_DIR}/dtb*
		# Change the directory to anykernel3 directory
		cd ${ANYKERNEL_DIR}
		# remove all zips
		rm *.zip
		# Copy thhe image.gz-dtb to anykernel2 directory
		cp $OUT_DIR/arch/$ARCH/boot/zImage-dtb ${ANYKERNEL_DIR}/zImage
		# Build a flashable zip Device using anykernel2
		zip -r9 kernel-$LOCALVERSION-$DATE.zip * -x README kernel-$LOCALVERSION-$DATE.zip
	else
		echo -e "$red Build failed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds. $reset"
fi

# Exported variables cleanup
for i in O ARCH SUBARCH LOCALVERSION KBUILD_BUILD_USER KBUILD_BUILD_HOST DEFCONFIG CROSS_COMPILE CROSS_COMPILE_ARM32 CROSS_COMPILE_X86
	do
		unset $i
	done
