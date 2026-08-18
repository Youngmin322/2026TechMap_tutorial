#!/usr/bin/env bash
set -euo pipefail

# 설정값: 필요에 맞게 수정하세요
SCHEME="SolarSystemAtlas"
DESTINATION="generic/platform=iOS"
PRODUCT_MODULE_NAME="SolarSystemAtlas"
HOSTING_BASE_PATH="SolarSystemAtlas-docs" # GitHub Pages 리포지토리명 또는 서브디렉토리명
OUTPUT_DIR="docs"
TMP_DIR=".docc-build"

rm -rf "$OUTPUT_DIR" "$TMP_DIR"
mkdir -p "$OUTPUT_DIR"

# 1) xcodebuild로 DocC 아카이브 생성
xcodebuild \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  docbuild \
  OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path $HOSTING_BASE_PATH" \
  | tee xcodebuild.log \
  | xcpretty || true

# DocC 아카이브 경로 찾기
ARCHIVE_PATH=$(grep -Eo "\/(DerivedData|Build)\/.+\.doccarchive" xcodebuild.log | tail -n 1)
if [[ -z "$ARCHIVE_PATH" ]]; then
  echo "DocC archive not found. Falling back to xcrun docc convert."
  ARCHIVE_PATH=""
fi

if [[ -n "$ARCHIVE_PATH" ]]; then
  echo "Found archive: $ARCHIVE_PATH"
  # 2) xcrun docc convert로 정적 사이트 출력
  xcrun docc convert "$ARCHIVE_PATH" \
    --transform-for-static-hosting \
    --hosting-base-path "$HOSTING_BASE_PATH" \
    --output-path "$OUTPUT_DIR"
else
  echo "Running direct conversion from .docc bundle"
  xcrun docc convert "Sources/$PRODUCT_MODULE_NAME/$PRODUCT_MODULE_NAME.docc" \
    --transform-for-static-hosting \
    --hosting-base-path "$HOSTING_BASE_PATH" \
    --output-path "$OUTPUT_DIR"
fi

# 3) GitHub Pages 호환 파일 추가
# Jekyll 비활성화
: > "$OUTPUT_DIR/.nojekyll"

# 404.html 생성 (간단 리다이렉트 안내)
cat > "$OUTPUT_DIR/404.html" <<'HTML'
<!DOCTYPE html>
<meta charset="utf-8">
<title>Page Not Found</title>
<p>문서 경로가 변경되었을 수 있어요. 상단 로고를 눌러 홈으로 이동해 주세요.</p>
HTML

# index.html 리다이렉트 (루트로 접근 시 메인 문서로 이동)
cat > "$OUTPUT_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=./documentation/solarsystematlas">
<link rel="canonical" href="./documentation/solarsystematlas">
<title>SolarSystemAtlas Docs</title>
HTML

echo "✅ DocC 정적 사이트가 '$OUTPUT_DIR' 폴더에 생성되었습니다."
