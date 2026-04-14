#!/bin/bash
set -e

source ./projectConfig.sh

PROJECT_DIR="$(pwd)/.."
BUILD_DIR="$(pwd)/build_${ARCH_NAME}"

echo "=== Cleaning build ==="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "=== Running CMake ==="
cmake "$PROJECT_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=$ARCH_NAME \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$OS_TARGET \
  -DCMAKE_PREFIX_PATH="$(brew --prefix qt)"

echo "=== Building ==="
make -j$(sysctl -n hw.ncpu)

echo "=== Checking app ==="
if [ ! -d "QRookie.app" ]; then
  echo "ERROR: QRookie.app not found — build failed"
  exit 1
fi

echo "=== Deploying Qt dependencies ==="
macdeployqt QRookie.app

echo "=== Creating DMG ==="
cd ..
mkdir -p dist
hdiutil create dist/QRookie_${ARCH_NAME}.dmg \
  -volname "QRookie" \
  -srcfolder "$BUILD_DIR/QRookie.app" \
  -ov -format UDZO

echo "=== DONE ==="
