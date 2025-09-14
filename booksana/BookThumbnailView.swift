import SwiftUI

struct BookThumbnailView: View {
  let book: Book

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      AsyncImage(url: URL(string: book.cover ?? "")) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
        default:
          Image(systemName: "book")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.secondary)
        }
      }
      .frame(width: 158, height: 158)
      .background(Color.gray.opacity(0.2))
      .clipShape(RoundedRectangle(cornerRadius: 20))

      Text(book.title)
        .font(.subheadline)
        .foregroundStyle(.primary)
        .lineLimit(2)
    }
    .frame(width: 158, alignment: .leading)
  }
}
