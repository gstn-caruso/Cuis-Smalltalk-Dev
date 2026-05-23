#!/usr/bin/env bash
set -euo pipefail

IMAGE_DIR="${1:-CuisImage}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CUIS_VM_BIN="${CUIS_VM:-${CUIS_VM_PATH:-}}"
CUIS_VM_OPTIONS="${CUIS_VM_ARGS:-${CUIS_VM_ARGUMENTS:-}}"

if [[ -z "$CUIS_VM_BIN" ]]; then
  echo "ERROR: set CUIS_VM or CUIS_VM_PATH before installing updates" >&2
  exit 1
fi

IMAGE_FILE="$(bash "$SCRIPT_DIR/find-cuis-image.sh" "$REPO_ROOT/$IMAGE_DIR")"

INSTALL_UPDATES_SCRIPT="
Utilities classPool at: #AuthorName put: 'GitHubActions'.
Utilities classPool at: #AuthorInitials put: 'GHA'.
ChangeSet installNewUpdates.
Smalltalk saveAndQuit.
"

VM_ARGS_ARRAY=()
if [[ -n "$CUIS_VM_OPTIONS" ]]; then
  read -r -a VM_ARGS_ARRAY <<< "$CUIS_VM_OPTIONS"
  "$CUIS_VM_BIN" "${VM_ARGS_ARRAY[@]}" "$REPO_ROOT/$IMAGE_DIR/$IMAGE_FILE" -d "$INSTALL_UPDATES_SCRIPT"
else
  "$CUIS_VM_BIN" "$REPO_ROOT/$IMAGE_DIR/$IMAGE_FILE" -d "$INSTALL_UPDATES_SCRIPT"
fi

# Rename image to the highest update number found in CoreUpdates/
LATEST_UPDATE=$(ls "$REPO_ROOT/CoreUpdates/"*.cs.st 2>/dev/null \
  | xargs -n1 basename \
  | grep -oE '^[0-9]+' \
  | sort -n \
  | tail -1 || true)

if [[ -n "$LATEST_UPDATE" && "$IMAGE_FILE" =~ ^(Cuis[0-9]+\.[0-9]+-)[0-9]+(\.image)$ ]]; then
  NEW_IMAGE_FILE="${BASH_REMATCH[1]}${LATEST_UPDATE}${BASH_REMATCH[2]}"
  if [[ "$NEW_IMAGE_FILE" != "$IMAGE_FILE" ]]; then
    mv "$REPO_ROOT/$IMAGE_DIR/$IMAGE_FILE" "$REPO_ROOT/$IMAGE_DIR/$NEW_IMAGE_FILE"
    OLD_CHANGES="${IMAGE_FILE%.image}.changes"
    NEW_CHANGES="${NEW_IMAGE_FILE%.image}.changes"
    [[ -f "$REPO_ROOT/$IMAGE_DIR/$OLD_CHANGES" ]] && \
      mv "$REPO_ROOT/$IMAGE_DIR/$OLD_CHANGES" "$REPO_ROOT/$IMAGE_DIR/$NEW_CHANGES"
    echo "Imagen renombrada: $IMAGE_FILE → $NEW_IMAGE_FILE"
  fi
fi
