//
//  ScriptTemplates.swift
//  alan
//
//  Created by Felipe González on 20/11/25.
//

import Foundation

enum ScriptTemplates {
    static let jumpTrainer = """
import mlx.core as mx
import mlx.nn as nn
from mlx.optimizers import adam

# --- Environment -----------------------------------------------------------
class JumpEnv:
    def __init__(self, num_agents: int, obstacle_height: float = 1.0):
        self.num_agents = min(max(num_agents, 1), 15)
        self.obstacle_height = obstacle_height
        self.reset()

    def reset(self):
        self.t = 0
        self.obstacles = mx.random.uniform(shape=(self.num_agents,), low=0.4, high=1.0)
        return self._get_state()

    def _get_state(self):
        return mx.stack([
            self.obstacles,              # distance to next obstacle
            mx.zeros(self.num_agents),   # velocity
        ], axis=-1)

    def step(self, action: mx.array) -> tuple[mx.array, mx.array, mx.array]:
        jump_mask = action.squeeze() > 0.5
        reward = mx.where(jump_mask, 0.1, -0.02)

        crossed = self.obstacles < 0.02
        success = mx.logical_and(crossed, jump_mask)
        failure = mx.logical_and(crossed, mx.logical_not(jump_mask))

        reward = reward + mx.where(success, 1.0, 0.0) - mx.where(failure, 1.0, 0.0)
        done = failure

        self.obstacles = mx.where(
            crossed,
            mx.random.uniform(shape=self.obstacles.shape, low=0.4, high=1.0),
            self.obstacles - 0.02
        )
        self.t += 1
        return self._get_state(), reward, done

# --- Policy & Training -----------------------------------------------------
class JumpPolicy(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 32),
            nn.GELU(),
            nn.Linear(32, 1),
            nn.Sigmoid(),
        )

    def __call__(self, x):
        return self.net(x)

def train(num_agents: int = 4, episodes: int = 2_000):
    env = JumpEnv(num_agents=num_agents)
    policy = JumpPolicy()
    optimizer = adam(learning_rate=3e-4)

    @mx.compile
    def loss_fn(state, reward, done):
        action = policy(state)
        advantage = reward - reward.mean()
        logp = mx.log(action + 1e-6)
        return -(advantage * logp).mean()

    for episode in range(episodes):
        state = env.reset()
        total_reward = 0.0
        for step in range(256):
            action = policy(state)
            next_state, reward, done = env.step(action)
            total_reward += reward.mean()
            optimizer.update(policy, loss_fn)(state, reward, done)
            state = next_state
        if episode % 100 == 0:
            print(f"Episode {episode} :: reward={float(total_reward):.2f}")

    mx.savez("jump_policy.npz", **policy.state)


if __name__ == "__main__":
    train(num_agents=4)
"""
}

