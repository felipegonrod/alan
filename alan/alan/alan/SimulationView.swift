//
//  SimulationView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct SimulationView: View {
    @ObservedObject var viewModel: SimulationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            simulationHeader
            simulationViewport
        }
    }
}

private extension SimulationView {
    var simulationHeader: some View {
        HStack {
            Image(systemName: "cube.transparent")
                .font(.caption)
                .foregroundColor(Theme.accent)
            Text("VIEWPORT_01 // SIMULATION")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.accent)
                .tracking(1.0)
            Spacer()
            Text("Episode \(viewModel.episode)")
                .font(.caption2)
                .foregroundColor(Theme.accent)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.panelBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.border), alignment: .bottom)
    }
    
    var simulationViewport: some View {
        ZStack {
            Theme.codeBackground
            Canvas { context, size in
                drawGrid(in: context, size: size)
                drawGround(in: context, size: size)
                drawObstacles(in: context, size: size, obstacles: viewModel.obstacles)
                drawAgents(in: context, size: size, agents: viewModel.agents)
            }
            overlayStats
        }
        .clipped()
    }
    
    var overlayStats: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.infoMessage)
                .font(.caption2)
                .foregroundColor(.gray)
            ForEach(viewModel.agents) { agent in
                HStack {
                    Circle()
                        .fill(agent.color)
                        .frame(width: 6, height: 6)
                    Text(agent.name)
                        .font(.caption2)
                        .foregroundColor(Theme.text)
                    Text(String(format: "r=%.1f", agent.reward))
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(.gray)
                    Text(agent.displayText)
                        .font(.caption2)
                        .foregroundColor(agent.result == .success ? .green : (agent.result == .failure ? .red : .gray))
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func drawGrid(in context: GraphicsContext, size: CGSize) {
        let gridPath = Path { path in
            let step: CGFloat = 40
            for x in stride(from: 0, through: size.width, by: step) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: step) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
        context.stroke(gridPath, with: .color(Color.white.opacity(0.04)), lineWidth: 0.5)
    }
    
    func drawGround(in context: GraphicsContext, size: CGSize) {
        let groundY = size.height * 0.75
        let groundPath = Path { path in
            path.move(to: CGPoint(x: 0, y: groundY))
            path.addLine(to: CGPoint(x: size.width, y: groundY))
        }
        context.stroke(groundPath, with: .color(Theme.text.opacity(0.8)), lineWidth: 2)
    }
    
    func drawObstacles(in context: GraphicsContext, size: CGSize, obstacles: [SimulationViewModel.Obstacle]) {
        let groundY = size.height * 0.75
        for obstacle in obstacles {
            let rect = CGRect(
                x: obstacle.position * size.width,
                y: groundY - obstacle.height * size.height,
                width: obstacle.width * size.width,
                height: obstacle.height * size.height
            )
            var path = Path(rect)
            context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
            context.fill(path, with: .color(Color(red: 0.5, green: 0.5, blue: 0.6).opacity(0.5)))
        }
    }
    
    func drawAgents(in context: GraphicsContext, size: CGSize, agents: [SimulationViewModel.Agent]) {
        let groundY = size.height * 0.75
        let radius = size.height * 0.04
        for agent in agents {
            let x = agent.baseHorizontal * size.width
            let y = groundY - agent.verticalOffset * size.height
            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            let shadow = rect.offsetBy(dx: 4, dy: 4)
            context.fill(Path(ellipseIn: shadow), with: .color(.black.opacity(0.4)))
            context.fill(Path(ellipseIn: rect), with: .color(agent.color))
            context.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.6)), lineWidth: 1)
        }
    }
}

#Preview {
    SimulationView(viewModel: SimulationViewModel())
}

