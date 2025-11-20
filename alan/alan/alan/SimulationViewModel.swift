//
//  SimulationViewModel.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import SwiftUI
import Combine

final class SimulationViewModel: ObservableObject {
    struct Agent: Identifiable {
        enum Result {
            case pending
            case success
            case failure
        }
        
        let id = UUID()
        let name: String
        let baseHorizontal: CGFloat
        let color: Color
        
        var jumpProgress: CGFloat = 1.0
        var isJumping: Bool = false
        var reactionThreshold: CGFloat
        var learningRate: CGFloat
        var reward: CGFloat = 0
        var result: Result = .pending
        var trackedObstacleID: UUID?
        
        var verticalOffset: CGFloat {
            guard isJumping else { return 0 }
            let clamped = min(max(jumpProgress, 0), 1)
            return sin(.pi * clamped) * 0.22
        }
        
        var displayText: String {
            switch result {
            case .pending: return "…"
            case .success: return "✓"
            case .failure: return "✕"
            }
        }
    }
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var position: CGFloat
        let width: CGFloat
        var height: CGFloat
    }
    
    enum Status: String {
        case idle = "IDLE"
        case running = "TRAINING"
        case completed = "COMPLETE"
    }
    
    @Published private(set) var agents: [Agent] = []
    @Published private(set) var obstacles: [Obstacle] = []
    @Published private(set) var status: Status = .idle
    @Published private(set) var episode: Int = 0
    @Published private(set) var infoMessage: String = "Ready."
    @Published private(set) var step: Int = 0
    
    private var timer: AnyCancellable?
    private let fps: Double = 60
    private let maxEpisodes = 60
    
    private let maxEntities = 15
    private let colors: [Color] = [
        Color(red: 0.91, green: 0.27, blue: 0.27),
        Color(red: 0.94, green: 0.51, blue: 0.19),
        Color(red: 0.95, green: 0.79, blue: 0.13),
        Color(red: 0.36, green: 0.76, blue: 0.32),
        Color(red: 0.23, green: 0.67, blue: 0.83),
        Color(red: 0.27, green: 0.44, blue: 0.94),
        Color(red: 0.56, green: 0.32, blue: 0.99),
        Color(red: 0.92, green: 0.33, blue: 0.63),
        Color(red: 0.64, green: 0.76, blue: 0.91),
        Color(red: 0.71, green: 0.64, blue: 0.92),
        Color(red: 0.59, green: 0.85, blue: 0.78),
        Color(red: 0.86, green: 0.53, blue: 0.94),
        Color(red: 0.94, green: 0.79, blue: 0.56),
        Color(red: 0.47, green: 0.85, blue: 0.41),
        Color(red: 0.89, green: 0.41, blue: 0.25)
    ]
    
    func runSimulation(script: String, entityCount: Int) {
        stop()
        let clampedCount = min(max(entityCount, 1), maxEntities)
        configureAgents(count: clampedCount)
        configureObstacles()
        status = .running
        episode = 0
        infoMessage = "Compiling MLX policy…"
        
        // Pretend to parse script hash for display/debugging.
        let hash = abs(script.hashValue) % 99_999
        infoMessage = "Loaded policy signature #\(hash)."
        
        timer = Timer.publish(every: 1.0 / fps, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        if status == .running {
            status = .completed
        }
        infoMessage = "Simulation stopped."
    }
    
    private func configureAgents(count: Int) {
        agents = (0..<count).map { idx in
            Agent(
                name: String(format: "AG-%02d", idx + 1),
                baseHorizontal: 0.15 + CGFloat(idx) * 0.03,
                color: colors[idx % colors.count],
                jumpProgress: 1.0,
                isJumping: false,
                reactionThreshold: 0.28 + CGFloat(idx) * 0.01,
                learningRate: CGFloat.random(in: 0.001...0.01)
            )
        }
    }
    
    private func configureObstacles() {
        obstacles = (0..<3).map { idx in
            Obstacle(
                position: 0.7 + CGFloat(idx) * 0.2,
                width: 0.05,
                height: 0.18
            )
        }
    }
    
    private func tick() {
        guard status == .running else { return }
        step += 1
        if step % Int(fps) == 0 {
            episode += 1
        }
        if episode >= maxEpisodes {
            stop()
            status = .completed
            infoMessage = "Episode budget reached."
            return
        }
        
        updateObstacles()
        updateAgents()
        
        let totalReward = agents.reduce(0) { $0 + $1.reward }
        let avg = agents.isEmpty ? 0 : totalReward / CGFloat(agents.count)
        infoMessage = String(format: "Episode %02d/%02d • avg r=%.2f",
                             episode,
                             maxEpisodes,
                             Double(avg))
    }
    
    private func updateObstacles() {
        for idx in obstacles.indices {
            obstacles[idx].position -= 0.007
            if obstacles[idx].position + obstacles[idx].width < 0 {
                let gap = CGFloat.random(in: 0.2...0.4)
                obstacles[idx].position = 1 + gap
                obstacles[idx].height = CGFloat.random(in: 0.12...0.22)
            }
        }
    }
    
    private func updateAgents() {
        for idx in agents.indices {
            var agent = agents[idx]
            guard let obstacle = obstacles
                .filter({ $0.position + $0.width > agent.baseHorizontal - 0.02 })
                .min(by: { $0.position < $1.position }) else {
                agents[idx] = agent
                continue
            }
            
            if agent.trackedObstacleID != obstacle.id {
                agent.trackedObstacleID = obstacle.id
                agent.result = .pending
            }
            
            let distance = obstacle.position - agent.baseHorizontal
            if !agent.isJumping && distance < agent.reactionThreshold {
                agent.isJumping = true
                agent.jumpProgress = 0
            }
            
            if agent.isJumping {
                agent.jumpProgress += 0.06
                if agent.jumpProgress >= 1 {
                    agent.isJumping = false
                    agent.jumpProgress = 1
                }
            }
            
            let overlapsHorizontally = obstacle.position < agent.baseHorizontal &&
            agent.baseHorizontal < obstacle.position + obstacle.width
            let collides = overlapsHorizontally &&
            agent.verticalOffset < obstacle.height + 0.02
            
            if obstacle.position + obstacle.width < agent.baseHorizontal,
               agent.trackedObstacleID == obstacle.id {
                agent.reward += 1
                agent.result = .success
                agent.reactionThreshold = max(0.08, agent.reactionThreshold - agent.learningRate)
                agent.trackedObstacleID = nil
            } else if collides,
                      agent.trackedObstacleID == obstacle.id {
                agent.reward -= 1
                agent.result = .failure
                agent.reactionThreshold = min(0.4, agent.reactionThreshold + agent.learningRate * 4)
                agent.trackedObstacleID = nil
            }
            
            agents[idx] = agent
        }
    }
}

extension SimulationViewModel.Status {
    var color: Color {
        switch self {
        case .idle:
            return Theme.accent
        case .running:
            return Color.green
        case .completed:
            return Color.orange
        }
    }
}

