#!/bin/bash
set -euo pipefail

read -p "Please enter the disk you want to use for the install" $DISK
export $DISK
PLAT_FILE="/sys/firmware/efi/fw_platform_size"
FW_TYPE="MBR"
if [[ -f "$PLAT_FILE" ]]; then
    ARCHITECTURE=$(< "$FILE_PATH")
    if [[ "$ARCHITECTURE" == 64 ]]; then
        FW_TYPE="UEFI"
        echo "Detected 64-Bit UEFI"
    else
        FW_TYPE="IA32"
        echo "Detected 32-Bit IA32 UEFI"
    fi
else
    echo "Detected BIOS / CSM mode"
fi
MODE="minimal"
read -p "Please select an option:\n[1] Minimal\n[2] KDE\n[3] i3" $DE
if [[ "$DE" == 1 ]]; then
    echo "Continuing with minimal install"
elif [[ "$DE" == 2 ]]; then
    echo "Continuing with KDE install"
    MODE="kde"
elif [[ "$DE" == 3 ]]; then
    echo "Continuing with i3 install"
    MODE="i3"
else
    echo "No such option"
    exit 1
fi

echo "Continuing with ${FW_TYPE} ${MODE} installation...";

if [[ "$FW_TYPE" == "UEFI" && "$MODE" == "minimal" ]]; then
    chmod +x minimal_uefi/install.sh
    bash install.sh
fi