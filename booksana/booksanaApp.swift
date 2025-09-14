import SwiftUI

@main
struct booksanaApp: App {
  var body: some Scene {
    WindowGroup {
      RootTabView()
        .preferredColorScheme(.dark)
        .tint(.white)
    }
  }
}
