import SwiftUI

struct FeaturedHeroView: View {
  private static var hasAnimatedFeaturedHeroSession = false
  let book: Book
  let screenWidth = UIScreen.main.bounds.width

  @State private var selectedBook: Book?
  @StateObject private var savedBooksManager = SavedBooksManager.shared
  @State private var showHero = false
  @State private var shouldAnimate = true
  private var isBookmarked: Bool {
    savedBooksManager.isBookmarked(book.id)
  }

  var body: some View {
    ZStack(alignment: .top) {
        
     // OKŁADKA
        if let urlString = book.cover, let url = URL(string: urlString) {
          CachedImageView(url: url, contentMode: .fill)
            .frame(width: screenWidth, height: screenWidth, alignment: .top)
            .clipped()
            .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
            .animation(shouldAnimate ? .easeOut(duration: 0.4) : .none, value: showHero)
        } else {
          Color.gray.opacity(0.3)
            .frame(width: screenWidth, height: screenWidth)
            .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
            .animation(shouldAnimate ? .easeOut(duration: 0.4) : .none, value: showHero)
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
          .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
          .animation(shouldAnimate ? .easeOut(duration: 0.35) : .none, value: showHero)

        Text(book.title ?? "")
          .font(.custom("PPEditorialNew-Regular", size: 34))
          .lineSpacing(2)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
          .layoutPriority(1)
          .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
          .offset(y: shouldAnimate ? (showHero ? 0 : 12) : 0)
          .animation(shouldAnimate ? .easeOut(duration: 0.45).delay(0.05) : .none, value: showHero)

        if let desc = book.description, !desc.isEmpty {
          Text(desc)
            .font(.callout.weight(.regular))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
            .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
            .offset(y: shouldAnimate ? (showHero ? 0 : 12) : 0)
            .animation(shouldAnimate ? .easeOut(duration: 0.45).delay(0.12) : .none, value: showHero)
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
        .opacity(shouldAnimate ? (showHero ? 1 : 0) : 1)
        .offset(y: shouldAnimate ? (showHero ? 0 : 12) : 0)
        .animation(shouldAnimate ? .easeOut(duration: 0.45).delay(0.18) : .none, value: showHero)
      })
      .padding(.horizontal, 32)
    }
    .onAppear {
      // Animate only once per app session (first visible hero)
      if !Self.hasAnimatedFeaturedHeroSession {
        shouldAnimate = true
        Self.hasAnimatedFeaturedHeroSession = true
      } else {
        shouldAnimate = false
      }
      // Move to the final state (animated if allowed, instant otherwise) on next runloop turn
      DispatchQueue.main.async {
        showHero = true
      }
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

