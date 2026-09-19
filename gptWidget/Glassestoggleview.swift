import SwiftUI

/// Not a loop — a one-shot transition triggered by hover state:
///   hover starts -> plays offImageName forward once, holds its last frame
///   hover ends   -> plays onImageName forward once, then returns to idle
struct GlassesToggleView: View {
    @Binding var isHovering: Bool

    let idleImageName: String

    let offImageName: String
    let offColumns: Int
    let offRows: Int
    let offFrameCount: Int

    let onImageName: String
    let onColumns: Int
    let onRows: Int
    let onFrameCount: Int

    let frameDuration: Double

    @State private var activeSheet: ActiveSheet?
    @State private var frameIndex: Int = 0
    @State private var timer: Timer?

    private enum ActiveSheet {
        case off
        case on
    }

    var body: some View {
        Group {
            switch activeSheet {
            case .off:
                StaticSpriteFrameView(
                    imageName: offImageName, columns: offColumns,
                    rows: offRows, frameIndex: frameIndex
                )
            case .on:
                StaticSpriteFrameView(
                    imageName: onImageName, columns: onColumns,
                    rows: onRows, frameIndex: frameIndex
                )
            case nil:
                Image(idleImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            // This view gets torn down and remounted whenever the
            // thinking animation takes over (see CharacterView's
            // if/else) and then gives control back. If the mouse is
            // still hovering at that point, jump straight to the held
            // "glasses off" frame instead of replaying the transition.
            if isHovering {
                timer?.invalidate()
                activeSheet = .off
                frameIndex = offFrameCount - 1
            }
        }
        .onChange(of: isHovering) { hovering in
            hovering ? playOff() : playOn()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func playOff() {
        timer?.invalidate()
        activeSheet = .off
        frameIndex = 0
        var step = 0
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { t in
            step += 1
            if step >= offFrameCount {
                t.invalidate()
                frameIndex = offFrameCount - 1
            } else {
                frameIndex = step
            }
        }
    }

    private func playOn() {
        timer?.invalidate()
        activeSheet = .on
        frameIndex = 0
        var step = 0
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { t in
            step += 1
            if step >= onFrameCount {
                t.invalidate()
                activeSheet = nil
            } else {
                frameIndex = step
            }
        }
    }
}
