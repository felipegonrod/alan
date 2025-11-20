//
//  SystemHeaderView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct SystemHeaderView: View {
    let title: String
    let statusText: String
    let statusColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.fontHeader)
                .foregroundColor(Theme.accent)
                .tracking(1.5)
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(statusText)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Theme.panelBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.border), alignment: .bottom)
    }
}

