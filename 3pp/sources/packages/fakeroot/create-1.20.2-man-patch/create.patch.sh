#!/bin/sh

VERSION=1.20.2

tar --files-from=file.list -xJvf ../fakeroot-$VERSION.tar.xz
mv fakeroot-$VERSION fakeroot-$VERSION-orig

cp -rf ./fakeroot-$VERSION-new ./fakeroot-$VERSION

diff -b --unified -Nr  fakeroot-$VERSION-orig  fakeroot-$VERSION > fakeroot-$VERSION-man.patch

mv fakeroot-$VERSION-man.patch ../patches

rm -rf ./fakeroot-$VERSION
rm -rf ./fakeroot-$VERSION-orig
