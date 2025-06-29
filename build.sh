#!/bin/sh
# This script will build QuartzOS (untested)

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root." >&2
  exit 1
fi

set -e

ISO_NAME="QuartzOS"
WORKDIR="./work"
OVERLAY="./overlayfs"

# Create working directory
rm -rf "$WORKDIR" "$OVERLAY"
mkdir -p "$WORKDIR"

if [ ! -f base.txz ]; then
    echo "base.txz is missing, please download from FreeBSD Website"
    echo "https://download.freebsd.org/releases/amd64/14.3-RELEASE/base.txz"
    exit 1
fi

if [ ! -f kernel.txz ]; then
    echo "kernel.txz is missing, please download from FreeBSD Website"
    echo "https://download.freebsd.org/releases/amd64/14.3-RELEASE/kernel.txz"
    exit 1
fi


# Extract FreeBSD FIles
tar -xpvf base.txz -C "$WORKDIR" --same-owner
tar -xpvf kernel.txz -C "$WORKDIR" --same-owner

# Clone overlay repository
git clone https://github.com/QuartzBSD/rootfs.git "$OVERLAY"
rm -f "$OVERLAY/LICENSE" "$OVERLAY/README.md"

# Copy overlays ( QuartzOS Files )
cp -a "$OVERLAY/." "$WORKDIR"

# Bootloader check
if [ ! -f "$WORKDIR/boot/cdboot" ]; then
    echo "'$WORKDIR/boot/cdboot/' is missing. Make sure cdboot is present in your base or added manually vro."
    exit 1
fi

# Create quartz.txz ( for the installer )
tar -cJpvf ./$WORKDIR/quartzos-dist/quartz.txz -C "$WORKDIR" .

# Build ISO
# makefs -t ffs -B little -o label=QUARTZOS rootfs.img "$WORKDIR"
# mkisofs -o "$ISO_NAME" -b boot/cdboot -no-emul-boot -r -J "$WORKDIR"
xorriso -as mkisofs -outdev "$ISO_NAME".iso -volid QUARTZOS -boot_image boot_image="$WORKDIR/boot/cdboot" -boot_image no-emul-boot -rational-rock -joliet on "$WORKDIR"/

echo "ISO created: $ISO_NAME"

# i have no idea if this even works
