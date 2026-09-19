import SwiftUI

/// Same crop technique as SpriteSheetAnimationView (scale the atlas up,
/// offset to the target cell, clip the rest), but for a single frame you
/// pick explicitly rather than one driven by elapsed time. Used to hold
/// a frozen pose, or to be stepped frame-by-frame from outside.
struct StaticSpriteFrameView: View {
    let imageName: String
    let columns: Int
    let rows: Int
    let frameIndex: Int

    var body: some View {
        let row = frameIndex / columns
        let col = frameIndex % columns

        GeometryReader { geo in
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
