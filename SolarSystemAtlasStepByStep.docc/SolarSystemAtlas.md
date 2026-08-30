# SolarSystemAtlas

SwiftUI Spatial Layout의 개념을 익히고 RealityKit 기반 visionOS 태양계 도감으로 확장합니다.

@Metadata {
    @TechnologyRoot
    @PageColor(blue)
}

![태양과 행성을 깊이감 있게 배치한 SolarSystemAtlas 개념도](spatial-layout-cover.svg)

## Overview

SolarSystemAtlas는 볼륨 윈도우 안에서 태양과 여덟 행성을 보여 주는 학습용 visionOS 앱입니다. 행성 데이터, USDZ 에셋, RealityKit 엔티티 장면, SwiftUI 정보 카드를 서로 분리해 공간 배치와 입력 흐름을 단계적으로 살펴볼 수 있습니다.

이 문서는 두 가지 학습 경로를 제공합니다.

- **Spatial Layout 경로**는 `depthAlignment`, `rotation3DLayout`, `SpatialContainer`, `spatialOverlay`를 작은 SwiftUI 예제로 익힙니다.
- **완성 앱 경로**는 같은 모델과 상태 흐름을 `RealityView`, attachment, `SpatialTapGesture`로 확장합니다.

튜토리얼의 `Tutorials/Resources` 코드는 단계별 학습을 위한 별도 스냅샷입니다. 실제 실행 앱의 최신 구현은 `SolarSystemAtlas/` 아래 소스를 기준으로 합니다.

### 시작 전 확인

- Xcode 26 이상과 visionOS 26 SDK
- visionOS Simulator 또는 Apple Vision Pro
- `Packages/RealityKitContent` 패키지 안의 태양·행성 USDZ 에셋
- 볼륨 윈도우에서 모델이 잘리지 않을 만큼 충분한 기본 크기

처음이라면 <doc:01-SpatialLayoutBasics>의 프로젝트 준비 단계부터 시작하세요. Xcode 그룹과 Swift 파일을 직접 만든 뒤 USDZ 연결을 확인하고 첫 장면을 실행합니다. 파일별 책임을 먼저 비교하고 싶다면 <doc:Project-Architecture>를 함께 참고하세요. 이미 앱 구조를 이해하고 있다면 <doc:04-RealityKitIntegration>으로 이동해 완성 장면을 살펴볼 수 있습니다.

## Topics

### 프로젝트 이해하기

- <doc:Project-Architecture>
- <doc:RealityKit-Scene-Guide>

### 단계별 실습

- <doc:01-SpatialLayoutBasics>
- <doc:02-PlanetRotation>
- <doc:03-PlanetInfoOverlay>
- <doc:04-RealityKitIntegration>

### 품질과 배포

- <doc:Testing-and-Troubleshooting>
- <doc:Publishing-DocC>
