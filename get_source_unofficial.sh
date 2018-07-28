#!/bin/bash

DEB_VERSION=`(cd etherlabmaster && dpkg-parsechangelog | sed -rne 's/^Version: ([0-9.]+(\+[0-9]*git[0-9a-z]*)?).*$$/\1/p')`
DEB_ORIG="etherlabmaster_$DEB_VERSION.orig.tar.gz"

GIT_REPOS=https://github.com/ribalda/ethercat.git
GIT_COMMIT=`(echo "$DEB_VERSION" | sed -rne 's/^[0-9.]+\+[0-9]*git([0-9a-z]*).*$$/\1/p')`
GIT_DIR=".ethercat"

set -e

if ! test -e $GIT_DIR/.git; then
    echo "Cloning git commit $GIT_COMMIT..."
    function cleanup {
	rm -rf "$GIT_DIR"
    }
    trap cleanup EXIT
    git clone $GIT_REPOS "$GIT_DIR"
    (cd $GIT_DIR && git checkout $GIT_COMMIT)
    trap - EXIT
fi

echo "Create source archive..."
(cd $GIT_DIR && git archive --format=tar HEAD) | gzip > "$DEB_ORIG"

echo "Extracting source..."
(cd etherlabmaster && tar xf "../$DEB_ORIG")

echo "DONE."
