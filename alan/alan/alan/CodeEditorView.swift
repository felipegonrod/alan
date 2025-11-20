//
//  CodeEditorView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct CodeEditorView: View {
    @Binding var code: String
    
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

#Preview {
    CodeEditorView(code: .constant(ScriptTemplates.jumpTrainer))
}

