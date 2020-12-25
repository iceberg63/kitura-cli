#!/bin/bash
set -ex

# if [ -z "$1" ]; then
#     echo "Usage: build.sh <release>"
#     echo " - where <release> is a SemVer version in the format x.y.z"
#     exit 1
# fi

export RELEASE='0.0.2'

case `uname` in
  Darwin)
    make build-darwin package-darwin
    test_Darwin
    ;;
  Linux)
    make package-linux
    ;;
  *)
    echo "Unsupported OS: `uname`"
    exit 1
esac
