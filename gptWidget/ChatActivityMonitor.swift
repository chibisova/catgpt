import Foundation

/// Bridges the DOM-polling heuristic inside ChatWebView's JS to SwiftUI.
/// One instance is shared between ChatWebView (which writes to it) and
/// CharacterView (which reads it to pick idle vs. thinking artwork).
final class ChatActivityMonitor: ObservableObject {
    @Published var isGenerating: Bool = false
}
