import AppKit
import SwiftUI

// .nonactivatingPanel windows refuse to become key by default, which
// means text fields inside them never get keyboard focus. Overriding
// canBecomeKey is the standard fix for a floating panel that still
// needs to accept typing.
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: FloatingPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let hostingController = NSHostingController(rootView: CharacterView())

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 960, height: 700),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        panel.minSize = NSSize(width: 560, height: 520)

        panel.contentViewController = hostingController
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        if let screen = NSScreen.main {
            let visible = screen.visibleFrame
            let originX = visible.maxX - 1000
            let originY = visible.maxY - 740
            panel.setFrameOrigin(NSPoint(x: originX, y: originY))
        }

        panel.makeKeyAndOrderFront(nil)

        // Once you're happy with it, hide the Dock icon by adding
        // "Application is agent (UIElement)" = YES to Info.plist.
        // Leave it visible for now — much easier to Cmd+Q while prototyping.
    }
}
