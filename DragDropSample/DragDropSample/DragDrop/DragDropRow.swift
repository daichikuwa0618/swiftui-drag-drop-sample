//
//  DragDropRow.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

struct DragDropRow: View {
  @State private var texts = ["です", "名前", "私", "は", "の", "山田太郎"]
  var body: some View {
    AnyLayout(FlowLayout()) {
      ForEach(texts, id: \.self) { text in
        DragDropButton(title: text)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
  }
}

#Preview {
  DragDropRow()
}
