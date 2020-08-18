#!/bin/bash

DEB_VERSION=`(cd etherlabmaster && dpkg-parsechangelog | sed -rne 's/^Version: ([0-9.]+(\+[0-9]*hg[0-9a-z]*)?).*$$/\1/p')`
DEB_ORIG="etherlabmaster_$DEB_VERSION.orig.tar.gz"

HG_REPOS="http://hg.code.sf.net/p/etherlabmaster/code"
HG_COMMIT=`(echo "$DEB_VERSION" | sed -rne 's/^[0-9.]+\+[0-9]*hg([0-9a-z]*)p([0-9a-z]*).*$$/\1/p')`
HG_DIR="etherlabmaster-hg"

PATCH_REPOS="http://hg.code.sf.net/u/uecasm/etherlab-patches"
PATCH_COMMIT=`(echo "$DEB_VERSION" | sed -rne 's/^[0-9.]+\+[0-9]*hg([0-9a-z]*)p([0-9a-z]*).*$$/\2/p')`

usage() {
    if test -z "$*"; then
	RC=0
    else
	echo "Error:  $*" >&2
	RC=1
    fi
    cat >&2 <<EOF
Usage: $0 [-C] [-c] [-x] [-a]
    -C:  Clean up "etherlabmaster" directory
    -c:  Clone upscream repositories and apply patchsets
    -x:  Extract sources into "etherlabmaster" directory & create source tarball
    -a:  All (except clone); like "-Ccx"
    -h:  This help message
EOF
    exit $RC
}

CLEAN=false
CLONE=false
EXTRACT=false
while getopts aCcxh ARG; do
    case $ARG in
	a) CLONE=true; CLEAN=true; EXTRACT=true ;;
	C) CLEAN=true ;;
	c) CLONE=true ;;
	x) EXTRACT=true ;;
	h) usage ;;
	*) usage "Illegal option -$OPTARG" ;;
    esac
done
shift $(($OPTIND - 1))

if test "${CLEAN}${CLONE}${EXTRACT}" = "falsefalsefalse"; then
    usage "Please select a argument"
fi

# Be sure we're in the right directory
cd $(dirname $0)

set -e

if $CLEAN; then
    echo 'Cleaning up "etherlabmaster" directory'
    git clean -Xdf etherlabmaster
fi

if $CLONE && test ! -d $HG_DIR; then
    echo "Cloning HG commit $HG_COMMIT..."
    hg clone $HG_REPOS "$HG_DIR" -r $HG_COMMIT

    echo "Cloning patchset commit $PATCH_COMMIT..."
    hg clone $PATCH_REPOS "$HG_DIR/.hg/patches" -r $PATCH_COMMIT

    if test -f $HG_DIR/.hg/hgrc && ! grep -q '^mq' $HG_DIR/.hg/hgrc; then
	echo "Enabling hg mq extension..."
	echo -e "[extensions]\nmq =" >> $HG_DIR/.hg/hgrc
    fi

    echo "Apply patchset..."
    (cd $HG_DIR && hg qpush -a)
fi

if $EXTRACT; then
    echo "Create source archive..."
    (cd $HG_DIR && hg archive "../$DEB_ORIG")

    echo "Extracting source..."
    (cd etherlabmaster && tar xfz "../$DEB_ORIG" --strip 1)
fi

echo "DONE."
