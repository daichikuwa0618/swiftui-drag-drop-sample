//
//  DragDropRow.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

struct DragDropRow: View {
  @State private var words: [Word] = [
    Word(title: "です"),
    Word(title: "名前"),
    Word(title: "私"),
    Word(title: "は"),
    Word(title: "の"),
    Word(title: "山田太郎")
  ]
  @State private var draggingItemID: UUID?

  var body: some View {
    AnyLayout(FlowLayout()) {
      ForEach(words, id: \.id) { word in
        DragDropButton(title: word.title)
          .opacity(draggingItemID == word.id ? 0.3 : 1)
          .onDrag {
            NSItemProvider(object: word.id.uuidString as NSString)
          } preview: {
            DragDropButton(title: word.title)
              .onAppear {
                draggingItemID = word.id
              }
          }
          .onDrop(
            of: [.text],
            delegate: MyDropDelegate(
              word: word,
              words: $words,
              draggingItemID: $draggingItemID
            )
          )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .animation(.default, value: words)
    // DragDropButton の外側で Drop されたときに選択状態を解除するために、親 View にも DropDelegate を仕込んでいる
    // contentShape が無いと Drop 判定が効かないので必要
    .contentShape(Rectangle())
    .onDrop(of: [.text], delegate: DropOutsideDelegate(draggingItemID: $draggingItemID))
  }
}

struct MyDropDelegate: DropDelegate {
  let word: Word
  @Binding var words: [Word]
  @Binding var draggingItemID: UUID?

  func dropEntered(info: DropInfo) {
    guard let draggedItemID = draggingItemID else { return }
    if draggedItemID != word.id {
      let from = words.firstIndex { $0.id == draggedItemID }!
      let to = words.firstIndex { $0.id == word.id }!
      words.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
    }
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItemID = nil
    return true
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }
}

struct DropOutsideDelegate: DropDelegate {
  @Binding var draggingItemID: UUID?

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItemID = nil
    return true
  }
}

#Preview {
  DragDropRow()
}
