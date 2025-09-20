import SwiftUI

struct SearchView: View {
  @StateObject private var latestVM = LatestBooksViewModel()
  @StateObject private var catsVM = CategoriesViewModel()
  @State private var selectedBook: Book?

  var body: some View {
    NavigationStack {
      ScrollView {
        // Main content (only when not offline)
        VStack(alignment: .leading, spacing: 16) {
          let isOffline = latestVM.books.isEmpty && catsVM.categories.isEmpty && (latestVM.errorText != nil)

          if !isOffline {
            // --- KATEGORIE ---
            Text("Szukaj")
              .font(.custom("PPEditorialNew-Regular", size: 40))
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.top, 32)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(alignment: .top, spacing: 16) {
                ForEach(catsVM.categories, id: \.id) { cat in
                  NavigationLink {
                    CategoryDetailView(category: cat)
                  } label: {
                    CategoryCardView(category: cat)
                  }
                }
              }
              .padding([.horizontal, .bottom], 16)
            }

            Text("Nowości")
              .font(.custom("PPEditorialNew-Regular", size: 30))
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(alignment: .top, spacing: 16) {
                ForEach(latestVM.books, id: \.id) { book in
                  Button {
                    Haptics.tap(.soft)
                    selectedBook = book
                  } label: {
                    BookThumbnailView(book: book)
                  }
                  .buttonStyle(.plain)
                }
              }
              .padding([.horizontal, .bottom], 16)
            }
          }
        }

        // Centered offline overlay
        if latestVM.books.isEmpty && catsVM.categories.isEmpty && (latestVM.errorText != nil) {
          OfflineStateView {
            Task {
              await latestVM.loadLatest()
              await catsVM.loadAll()
            }
          }
          .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height)
          .ignoresSafeArea(edges: .top)
        }
      }
      .if(latestVM.books.isEmpty && catsVM.categories.isEmpty && (latestVM.errorText != nil)) { view in
        view.ignoresSafeArea(edges: .top)
      }
      .sheet(item: $selectedBook) { book in
        TitlePageView(book: book)
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .task {
        await latestVM.loadLatest()
        await catsVM.loadAll()
        // Ensure startup prefetch runs if user lands here first
        await AppStartup.shared.prefetchIfNeeded(
          books: latestVM.books,
          categories: catsVM.categories
        )
      }
      .navigationTitle("") // duży własny nagłówek, bez tytułu w pasku
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

private extension View {
  @ViewBuilder
  func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition { transform(self) } else { self }
  }
}

#Preview {
  SearchView().preferredColorScheme(.dark)
}
