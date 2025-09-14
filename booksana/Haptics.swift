import UIKit

enum Haptics {
  static func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let gen = UIImpactFeedbackGenerator(style: style)
    gen.prepare()
    gen.impactOccurred()
  }

  static func select() {
    let gen = UISelectionFeedbackGenerator()
    gen.prepare()
    gen.selectionChanged()
  }

  static func success() {
    let gen = UINotificationFeedbackGenerator()
    gen.prepare()
    gen.notificationOccurred(.success)
  }
}
