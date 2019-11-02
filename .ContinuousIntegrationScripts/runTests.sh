#!/bin/bash

set -euo pipefail

IMAGE_FILE="$(ls | grep 'Cuis5.0-[0-9]\+.image')"
IMAGE32_FILE="$(ls | grep 'Cuis5.0-[0-9]\+-32.image')"
PROCESSOR_TYPE="$(uname -m)"
RUN_TESTS_SCRIPT_FILEPATH=".ContinuousIntegrationScripts/runTests.st"

runTestsOnLinux() {
  case $PROCESSOR_TYPE in
  "x86_64")
    sqcogspur64linuxht/bin/squeak -vm-display-null "$IMAGE_FILE" -s "$RUN_TESTS_SCRIPT_FILEPATH" ;;
  "aarch64")
    ./sqcogspurlinuxhtRPi/bin/squeak -vm-display-null "$IMAGE32_FILE" -s "$RUN_TESTS_SCRIPT_FILEPATH" ;;
  esac  
}

runTestsOnMacOS() {
  /Applications/Squeak.app/Contents/MacOS/Squeak -headless "$IMAGE_FILE" -s "$RUN_TESTS_SCRIPT_FILEPATH"
}

case $TRAVIS_OS_NAME in
  "linux")
    runTestsOnLinux ;;
  "osx")
    runTestsOnMacOS ;;
esac
