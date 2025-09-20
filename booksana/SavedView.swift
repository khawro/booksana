import SwiftUI

struct SavedView: View {
  @StateObject private var savedBooksManager = SavedBooksManager.shared
  @State private var selectedBook: Book?
  
  private let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
  ]
  
  var body: some View {
    NavigationStack {
      Group {
        if savedBooksManager.savedBooks.isEmpty && !savedBooksManager.isLoading {
          // Empty state
          VStack(spacing: 24) {
            Image(systemName: "bookmark")
              .font(.system(size: 60))
              .fontWeight(.thin)
              .opacity(0.5)
            Text("Brak zapisanych")
              .font(.custom("PPEditorialNew-Regular", size: 30))
            Text("Kliknij ikonkę zakładki na górze okładki aby zapisać.")
              .font(.subheadline)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
          .padding(.horizontal)
        } else {
          // Books grid
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              // Title inside scroll
              Text("Zapisane")
                .font(.custom("PPEditorialNew-Regular", size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 32)

              LazyVGrid(columns: columns, spacing: 16) {
                ForEach(savedBooksManager.savedBooks, id: \.id) { book in
                  Button {
                    Haptics.tap(.soft)
                    selectedBook = book
                  } label: {
                    ZStack(alignment: .bottomLeading) {
                      GeometryReader { geometry in
                        let size = geometry.size.width

                        CachedCoverView(urlString: book.cover)
                          .frame(width: size, height: size)
                          .background(Color.gray.opacity(0.2))
                          .clipShape(RoundedRectangle(cornerRadius: 20))
                      }
                      .aspectRatio(1, contentMode: .fit)

                      // Gradient overlay for readability
                      LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                      )
                      .frame(height: 70)
                      .frame(maxWidth: .infinity, alignment: .bottom)
                      .allowsHitTesting(false)
                 
                      // Title over image
                      Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .shadow(color: Color.black.opacity(0.7), radius: 3, x: 0, y: 1)
                        .padding(10)
                    }
                  }
                  .buttonStyle(.plain)
                }
              }
              .padding(.horizontal, 16)
              .padding(.bottom, 40)
            }
          }
          .refreshable {
            await savedBooksManager.refreshSavedBooks()
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .overlay {
        if savedBooksManager.isLoading {
          ProgressView("Ładowanie...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }
      }
      .sheet(item: $selectedBook) { book in
        TitlePageView(book: book)
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .task {
        await savedBooksManager.loadSavedBooks()
      }
    }
  }
}



#Preview {
  SavedView().preferredColorScheme(.dark)
}

