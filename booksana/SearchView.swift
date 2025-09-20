import SwiftUI

struct SearchView: View {
  @StateObject private var latestVM = LatestBooksViewModel()
    @StateObject private var catsVM = CategoriesViewModel()
  @State private var selectedBook: Book?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            
            // --- KATEGORIE ---
            Text("Szukaj")
              .font(.custom("PPEditorialNew-Regular", size: 40))
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.top, 24)

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

          if let err = latestVM.errorText {
            Text(err)
              .font(.footnote)
              .foregroundStyle(.red)
              .padding(.horizontal, 16)
          }
        }
        .padding(.top, 8)
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

#Preview {
  SearchView().preferredColorScheme(.dark)
}
