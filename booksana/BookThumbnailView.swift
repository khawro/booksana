import SwiftUI
import Foundation

struct BookThumbnailView: View {
  let book: Book

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ZStack {
        Color.clear
        CachedCoverView(urlString: book.cover)
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

struct CachedCoverView: View {
  let urlString: String?
  @State private var uiImage: UIImage?
  @State private var isLoading = false

  var body: some View {
    Group {
      if let uiImage {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      } else if isLoading {
        ProgressView()
          .progressViewStyle(.circular)
          .tint(.secondary)
      } else {
        Image(systemName: "book")
          .font(.largeTitle)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .foregroundStyle(.secondary)
      }
    }
    .task(id: urlString) {
      guard !isLoading else { return }
      isLoading = true
      defer { isLoading = false }
      guard let urlString, let url = URL(string: urlString) else { return }
      if let cached = await ImageCache.shared.image(for: url) {
        uiImage = cached
        return
      }
      if let fetched = await ImageCache.shared.fetchIfNeeded(from: url) {
        uiImage = fetched
      }
    }
  }
}
