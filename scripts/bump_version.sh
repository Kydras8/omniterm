#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?Usage: bump_version.sh vX.Y.Z}"
case "$TAG" in v[0-9]*.[0-9]*.[0-9]*) ;; *) echo "Tag must look like v1.2.3"; exit 1 ;; esac
VER="${TAG#v}"

echo "[bump] Setting version to: $VER (from $TAG)"
# 1) Makefile DEB_VERSION
if grep -q "^DEB_VERSION ?=" Makefile; then
  sed -i "s/^DEB_VERSION ?=.*/DEB_VERSION ?= ${VER}/" Makefile
else
  echo "DEB_VERSION ?= ${VER}" >> Makefile
fi

# 2) debian/control Version:
if [ -f debian/control ]; then
  sed -i "s/^Version: .*/Version: ${VER}/" debian/control
else
  echo "[bump] ERROR: debian/control missing" >&2; exit 1
fi

# 3) launch_post.md (create or update title/version refs)
if [ ! -f launch_post.md ]; then
  printf "# Kydras OmniTerm — %s\n\n" "$TAG" > launch_post.md
  printf "Release notes for %s.\n" "$TAG" >> launch_post.md
else
  # update first header line to new tag
  awk -v tag="$TAG" 'NR==1{$0="# Kydras OmniTerm — " tag} {print}' launch_post.md > launch_post.md.tmp && mv launch_post.md.tmp launch_post.md
fi

# 4) Git commit
git add Makefile debian/control launch_post.md
git commit -m "[Kydras] Bump version to ${TAG}" || true
echo "[bump] Done."
