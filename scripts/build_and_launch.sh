#!/usr/bin/env bash
set -euo pipefail

PROJECT="calnora.xcodeproj"
SCHEME="calnora"
CONFIGURATION="${CONFIGURATION:-Debug}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17 Pro}"
DERIVED_DATA="${DERIVED_DATA:-$PWD/build/DerivedData}"
SCREENSHOT_PATH="${SCREENSHOT_PATH:-$PWD/build/calnora-dashboard.png}"
SCREENSHOT_DELAY="${SCREENSHOT_DELAY:-2}"
BUNDLE_ID="com.gerardgomez.calnora"

mkdir -p "$DERIVED_DATA" "$(dirname "$SCREENSHOT_PATH")"

SIMULATOR_ID="$(
  xcrun simctl list devices available |
  sed -nE "/$SIMULATOR_NAME/s/.*\(([0-9A-Fa-f-]{36})\).*/\1/p" |
  head -n 1
)"

if [[ -z "$SIMULATOR_ID" ]]; then
  echo "Simulator not found: $SIMULATOR_NAME" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator/calnora.app"

if ! xcrun simctl bootstatus "$SIMULATOR_ID" -b >/dev/null 2>&1; then
  xcrun simctl boot "$SIMULATOR_ID"
  xcrun simctl bootstatus "$SIMULATOR_ID" -b >/dev/null
fi

xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"
sleep "$SCREENSHOT_DELAY"
xcrun simctl io "$SIMULATOR_ID" screenshot "$SCREENSHOT_PATH"

echo "Launched $BUNDLE_ID on $SIMULATOR_NAME ($SIMULATOR_ID)"
echo "Screenshot: $SCREENSHOT_PATH"
