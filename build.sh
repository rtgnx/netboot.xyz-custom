#!/usr/bin/fakeroot /bin/bash
set -o errexit
set -o nounset
set -o pipefail

IMAGE="$1"


docker build -t "${IMAGE}:kernel" -f Dockerfile.kernel .
#docker build -t "${IMAGE}:root" -f Dockerfile .
docker build -t "${IMAGE}:squashfs" -f Dockerfile.squashfs .

OUTFILE=$2.squashfs
TMPDIR=$(mktemp -d -p .)

cleanup() {
  rm -fr $TMPDIR
}

trap cleanup EXIT

echo "OK"
CONTAINER=$(docker create "${IMAGE}:kernel" /bin/noop )
docker export $CONTAINER | tar -C $TMPDIR -p --same-owner -xv
docker rm $CONTAINER

ls -larth ${TMPDIR}/
mv ${TMPDIR}/vmlinuz .
mv ${TMPDIR}/initramfs.img .


# Copy squashfs from image
CONTAINER=$(docker create "${IMAGE}:kernel" /bin/noop )
docker export $CONTAINER | tar -C $TMPDIR -p --same-owner -xv
docker rm $CONTAINER
mv ${TMPDIR}/rootfs.squashfs . 

# Build squashfs on host
#CONTAINER=$(docker create "${IMAGE}:root")
#docker export $CONTAINER | tar -C $TMPDIR -p --same-owner -xv

#docker rm $CONTAINER
#sudo mksquashfs $TMPDIR $OUTFILE -info -processors 1 -noappend -comp xz -Xdict-size 100%
