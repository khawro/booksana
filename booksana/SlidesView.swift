import SwiftUI
import AVKit
import Foundation

private struct ImageHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct SlidesView: View {
    let bookID: Int64
    let onClose: (() -> Void)?
    @State private var slides: [Slide] = []
    @State private var currentIndex: Int = 0
    @State private var isLoading = true
    @State private var imageHeight: CGFloat = 0
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss

    init(bookID: Int64, onClose: (() -> Void)? = nil) {
        self.bookID = bookID
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                Color.black
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            } else if slides.isEmpty {
                Color.black
                    .ignoresSafeArea()
                if !showErrorAlert {
                    Text("No slides available")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            } else {
                SlideLayerView(slide: slides[currentIndex])
                    .ignoresSafeArea()
                    .id(slides[currentIndex].id)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: currentIndex)
                .onPreferenceChange(ImageHeightKey.self) { imageHeight = $0 }
                .overlay(alignment: .top) {
                    // Progress bar centered at top
                    ProgressBar(progress: Double(currentIndex + 1) / Double(slides.count))
                        .frame(height: 4)
                        .padding(.top, 64)
                        .padding(.horizontal, 80)
                }
                .overlay(alignment: .topLeading) {
                    // X close button with glass effect
                    Button(action: {
                        onClose?()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                  
                            )
                    }
                    .padding(.top, 52)
                    .padding(.leading, 16)
                }

                // Tap areas left and right for navigation
                VStack {
                    // Top area excluded for close button
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 100) // Space for close button
                    
                    // Main navigation area
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentIndex > 0 {
                                    let target = currentIndex - 1
                                    // Prefetch image only (videos load on demand)
                                    if let url = slides[target].image_url {
                                        Task { _ = await ImageCache.shared.fetchIfNeeded(from: url) }
                                    }
                                    if let vurl = slides[target].video_mp4_url {
                                        Task { _ = await VideoCache.shared.fetchIfNeeded(from: vurl) }
                                    }
                                    DispatchQueue.main.async {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentIndex = target
                                        }
                                    }
                                }
                            }
                            .disabled(currentIndex == 0)
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentIndex < slides.count - 1 {
                                    let target = currentIndex + 1
                                    // Prefetch image only (videos load on demand)
                                    if let url = slides[target].image_url {
                                        Task { _ = await ImageCache.shared.fetchIfNeeded(from: url) }
                                    }
                                    if let vurl = slides[target].video_mp4_url {
                                        Task { _ = await VideoCache.shared.fetchIfNeeded(from: vurl) }
                                    }
                                    DispatchQueue.main.async {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            currentIndex = target
                                        }
                                    }
                                }
                            }
                            .disabled(currentIndex == slides.count - 1)
                    }
                    .frame(maxHeight: .infinity)
                }
                .ignoresSafeArea()
            }
        }
        .task {
            do {
                let fetchedSlides = try await SlidesService.shared.fetchSlides(bookID: Int(bookID))
                // keep data locally first
                slides = fetchedSlides
                currentIndex = 0
                // prefetch all images and videos before showing UI
                await prefetchImages(for: fetchedSlides)
                await prefetchVideos(for: fetchedSlides)
                withAnimation(.easeInOut(duration: 0.25)) {
                    isLoading = false
                }
            } catch {
                // Do not show demo slides; show an error popup instead
                #if DEBUG
                print("SlidesView: fetch error: \(error)")
                #endif
                withAnimation(.easeInOut(duration: 0.25)) {
                    isLoading = false
                }
                errorMessage = "Nie udało się wczytać slajdów. Spróbuj ponownie później."
                showErrorAlert = true
            }
        }
        .alert("Coś poszło nie tak", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Wystąpił nieoczekiwany błąd.")
        }
        .statusBarHidden(false)
    }
    
    private func color(from hex: String?) -> Color {
        guard let hex = hex else { return .white }
        #if canImport(UIKit)
        if let uiColor = UIColor(hex: hex) {
            return Color(uiColor)
        } else {
            return .white
        }
        #elseif canImport(AppKit)
        if let nsColor = NSColor(hex: hex) {
            return Color(nsColor)
        } else {
            return .white
        }
        #else
        // Fallback naive hex parsing #RRGGBB
        let r, g, b: Double
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hexString.count == 6 {
            let scanner = Scanner(string: hexString)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                r = Double((hexNumber & 0xFF0000) >> 16) / 255
                g = Double((hexNumber & 0x00FF00) >> 8) / 255
                b = Double(hexNumber & 0x0000FF) / 255
                return Color(red: r, green: g, blue: b)
            }
        }
        return .white
        #endif
    }
    
    private func textAlignment(from string: String?) -> TextAlignment {
        guard let string = string?.lowercased() else { return .leading }
        switch string {
        case "left":
            return .leading
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }
    
    private func alignment(from string: String?) -> Alignment {
        guard let string = string?.lowercased() else { return .leading }
        switch string {
        case "left":
            return .leading
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }
    
    private func prefetchImages(for slides: [Slide]) async {
        await withTaskGroup(of: Void.self) { group in
            for slide in slides {
                if let url = slide.image_url {
                    group.addTask {
                        _ = await ImageCache.shared.fetchIfNeeded(from: url)
                    }
                }
            }
        }
    }
    
    private func prefetchVideos(for slides: [Slide]) async {
        await withTaskGroup(of: Void.self) { group in
            for slide in slides {
                if let url = slide.video_mp4_url {
                    group.addTask {
                        _ = await VideoCache.shared.fetchIfNeeded(from: url)
                    }
                }
            }
        }
    }
}


struct CachedImageView: View {
    let url: URL
    let contentMode: ContentMode
    @State private var currentImage: UIImage?
    @State private var targetImage: UIImage?
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            if let img = currentImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .opacity(opacity)
            } else {
                Color.clear
            }
        }
        .task(id: url) {
            // show cached immediately if present
            if let cached = await ImageCache.shared.image(for: url) {
                currentImage = cached
                opacity = 1.0
            }
            // fetch (or refetch) and crossfade if new data arrives
            if let fetched = await ImageCache.shared.fetchIfNeeded(from: url) {
                if currentImage == nil {
                    currentImage = fetched
                    opacity = 1.0
                } else if currentImage !== fetched {
                    withAnimation(.easeInOut(duration: 0.25)) { opacity = 0.0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        currentImage = fetched
                        opacity = 1.0
                    }
                }
            }
        }
    }
}

struct CachedVideoView: View {
    let url: URL
    @StateObject private var playerManager = VideoPlayerManager()
    
    var body: some View {
        ZStack {
            if let player = playerManager.player {
                PlayerLayerView(player: player)
                    .aspectRatio(contentMode: .fill)
                    .opacity(playerManager.opacity)
            } else {
                Color.clear
            }
        }
        .onAppear {
            playerManager.setupPlayer(with: url)
        }
        .onDisappear {
            playerManager.cleanup()
        }
        .onChange(of: url) { _, newURL in
            playerManager.setupPlayer(with: newURL)
        }
    }
}

#if canImport(UIKit)
import UIKit

private final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer? {
        didSet {
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}

private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer
    func makeUIView(context: Context) -> PlayerContainerView {
        let v = PlayerContainerView()
        v.isUserInteractionEnabled = false // no controls
        v.player = player
        return v
    }
    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        if uiView.player !== player { uiView.player = player }
    }
}
#endif

class VideoPlayerManager: ObservableObject {
    @Published var opacity: Double = 0.0
    @Published var player: AVPlayer?
    
    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?
    private var endTimeObserver: NSObjectProtocol?
    
    func setupPlayer(with url: URL) {
        cleanup()
        Task { @MainActor in
            let resolvedURL: URL
            if let local = await VideoCache.shared.localURLIfExists(for: url) {
                resolvedURL = local
            } else if let fetched = await VideoCache.shared.fetchIfNeeded(from: url) {
                resolvedURL = fetched
            } else {
                resolvedURL = url
            }

            let item = AVPlayerItem(url: resolvedURL)
            let newPlayer = AVPlayer(playerItem: item)
            newPlayer.isMuted = true

            self.playerItem = item
            self.player = newPlayer
            self.opacity = 0.0

            self.statusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                DispatchQueue.main.async {
                    if item.status == .readyToPlay {
                        newPlayer.play()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self?.opacity = 1.0
                        }
                    }
                }
            }

            self.endTimeObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
        }
    }
    
    func cleanup() {
        player?.pause()
        statusObserver?.invalidate()
        statusObserver = nil
        
        if let observer = endTimeObserver {
            NotificationCenter.default.removeObserver(observer)
            endTimeObserver = nil
        }
        
        playerItem = nil
        player = nil
    }
    
    deinit {
        cleanup()
    }
}

private struct ProgressBar: View {
    let progress: Double // 0.0 ... 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(Color.white.opacity(0.3))
                Capsule()
                    .frame(width: max(0, min(CGFloat(progress) * geo.size.width, geo.size.width)))
                    .foregroundColor(Color.white)
            }
        }
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

private func slideColor(from hex: String?) -> Color {
    guard let hex = hex else { return .white }
    #if canImport(UIKit)
    if let uiColor = UIColor(hex: hex) { return Color(uiColor) } else { return .white }
    #elseif canImport(AppKit)
    if let nsColor = NSColor(hex: hex) { return Color(nsColor) } else { return .white }
    #else
    var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    if hexString.count == 6, let value = UInt64(hexString, radix: 16) {
        let r = Double((value & 0xFF0000) >> 16) / 255
        let g = Double((value & 0x00FF00) >> 8) / 255
        let b = Double(value & 0x0000FF) / 255
        return Color(red: r, green: g, blue: b)
    }
    return .white
    #endif
}

private func slideTextAlignment(from string: String?) -> TextAlignment {
    guard let s = string?.lowercased() else { return .leading }
    switch s { case "left": return .leading; case "center": return .center; case "right": return .trailing; default: return .leading }
}

private func slideAlignment(from string: String?) -> Alignment {
    guard let s = string?.lowercased() else { return .leading }
    switch s { case "left": return .leading; case "center": return .center; case "right": return .trailing; default: return .leading }
}

private struct SlideLayerView: View {
    let slide: Slide
    private var hasMedia: Bool { slide.video_mp4_url != nil || slide.image_url != nil }
    // Computed property to check if any text field is non-empty
    private var hasText: Bool {
        let fields = [slide.eyebrow, slide.title_1, slide.title_2, slide.lead, slide.body]
        return fields.contains { ($0?.isEmpty == false) }
    }
    
    private func normalizeNewlines(_ s: String) -> String {
        // Convert CRLF and CR to LF and replace literal \n with actual newlines
        return s
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\\n", with: "\n")
    }
    
    private func isListParagraph(_ paragraph: String) -> Bool {
        // Consider a paragraph a list if any non-empty line starts with -, *, or + followed by a space
        let lines = paragraph
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
        var foundBullet = false
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                foundBullet = true
            } else if foundBullet {
                // If we already saw a bullet and this line isn't a bullet, still treat as list (wrapped line)
                continue
            } else {
                return false
            }
        }
        return foundBullet
    }
    
    @ViewBuilder
    private func renderList(from paragraph: String) -> some View {
        let lines = paragraph
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
        let items: [String] = lines.compactMap { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                return String(trimmed.dropFirst(2))
            } else {
                // Continuation line for the previous bullet: keep it as-is prefixed with a space
                return " " + trimmed
            }
        }
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, rawItem in
                // Support simple inline markdown within list items
                let itemText: Text = {
                    if let attributed = try? AttributedString(markdown: rawItem) {
                        return Text(attributed)
                    } else {
                        return Text(rawItem)
                    }
                }()
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(slideColor(from: slide.content_color))
                    itemText
                        .font(.system(size: 17).weight(.regular))
                        .opacity(0.9)
                        .lineSpacing(5)
                }
                .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
            }
        }
        .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
    }

    @ViewBuilder
    private func textContent() -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                if let eyebrow = slide.eyebrow, !eyebrow.isEmpty {
                    Text(eyebrow.uppercased()).font(.system(size: 16).weight(.medium))
                        .kerning(1.6)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                }
                if let title1 = slide.title_1, !title1.isEmpty {
                    Text(title1).font(.custom("PPEditorialNew-Regular", size: 40)).multilineTextAlignment(.center)
                }
                if let title2 = slide.title_2, !title2.isEmpty {
                    Text(title2).font(.custom("PPEditorialNew-Regular", size: 30)).multilineTextAlignment(.center)
                       
                }
            }
            .foregroundColor(slideColor(from: slide.content_color))
            .frame(maxWidth: .infinity)

            VStack(spacing: 24) {
                if let lead = slide.lead, !lead.isEmpty {
                    Text(lead).font(.custom("PPEditorialNew-Regular", size: 24)).multilineTextAlignment(slideTextAlignment(from: slide.text_alignment))
                        .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
                }
                if let body = slide.body, !body.isEmpty {
                    let normalized = normalizeNewlines(body)
                    let paragraphs = normalized.components(separatedBy: "\n\n")
                    VStack(spacing: 20) {
                        ForEach(paragraphs.indices, id: \.self) { i in
                            let para = paragraphs[i]
                            if isListParagraph(para) {
                                renderList(from: para)
                            } else {
                                let paraWithHardBreaks = para.replacingOccurrences(of: "\n", with: "  \n")
                                if let attributed = try? AttributedString(markdown: paraWithHardBreaks) {
                                    Text(attributed)
                                        .font(.system(size: 17).weight(.regular))
                                        .opacity(0.9)
                                        .lineSpacing(5)
                                        .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
                                } else {
                                    Text(para)
                                        .font(.system(size: 17).weight(.regular))
                                        .opacity(0.9)
                                        .lineSpacing(5)
                                        .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
                }
            }
            .foregroundColor(slideColor(from: slide.content_color))
            .frame(maxWidth: .infinity, alignment: slideAlignment(from: slide.text_alignment))
            .padding(0)
            .multilineTextAlignment(slideTextAlignment(from: slide.text_alignment))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, hasText ? 48 : 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            if hasMedia {
                GeometryReader { geo in
                    if let videoURL = slide.video_mp4_url {
                        // Video takes priority over image
                        let videoView = CachedVideoView(url: videoURL)
                            .frame(width: UIScreen.main.bounds.width)
                        Group {
                            if hasText {
                                videoView
                                    .mask(
                                        VStack(spacing: 0) {
                                            Color.black
                                            LinearGradient(
                                                colors: [.black, .black.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: 150)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    )
                            } else {
                                videoView
                            }
                        }
                        .clipped()
                        .frame(width: UIScreen.main.bounds.width, height: geo.size.height, alignment: .top)
                        .preference(key: ImageHeightKey.self, value: geo.size.height)
                    } else if let imageURL = slide.image_url {
                        let imageView = CachedImageView(url: imageURL, contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width)
                        Group {
                            if hasText {
                                imageView
                                    .mask(
                                        VStack(spacing: 0) {
                                            Color.black
                                            LinearGradient(
                                                colors: [.black, .black.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: 150)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    )
                            } else {
                                imageView
                            }
                        }
                        .clipped()
                        .frame(width: UIScreen.main.bounds.width, height: geo.size.height, alignment: .top)
                        .preference(key: ImageHeightKey.self, value: geo.size.height)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .ignoresSafeArea()
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(minHeight: 128)

                if hasText {
                    ScrollView(showsIndicators: false) {
                        textContent()
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                // No image/video: center textual content vertically
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        textContent()
                            .frame(minHeight: geo.size.height, alignment: .center)
                            .padding(.top, 64)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .background((slide.background_color != nil ? slideColor(from: slide.background_color) : Color.black))
    }
}


#if canImport(UIKit)
import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hexString.count == 6 {
            var hexNumber: UInt64 = 0
            let scanner = Scanner(string: hexString)
            if scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                let b = CGFloat(hexNumber & 0x0000FF) / 255
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        return nil
    }
}
#endif

#if canImport(AppKit)
import AppKit

extension NSColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hexString.count == 6 {
            var hexNumber: UInt64 = 0
            let scanner = Scanner(string: hexString)
            if scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                let b = CGFloat(hexNumber & 0x0000FF) / 255
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        return nil
    }
}
#endif

#Preview {
    SlidesView(bookID: Int64(1))
}

