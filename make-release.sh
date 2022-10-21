#!/bin/sh
set -x
TAG_PREFIX="galene-"
VERSION="$(git describe --tags|sed -e "s/^${TAG_PREFIX}//")"
TAG="$(git tag -l "${TAG_PREFIX}${VERSION}")"
test -z "${TAG}" && {
    TAG="$(git tag -l "${TAG_PREFIX}$(echo "${VERSION}"|sed -e 's/-[0-9]*-g[0-9a-f]*$//')"|sed -e "s/^${TAG_PREFIX}//")"
}
test "${VERSION}" != "${TAG}" && {
    RC="$(echo "${VERSION}"|sed -e "s/^${TAG}//"|cut -d- -f2)"
    VERSION="${TAG}-rc$(printf "%02d" "${RC}")"
}

rm -rf vendor
rm -rf galene
rm -rf build
CGO_ENABLED=0 go build -ldflags='-s -w'

mkdir build
cp galene "build/galene-${VERSION}"
rm -rf "static-${VERSION}"
cp -a static "static-${VERSION}"

sed -i -e "s/>Galène</>Galène ${VERSION}</"  "static-${VERSION}/index.html"
sed -i -e "s/>Galène</>Galène ${VERSION}</"  "static-${VERSION}/galene.html"

tar cf - "./static-${VERSION}"|xz -c9 >"build/static-${VERSION}.tar.xz"
rm -rf "static-${VERSION}"
