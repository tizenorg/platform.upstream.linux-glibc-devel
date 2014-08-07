#!/bin/bash
# bash -x $0 linux-1.2.3.tar.bz2
set -e
kernel=$1
if ! test -f "$1"
then
	echo "Usage: ${0##*/} linux-1.2.3.tar.gz"
	exit 1
fi
if echo $PWD | grep -q :; then
  echo "do not call this in a directory with : - make will fail"
  exit 1
fi

kernel_dir="`tar -tf $1 | sed '1 {s@^.*[[:blank:]]@@;s@linux-@@;s@/.*$@@;s@^\([0-9]\+\.[0-9]\+\.[0-9]\+\)\(.*\)@\1@;p;Q}'`"
header_dir="$PWD/linux-glibc-devel-$kernel_dir"
if test -d "$kernel_dir"
then
	echo "$kernel_dir exists, remove it first."
	exit 1
fi
if ! mkdir "$header_dir"
then
	echo "$header_dir exists, remove it first."
	exit 1
fi
tar -xf $1
pushd linux-${kernel_dir}
cp Makefile $header_dir
# header export for unicore32 in 2.6.39 is broken, disable it
sed -i -e 's/cris/cris\|unicore32/' scripts/headers.sh
/usr/bin/make O="$header_dir" headers_install_all
# kvm.h and aout.h are only installed if SRCARCH is an architecture
# that has support for them. As the package is noarch we need to make
# sure we get the full support on x86
/usr/bin/make SRCARCH=x86 O="$header_dir" headers_install_all
popd
pushd "$header_dir"
for asm in \
	arm64 \
	alpha \
	avr32 \
	blackfin \
	cris \
	frv \
	h8300 \
	m32r \
	m68k \
	m68knommu \
	mips \
	mn10300 \
	sh \
	sh64 \
	v850 \
	xtensa \
        unicore32 \
; do
	rm -rf usr/include/asm-$asm
done
rm Makefile
find -type f -name "..install.cmd" -print0 | xargs -0 --no-run-if-empty rm
find -type f -name ".install" -print0 | xargs -0 --no-run-if-empty rm
#-------------------------------------------------------------------
#Fri Sep  5 10:43:49 CEST 2008 - matz@suse.de

#- Remove the kernel version of drm headers, they conflict
#  with the libdrm ones, and those are slightly newer.
#
rm -rf usr/include/drm/
for dir in *
do
	case "$dir" in
		usr) ;;
		*) 
			if test -d "$dir"
			then
				rm -rf "$dir"
			fi
		;;
	esac
done
popd
du -sh "$header_dir/usr"
tar -cjf "$header_dir.tar.bz2" "${header_dir##*/}"
rm -rf $header_dir linux-${kernel_dir}

