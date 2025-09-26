import SwiftUI
import Foundation

struct BookThumbnailView: View {
  let book: Book

  var body: some View {
    let bg = Color(hex: book.color_hex ?? "#173E68")

    ZStack {
      // Card background uses the book color
      bg

      // Content stack: fixed 162x162 cover on top, title below with 0px spacing
      VStack(spacing: 0) {
        // Cover area strictly 162x162
        CachedCoverView(urlString: book.cover)
          .frame(width: 162, height: 162)
          .clipped()
          .mask(
            VStack(spacing: 0) {
              Color.black
              LinearGradient(
                colors: [.black, .black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
              )
              .frame(height: 72) // gradient mask height
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
          )

        // Title area
        Text(book.title)
          .font(.subheadline)
          .foregroundStyle(.white)
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, alignment: .center)
          .frame(height: 40, alignment: .center)
          .padding(.horizontal, 16)
          .offset(y: -12)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    .frame(width: 162, height: 206, alignment: .top)
    .clipShape(RoundedRectangle(cornerRadius: 24))
    /* .overlay(alignment: .top) { // gradient from top
      LinearGradient(
        colors: [Color.white.opacity(0.025), Color.white.opacity(0.0)],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 84)
      .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    .overlay( // transparent border
      RoundedRectangle(cornerRadius: 24)
        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
    ) */
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

