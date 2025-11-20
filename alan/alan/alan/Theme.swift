//
//  Theme.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct Theme {
    static let background = Color(hex: "121214")
    static let panelBackground = Color(hex: "1C1C1E")
    static let border = Color(hex: "3A3A3C")
    static let accent = Color(hex: "8E8E93")
    static let text = Color(hex: "E5E5E7")
    static let codeBackground = Color(hex: "0A0A0C")
    
    static let fontMono = Font.system(.body, design: .monospaced)
    static let fontHeader = Font.system(.headline, design: .default).weight(.bold)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

