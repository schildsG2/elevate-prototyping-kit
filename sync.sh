#!/bin/bash
# sync.sh — Sync Elevate Prototyping Kit from upstream sources
#
# Usage:
#   ./sync.sh [VERSION]
#
#   VERSION (optional): @g2crowd/elevate npm version to sync from.
#                        Defaults to 'latest'.
#
# What this does:
#   1. CSS sync: pulls dist/elevate.css from @g2crowd/elevate npm package
#   2. Examples sync: pulls examples/ directory from g2crowd/elevate-g2 GitHub repo
#
# NOTE: As of @g2crowd/elevate v1.3.0, the npm dist contains ~575 of the
# ~1,003 elv-* utility classes used in this kit. The missing classes are
# primarily nav-shell and product-specific component classes defined in the
# templates' own <style> blocks — they are intentionally self-contained.
# The CSS swap proceeds regardless since examples require the npm dist classes.
# See: .sisyphus/evidence/task-1-parity-check.txt for the full analysis.
#
set -euo pipefail

VERSION="${1:-latest}"
TMPDIR=$(mktemp -d)
trap "rm -rf \"\$TMPDIR\"" EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Elevate Prototyping Kit Sync ==="
echo "CSS version : @g2crowd/elevate@${VERSION}"
echo "Examples    : g2crowd/elevate-g2 (latest main)"
echo ""

# ---------------------------------------------------------------
# PART 1: Sync components/elevate.css from npm dist
# ---------------------------------------------------------------
echo "→ Fetching @g2crowd/elevate@${VERSION}..."
cd "$TMPDIR"
npm pack "@g2crowd/elevate@${VERSION}" --quiet 2>/dev/null
tar xzf g2crowd-elevate-*.tgz

NEW_LINES=$(wc -l < package/dist/elevate.css | tr -d ' ')
OLD_LINES=$(wc -l < "$SCRIPT_DIR/components/elevate.css" | tr -d ' ')
NEW_CLASSES=$(grep -c '^\.' package/dist/elevate.css || true)
OLD_CLASSES=$(grep -c '^\.' "$SCRIPT_DIR/components/elevate.css" || true)

echo "  CSS lines  : ${OLD_LINES} → ${NEW_LINES}"
echo "  Selectors  : ${OLD_CLASSES} → ${NEW_CLASSES}"

if [ "$NEW_CLASSES" -lt "$OLD_CLASSES" ]; then
  echo "  NOTE: New dist has fewer selectors than current file."
  echo "  This is expected — see header comment for context."
fi

cp package/dist/elevate.css "$SCRIPT_DIR/components/elevate.css"
echo "  ✓ components/elevate.css synced"

# ---------------------------------------------------------------
# PART 2: Sync examples/ from g2crowd/elevate-g2 GitHub repo
# ---------------------------------------------------------------
echo ""
echo "→ Cloning g2crowd/elevate-g2 (shallow)..."
cd "$TMPDIR"
git clone --depth 1 --quiet https://github.com/g2crowd/elevate-g2.git elevate-g2-src

echo "→ Copying examples/..."
# Remove old examples dir if present, then copy fresh
rm -rf "$SCRIPT_DIR/examples"
cp -r elevate-g2-src/examples "$SCRIPT_DIR/examples"

# Remove token-editor dev tools (absolute-path dev-server artifacts)
rm -rf "$SCRIPT_DIR/examples/public"

echo "→ Applying path rewrites to examples/styles.css..."
# Rewrite the 3 import lines:
#   1. ../src/css/application.css → ../components/elevate.css  (point to kit CSS)
#   2. Remove vendor CSS imports   (already bundled in elevate.css dist)
sed -i '' \
  -e "s|^@import '../src/css/application.css';$|@import '../components/elevate.css';|" \
  -e "/^@import '..\/src\/css\/vendor\/select2.css';$/d" \
  -e "/^@import '..\/src\/css\/vendor\/choices.css';$/d" \
  "$SCRIPT_DIR/examples/styles.css"

echo "→ Stripping token-editor references from example HTML files..."
# Remove <link> tags pointing to /token-editor.css (absolute dev-server path)
# Remove <script> tags pointing to /token-editor.js (absolute dev-server path)
for f in "$SCRIPT_DIR/examples"/*.html; do
  sed -i '' \
    -e '/<link[^>]*\/token-editor\.css[^>]*>/d' \
    -e '/<script[^>]*\/token-editor\.js[^>]*><\/script>/d' \
    "$f"
done

# ---------------------------------------------------------------
# PART 3: Verify
# ---------------------------------------------------------------
echo ""
EXAMPLE_COUNT=$(ls "$SCRIPT_DIR/examples"/*.html 2>/dev/null | wc -l | tr -d ' ')
TOKEN_REFS=$(grep -r "token-editor" "$SCRIPT_DIR/examples/" 2>/dev/null | wc -l | tr -d ' ')
SRC_REFS=$(grep -r "src/css/application" "$SCRIPT_DIR/examples/" 2>/dev/null | wc -l | tr -d ' ')
KIT_IMPORT=$(grep -c "components/elevate.css" "$SCRIPT_DIR/examples/styles.css" || true)

echo "=== Sync Complete ==="
echo "  Examples        : ${EXAMPLE_COUNT} HTML files"
echo "  token-editor refs: ${TOKEN_REFS} (expected: 0)"
echo "  src/css refs    : ${SRC_REFS} (expected: 0)"
echo "  kit CSS import  : ${KIT_IMPORT} (expected: 1)"

if [ "$TOKEN_REFS" -gt 0 ] || [ "$SRC_REFS" -gt 0 ]; then
  echo ""
  echo "ERROR: Stale references remain after rewrite. Check sed rules."
  exit 1
fi

echo ""
echo "✓ Sync successful. Run git diff to review changes before committing."
