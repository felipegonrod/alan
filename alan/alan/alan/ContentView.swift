//
//  ContentView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var simulationViewModel = SimulationViewModel()
    @State private var scriptText: String = ScriptTemplates.jumpTrainer
    @State private var entityCount: Int = 4
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                SystemHeaderView(title: "ALAN // SIMULATION_ENV",
                                 statusText: simulationViewModel.status.rawValue,
                                 statusColor: simulationViewModel.status.color)
                
                CodeEditorView(code: $scriptText)
                    .frame(maxHeight: .infinity)
                
                SimulationControlsView(entityCount: $entityCount,
                                       status: simulationViewModel.status,
                                       infoText: simulationViewModel.infoMessage,
                                       runAction: runSimulation,
                                       stopAction: simulationViewModel.stop)
                
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 2)
                
                SimulationView(viewModel: simulationViewModel)
                    .frame(maxHeight: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func runSimulation() {
        simulationViewModel.runSimulation(script: scriptText, entityCount: entityCount)
    }
}

#Preview {
    ContentView()
}

