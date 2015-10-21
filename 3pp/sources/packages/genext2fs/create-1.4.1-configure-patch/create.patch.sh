#!/bin/sh

VERSION=1.4.1

tar --files-from=file.list -xzvf ../genext2fs-$VERSION.tar.gz
mv genext2fs-$VERSION genext2fs-$VERSION-orig

cp -rf ./genext2fs-$VERSION-new ./genext2fs-$VERSION

diff -b --unified -Nr  genext2fs-$VERSION-orig  genext2fs-$VERSION > genext2fs-$VERSION-configure.patch

mv genext2fs-$VERSION-configure.patch ../patches

rm -rf ./genext2fs-$VERSION
rm -rf ./genext2fs-$VERSION-orig
