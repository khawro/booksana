import SwiftUI
import WebKit

struct TitlePageView: View {
  let book: Book
  @StateObject private var vm = TitlePageViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showReader = false
  
  @StateObject private var reader = ReaderLoader()
    
  var body: some View {
    let bg = Color(hex: book.color_hex ?? "#173E68")  // fallback kolor

    ZStack {
      bg.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {

          // Okładka
          AsyncImage(url: URL(string: book.cover ?? "")) { phase in
            switch phase {
            case .success(let image):
              image.resizable().scaledToFill()
            default:
              Color.white.opacity(0.08)
            }
          }
          .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width - 64)
          .clipShape(RoundedRectangle(cornerRadius: 22))
          .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
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
      VStack {
        Spacer()
        if let url = normalizedURL(from: book.book_url) {
          Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            reader.load(url: url)                  // start preload
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
