# 프로젝트 아키텍처

데이터, 3D 에셋, RealityKit 장면, SwiftUI 인터페이스가 연결되는 지점을 이해합니다.

![SolarSystemAtlas의 파일 구조와 런타임 데이터 흐름](realityview-architecture.svg)

## Overview

### 앱을 이루는 영역

| 영역 | 주요 파일 | 책임 |
| --- | --- | --- |
| 앱 진입점 | `SolarSystemAtlasApp.swift`, `ContentView.swift` | 볼륨 윈도우와 몰입 공간을 선언하고 첫 화면을 연결합니다. |
| 데이터 | `Models/Planet.swift` | 이름, 에셋 이름, 표시 크기, 공전·자전 값을 한곳에서 관리합니다. |
| 모델 표시 | `Views/PlanetModelView.swift` | `assetName`으로 RealityKitContent의 USDZ를 불러오고 로딩 상태를 표시합니다. |
| 학습용 장면 | `Views/SolarSystemView.swift` | `Model3D`와 Spatial Layout API로 태양과 행성을 단계적으로 배치합니다. |
| 완성 장면 | `Views/SolarSystemAtlasView.swift` | 엔티티를 만들고 위치·회전·선택 상태를 매 프레임 반영합니다. |
| 표시 UI | `PlanetInfoCard.swift`, RealityView attachments | 행성 레이블과 선택한 행성의 설명을 SwiftUI로 표시합니다. |

처음 실습할 때는 앱 그룹의 루트에 `SolarSystemAtlasApp.swift`와 `ContentView.swift`를 두고, `Models` 그룹에는 `Planet.swift`, `Views` 그룹에는 `PlanetModelView.swift`와 `SolarSystemView.swift`를 만듭니다. 파일 생성 창의 **Add to targets**에서 `SolarSystemAtlas`가 선택되어 있어야 앱이 코드를 컴파일합니다.

3D 파일은 `Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets`에 있습니다. `Planet.assetName`과 USDZ 파일의 기본 이름이 같아야 `Entity(named:in:)`과 `Model3D`가 에셋을 찾을 수 있습니다.

| USDZ 파일 | Swift에서 사용하는 이름 |
| --- | --- |
| `Sun.usdz` | `"Sun"` |
| `Mercury.usdz` | `"Mercury"` |
| `Venus.usdz` | `"Venus"` |
| `Earth.usdz` | `"Earth"` |
| `Mars.usdz` | `"Mars"` |
| `Jupiter.usdz` | `"Jupiter"` |
| `Saturn.usdz` | `"Saturn"` |
| `Uranus.usdz` | `"Uranus"` |
| `Neptune.usdz` | `"Neptune"` |

### 런타임 데이터 흐름

1. `Planet.starter`가 각 행성의 표시 크기와 애니메이션 주기를 제공합니다.
2. `RealityView`의 생성 클로저가 루트, 태양, 궤도, 행성, 레이블 엔티티를 한 번 구성합니다.
3. `TimelineView(.animation)`이 전달한 시각으로 공전·자전 진행률을 계산합니다.
4. `RealityView`의 update 클로저가 기존 엔티티의 위치, 방향, 선택 크기만 바꿉니다.
5. `SpatialTapGesture`가 탭한 엔티티 이름을 `Planet`으로 되돌리고 `selectedPlanet`을 갱신합니다.
6. 선택 상태가 바뀌면 SwiftUI 정보 카드와 RealityKit 모델 강조가 함께 바뀝니다.

생성과 갱신을 나누는 것이 핵심입니다. update 클로저에서 USDZ를 반복해서 불러오거나 엔티티를 계속 추가하면 프레임마다 중복 장면이 생길 수 있습니다.

### 두 렌더링 경로의 역할

`PlanetModelView`와 튜토리얼 스냅샷은 `Model3D`와 Spatial Layout API를 작은 단위로 실험하기 좋습니다. 완성 앱의 `SolarSystemAtlasView`는 궤도 메시, 충돌 영역, attachment처럼 엔티티 수준의 제어가 필요하므로 `RealityView`를 사용합니다.

둘 중 하나가 항상 우월한 것은 아닙니다. SwiftUI 레이아웃 학습과 간단한 3D 표시에는 `Model3D`, 여러 엔티티의 생명주기와 공간 입력을 직접 관리해야 하는 장면에는 `RealityView`가 적합합니다.

### 다음 단계

실제 장면이 만들어지고 움직이는 과정은 <doc:RealityKit-Scene-Guide>에서, 작은 SwiftUI 예제를 RealityKit으로 확장하는 실습은 <doc:04-RealityKitIntegration>에서 이어집니다.
