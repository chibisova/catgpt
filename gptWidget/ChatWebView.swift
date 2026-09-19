import SwiftUI
import WebKit

struct ChatWebView: NSViewRepresentable {
    let activity: ChatActivityMonitor
    let commander: WebViewCommander
    let provider: AIProvider

    // Shared across instances so if you ever show more than one web view,
    // they don't spin up separate renderer processes.
    static let sharedProcessPool = WKProcessPool()

    // Heuristic, not an API: polls the DOM for the element the page's own
    // UI shows while streaming a reply (a "Stop generating" button). The
    // aria-label match is generic enough to often work across both
    // ChatGPT and Claude, but if switching providers stops updating the
    // character, inspect that page's stop button and adjust the selector.
    private static let activityPollingJS = """
    (function() {
      var lastState = null;
      setInterval(function() {
        var stopButton = document.querySelector('[data-testid="stop-button"]') ||
                          document.querySelector('button[aria-label*="Stop" i]');
        var isGenerating = !!stopButton;
        if (isGenerating !== lastState) {
          lastState = isGenerating;
          window.webkit.messageHandlers.chatState.postMessage(isGenerating);
        }
      }, 400);
    })();
    """

    func makeCoordinator() -> Coordinator {
        Coordinator(activity: activity)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        // .default() is the persistent, on-disk store — cookies and login
        // survive quitting and relaunching the app, same as a Safari tab.
        // Both providers share this store; each site only ever sees its
        // own cookies, same as two tabs in one browser.
        configuration.websiteDataStore = .default()
        configuration.processPool = Self.sharedProcessPool

        let script = WKUserScript(
            source: Self.activityPollingJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(context.coordinator, name: "chatState")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        // Some sites add friction for unrecognized user agents. A
        // standard desktop Safari UA avoids that.
        webView.customUserAgent =
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 " +
            "(KHTML, like Gecko) Version/17.4 Safari/605.1.15"

        webView.load(URLRequest(url: provider.url))
        context.coordinator.lastLoadedURL = provider.url
        commander.attach(webView)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // SwiftUI calls this on every re-render of the parent (e.g. every
        // time activity.isGenerating flips), not just when provider
        // actually changes. Compare against the last URL we loaded so we
        // only navigate when the person actually switched models —
        // otherwise this would reload the page dozens of times a minute.
        guard context.coordinator.lastLoadedURL != provider.url else { return }
        context.coordinator.lastLoadedURL = provider.url
        nsView.load(URLRequest(url: provider.url))
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        let activity: ChatActivityMonitor
        var lastLoadedURL: URL?

        init(activity: ChatActivityMonitor) {
            self.activity = activity
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let isGenerating = message.body as? Bool else { return }
            DispatchQueue.main.async {
                self.activity.isGenerating = isGenerating
            }
        }
    }
}
