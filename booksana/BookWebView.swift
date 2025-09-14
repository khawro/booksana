import SwiftUI
import WebKit

struct BookWebView: View {
  let url: URL

  var body: some View {
    ZStack {
      SimpleWebView(url: url)
        .ignoresSafeArea()
    }
  }
}

private struct SimpleWebView: UIViewRepresentable {
  let url: URL

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.backgroundColor = .systemBackground
    webView.isOpaque = true
    webView.allowsBackForwardNavigationGestures = true

    // Load once
    let request = URLRequest(url: url)
    webView.load(request)
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    // No-op: do not reload on state updates
  }
}
