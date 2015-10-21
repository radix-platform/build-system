#!/bin/sh

VERSION=1.0

tar --files-from=file.list -xJvf ../populatefs-$VERSION.tar.xz
mv populatefs-$VERSION populatefs-$VERSION-orig

cp -rf ./populatefs-$VERSION-new ./populatefs-$VERSION

diff -b --unified -Nr  populatefs-$VERSION-orig  populatefs-$VERSION > populatefs-$VERSION-notrunc-rfiles.patch

mv populatefs-$VERSION-notrunc-rfiles.patch ../patches

rm -rf ./populatefs-$VERSION
rm -rf ./populatefs-$VERSION-orig
