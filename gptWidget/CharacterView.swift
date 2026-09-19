import AppKit
import SwiftUI

struct CharacterView: View {
    @State private var isChatOpen = false
    @State private var isHovering = false
    @State private var hoverExitWorkItem: DispatchWorkItem?
    @StateObject private var activity = ChatActivityMonitor()

    var body: some View {
        HStack(alignment: .top, spacing: isChatOpen ? 10 : 0) {
            // --- Character ---
            // Priority order: thinking (while a reply streams) beats the
            // hover state machine beats plain idle. Thinking loops via
            // SpriteSheetAnimationView; hover enter/exit is a one-shot
            // transition, not a loop — see HoverTransitionView, which is
            // deliberately generic (not glasses-specific) so future
            // characters without glasses can reuse it with their own
            // enter/exit sheets. All sprite sheets live in Assets.xcassets
            // as plain static images; we crop frames ourselves.
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onHover { hovering in setHovering(hovering) }

                Group {
                    if activity.isGenerating {
                        SpriteSheetAnimationView(
                            imageName: "CharacterThinking",
                            columns: 8,
                            rows: 3,
                            frameCount: 24,
                            frameDuration: 1.0 / 12.0
                        )
                    } else {
                        HoverTransitionView(
                            isHovering: $isHovering,
                            idleImageName: "gptIcon",
                            enterImageName: "CharacterHoverEnter",
                            enterColumns: 2, enterRows: 1, enterFrameCount: 2,
                            exitImageName: "CharacterHoverExit",
                            exitColumns: 2, exitRows: 1, exitFrameCount: 2,
                            frameDuration: 1.0 / 5.0
                        )
                    }
                }
                .allowsHitTesting(false)
            }
            .frame(width: 100, height: 100)
            .shadow(radius: 6)
            .onTapGesture { isChatOpen.toggle() }
            .contextMenu {
                Button("Quit the app?") {
                    NSApplication.shared.terminate(nil)
                }
            }

            // Kept mounted at all times instead of conditionally inserted —
            // an `if isChatOpen { ... }` here would destroy and recreate
            // ChatWebView (and its WKWebView) every time you close and
            // reopen, resetting you to the ChatGPT homepage. Collapsing it
            // to zero size instead preserves the underlying web view and
            // whatever conversation you had open.
            ChatOverlayView(isOpen: $isChatOpen, activity: activity)
                .frame(
                    maxWidth: isChatOpen ? .infinity : 0,
                    maxHeight: isChatOpen ? .infinity : 0
                )
                .opacity(isChatOpen ? 1 : 0)
                .allowsHitTesting(isChatOpen)
                .clipped()
        }
        // Flexible instead of a fixed size — this is what actually lets
        // dragging the panel's edge reflow the content instead of just
        // cropping it. The panel window itself owns the real size.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Debounces hover-exit specifically. During the enter/exit sprite
    // animation, GeometryReader recomputing layout ~12x/sec can make
    // macOS misfire a phantom exit-then-reenter even though the cursor
    // never left — which was making both animations play back to back
    // every time. A real mouse-leave stays false for more than an
    // instant; a phantom flicker doesn't, so we wait briefly before
    // acting on "false" and cancel that wait if "true" arrives first.
    private func setHovering(_ hovering: Bool) {
        if hovering {
            hoverExitWorkItem?.cancel()
            hoverExitWorkItem = nil
            isHovering = true
        } else {
            let workItem = DispatchWorkItem { isHovering = false }
            hoverExitWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        }
    }
}
