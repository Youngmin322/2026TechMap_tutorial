#!/usr/bin/env bash
set -euo pipefail

# GitHub Pages의 프로젝트 페이지라면 저장소 이름으로 바꾸거나,
# 실행할 때 HOSTING_BASE_PATH=저장소이름 ./build-docs.sh처럼 지정하세요.
PROJECT="SolarSystemAtlas.xcodeproj"
SCHEME="SolarSystemAtlas"
CATALOG_PATH="Sources/SolarSystemAtlas/SolarSystemAtlas.docc"
DISPLAY_NAME="SolarSystemAtlas"
BUNDLE_IDENTIFIER="co.kr.youngmin.SolarSystemAtlas.documentation"
HOSTING_BASE_PATH="${HOSTING_BASE_PATH:-SolarSystemAtlas}"
OUTPUT_DIR="${OUTPUT_DIR:-docs}"
BUILD_DIR=".docc-build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
BUILD_LOG="$BUILD_DIR/xcodebuild.log"

if [[ ! -d "$CATALOG_PATH" ]]; then
  echo "DocC 카탈로그를 찾을 수 없습니다: $CATALOG_PATH" >&2
  exit 1
fi

rm -rf "$OUTPUT_DIR" "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR" "$BUILD_DIR"

# Xcode가 심볼 그래프와 타깃 문서를 검사하도록 먼저 DocC 빌드를 실행합니다.
# 카탈로그를 Xcode 타깃에 추가한 경우 이 단계에서 .doccarchive도 생성됩니다.
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=visionOS Simulator" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  docbuild | tee "$BUILD_LOG"

# 튜토리얼 카탈로그를 정적 GitHub Pages 사이트로 변환합니다.
# fallback 값은 이 카탈로그를 Swift Package와 별도로도 변환할 수 있게 합니다.
xcrun docc convert "$CATALOG_PATH" \
  --fallback-display-name "$DISPLAY_NAME" \
  --fallback-bundle-identifier "$BUNDLE_IDENTIFIER" \
  --fallback-bundle-version "1.0.0" \
  --transform-for-static-hosting \
  --hosting-base-path "$HOSTING_BASE_PATH" \
  --output-path "$OUTPUT_DIR"

# GitHub Pages가 DocC의 정적 자산을 Jekyll 처리 없이 제공하도록 합니다.
touch "$OUTPUT_DIR/.nojekyll"

# 존재하지 않는 경로도 DocC 앱으로 되돌립니다.
printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta name="viewport" content="width=device-width, initial-scale=1">' \
  '  <meta http-equiv="refresh" content="0; url=./">' \
  '  <title>SolarSystemAtlas 문서</title>' \
  '</head>' \
  '<body>문서 홈으로 이동합니다.</body>' \
  '</html>' > "$OUTPUT_DIR/404.html"

# 저장소 루트로 접속했을 때 튜토리얼 첫 화면으로 이동합니다.
printf '%s\n' \
  '<!doctype html>' \
  '<html lang="ko">' \
  '<head>' \
  '  <meta charset="utf-8">' \
  '  <meta http-equiv="refresh" content="0; url=./tutorials/solarsystematlas">' \
  '  <title>SolarSystemAtlas 튜토리얼</title>' \
  '</head>' \
  '<body><a href="./tutorials/solarsystematlas">튜토리얼 열기</a></body>' \
  '</html>' > "$OUTPUT_DIR/index.html"

echo "완료: $OUTPUT_DIR/ 에 GitHub Pages용 DocC 사이트를 만들었습니다."
