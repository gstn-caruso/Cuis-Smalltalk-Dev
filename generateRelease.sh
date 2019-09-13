#!/bin/bash

set -euo pipefail

IMAGE_FILE="$(ls | grep 'Cuis5.0-[0-9]\+.image')"
CHANGES_FILE="$(ls | grep 'Cuis5.0-[0-9]\+.changes')"

mkdir release

cp -r sqcogspur64linuxht release/vm
cp -r Packages release
cp CuisV5.sources "$IMAGE_FILE" "$CHANGES_FILE" release

tar -czvf cuis-linux-x64.tar.gz -C release .
