//
//  DragDropRow.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

let initialWords = [
  Word(title: "です"),
  Word(title: "名前"),
  Word(title: "私"),
  Word(title: "は"),
  Word(title: "の"),
  Word(title: "山田太郎")
]
struct DragDropRow: View {
  @State private var topWords: [Word] = []
  @State private var bottomWords: [Word] = initialWords
  @State private var draggingItemID: UUID?
  @State private var draggingSource: DraggingSource?

  var body: some View {
    VStack(spacing: 20) {
      Button("Reset") {
        topWords = []
        bottomWords = initialWords
      }

      VStack(alignment: .leading) {
        Text("Selected - can Drag & Drop")
          .font(.caption)
          .foregroundColor(.gray)

        ZStack(alignment: .topLeading) {
          // 高さを確保するための不可視の View
          ForEach(bottomWords) { word in
            DragDropButton(title: word.title)
          }
          .withUnderlines()
          .opacity(0)

          if topWords.isEmpty {
            // 最初の 1 行だけ下線を表示するための View
            DragDropButton(title: "あ")
              .opacity(0)
              .withUnderlines()
          }

          ForEach(topWords) { word in
            DragDropButton(title: word.title) {
              moveWordToBottom(word)
            }
            .opacity(draggingItemID == word.id ? 0.3 : 1)
            .onDrag {
              draggingSource = .top
              return NSItemProvider(object: word.id.uuidString as NSString)
            } preview: {
              DragDropButton(title: word.title)
                .onAppear {
                  draggingItemID = word.id
                }
            }
            .onDrop(
              of: [.text],
              delegate: TopFlowDropDelegate(
                word: word,
                topWords: $topWords,
                bottomWords: $bottomWords,
                draggingItemID: $draggingItemID,
                draggingSource: $draggingSource
              )
            )
          }
          .withUnderlines()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
          Color.gray.opacity(0.1)
            .contentShape(Rectangle())
            .onDrop(of: [.text], delegate: TopFlowBackgroundDelegate(
              topWords: $topWords,
              bottomWords: $bottomWords,
              draggingItemID: $draggingItemID,
              draggingSource: $draggingSource
            ))
        }
        .cornerRadius(8)
        .animation(.default, value: topWords)
        .frame(minHeight: 120)
      }

      VStack(alignment: .leading) {
        Text("Initial - can't Drag & Drop")
          .font(.caption)
          .foregroundColor(.gray)

        ForEach(bottomWords) { word in
          if topWords.contains(where: { $0.id == word.id }) {
            DragDropButton(
              title: word.title,
              isDisabled: true
            ) {
              moveWordToTop(word)
            }
          } else {
            DragDropButton(title: word.title) {
              moveWordToTop(word)
            }
            .opacity(draggingItemID == word.id ? 0.3 : 1)
            .onDrag {
              draggingSource = .bottom
              return NSItemProvider(object: word.id.uuidString as NSString)
            } preview: {
              DragDropButton(title: word.title)
                .onAppear {
                  draggingItemID = word.id
                }
            }
          }
        }
        .withUnderlines(color: Color.clear)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .animation(.default, value: bottomWords)
        .animation(.default, value: topWords)
      }
    }
    .padding()
    .contentShape(Rectangle())
    .onDrop(of: [.text], delegate: BackgroundDropDelegate(
      draggingItemID: $draggingItemID, 
      draggingSource: $draggingSource
    ))
  }
  
  private func moveWordToTop(_ word: Word) {
    if !topWords.contains(where: { $0.id == word.id }) {
      topWords.append(word)
    }
  }
  
  private func moveWordToBottom(_ word: Word) {
    if let index = topWords.firstIndex(where: { $0.id == word.id }) {
      topWords.remove(at: index)
    }
  }
}

enum DraggingSource {
  case top
  case bottom
}

struct TopFlowDropDelegate: DropDelegate {
  let word: Word
  @Binding var topWords: [Word]
  @Binding var bottomWords: [Word]
  @Binding var draggingItemID: UUID?
  @Binding var draggingSource: DraggingSource?

  func dropEntered(info: DropInfo) {
    guard let draggingItemID, let draggingSource else { return }

    switch draggingSource {
    case .top:
      if draggingItemID != word.id {
        if let fromIndex = topWords.firstIndex(where: { $0.id == draggingItemID }),
           let toIndex = topWords.firstIndex(where: { $0.id == word.id }) {
          topWords.move(fromOffsets: IndexSet(integer: fromIndex),
                      toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
      }

    case .bottom:
      if let draggedItemIndex = bottomWords.firstIndex(where: { $0.id == draggingItemID }) {
        let draggedItem = bottomWords[draggedItemIndex]
        
        if !topWords.contains(where: { $0.id == draggedItem.id }) {
          topWords.append(draggedItem)

          if let toIndex = topWords.firstIndex(where: { $0.id == word.id }),
             let lastIndex = topWords.count > 0 ? topWords.count - 1 : nil {
            topWords.move(fromOffsets: IndexSet(integer: lastIndex),
                        toOffset: toIndex > lastIndex ? toIndex : toIndex)
          }
          self.draggingSource = .top
        }
      }
    }
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItemID = nil
    draggingSource = nil
    return true
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }
}

struct TopFlowBackgroundDelegate: DropDelegate {
  @Binding var topWords: [Word]
  @Binding var bottomWords: [Word]
  @Binding var draggingItemID: UUID?
  @Binding var draggingSource: DraggingSource?

  func dropEntered(info: DropInfo) {
    if draggingSource == .bottom,
       let draggedItemID = draggingItemID,
       let draggedItemIndex = bottomWords.firstIndex(where: { $0.id == draggedItemID }) {
      let draggedItem = bottomWords[draggedItemIndex]
      
      if !topWords.contains(where: { $0.id == draggedItem.id }) {
        topWords.append(draggedItem)
        draggingSource = .top
      }
    }
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItemID = nil
    draggingSource = nil
    return true
  }
}

struct BackgroundDropDelegate: DropDelegate {
  @Binding var draggingItemID: UUID?
  @Binding var draggingSource: DraggingSource?

  func dropUpdated(info: DropInfo) -> DropProposal? {
    DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    draggingItemID = nil
    draggingSource = nil
    return true
  }
}

#Preview {
  DragDropRow()
}
