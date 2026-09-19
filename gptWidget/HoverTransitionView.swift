import SwiftUI

/// Same TimelineView technique as SpriteSheetAnimationView, applied to a
/// one-shot transition instead of a loop: frame = elapsed time since the
/// phase started, clamped instead of wrapped. No Timer is involved —
/// Timer.scheduledTimer doesn't reliably fire on the default run loop
/// while the mouse is being tracked on macOS, which is what caused the
/// entire enter+exit sequence to play in a burst regardless of how long
/// the cursor actually stayed put.
struct HoverTransitionView: View {
    @Binding var isHovering: Bool

    let idleImageName: String

    let enterImageName: String
    let enterColumns: Int
    let enterRows: Int
    let enterFrameCount: Int

    let exitImageName: String
    let exitColumns: Int
    let exitRows: Int
    let exitFrameCount: Int

    let frameDuration: Double

    private enum Phase {
        case idle                   // never hovered yet
        case entering(start: Date)  // hover is (or was) true; clamps and
                                     // holds on the last frame once done
        case exiting(start: Date)   // hover just turned false; clamps and
                                     // holds on its last frame, which
                                     // should already look like idle
    }

    @State private var phase: Phase = .idle

    var body: some View {
        Group {
            switch phase {
            case .idle:
                Image(idleImageName)
                    .resizable()
                    .scaledToFit()

            case .entering(let start):
                TimelineView(.periodic(from: .now, by: frameDuration)) { timeline in
                    let frame = clampedFrame(since: start, at: timeline.date, count: enterFrameCount)
                    StaticSpriteFrameView(
                        imageName: enterImageName, columns: enterColumns,
                        rows: enterRows, frameIndex: frame
                    )
                }

            case .exiting(let start):
                TimelineView(.periodic(from: .now, by: frameDuration)) { timeline in
                    let frame = clampedFrame(since: start, at: timeline.date, count: exitFrameCount)
                    StaticSpriteFrameView(
                        imageName: exitImageName, columns: exitColumns,
                        rows: exitRows, frameIndex: frame
                    )
                }
            }
        }
        .onAppear {
            // Fires whenever this view remounts — e.g. after the thinking
            // loop takes over and gives control back. Jump straight to
            // the right resting state instead of replaying a transition.
            phase = isHovering ? .entering(start: .distantPast) : .idle
        }
        .onChange(of: isHovering) { hovering in
            phase = hovering ? .entering(start: Date()) : .exiting(start: Date())
        }
    }

    private func clampedFrame(since start: Date, at now: Date, count: Int) -> Int {
        let elapsedFrames = Int(now.timeIntervalSince(start) / frameDuration)
        return min(max(elapsedFrames, 0), count - 1)
    }
}
