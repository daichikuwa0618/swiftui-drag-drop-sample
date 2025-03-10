import SwiftUI

struct LineInfo: Identifiable, Equatable {
  let id = UUID()
  let bottomY: CGFloat
  let height: CGFloat
  
  static func == (lhs: LineInfo, rhs: LineInfo) -> Bool {
    abs(lhs.bottomY - rhs.bottomY) < 0.1 && abs(lhs.height - rhs.height) < 0.1
  }
}

struct WithUnderlineFlowLayout: Layout {
  var spacing: CGFloat = 8
  var lineSpacing: CGFloat = 4
  var onUpdateLines: @MainActor ([LineInfo]) -> Void

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    let containerWidth = proposal.width ?? .infinity
    let (size, lines) = flowLayout(
      subviews: subviews,
      containerWidth: containerWidth,
      spacing: spacing,
      lineSpacing: lineSpacing
    )
    Task { @MainActor in
      onUpdateLines(lines)
    }
    return size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
    let containerWidth = bounds.width
    let (_, positions, _) = flowLayoutCalculation(
      subviews: subviews,
      containerWidth: containerWidth,
      spacing: spacing,
      lineSpacing: lineSpacing
    )

    for (index, subview) in subviews.enumerated() {
      if index < positions.count {
        let position = positions[index]
        subview.place(
          at: CGPoint(
            x: position.x + bounds.minX,
            y: position.y + bounds.minY
          ),
          anchor: .topLeading,
          proposal: .unspecified
        )
      }
    }
  }

  private func flowLayout(
    subviews: Subviews,
    containerWidth: CGFloat,
    spacing: CGFloat,
    lineSpacing: CGFloat
  ) -> (CGSize, [LineInfo]) {
    let (size, _, lines) = flowLayoutCalculation(
      subviews: subviews,
      containerWidth: containerWidth,
      spacing: spacing,
      lineSpacing: lineSpacing
    )
    return (size, lines)
  }

  private func flowLayoutCalculation(
    subviews: Subviews,
    containerWidth: CGFloat,
    spacing: CGFloat,
    lineSpacing: CGFloat
  ) -> (CGSize, [CGPoint], [LineInfo]) {
    var viewPositions: [CGPoint] = []
    var lineInfos: [LineInfo] = []

    var currentX: CGFloat = 0
    var currentY: CGFloat = 0
    var maxWidth: CGFloat = 0
    var lineHeight: CGFloat = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)

      // 行の折り返し判定
      if currentX + size.width > containerWidth && currentX > 0 {
        // 現在の行の情報を記録
        let lineInfo = LineInfo(bottomY: currentY + lineHeight, height: lineHeight)
        lineInfos.append(lineInfo)

        // 次の行へ
        currentX = 0
        currentY += lineHeight + lineSpacing
        lineHeight = 0
      }

      // アイテムの位置を確定
      viewPositions.append(CGPoint(x: currentX, y: currentY))

      // 位置の更新
      currentX += size.width + spacing
      lineHeight = max(lineHeight, size.height)
      maxWidth = max(maxWidth, currentX - spacing)
    }

    // 最後の行の情報を記録（アイテムがある場合のみ）
    if lineHeight > 0 {
      let lineInfo = LineInfo(bottomY: currentY + lineHeight, height: lineHeight)
      if !lineInfos.contains(where: { $0 == lineInfo }) {
        lineInfos.append(lineInfo)
      }
    }

    let totalHeight = currentY + lineHeight
    let totalSize = CGSize(width: maxWidth, height: totalHeight)

    return (totalSize, viewPositions, lineInfos)
  }
}

struct WithUnderlineFlowLayoutView<Content: View, Line: View>: View {
  var spacing: CGFloat = 8
  var lineSpacing: CGFloat = 4
  var content: Content
  @State private var lineInfos: [LineInfo] = []
  var underlineBuilder: ([LineInfo]) -> Line

  init(
    spacing: CGFloat = 8,
    lineSpacing: CGFloat = 4,
    @ViewBuilder content: () -> Content,
    @ViewBuilder underlineBuilder: @escaping ([LineInfo]) -> Line
  ) {
    self.spacing = spacing
    self.lineSpacing = lineSpacing
    self.content = content()
    self.underlineBuilder = underlineBuilder
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      AnyLayout(
        WithUnderlineFlowLayout(
          spacing: spacing,
          lineSpacing: lineSpacing,
          onUpdateLines: { lines in
            self.lineInfos = lines
          }
        )
      ) {
        content
      }

      underlineBuilder(lineInfos)
    }
  }
}

extension View {
  func withUnderlines(
    spacing: CGFloat = 8,
    lineSpacing: CGFloat = 8,
    color: Color = .gray.opacity(0.3),
    lineWidth: CGFloat = 2
  ) -> some View {
    WithUnderlineFlowLayoutView(
      spacing: spacing,
      lineSpacing: lineSpacing,
      content: { self },
      underlineBuilder: { lines in
        ZStack {
          ForEach(lines) { line in
            Rectangle()
              .fill(color)
              .frame(height: lineWidth)
              .frame(maxWidth: .infinity)
              .offset(y: line.bottomY + lineSpacing / 2 - lineWidth / 2)
          }
        }
      }
    )
  }
}
