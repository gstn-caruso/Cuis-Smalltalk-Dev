#!/bin/bash

set -euo pipefail

IMAGE_FILE="$(ls | grep 'Cuis5.0-[0-9]\+.image')"
IMAGE32_FILE="$(ls | grep 'Cuis5.0-[0-9]\+-32.image')"
PROCESSOR_TYPE="$(uname -m)"

INSTALL_UPDATES_SCRIPT="\
  Utilities classPool at: #AuthorName put: 'TravisCI'.
  Utilities classPool at: #AuthorInitials put: 'TCI'.
  ChangeSet installNewUpdates.\
  Smalltalk snapshot: true andQuit: true clearAllClassState: false.\
"

installUpdatesLinux() {
  case $PROCESSOR_TYPE in
  "x86_64")
    ./sqcogspur64linuxht/bin/squeak -vm-display-null "$IMAGE_FILE" -d "$INSTALL_UPDATES_SCRIPT" ;;
  "aarch64")
    ./sqcogspurlinuxhtRPi/bin/squeak -vm-display-null "$IMAGE32_FILE" -d "$INSTALL_UPDATES_SCRIPT" ;;
  esac
}

installUpdatesMacOS() {
  /Applications/Squeak.app/Contents/MacOS/Squeak -headless "$IMAGE_FILE" -d "$INSTALL_UPDATES_SCRIPT"
}

case $TRAVIS_OS_NAME in
  "linux")
    installUpdatesLinux ;;
  "osx")
    installUpdatesMacOS ;;
esac
