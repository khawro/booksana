import SwiftUI

struct FeaturedHeroView: View {
  let book: Book
  let screenWidth = UIScreen.main.bounds.width

  @State private var selectedBook: Book?
  @StateObject private var savedBooksManager = SavedBooksManager.shared
  private var isBookmarked: Bool {
    savedBooksManager.isBookmarked(book.id)
  }

  var body: some View {
    ZStack(alignment: .top) {
        
     // OKŁADKA
        AsyncImage(url: URL(string: book.cover ?? ""), transaction: Transaction(animation: .none)) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
              .frame(width: screenWidth, height: screenWidth, alignment: .top)
              .clipped()
          default:
            Color.gray.opacity(0.3)
              .frame(width: screenWidth, height: screenWidth)
          }
        }
        
        
        // GRADIENT NA DOLE
        VStack(spacing: 0) {
         Spacer()
            
          LinearGradient(
            colors: [.clear, .black.opacity(1)],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: 160)
        }
        .frame(width: screenWidth, height: screenWidth)
        .allowsHitTesting(false) // gradient nie blokuje kliknięć

        
      // TREŚĆ HERO
    VStack(alignment: .center, spacing: 8, content: {
        
        Spacer()
        
        Text("POLECANA")
          .font(.footnote.weight(.bold))
          .kerning(1.05)
          .foregroundStyle(.primary)

        Text(book.title ?? "")
          .font(.custom("PPEditorialNew-Regular", size: 34))
          .lineSpacing(2)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
          .layoutPriority(1)

        if let desc = book.description, !desc.isEmpty {
          Text(desc)
            .font(.callout.weight(.regular))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
            .opacity(0.9)
        }

        HStack(spacing: 12) {
          // Czytaj button (not full-width)
          Button {
            Haptics.tap(.soft)
            selectedBook = book
          } label: {
            Label("Czytaj", systemImage: "book")
              .font(.headline)
              .foregroundColor(.black)
              .padding(.horizontal, 28)
              .padding(.vertical, 12)
              .background(Color.white, in: Capsule())
          }
          .buttonStyle(.plain)

          // Bookmark toggle button
          Button {
            Haptics.tap(.soft)
            _ = savedBooksManager.toggleBookmark(for: book)
          } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
              .font(.headline)
              .foregroundStyle(.white)
              .frame(width: 44, height: 44)
              .background(.ultraThinMaterial, in: Circle())
              .overlay(
                Circle().stroke(Color.white.opacity(0.35), lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
      })
      .padding(.horizontal, 32)
    }
  
    .sheet(item: $selectedBook) { b in
      TitlePageView(book: b)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }
  }
}


#Preview {
  ForYouView().preferredColorScheme(.dark)
}

