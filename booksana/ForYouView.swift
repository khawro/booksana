import SwiftUI

struct ForYouView: View {
  @StateObject private var featuredVM = FeaturedViewModel()
    @StateObject private var selectedVM = SelectedBooksViewModel()
    @StateObject private var categoriesVM = CategoriesViewModel()
    @State private var selectedBook: Book?
    let screenWidth = UIScreen.main.bounds.width
  var body: some View {
    NavigationStack {
      ScrollView {
          
        VStack(alignment: .leading) {
          
      /*  Text("Dla Ciebie")
            .font(.custom("PPEditorialNew-Regular", size: 40))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16) */

          Group() {
              if let book = featuredVM.book {
                FeaturedHeroView(book: book)   // <- nowy hero full-bleed
              } else if let err = featuredVM.errorText {
                // obsługa błędu
                VStack(spacing: 8) {
                  Image(systemName: "exclamationmark.triangle")
                  Text(err).font(.footnote).multilineTextAlignment(.center)
                }
                .foregroundStyle(.red)
                .padding(.horizontal)
              } else {
                // SKELETON HERO (dopasowany do hero)
                SkeletonHero()
                  .frame(maxWidth: .infinity)
                  .frame(height: screenWidth + 120)
                  .redacted(reason: .placeholder)
              }
            }
          

        
            
            VStack(alignment: .leading, spacing: 24) {
              // Wybrane
              VStack(alignment: .leading, spacing: 8) {
                Text("Wybrane")
                  .font(.custom("PPEditorialNew-Regular", size: 30))
                
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(alignment: .top, spacing: 16) {
                    if selectedVM.books.isEmpty {
                      SkeletonCarousel()
                        .redacted(reason: .placeholder)
                    } else {
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
                  }
                  .padding(.bottom, 8)
                }
              }

              // Sekcje po kategoriach
              ForEach(categoriesVM.categories, id: \.id) { cat in
                if let books = categoriesVM.booksByCategory[cat.id], !books.isEmpty {
                  VStack(alignment: .leading, spacing: 8) {
                    Text(cat.category_name)
                      .font(.custom("PPEditorialNew-Regular", size: 30))

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
                      .padding(.bottom, 8)
                    }
                  }
                } else {
                  // SKELETON dla kategorii w trakcie ładowania
                  VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                      .fill(Color.gray.opacity(0.2))
                      .frame(width: 160, height: 20)
                      .cornerRadius(6)
                      .redacted(reason: .placeholder)

                    ScrollView(.horizontal, showsIndicators: false) {
                      HStack(alignment: .top, spacing: 16) {
                        SkeletonCarousel()
                          .redacted(reason: .placeholder)
                      }
                      .padding(.bottom, 8)
                    }
                  }
                }
              }
            }
            .padding(.horizontal, 16)
        }
      }.ignoresSafeArea(edges: .top)
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

// MARK: - Skeleton Helpers
private struct SkeletonHero: View {
  var body: some View {
    ZStack(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray.opacity(0.18))
      LinearGradient(colors: [.clear, .black.opacity(0.15), .black.opacity(0.35)], startPoint: .top, endPoint: .bottom)
        .frame(height: 160)
        .allowsHitTesting(false)
    }
  }
}

private struct SkeletonCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      RoundedRectangle(cornerRadius: 18)
        .fill(Color.gray.opacity(0.18))
        .frame(width: 140, height: 200)
      RoundedRectangle(cornerRadius: 6)
        .fill(Color.gray.opacity(0.2))
        .frame(width: 120, height: 14)
      RoundedRectangle(cornerRadius: 6)
        .fill(Color.gray.opacity(0.2))
        .frame(width: 80, height: 12)
    }
  }
}

private struct SkeletonCarousel: View {
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      ForEach(0..<4) { _ in
        SkeletonCard()
      }
    }
  }
}

#Preview {
  ForYouView().preferredColorScheme(.dark)
}
