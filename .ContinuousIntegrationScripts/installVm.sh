#!/bin/bash

set -euo pipefail
VM_VERSION="201910110209"
BASE_VM_DOWNLOAD_PATH="https://bintray.com/opensmalltalk/vm/download_file?file_path="

echo "Installing VM $VM_VERSION for $TRAVIS_OS_NAME"

installVmLinux() {
  VM_FILENAME="squeak.cog.spur_linux64x64_$VM_VERSION"

  wget "$BASE_VM_DOWNLOAD_PATH$VM_FILENAME.tar.gz" -O vm
  wget "https://github.com/OpenSmalltalk/opensmalltalk-vm/releases/download/201901172323/squeak.cog.spur_linux64x64_201901172323.tar.gz" -O vm_plugins
  
  tar -xvzf vm
  tar -xvzf vm_plugins

  ls

  sqcogspur64linuxht/bin/squeak --version
}

installVmMacOS() {
  VM_FILENAME=" squeak.cog.spur_macos64x64_$VM_VERSION"

  wget "$BASE_VM_DOWNLOAD_PATH$VM_FILENAME.dmg" -O vm.dmg
  sudo hdiutil attach "$VM_FILENAME.dmg"
  cd "/Volumes/$VM_FILENAME"
  sudo cp -rf Squeak.app /Applications
}

case $TRAVIS_OS_NAME in
  "linux")
    installVmLinux ;;
  "osx")
    installVmMacOS ;;
esac
