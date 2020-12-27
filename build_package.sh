#!/bin/bash
set -ex

if [ -z "$1" ]; then
    echo "Usage: build.sh <release>"
    echo " - where <release> is a SemVer version in the format x.y.z"
    exit 1
fi

export RELEASE=$1

case `uname` in
  Darwin)
    make package-darwin
    ;;
  Linux)
    make package-linux
    make ARCH=arm64 package-linux
    make package-darwin
    ;;
  *)
    echo "Unsupported OS: `uname`"
    exit 1
esac
