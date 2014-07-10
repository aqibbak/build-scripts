#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Mininet nightly build tester"
  echo "Usage: $0 <day> <flavor> [<test>...]"
  echo "Valid tests include: sanity core examplesquick examplesfull ..."
  exit 1
fi

set -u  # error on undefined var
set -e  # exit on error

day=$1
flavor=$2
shift
shift

tests=""
for test in $*; do
  tests="$tests --test $test"
done

images=`eval ls /build/*$day*/*$flavor*/*.vmdk`
if [ "$images" != "" ]; then
  echo "* Found images:"
  echo $images
fi

build=~/mininet/util/vm/build.py
# was: --verbose
opts=""
branch=""
#--branch master"

for image in $images; do
  echo "* Testing $image"
    cmd="$build $opts $branch $tests --image $image"
    echo "- $cmd"
    $cmd
  echo "* Done testing $image"
done

exit 0
