//
//  SimulationControlsView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct SimulationControlsView: View {
    @Binding var entityCount: Int
    let status: SimulationViewModel.Status
    let infoText: String
    let runAction: () -> Void
    let stopAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Entities", systemImage: "person.3.sequence")
                    .font(.caption)
                    .foregroundColor(Theme.accent)
                Stepper(value: $entityCount, in: 1...15) {
                    Text("\(entityCount) / 15")
                        .font(.subheadline)
                        .foregroundColor(Theme.text)
                }
                Spacer()
                Button(action: buttonAction) {
                    Label(status == .running ? "Stop Simulation" : "Run Simulation",
                          systemImage: status == .running ? "stop.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                Label(status.rawValue, systemImage: "waveform.path.ecg")
                    .font(.caption2)
                    .foregroundColor(status.color)
                Text(infoText)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .background(Theme.panelBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.border), alignment: .top)
    }
    
    private func buttonAction() {
        if status == .running {
            stopAction()
        } else {
            runAction()
        }
    }
}

#Preview {
    SimulationControlsView(entityCount: .constant(4),
                           status: .idle,
                           infoText: "Ready.",
                           runAction: {},
                           stopAction: {})
}

