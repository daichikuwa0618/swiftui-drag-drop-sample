//
//  DragDropButton.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

struct DragDropButton: View {
  let title: String

  private let cornerRadius: CGFloat = 8

  var body: some View {
    Text(title)
      .padding()
      .background {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(Color.gray.opacity(0.5), lineWidth: 2)
          .foregroundStyle(Color.gray.opacity(0.2))
      }
      .contentShape(RoundedRectangle(cornerRadius: 8))
      .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
  }
}

#Preview {
  DragDropButton(title: "私は")
}
