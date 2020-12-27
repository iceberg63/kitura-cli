#!/bin/bash
set -ex

export RELEASE=$1

function test_Darwin() {
    # Check that kitura init successfully produces a project
    ./darwin-amd64/kitura init -b -d TestProj
    rm -rf TestProj
}

function test_Linux() {
    # Check that kitura init successfully produces a project
    ./linux-amd64/usr/local/bin/kitura init -b -d TestProj
    rm -rf TestProj
}

case `uname` in
  Darwin)
    make build-darwin-test
    test_Darwin
    ;;
  Linux)
    make build-linux-test
    test_Linux
    ;;
  *)
    echo "Unsupported OS: `uname`"
    exit 1
esac
