import SwiftUI

struct ForYouView: View {
  @StateObject private var featuredVM = FeaturedViewModel()
    @StateObject private var selectedVM = SelectedBooksViewModel()
    @StateObject private var categoriesVM = CategoriesViewModel()    // NOWE
    @State private var selectedBook: Book?
    
  var body: some View {
    NavigationStack {
      ScrollView {
          
        VStack(alignment: .leading, spacing: 16) {
          
        Text("Dla Ciebie")
            .font(.custom("PPEditorialNew-Regular", size: 40))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)

          Group {
            if let book = featuredVM.book {
              FeaturedHeroView(book: book)
                .padding(.horizontal)
            } else if let err = featuredVM.errorText {
              VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                Text(err).font(.footnote).multilineTextAlignment(.center)
              }
              .foregroundStyle(.red)
              .padding(.horizontal)
            } else {
              RoundedRectangle(cornerRadius: 28)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 420)
                .padding(.horizontal)
            }
          }
            
            Spacer()
                .frame(height: 8)
            
            // Wybrane sekcja
            VStack(alignment: .leading, spacing: 8) {
              Text("Wybrane")
                .font(.custom("PPEditorialNew-Regular", size: 30))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                  ForEach(selectedVM.books, id: \.id) { book in
                    Button {
                      Haptics.tap(.soft)
                      selectedBook = book
                    } label: {
                      BookThumbnailView(book: book)
                    }
                    .buttonStyle(.plain)
                  }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
              }
            }
            
            // Sekcje po kategoriach
    // Sekcje po kategoriach
    ForEach(categoriesVM.categories, id: \.id) { cat in
      if let books = categoriesVM.booksByCategory[cat.id], !books.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          Text(cat.category_name)
            .font(.custom("PPEditorialNew-Regular", size: 30))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
              ForEach(books, id: \.id) { book in
                Button {
                  Haptics.tap(.soft)
                  selectedBook = book
                } label: {
                  BookThumbnailView(book: book)
                }
                .buttonStyle(.plain)
              }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
          }
        }
      }
    }
            
            
            
        }
        .padding(.vertical)
        .padding(.bottom, 32)
      }
      .overlay(alignment: .top) {
        LinearGradient(
          gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 60)
        .ignoresSafeArea(edges: .top)
      }
      .sheet(item: $selectedBook) { book in
        TitlePageView(book: book)
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .task {
        await featuredVM.loadFeatured()
        await selectedVM.loadSelected()
          await categoriesVM.loadAll()
      }
    }
  }
}

#Preview {
  ForYouView().preferredColorScheme(.dark)
}
