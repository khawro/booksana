import SwiftUI

struct RootTabView: View {
  var body: some View {
    TabView {
      ForYouView()
        .tabItem { Label("Dla Ciebie", systemImage: "books.vertical.fill") }

      SearchView()
        .tabItem { Label("Szukaj", systemImage: "magnifyingglass") }

      SavedView()
        .tabItem { Label("Zapisane", systemImage: "bookmark") }
    }
  }
}

#Preview {
  RootTabView().preferredColorScheme(.dark)
}
