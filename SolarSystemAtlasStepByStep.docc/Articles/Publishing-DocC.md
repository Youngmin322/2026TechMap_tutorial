# DocC 빌드와 배포

카탈로그를 검증하고 GitHub Pages에서 열 수 있는 정적 사이트로 변환합니다.

## Overview

### 로컬 빌드

저장소 루트에서 다음 스크립트를 실행합니다.

```shell
./build-docs.sh
```

스크립트는 먼저 visionOS 앱 소스를 빌드해 예제의 기반 코드가 컴파일되는지 확인합니다. 이어서 `docc convert`를 경고 엄격 모드로 실행하고, 정적 호스팅용 결과를 `docs/`에 만듭니다.

기본 GitHub Pages 경로가 저장소 이름과 다르면 환경 값으로 지정합니다.

```shell
HOSTING_BASE_PATH=my-repository ./build-docs.sh
```

로컬 서버처럼 도메인 루트에서 확인할 때는 빈 경로를 사용할 수 있습니다.

```shell
HOSTING_BASE_PATH= ./build-docs.sh
```

### 생성 결과

- `docs/index.html`: 문서 학습 가이드로 이동하는 진입점
- `docs/documentation/`: 아키텍처, 구현, 테스트, 배포 문서
- `docs/tutorials/`: 단계별 실습과 코드 스냅샷
- `docs/.nojekyll`: GitHub Pages가 DocC 자산을 그대로 제공하도록 하는 표시
- `.docc-build/`: 앱 빌드 로그와 임시 DerivedData

`docs/`와 `.docc-build/`는 빌드 과정에서 다시 만들어집니다. 직접 편집한 내용은 다음 빌드에서 사라지므로 원본 카탈로그만 수정합니다.

### GitHub Pages 설정

저장소의 Pages 소스를 `main` 브랜치의 `/docs` 폴더로 지정합니다. 프로젝트 페이지 주소가 `https://example.github.io/SolarSystemAtlas/` 형태라면 기본 `HOSTING_BASE_PATH=SolarSystemAtlas`를 그대로 사용할 수 있습니다.

사이트가 빈 화면으로 보이면 먼저 `docs/metadata.json`의 base path와 실제 저장소 이름이 같은지 확인합니다. 대소문자까지 일치해야 이미지와 JavaScript 자산 경로가 올바르게 해석됩니다.

### 배포 전 확인

1. `build-docs.sh`가 종료 코드 0으로 끝나는지 확인합니다.
2. `docs/data` 아래에 네 개의 튜토리얼과 모든 문서 article JSON이 생성되었는지 확인합니다.
3. 학습 가이드에서 각 튜토리얼과 article로 이동해 끊어진 링크가 없는지 확인합니다.
4. 좁은 브라우저 폭에서도 표와 코드 블록을 읽을 수 있는지 확인합니다.
