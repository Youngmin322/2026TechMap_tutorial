# RealityKit 장면 구현 가이드

SolarSystemAtlas가 서로 다른 크기의 USDZ를 정규화하고 공전 궤도와 입력 가능한 행성 장면을 만드는 방식을 살펴봅니다.

## Overview

### 에셋 크기 정규화

USDZ마다 원본 좌표와 크기가 다를 수 있습니다. `fittedModel(named:targetDiameter:)`는 `visualBounds`의 가장 큰 축을 기준으로 배율을 계산하고, 모델 중심을 컨테이너 원점으로 옮깁니다.

```swift
let bounds = source.visualBounds(relativeTo: source)
let largestDimension = max(
    bounds.extents.x,
    bounds.extents.y,
    bounds.extents.z
)
let scale = largestDimension > 0
    ? targetDiameter / largestDimension
    : 1

source.scale = SIMD3(repeating: scale)
source.position = -bounds.center * scale
```

모델 자체 대신 빈 컨테이너를 회전시키면 원본 피벗이 제각각이어도 앱이 정의한 중심을 기준으로 자전시킬 수 있습니다.

### 공전 좌표 계산

행성은 `cos(angle) * radius`로 가로 위치를, `sin(angle) * radius`로 깊이를 얻습니다. 앱은 궤도판을 살짝 기울여 깊이 변화가 높이에도 반영되도록 합니다.

```swift
let depth = sin(angle) * radius
return SIMD3(
    cos(angle) * radius,
    diameter / 2 - depth * sin(tabletopTilt),
    depth * cos(tabletopTilt)
)
```

실제 천문 거리 비율 대신 볼륨 안에서 읽기 좋은 값으로 압축합니다. `pointToMeter`는 `Planet`의 화면 친화적인 숫자를 RealityKit 미터 단위로 바꾸는 앱 내부 규칙입니다.

### 안정적인 시간 기반 애니메이션

누적 각도를 상태에 저장하지 않고 시작 시각 이후의 경과 시간으로 현재 진행률을 계산합니다.

```swift
private func cycleProgress(
    _ elapsedTime: TimeInterval,
    duration: TimeInterval
) -> Double {
    elapsedTime.truncatingRemainder(dividingBy: duration) / duration
}
```

뷰가 다시 평가되어도 같은 시각에는 같은 위치가 나오므로 공전과 자전이 불필요하게 튀지 않습니다. `duration`은 0보다 커야 하며, 새 데이터를 추가할 때 이 조건을 지켜야 합니다.

### 공간 입력 연결

행성 컨테이너에는 입력과 충돌 구성요소를 함께 추가합니다.

```swift
model.components.set(InputTargetComponent())
model.components.set(
    CollisionComponent(
        shapes: [.generateSphere(radius: diameter / 2)]
    )
)
model.components.set(HoverEffectComponent())
```

탭 결과가 USDZ 내부의 자식 엔티티일 수 있으므로, 현재 엔티티에서 부모 방향으로 올라가며 앱이 붙인 모델 이름을 찾습니다. 이 방식은 에셋 내부 계층이 달라도 선택 로직을 한곳에 유지합니다.

### SwiftUI attachment와 정보 카드

행성 이름 레이블은 `RealityView` attachment로 3D 장면 안에 놓고, 자세한 정보 카드는 바깥 `ZStack`에 둡니다. 레이블은 행성과 함께 움직여 맥락을 보존하고, 큰 카드는 사용자를 향한 안정적인 화면 방향을 유지합니다.

Spatial Layout 예제처럼 카드 자체가 행성과 함께 공전해야 한다면 <doc:03-PlanetInfoOverlay>의 `spatialOverlay` 방식을 사용할 수 있습니다. 완성 앱은 읽기 안정성을 우선해 두 방식을 혼합합니다.
