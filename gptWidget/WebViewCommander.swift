import WebKit

/// ChatWebView owns the actual WKWebView instance (SwiftUI doesn't see it
/// directly). This gives sibling views — like a refresh button in the
/// header — a way to reach in and act on it.
final class WebViewCommander: ObservableObject {
    weak var webView: WKWebView?

    func attach(_ webView: WKWebView) {
        self.webView = webView
    }

    func reload() {
        webView?.reload()
    }
}
