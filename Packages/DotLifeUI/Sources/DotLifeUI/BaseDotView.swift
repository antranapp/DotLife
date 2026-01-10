import SwiftUI

/// A reusable dot component for visualizations.
/// This is the foundational building block used by DotView (time buckets) and YearDotView (year grid).
public struct BaseDotView: View {
    let size: CGFloat
    let fillColor: Color
    let fillOpacity: Double
    let ringColor: Color
    let ringWidth: CGFloat
    let glowColor: Color
    let isAnimating: Bool
    let animationDuration: Double
    let breathingMinScale: CGFloat
    let breathingMaxScale: CGFloat

    /// Breathing animation state
    @State private var isBreathing = false

    public init(
        size: CGFloat,
        fillColor: Color,
        fillOpacity: Double = 1.0,
        ringColor: Color = .clear,
        ringWidth: CGFloat = 0,
        glowColor: Color = .clear,
        isAnimating: Bool = false,
        animationDuration: Double = 2.0,
        breathingScale: CGFloat = 1.08,
        breathingMinScale: CGFloat? = nil,
        breathingMaxScale: CGFloat? = nil
    ) {
        self.size = size
        self.fillColor = fillColor
        self.fillOpacity = fillOpacity
        self.ringColor = ringColor
        self.ringWidth = ringWidth
        self.glowColor = glowColor
        self.isAnimating = isAnimating
        self.animationDuration = animationDuration
        // If min/max not specified, use legacy behavior (1.0 to breathingScale)
        self.breathingMinScale = breathingMinScale ?? 1.0
        self.breathingMaxScale = breathingMaxScale ?? breathingScale
    }

    public var body: some View {
        ZStack {
            // Breathing glow effect
            if isAnimating {
                Circle()
                    .fill(glowColor.opacity(0.2))
                    .frame(width: size * 2.0, height: size * 2.0)
                    .scaleEffect(isBreathing ? 1.0 : 0.6)
                    .opacity(isBreathing ? 0.0 : 0.8)
            }

            Circle()
                .fill(fillColor.opacity(fillOpacity))
                .overlay(
                    Circle()
                        .strokeBorder(ringColor, lineWidth: ringWidth)
                )
                .frame(width: size, height: size)
                .scaleEffect(isAnimating ? (isBreathing ? breathingMaxScale : breathingMinScale) : 1.0)
        }
        .onAppear {
            if isAnimating {
                startBreathingAnimation()
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startBreathingAnimation()
            } else {
                isBreathing = false
            }
        }
    }

    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: animationDuration)
                .repeatForever(autoreverses: true)
        ) {
            isBreathing = true
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct BaseDotView_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    // Empty dot
                    BaseDotView(
                        size: 32,
                        fillColor: .gray,
                        fillOpacity: 0.1
                    )

                    // Filled dot
                    BaseDotView(
                        size: 32,
                        fillColor: .blue,
                        fillOpacity: 0.85
                    )

                    // Multi-experience dot with ring
                    BaseDotView(
                        size: 32,
                        fillColor: .blue,
                        fillOpacity: 1.0,
                        ringColor: .blue.opacity(0.25),
                        ringWidth: 1.5
                    )
                }

                // Animated dot
                BaseDotView(
                    size: 40,
                    fillColor: .blue,
                    fillOpacity: 0.85,
                    glowColor: .blue,
                    isAnimating: true,
                    animationDuration: 3.0
                )
            }
            .padding()
        }
    }
#endif
