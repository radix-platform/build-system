#!/bin/bash

VERSION=1.3-20190808

tar --files-from=file.list -xzvf ../dialog-$VERSION.tgz
mv dialog-$VERSION dialog-$VERSION-orig

cp -rf ./dialog-$VERSION-new ./dialog-$VERSION

diff --unified -Nr  dialog-$VERSION-orig  dialog-$VERSION > dialog-$VERSION.patch

mv dialog-$VERSION.patch ../patches

rm -rf ./dialog-$VERSION
rm -rf ./dialog-$VERSION-orig
