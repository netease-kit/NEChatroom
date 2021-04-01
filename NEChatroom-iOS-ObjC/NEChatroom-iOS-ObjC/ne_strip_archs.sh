#!/bin/sh

# Strip invalid architectures

strip_invalid_archs() {
binary="$1"
echo "current binary ${binary}"
# Get architectures for current file
archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)"
stripped=""
for arch in $archs; do
if ! [[ "${ARCHS}" == *"$arch"* ]]; then
if [ -f "$binary" ]; then
# Strip non-valid architectures in-place
lipo -remove "$arch" -output "$binary" "$binary" || exit 1
stripped="$stripped $arch"
fi
fi
done
if [[ "$stripped" ]]; then
echo "Stripped $binary of architectures:$stripped"
fi
}

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

strip_invalid_archs "$FRAMEWORK_EXECUTABLE_PATH"
done
