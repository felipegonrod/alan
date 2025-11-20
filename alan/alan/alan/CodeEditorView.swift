//
//  CodeEditorView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct CodeEditorView: View {
    @State private var code: String = """
import mlx.core as mx

# ALAN Initialization
def main():
    print("Initializing system...")
    
    # Define tensor
    x = mx.array([1.0, 2.0, 3.0])
    
    print("Hello World")
    print(f"Tensor Status: {x}")

if __name__ == "__main__":
    main()
"""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            editorHeader
            editorBody
        }
    }
}

private extension CodeEditorView {
    var editorHeader: some View {
        HStack {
            Image(systemName: "terminal.fill")
                .font(.caption)
                .foregroundColor(Theme.accent)
            Text("SCRIPT_EDITOR.PY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.accent)
                .tracking(1.0)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.panelBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.border), alignment: .bottom)
    }
    
    var editorBody: some View {
        TextEditor(text: $code)
            .font(Theme.fontMono)
            .foregroundColor(Theme.text)
            .padding(8)
            .background(Theme.codeBackground)
            .scrollContentBackground(.hidden)
    }
}

