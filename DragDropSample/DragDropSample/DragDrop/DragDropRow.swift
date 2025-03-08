//
//  DragDropRow.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

struct DragDropRow: View {
  @State private var texts = ["です", "名前", "私", "は", "の", "山田太郎"]
  @State private var draggingItem: String?

  var body: some View {
    AnyLayout(FlowLayout()) {
      ForEach(texts, id: \.self) { text in
        DragDropButton(title: text)
          .opacity(draggingItem == text ? 0.3 : 1)
          .onDrag {
            NSItemProvider(object: text as NSString)
          } preview: {
            DragDropButton(title: text)
              .onAppear {
                draggingItem = text
              }
          }
          .onDrop(
            of: [.text],
            delegate: MyDropDelegate(
              text: text,
              texts: $texts,
              draggingItem: $draggingItem
            )
          )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .animation(.default, value: texts)
    // DragDropButton の外側で Drop されたときに選択状態を解除するために、親 View にも DropDelegate を仕込んでいる
    // contentShape が無いと Drop 判定が効かないので必要
    .contentShape(Rectangle())
    .onDrop(of: [.text], delegate: DropOutsideDelegate(draggingItem: $draggingItem))
  }
}

struct MyDropDelegate: DropDelegate {
  let text: String
  @Binding var texts: [String]
  @Binding var draggingItem: String?

  func dropEntered(info: DropInfo) {
    guard let draggedItem = draggingItem else { return }
    if draggedItem != text {
      let from = texts.firstIndex(of: draggedItem)!
      let to = texts.firstIndex(of: text)!
      texts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
    }
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItem = nil
    return true
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }
}

struct DropOutsideDelegate: DropDelegate {
  @Binding var draggingItem: String?

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItem = nil
    return true
  }
}

#Preview {
  DragDropRow()
}
