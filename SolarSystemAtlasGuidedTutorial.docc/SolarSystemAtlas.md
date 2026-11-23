# SolarSystemAtlas

코드를 직접 입력하며 RealityKit 기반 visionOS 태양계 도감을 처음부터 완성합니다.

@Metadata {
    @TechnologyRoot
    @PageColor(blue)
}

![태양과 행성을 깊이감 있게 배치한 SolarSystemAtlas 개념도](spatial-layout-cover.svg)

## Overview

SolarSystemAtlas는 볼륨 윈도우 안에서 태양과 여덟 행성을 보여 주는 학습용 visionOS 앱입니다. 행성 데이터, USDZ 에셋, RealityKit 엔티티 장면, SwiftUI 정보 카드를 서로 분리해 공간 배치와 입력 흐름을 단계적으로 살펴볼 수 있습니다.

이 문서는 결과 코드를 먼저 제시하지 않습니다. 각 실습은 이전 체크포인트에서 시작해 파일을 만들고, 코드를 입력하고, 실행 결과를 확인하는 순서로 진행합니다.

- **프로젝트 뼈대**에서는 볼륨 윈도우, `Planet` 데이터, `Model3D` 로딩을 만듭니다.
- **태양계 장면**에서는 `RealityView`, 에셋 크기 정규화, 궤도, 시간 기반 애니메이션을 구현합니다.
- **도감 상호작용**에서는 attachment 레이블, `SpatialTapGesture`, 선택 상태, 정보 카드를 연결합니다.

튜토리얼의 코드는 각 단계에서 입력할 부분을 중심으로 보여 줍니다. 큰 최종 파일은 마지막 검토용 체크포인트에서만 제공합니다.

### 시작 전 확인

- Xcode 26 이상과 visionOS 26 SDK
- visionOS Simulator 또는 Apple Vision Pro
- `Packages/RealityKitContent` 패키지 안의 태양·행성 USDZ 에셋
- 볼륨 윈도우에서 모델이 잘리지 않을 만큼 충분한 기본 크기

처음이라면 <doc:01-PrepareVisionOSProject>부터 순서대로 진행하세요. 구조를 먼저 이해하고 싶다면 <doc:Project-Architecture>를 함께 참고할 수 있습니다.

## Topics

### 프로젝트 이해하기

- <doc:Project-Architecture>
- <doc:RealityKit-Scene-Guide>

### 단계별 실습

- <doc:01-PrepareVisionOSProject>
- <doc:02-CreatePlanetCatalog>
- <doc:03-BuildRealityViewScene>
- <doc:04-AddOrbitsAndAnimation>
- <doc:05-AddLabelsAndSelection>
- <doc:06-CompletePlanetInfoCard>

### 품질과 배포

- <doc:Testing-and-Troubleshooting>
- <doc:Publishing-DocC>
