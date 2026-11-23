private func cycleProgress(
    _ elapsedTime: TimeInterval,
    duration: TimeInterval
) -> Double {
    elapsedTime.truncatingRemainder(dividingBy: duration) / duration
}

private func rotation(radians: Float) -> simd_quatf {
    simd_quatf(angle: radians, axis: SIMD3(0, 1, 0))
}
