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

            if !featuredVM.books.isEmpty {
                FeaturedCarousel(books: featuredVM.books)
            } else if let book = featuredVM.books.first {
                FeaturedHeroView(book: book)
            } else if let err = featuredVM.errorText {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text(err).font(.footnote).multilineTextAlignment(.center)
                }
                .foregroundStyle(.red)
                .padding(.horizontal)
            } else {
                // skeleton dopasowany do hero
                SkeletonHero()
                    .frame(maxWidth: .infinity)
                    .frame(height: screenWidth + 198)
                    .redacted(reason: .placeholder)
                
            }
        
            VStack(alignment: .leading, spacing: 34) {
              // Wybrane
              VStack(alignment: .leading, spacing: 8) {
                Text("Wybrane")
                  .font(.custom("PPEditorialNew-Regular", size: 30))
                  .padding(.bottom, 8)
                  .padding(.horizontal, 16)
                
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
                  .padding(.horizontal, 16)
                }
              }

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
                      .padding(.bottom, 8)
                      .padding(.horizontal, 16)
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
            .padding(.bottom, 40)
        }
      }.ignoresSafeArea(edges: .top)
     /* .overlay(alignment: .top) {
        LinearGradient(
          gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 60)
        .ignoresSafeArea(edges: .top)
      }*/
      .sheet(item: $selectedBook) { book in
        TitlePageView(book: book)
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .task {
          await featuredVM.loadFeaturedList(limit: 3)   // NOWE
          await selectedVM.loadSelected()
          await categoriesVM.loadAll()
          
          // Cache all loaded books
          for book in featuredVM.books {
              BookCache.shared.cacheBook(book)
          }
          for book in selectedVM.books {
              BookCache.shared.cacheBook(book)
          }
          for (_, books) in categoriesVM.booksByCategory {
              for book in books {
                  BookCache.shared.cacheBook(book)
              }
          }
          
          // Prefetch all covers once (deduplicate by id without requiring Hashable)
          var uniqueByID: [Int64: Book] = [:]
          for b in featuredVM.books { uniqueByID[b.id] = b }
          for b in selectedVM.books { uniqueByID[b.id] = b }
          for list in categoriesVM.booksByCategory.values { for b in list { uniqueByID[b.id] = b } }
          await AppStartup.shared.prefetchIfNeeded(
              books: Array(uniqueByID.values),
              categories: categoriesVM.categories
          )
      }
    }
  }
}

// MARK: - Skeleton Helpers
private struct SkeletonHero: View {
  var body: some View {
    ZStack(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray.opacity(0.3))
      LinearGradient(colors: [.clear, .black.opacity(0), .black.opacity(1)], startPoint: .top, endPoint: .bottom)
        .frame(height: 500)
        .allowsHitTesting(false)
    }
  }
}

private struct SkeletonCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      RoundedRectangle(cornerRadius: 18)
        .fill(Color.gray.opacity(0.18))
        .frame(width: 158, height: 158)
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

// MARK: - CAROUSEL HERO

private struct FeaturedCarousel: View {
  let books: [Book]
  @State private var index = 0
  @State private var selectedBook: Book?
  let screenWidth = UIScreen.main.bounds.width
    
  var body: some View {
    VStack(spacing: 10) {
      // Slider
      TabView(selection: $index) {
        ForEach(Array(books.enumerated()), id: \.offset) { (i, book) in
          FeaturedHeroView(book: book)
            .tag(i)
            .contentShape(Rectangle())
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never)) // ukrywamy systemowe kropki
      .frame(height: screenWidth + 148)

      // Dots pod hero
      HStack(spacing: 8) {
        ForEach(0..<min(books.count, 3), id: \.self) { i in
          Circle()
            .fill(i == index ? Color.white : Color.white.opacity(0.35))
            .frame(width: i == index ? 8 : 6, height: i == index ? 8 : 6)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, 32)
      .animation(.easeInOut(duration: 0.2), value: index)
    }
    // Swipe zmienia indeks
    .onChange(of: books.count) { _, newValue in
      index = min(index, max(0, newValue - 1))
    }
  }
}

#Preview {
  ForYouView().preferredColorScheme(.dark)
}

