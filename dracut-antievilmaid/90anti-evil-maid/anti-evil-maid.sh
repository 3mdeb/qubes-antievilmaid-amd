#!/bin/sh
#
# Anti Evil Maid for dracut by Invisible Things Lab
# Copyright (C) 2010 Joanna Rutkowska <joanna@invisiblethingslab.com>
#
# Mount our device, read the sealed secret blobs, initilize TPM
# and finally try to unseal the secrets and display them to the user
#


. /lib/dracut-lib.sh

if [ -d /antievilmaid ] ; then
	info "/antievilmaid already exists, skipping..."
	exit 0
fi

info "Waiting for antievilmaid boot device to become avilable..."
while ! [ -b /dev/antievilmaid ]; do
	sleep 0.1
done

info "Mouting the antievilmaid boot device..."
mkdir /antievilmaid
mount /dev/antievilmaid /antievilmaid

info "Initializing TPM..."
/sbin/modprobe tpm_tis
ifconfig lo up
mkdir -p /var/lib/tpm/
cp /antievilmaid/antievilmaid/system.data /var/lib/tpm/
/usr/sbin/tcsd

/bin/plymouth hide-splash

TPMARGS=""
if ! getarg rd.antievilmaid.asksrkpass; then
    info "Using default SRK password"
    TPMARGS="-z"
fi

echo "Attempting to unseal the secret passphrase from the TPM..."
echo

/usr/bin/tpm_unsealdata $TPMARGS -i /antievilmaid/antievilmaid/sealed_secret.blob

echo
echo "Continue the boot process only if the secret above is correct!"
echo

info "Unmounting the antievilmaid device..."
umount /dev/antievilmaid

