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
          .draggable(text) {
            DragDropButton(title: text)
              .onAppear {
                draggingItem = text
              }
          }
          .opacity(draggingItem == text ? 0.4 : 1.0)
          .dropDestination(for: String.self) { items, location in
            draggingItem = nil
            return true
          } isTargeted: { status in
            if let draggingItem, status, draggingItem != text {
              let sourceIndex = texts.firstIndex(of: draggingItem)!
              let targetIndex = texts.firstIndex(of: text)!
              texts.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: targetIndex)
            }
          }
          .animation(.default, value: texts)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
  }
}

#Preview {
  DragDropRow()
}
