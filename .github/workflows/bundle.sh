#/bin/sh
set -e
PACKAGE=openssl

# Update
pacman -Sy
OUTPUT=$(mktemp -d)

pkgs=$(echo mingw-w64-{i686,x86_64,ucrt-x86_64}-${PACKAGE})
URLS=$(pacman -Sp $pkgs --cache=$OUTPUT)
VERSION=$(pacman -Si mingw-w64-x86_64-${PACKAGE} | awk '/^Version/{print $3}')

# Set version for next step
echo "::set-output name=VERSION::${VERSION}"
echo "::set-output name=PACKAGE::${PACKAGE}"
echo "Bundling $PACKAGE-$VERSION"
echo "# $PACKAGE $VERSION" > README.md
echo "" >> README.md

for URL in $URLS; do
  curl -OLs $URL
  FILE=$(basename $URL)
  echo "Extracting: $FILE"
  echo " - $FILE" >> readme.md
  tar xf $FILE -C ${OUTPUT}
  unlink $FILE
done
rm -Rf lib lib-8.3.0 lib-4.9.3 include
mkdir -p lib-8.3.0
mkdir -p lib
cp -Rf ${OUTPUT}/mingw64/include .
cp -Rf ${OUTPUT}/mingw64/lib lib-8.3.0/x64
cp -Rf ${OUTPUT}/mingw32/lib lib-8.3.0/i386
cp -Rf ${OUTPUT}/ucrt64/lib lib/x64
ls -ltrRh .
