#!/usr/bin/env bash
set -euo pipefail

PROJECT="SolarSystemAtlas.xcodeproj"
SCHEME="SolarSystemAtlas"
CATALOG_PATH="SolarSystemAtlasStepByStep.docc"
DISPLAY_NAME="SolarSystemAtlas"
BUNDLE_IDENTIFIER="co.kr.youngmin.SolarSystemAtlas.step-by-step.documentation"
HOSTING_BASE_PATH="${HOSTING_BASE_PATH:-2026TechMap_tutorial}"
OUTPUT_DIR="${OUTPUT_DIR:-docs}"
BUILD_DIR=".docc-step-by-step-build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
BUILD_LOG="$BUILD_DIR/xcodebuild.log"
DIAGNOSTICS_FILE="$BUILD_DIR/docc-diagnostics.json"

if [[ ! -d "$CATALOG_PATH" ]]; then
  echo "DocC 카탈로그를 찾을 수 없습니다: $CATALOG_PATH" >&2
  exit 1
fi

for directory in "$OUTPUT_DIR" "$BUILD_DIR"; do
  if [[ -z "$directory" || "$directory" == "/" || "$directory" == "." || "$directory" == ".." ]]; then
    echo "안전하지 않은 출력 경로입니다: $directory" >&2
    exit 1
  fi
done

if [[ "$OUTPUT_DIR" == "$BUILD_DIR" ]]; then
  echo "OUTPUT_DIR와 BUILD_DIR는 서로 달라야 합니다." >&2
  exit 1
fi

rm -rf -- "$OUTPUT_DIR" "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=visionOS Simulator" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  docbuild | tee "$BUILD_LOG"

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
DOCS_HOME="${SITE_ROOT}documentation/solarsystematlas"

printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta name="viewport" content="width=device-width, initial-scale=1">' \
  "  <meta http-equiv=\"refresh\" content=\"0; url=$DOCS_HOME\">" \
  '  <title>SolarSystemAtlas 단계별 문서</title>' \
  '</head>' \
  "<body><a href=\"$DOCS_HOME\">문서 홈으로 이동</a></body>" \
  '</html>' > "$OUTPUT_DIR/404.html"

printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta http-equiv="refresh" content="0; url=./documentation/solarsystematlas">' \
  '  <title>SolarSystemAtlas 단계별 문서</title>' \
  '</head>' \
  '<body><a href="./documentation/solarsystematlas">문서 열기</a></body>' \
  '</html>' > "$OUTPUT_DIR/index.html"

echo "완료: $OUTPUT_DIR/ 에 단계별 DocC 사이트를 만들었습니다."
