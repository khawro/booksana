import SwiftUI
import WebKit

struct BookWebView: View {
  let webView: WKWebView
  var onClose: (() -> Void)? = nil
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack(alignment: .topLeading) {
      WebViewContainer(webView: webView)
        .ignoresSafeArea()
        .onAppear {

          // Enable vertical bounce (rubber-banding)
          webView.scrollView.bounces = true
          webView.scrollView.alwaysBounceVertical = true
          webView.scrollView.alwaysBounceHorizontal = false
        }

      // przycisk zamknięcia
      Button {
        onClose?()   // inform parent to also close TitlePage or any parent sheet
      //  dismiss()    // then dismiss the reader overlay itself
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 14, weight: .semibold))
          .padding(12)
          .background(.ultraThinMaterial, in: Circle())
      }
      .padding(.top, 64)
      .padding(.leading, 16)
      .accessibilityLabel("Zamknij")
    }
  }
}

private struct WebViewContainer: UIViewRepresentable {
  let webView: WKWebView
  func makeUIView(context: Context) -> WKWebView { webView }
  func updateUIView(_ uiView: WKWebView, context: Context) {}
}
