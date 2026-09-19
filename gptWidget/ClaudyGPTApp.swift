import SwiftUI

@main
struct ClaudyGPTApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We deliberately don't use WindowGroup — it always gives you a
        // titled, activatable window. The floating panel is built by hand
        // in AppDelegate so we control style, level, and transparency.
        // This Settings scene just satisfies the App protocol.
        Settings {
            EmptyView()
        }
    }
}
