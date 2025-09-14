import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = 0
    
  var body: some View {
    TabView(selection: $selectedTab) {
      ForYouView()
        .tabItem { Label("Dla Ciebie", systemImage: "books.vertical.fill") }
        .tag(0)

      SearchView()
        .tabItem { Label("Szukaj", systemImage: "magnifyingglass") }
        .tag(1)

      SavedView()
        .tabItem { Label("Zapisane", systemImage: "bookmark") }
        .tag(2)
    }
    .onChange(of: selectedTab) {
      Haptics.select()
    }
  }
}

#Preview {
  RootTabView().preferredColorScheme(.dark)
}
