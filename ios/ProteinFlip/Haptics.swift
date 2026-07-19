import UIKit

enum Haptics {
    private static let impact = UIImpactFeedbackGenerator(style: .medium)
    private static let tick = UIImpactFeedbackGenerator(style: .light)
    private static let notify = UINotificationFeedbackGenerator()

    static func prepare() {
        impact.prepare()
        tick.prepare()
        notify.prepare()
    }
    static func tap() { impact.impactOccurred() }
    static func tickSmall() { tick.impactOccurred(intensity: 0.8) }
    static func success() { notify.notificationOccurred(.success) }
    static func warning() { notify.notificationOccurred(.warning) }
}

