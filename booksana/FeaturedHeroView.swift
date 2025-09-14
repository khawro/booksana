import SwiftUI

struct FeaturedHeroView: View {
  let book: Book
  @State private var showTitlePage = false

  var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 32)
          .fill(Color(hex: book.color_hex ?? "#272727"))

      VStack(alignment: .center, spacing: 8) {
        AsyncImage(url: URL(string: book.cover ?? "")) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
          default:
            Image(systemName: "book.closed")
              .font(.system(size: 40))
              .frame(width: 220, height: 220)
              .foregroundStyle(.white.opacity(0.7))
          }
        }
        .frame(width: 220, height: 220)
        .clipped()
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        .padding(.bottom, 16)
          
        Text("POLECANA")
            .font(.footnote.weight(.bold))
            .kerning(0.4)
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.6))

        Text(book.title)
          .font(.title2.weight(.semibold))
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)
          .lineLimit(2)

        if let desc = book.description, !desc.isEmpty {
          Text(desc)
            .font(.subheadline.weight(.regular))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.bottom, 8)
        }

        Button {
          showTitlePage = true
        } label: {
          HStack(spacing: 8) {
            Image(systemName: "book.fill")
            Text("Czytaj")
                .font(.subheadline.weight(.semibold))
          }
          .padding(.horizontal, 18)
          .padding(.vertical, 10)
          .background(.white)
          .foregroundStyle(.black)
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
      }
      .padding(.horizontal, 32)
      .padding(.vertical, 24)
    }
    .frame(maxWidth: .infinity)
    .sheet(isPresented: $showTitlePage) {
      TitlePageView(book: book)
        .presentationDragIndicator(.visible)         // show grabber
        .presentationCornerRadius(32)                // nicer rounded corners
    }
  }
}
