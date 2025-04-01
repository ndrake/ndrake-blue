#!/bin/bash
set -oue pipefail

DRIVER_NAME="rtl8852au"
DRIVER_VERSION="1.0"
SRC_DIR="/usr/src/$DRIVER_NAME-$DRIVER_VERSION"

# Install dependencies
dnf install -y dkms kernel-devel kernel-headers git make gcc
dnf group install -y "development-tools"

# Clone the driver source
rm -rf "$SRC_DIR"
git clone https://github.com/lwfinger/rtl8852au "$SRC_DIR"

echo "Clone complete!"

echo $(ls -l /lib/modules)


# Create a DKMS configuration file
cat <<EOF > "$SRC_DIR/dkms.conf"
PACKAGE_NAME="$DRIVER_NAME"
PACKAGE_VERSION="$DRIVER_VERSION"
MAKE[0]="make"
CLEAN="make clean"
BUILT_MODULE_NAME[0]="8852au"
DEST_MODULE_LOCATION[0]="/updates/dkms"
AUTOINSTALL="yes"
EOF

# Add the module to DKMS
dkms add -m "$DRIVER_NAME" -v "$DRIVER_VERSION"
dkms build -m "$DRIVER_NAME" -v "$DRIVER_VERSION"
dkms install -m "$DRIVER_NAME" -v "$DRIVER_VERSION"

# Ensure the module loads on boot
echo "8852au" | tee -a /etc/modules-load.d/8852au.conf

echo "Driver installation completed successfully!"
