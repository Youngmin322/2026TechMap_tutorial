#!/usr/bin/env bash
set -euo pipefail

PROJECT="SolarSystemAtlas.xcodeproj"
SCHEME="SolarSystemAtlas"
CATALOG_PATH="SolarSystemAtlas90MinuteTutorial.docc"
DISPLAY_NAME="SolarSystemAtlas 90분 워크숍"
BUNDLE_IDENTIFIER="co.kr.youngmin.SolarSystemAtlas.ninety-minute.documentation"
HOSTING_BASE_PATH="${HOSTING_BASE_PATH:-2026TechMap_tutorial}"
OUTPUT_DIR="${OUTPUT_DIR:-docs}"
BUILD_DIR=".docc-90-minute-build"
DIAGNOSTICS_FILE="$BUILD_DIR/docc-diagnostics.json"

for directory in "$OUTPUT_DIR" "$BUILD_DIR"; do
  if [[ -z "$directory" || "$directory" == "/" || "$directory" == "." || "$directory" == ".." ]]; then
    echo "안전하지 않은 출력 경로입니다: $directory" >&2
    exit 1
  fi
done

rm -rf -- "$OUTPUT_DIR" "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=visionOS Simulator" \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  docbuild

xcrun docc convert "$CATALOG_PATH" \
  --fallback-display-name "$DISPLAY_NAME" \
  --fallback-bundle-identifier "$BUNDLE_IDENTIFIER" \
  --fallback-bundle-version "1.0.0" \
  --transform-for-static-hosting \
  --hosting-base-path "$HOSTING_BASE_PATH" \
  --analyze \
  --warnings-as-errors \
  --diagnostics-file "$DIAGNOSTICS_FILE" \
  --output-path "$OUTPUT_DIR"

touch "$OUTPUT_DIR/.nojekyll"

if [[ -n "$HOSTING_BASE_PATH" ]]; then
  SITE_ROOT="/$HOSTING_BASE_PATH/"
else
  SITE_ROOT="/"
fi
TUTORIAL_HOME="${SITE_ROOT}tutorials/solarsystematlas"

printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta name="viewport" content="width=device-width, initial-scale=1">' \
  "  <meta http-equiv=\"refresh\" content=\"0; url=$TUTORIAL_HOME\">" \
  '  <title>SolarSystemAtlas 90분 워크숍</title>' \
  '</head>' \
  "<body><a href=\"$TUTORIAL_HOME\">튜토리얼 열기</a></body>" \
  '</html>' > "$OUTPUT_DIR/404.html"

printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta http-equiv="refresh" content="0; url=./tutorials/solarsystematlas">' \
  '  <title>SolarSystemAtlas 90분 워크숍</title>' \
  '</head>' \
  '<body><a href="./tutorials/solarsystematlas">튜토리얼 열기</a></body>' \
  '</html>' > "$OUTPUT_DIR/index.html"

echo "완료: $OUTPUT_DIR/ 에 90분 DocC 사이트를 만들었습니다."
