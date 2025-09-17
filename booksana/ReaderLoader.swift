import SwiftUI
import WebKit

final class ReaderLoader: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var isLoading: Bool = false
  @Published var webView: WKWebView?

  func load(url: URL) {
    // jeśli już ładujemy ten sam adres – nic nie rób
    if let wv = webView, wv.url == url { return }

    // konfiguracja webview
    let conf = WKWebViewConfiguration()
    conf.allowsInlineMediaPlayback = true

    let wv = WKWebView(frame: .zero, configuration: conf)
    wv.navigationDelegate = self
    wv.isOpaque = false
    wv.backgroundColor = .black
    wv.scrollView.backgroundColor = .black
    wv.scrollView.bounces = false

    self.webView = wv
    self.isLoading = true

    let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
    wv.load(req)
  }

  // MARK: - WKNavigationDelegate
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    isLoading = true
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    isLoading = false
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    isLoading = false
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    isLoading = false
  }
}
