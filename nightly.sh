#!/bin/bash

# We don't set -e because some of the commands may
# fail or exit with non-zero return codes.

# BL note: the actual cron job is another script which
# runs this one and posts its output to Jenkins

echo '* Simple Mininet Nightly Build Script'

date=`date +%Y-%m-%d-%a`
builddir=/build
dir=$builddir/nightly-$date
mndir=${HOME}/mininet
build=${mndir}/util/vm/build.py
opts='-z --timeout 1800'
scripts=/home/mininet/build-scripts
post=$scripts/post-build-result.sh
check=$scripts/check-build-dir.sh
maxbuilds=3

echo '* Pulling latest build.py'
  pushd $mndir
  git pull --rebase
  popd

# If we have a bunch of builds, remove the oldest first
cd $builddir
while [ `ls -td nightly-* | wc -l` -gt $maxbuilds ]; do 
  oldest=`ls -td nightly-* | tail -1`
  echo "* Removing old build directory $oldest"
  sudo rm -rf $oldest
done

# Create new nightly build directory
mkdir $dir
cd $dir

# Build current master branch

dists="precise quantal raring saucy trusty"
archs="32 64"

for dist in $dists; do
  for arch in $archs ; do
    target="${dist}${arch}server"
    echo "* Building $target and posting to jenkins"
    $post "mininet-$target" $build $opts $target
    builddir=mn-$target*
    echo "* Checking build log for $builddir"
    $post "check-$target" $check $builddir
    echo "* Testing examples"
    $post "check-examples-$target" $examples $date $target examples
  done
done

# Build stable release

release=2.1.0p2
dists="raring"
opts="$opts -b $release"

for dist in $dists; do
  for arch in $archs; do
    target="${dist}${arch}server"
    echo "* Building $target and posting to jenkins"
    $post "mininet-$release-$target" $build $opts $target
    builddir=mn-$release-$target*
    echo "* Checking build log for $builddir"
    $post "check-$release-$target" $check $builddir
    echo "* Testing examples"
    $post "check-examples-$target" $examples $date $target examples
  done
done

echo '* Nightly Build Script complete'
exit 0
