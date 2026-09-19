import SwiftUI

/// Animates a grid sprite sheet the same way a shader would scroll UV
/// coordinates across an atlas: scale the whole image up so one cell
/// fills the view, offset to the target cell, clip the rest away.
struct SpriteSheetAnimationView: View {
    let imageName: String
    let columns: Int
    let rows: Int
    let frameCount: Int      // may be less than columns * rows if trailing cells are unused
    let frameDuration: Double // seconds per frame, e.g. 1.0/12.0 for 12fps

    var body: some View {
        TimelineView(.periodic(from: .now, by: frameDuration)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let safeFrameCount = max(frameCount, 1)
            let frame = Int(elapsed / frameDuration) % safeFrameCount
            frameView(frame)
        }
    }

    private func frameView(_ frame: Int) -> some View {
        let row = frame / columns
        let col = frame % columns

        return GeometryReader { geo in
            let cellWidth = geo.size.width
            let cellHeight = geo.size.height

            Image(imageName)
                .resizable()
                .frame(
                    width: cellWidth * CGFloat(columns),
                    height: cellHeight * CGFloat(rows)
                )
                .offset(
                    x: -CGFloat(col) * cellWidth,
                    y: -CGFloat(row) * cellHeight
                )
        }
        .clipped()
    }
}
