#!/bin/sh

VERSION=5.30.2

tar --files-from=file.list -xJvf ../perl-$VERSION.tar.xz
mv perl-$VERSION perl-$VERSION-orig

cp -rf ./perl-$VERSION-new ./perl-$VERSION

diff -b --unified -Nr  perl-$VERSION-orig  perl-$VERSION > perl-$VERSION-CPAN.patch

mv perl-$VERSION-CPAN.patch ../patches

rm -rf ./perl-$VERSION
rm -rf ./perl-$VERSION-orig
