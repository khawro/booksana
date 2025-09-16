import SwiftUI

struct FeaturedHeroView: View {
  let book: Book
    let screenWidth = UIScreen.main.bounds.width

  @State private var selectedBook: Book?

  var body: some View {
    ZStack(alignment: .top) {
        
     // OKŁADKA
        AsyncImage(url: URL(string: book.cover ?? "")) { phase in
          switch phase {
          case .success(let image):
            image
                  .resizable()
                     .scaledToFill()
                     .clipped()
                     .frame(maxWidth: screenWidth, maxHeight: screenWidth, alignment: .top)
                     
          default:
            Color.gray.opacity(0.3)
              .frame(maxWidth: .infinity, maxHeight: screenWidth)
          }
        }
        
        
        // GRADIENT NA DOLE
        LinearGradient(
          gradient: Gradient(colors: [.clear, .black]),
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 200) // wysokość „nakładki” gradientu
        .frame(width: screenWidth, height: screenWidth, alignment: .bottom)
        .allowsHitTesting(false) // gradient nie blokuje kliknięć

        
      // TREŚĆ HERO
      VStack(alignment: .leading, spacing: 16) {
        Text("POLECANA")
          .font(.footnote.weight(.semibold))
          .kerning(1.1)
          .foregroundStyle(.secondary)

        Text(book.title ?? "")
          .font(.custom("PPEditorialNew-Regular", size: 36))
          .lineSpacing(3)
          .fixedSize(horizontal: false, vertical: true)

        if let desc = book.description, !desc.isEmpty {
          Text(desc)
            .font(.callout)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }

        Button {
          Haptics.tap(.soft)
          selectedBook = book
        } label: {
          Label("Czytaj", systemImage: "book")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.black)
        }
        .background(Color.white, in: Capsule())
      }
      .frame(maxWidth: .infinity)
      .padding(.top, screenWidth - 100)
      .padding(.horizontal, 16)
      .padding(.bottom, 40)
    }
    .frame(maxWidth: .infinity)
  
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
