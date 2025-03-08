//
//  DragDropButton.swift
//  DragDropSample
//
//  Created by Daichi Hayashi on 2025/03/07.
//

import SwiftUI

struct DragDropButton: View {
  let title: String
  var isDisabled: Bool = false
  var action: (() -> Void)? = nil

  private let cornerRadius: CGFloat = 8

  var body: some View {
    Button {
      action?()
    } label: {
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
    .buttonStyle(PlainButtonStyle())
    .disabled(isDisabled)
    .opacity(isDisabled ? 0.4 : 1.0)
  }
}

#Preview {
  VStack(spacing: 20) {
    DragDropButton(title: "タップ可能")

    DragDropButton(title: "無効化状態", isDisabled: true)
  }
  .padding()
}
