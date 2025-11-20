//
//  ContentView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                SystemHeaderView(title: "ALAN // SIMULATION_ENV",
                                 statusText: "SYSTEM ONLINE",
                                 statusColor: .green)
                
                CodeEditorView()
                    .frame(maxHeight: .infinity)
                
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 2)
                
                SimulationView()
                    .frame(maxHeight: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

