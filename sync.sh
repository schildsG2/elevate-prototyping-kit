#!/bin/bash
# sync.sh — Sync components/elevate.css from @g2crowd/elevate npm package
#
# Usage:
#   ./sync.sh           — sync latest version
#   ./sync.sh 1.3.0     — sync specific version
#
# NOTE: As of v1.3.0, @g2crowd/elevate's dist/elevate.css only contains
# ~575 of the 1,003 elv-* utility classes in the current components/elevate.css.
# Run this script only when you have confirmed the new version has full
# utility parity with the existing file. Check with:
#   npm pack @g2crowd/elevate@VERSION && grep -c 'elv-' package/dist/elevate.css
#
set -euo pipefail

VERSION="${1:-latest}"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Fetching @g2crowd/elevate@${VERSION}..."
cd "$TMPDIR"
npm pack "@g2crowd/elevate@${VERSION}" --quiet
tar xzf g2crowd-elevate-*.tgz

NEW_LINES=$(wc -l < package/dist/elevate.css)
OLD_LINES=$(wc -l < "$SCRIPT_DIR/components/elevate.css")
echo "New: ${NEW_LINES} lines  |  Current: ${OLD_LINES} lines"

NEW_CLASSES=$(grep -c '^\.' package/dist/elevate.css || true)
OLD_CLASSES=$(grep -c '^\.' "$SCRIPT_DIR/components/elevate.css" || true)
echo "New selectors: ${NEW_CLASSES}  |  Current selectors: ${OLD_CLASSES}"

if [ "$NEW_CLASSES" -lt "$OLD_CLASSES" ]; then
  echo ""
  echo "WARNING: New dist has fewer selectors than current file."
  echo "This may indicate a utility class coverage regression."
  echo "Review before proceeding. Run with --force to override."
  if [ "${2:-}" != "--force" ]; then
    exit 1
  fi
fi

cp package/dist/elevate.css "$SCRIPT_DIR/components/elevate.css"
echo ""
echo "✓ Synced components/elevate.css from @g2crowd/elevate@${VERSION}"
