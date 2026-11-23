@State private var animationStartDate = Date()

var body: some View {
    TimelineView(.animation) { timeline in
        let elapsedTime = max(
            0,
            timeline.date.timeIntervalSince(animationStartDate)
        )

        RealityView { content in
            // 태양과 행성 엔티티를 한 번 생성합니다.
        } update: { content in
            // elapsedTime으로 기존 엔티티만 갱신합니다.
        }
    }
}
