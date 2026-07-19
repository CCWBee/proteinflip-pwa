import SwiftUI

/// An animating split-flap style digit that flips from the previous value to
/// the new value using a 3D rotation effect. The digit is split into a top and
/// bottom half which rotate independently to mimic mechanical displays.
struct FlipDigit: View {
    /// The digit to display.
    let digit: Character
    /// Font size used to calculate the overall dimensions of the digit.
    let fontSize: CGFloat
    /// Desired width for the digit.
    let width: CGFloat

    // MARK: - Animation State

    /// Character shown on the top flap.
    @State private var topDigit: Character
    /// Character shown on the bottom flap.
    @State private var bottomDigit: Character
    /// Rotation for the top flap. `0` is resting, `-90` hides the flap.
    @State private var topRotation: Double = 0
    /// Rotation for the bottom flap. `0` is resting, `90` hides the flap.
    @State private var bottomRotation: Double = 0

    init(digit: Character, fontSize: CGFloat, width: CGFloat) {
        self.digit = digit
        self.fontSize = fontSize
        self.width = width
        _topDigit = State(initialValue: digit)
        _bottomDigit = State(initialValue: digit)
    }

    var body: some View {
        let height = fontSize * 1.2
        let half = height / 2

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.6))
                )

            VStack(spacing: 0) {
                // Top flap
                ZStack {
                    Rectangle().fill(Color(white: 0.16))
                    digitLayer(for: topDigit, clip: .top, color: .white)
                }
                .frame(height: half)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .frame(height: 1),
                    alignment: .bottom
                )
                .rotation3DEffect(
                    .degrees(topRotation),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom,
                    perspective: 0.6
                )

                // Bottom flap
                ZStack {
                    Rectangle().fill(Color(white: 0.14))
                    digitLayer(for: bottomDigit, clip: .bottom, color: .white.opacity(0.95))
                }
                .frame(height: half)
                .rotation3DEffect(
                    .degrees(bottomRotation),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .top,
                    perspective: 0.6
                )
            }
        }
        .frame(width: width, height: height)
        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 4)
        .accessibilityHidden(true)
        .onChange(of: digit) { newValue in
            // First half of the flip: rotate the top away.
            withAnimation(.easeIn(duration: 0.15)) {
                topRotation = -90
            }

            // Once the top flap has rotated out of sight, swap digits and
            // animate the bottom flap into view while resetting the top.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                topDigit = newValue
                bottomDigit = newValue
                bottomRotation = 90
                withAnimation(.easeOut(duration: 0.15)) {
                    topRotation = 0
                    bottomRotation = 0
                }
            }
        }
    }
}

private extension FlipDigit {
    /// Defines which half of the flap should be visible.
    enum ClipHalf {
        case top
        case bottom
    }

    /// Creates the text for a flap, masking it so only the requested half is visible.
    func digitLayer(for character: Character, clip: ClipHalf, color: Color) -> some View {
        let height = fontSize * 1.2
        let half = height / 2
        let alignment: Alignment = clip == .top ? .top : .bottom

        return Text(String(character))
            .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
            .foregroundStyle(color)
            .fixedSize()
            .frame(width: width, height: height)
            .mask(alignment: alignment) {
                Rectangle()
                    .frame(height: half)
            }
            .frame(width: width, height: half, alignment: alignment)
    }
}

/// Displays a numeric value using a series of ``FlipDigit`` views. When the
/// value changes the corresponding digits animate to the new representation.
struct SplitFlapCounter: View {
    /// Numeric value to display.
    let value: Int
    /// Base font size for the digits.
    let fontSize: CGFloat

    var body: some View {
        let digits = Array(String(value)).enumerated()
        let width = fontSize * 0.65

        return HStack(spacing: 6) {
            ForEach(Array(digits), id: \.offset) { _, ch in
                FlipDigit(digit: ch, fontSize: fontSize, width: width)
            }
            Text("g")
                .font(.system(size: fontSize * 0.6, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value) grams"))
    }
}

