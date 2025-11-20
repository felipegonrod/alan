//
//  SimulationView.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI

struct SimulationView: View {
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
            Text("60 FPS")
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
                drawUnit(in: context, size: size)
            }
        }
        .clipped()
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
        context.stroke(gridPath, with: .color(Color.white.opacity(0.05)), lineWidth: 0.5)
    }
    
    func drawGround(in context: GraphicsContext, size: CGSize) {
        let groundY = size.height * 0.75
        let groundPath = Path { path in
            path.move(to: CGPoint(x: 0, y: groundY))
            path.addLine(to: CGPoint(x: size.width, y: groundY))
        }
        context.stroke(groundPath, with: .color(Theme.text.opacity(0.8)), lineWidth: 2)
    }
    
    func drawUnit(in context: GraphicsContext, size: CGSize) {
        let circleSize: CGFloat = 50
        let groundY = size.height * 0.75
        let circleOrigin = CGPoint(x: size.width / 2 - circleSize / 2,
                                   y: groundY - circleSize)
        let circleRect = CGRect(origin: circleOrigin,
                                size: CGSize(width: circleSize, height: circleSize))
        
        let shadowRect = circleRect.offsetBy(dx: 4, dy: 4)
        context.fill(Path(ellipseIn: shadowRect), with: .color(.black.opacity(0.5)))
        context.fill(Path(ellipseIn: circleRect),
                     with: .color(Color(red: 0.8, green: 0.2, blue: 0.2)))
        context.stroke(Path(ellipseIn: circleRect),
                       with: .color(.white.opacity(0.5)),
                       lineWidth: 1)
    }
}

