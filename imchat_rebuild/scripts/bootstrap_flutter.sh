#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter stable and retry." >&2
  exit 1
fi
flutter create --project-name imchat_rebuild --org com.imchat.rebuild --platforms=android .
flutter pub get
echo "Android platform scaffold generated. Next: flutter run"
