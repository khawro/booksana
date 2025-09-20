import SwiftUI
import WebKit

struct TitlePageView: View {
  let book: Book
  @StateObject private var vm = TitlePageViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showReader = false
  
  @StateObject private var reader = ReaderLoader()
  
  @State private var showSlides = false
  @State private var showUnavailableAlert = false
  
  @State private var isBookmarked: Bool = false
  @StateObject private var savedBooksManager = SavedBooksManager.shared
    
  var body: some View {
    let bg = Color(hex: book.color_hex ?? "#173E68")  // fallback kolor

    ZStack {
      bg.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {

          // Okładka + przycisk bookmark w prawym górnym rogu
          ZStack(alignment: .topTrailing) {
            CachedCoverView(urlString: book.cover)
              .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width - 64)
              .clipShape(RoundedRectangle(cornerRadius: 22))
              .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)

            Button {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              isBookmarked = savedBooksManager.toggleBookmark(for: book)
            } label: {
              Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
            }
            .padding(14)
          }
          .padding(.horizontal, 32)
          .padding(.top, 32)
          .padding(.bottom, 16)
          

          // Kategoria • Extra
          HStack(spacing: 8) {
            if let name = vm.categoryName, !name.isEmpty {
              Text(name.uppercased())
                .font(.caption.weight(.semibold)).opacity(0.8)
            }
            if (book.extrainfo ?? "").isEmpty == false {
              if vm.categoryName != nil { Text("•").font(.caption.weight(.semibold)).opacity(0.6) }
              Text((book.extrainfo ?? "").uppercased())
                .font(.caption.weight(.semibold)).opacity(0.8)
            
            }
          }
          .padding(.horizontal, 32)
          .foregroundStyle(.white.opacity(0.9))

          // Tytuł
          Text(book.title)
            .font(.custom("PPEditorialNew-Regular", size: 36))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)

          // Opis
          if let desc = book.description, !desc.isEmpty {
            Text(desc)
              .font(.callout)
              .foregroundStyle(.white.opacity(0.9))
              .padding(.horizontal, 32)
              .padding(.bottom, 64)
          }
        }
      }
      .task {
        isBookmarked = savedBooksManager.isBookmarked(book.id)
      }
      VStack {
        Spacer()
        if let url = normalizedURL(from: book.book_url) {
          Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            Task {
              let slides = await SlidesService.shared.fetchSlidesSafe(bookID: Int(book.id))
              if slides.isEmpty {
                showUnavailableAlert = true
              } else {
                showSlides = true
              }
            }
            // reader.load(url: url)                  // start preload (commented out)
          } label: {
            Group {
              if reader.isLoading || showReader {
                HStack(spacing: 8) {
                  ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.black)
                  Text("Wczytywanie…")
                }
              } else {
                Text("Rozpocznij")
              }
            }
            .font(.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white, in: Capsule())
          }
          .disabled(reader.isLoading || showReader)
          .padding(.horizontal, 32)
          .padding(.bottom, 8)
         
        } else {
          // Fallback – brak poprawnego URL
          Text("Rozpocznij")
            .font(.headline)
            .foregroundStyle(.black.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.5), in: Capsule())
            .padding(.horizontal, 32)
            .padding(.bottom, 8)
            .disabled(true)
        }
      }
    }
    .task {
      print("book.category =", String(describing: book.category))
      await vm.loadCategoryName(for: book.category)
      
      // Cache the book
      BookCache.shared.cacheBook(book)
    }
    .onChange(of: reader.isLoading) { _, newValue in
      if newValue == false, reader.webView != nil {
        withAnimation(.easeInOut(duration: 0.22)) {
          showReader = true
        }
      }
    }
    .fullScreenCover(isPresented: $showReader) {
      ZStack {
        if let wv = reader.webView {
          BookWebView(webView: wv, onClose: {
            withAnimation(.easeInOut(duration: 0.24)) {
            //  showReader = false
              dismiss()
            }
          })
          .ignoresSafeArea()
        } else {
          Color.black.ignoresSafeArea()
        }
      }
    }
    .onChange(of: showReader) { oldValue, newValue in
      if oldValue == true && newValue == false {
        withAnimation(.easeInOut(duration: 0.24)) {
          dismiss()
        }
      }
    }
    .fullScreenCover(isPresented: $showSlides) {
      SlidesView(bookID: book.id)
        .ignoresSafeArea()
    }
    .alert("Książka niedostępna", isPresented: $showUnavailableAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Ta książka jest aktualnie niedostępna.")
    }
    .navigationBarTitleDisplayMode(.inline)
  }

  private func normalizedURL(from raw: String?) -> URL? {
    guard var s = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
    // If scheme is missing, assume https
    if !(s.lowercased().hasPrefix("http://") || s.lowercased().hasPrefix("https://")) {
      s = "https://" + s
    }
    // Percent-encode if needed
    if let enc = s.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
       let u = URL(string: enc) {
      return u
    }
    return URL(string: s)
  }
}



#Preview {
  TitlePageView(book: Book(
    id: 1, title: "Zostań Stoikiem XXI wieku",
    description: "Życie bywa chaotyczne...",
    cover: "https://picsum.photos/600/600",
    featured: true, selected: true,
    extrainfo: "10 rozdziałów",
    book_url: "https://example.com",
    category: 1, color_hex: "#173E68"
  ))
}

