# ALAN Project Update

## Overview
This update evolves the original split-view UI into an RL playground for a jumping-agent environment. The upper code editor now ships with an MLX training script and the lower viewport visualizes up to 15 concurrent agents learning to avoid rectangular obstacles in real time. The visual language remains dark, metallic, and brutalist.

## Changes Implemented
1.  **Split Layout**: The main view is divided into two vertical sections:
    -   **Upper Section**: Code Editor.
    -   **Lower Section**: Simulation Viewport.
2.  **Design System**:
    -   Implemented a dark, metallic theme (`Theme` struct).
    -   Custom colors for background, panels, borders, and accents.
    -   Monospaced fonts for code and technical headers.
3.  **MLX RL Script**:
    -   The editor now boots with `ScriptTemplates.jumpTrainer`, a multi-agent MLX policy-gradient loop for the jumping task.
    -   The script exposes `train(num_agents=4)` so the same entity count selected in Swift can be mirrored in Python.
4.  **Simulation View & Engine**:
    -   Introduced `SimulationViewModel` that mimics basic RL behavior: each agent adapts its reaction threshold based on pass/fail events.
    -   `SimulationView` renders multiple agents, their rewards, and moving obstacles via `Canvas`, updating at 60 FPS.
5.  **Control Surface**:
    -   Added `SimulationControlsView` with a Stepper (1–15 entities) and a Run/Stop toggle.
    -   Header status LEDs change color according to the sim state (idle/running/complete).
6.  **Modular Architecture**:
    -   Maintained separate files for theme, views, models, and script templates.
    -   `ContentView` now orchestrates bindings between editor text, controls, and the renderer.

## MLX ↔ Swift Integration Plan (v0.1 Instructions)
1.  **Python Runtime** (macOS):
    1.  Install MLX in the project’s virtual environment.
    2.  Use `PythonKit` (or a dedicated XPC helper) inside the macOS target to evaluate the code shown in the editor.
    3.  When the user taps “Run Simulation,” persist the current script to a temp `.py` file and invoke it in a background task.
2.  **Bridge Contract**:
    -   The MLX script should emit lightweight telemetry per episode (e.g., JSON lines containing `agent_id`, `distance`, `jump_trigger`, `reward`).
    -   Stream that telemetry back to Swift via `Pipe` / XPC / sockets and decode into `SimulationViewModel.Agent` updates.
    -   Swift’s `SimulationViewModel` already expects:
        -   `num_agents ≤ 15`
        -   Per-agent reward deltas
        -   Timely obstacle metadata (distance & height)
    -   Once the real data arrives, replace the heuristic `updateAgents()` logic with the decoded telemetry.
3.  **Synchronization**:
    -   Keep the Swift `entityCount` Stepper in sync with the MLX script by string-searching for `train(num_agents=...)` and mutating before execution.
    -   Use `DispatchSourceRead` or `async` `FileHandle` streams so the simulator updates in real time, not after the process exits.
4.  **Testing**:
    -   Start with deterministic seeds on both sides (Swift + Python) for reproducible visuals.
    -   Add unit tests that assert the Python bridge produces ≤15 agents and that Swift gracefully handles missing frames.

## How the Pieces Connect
| Layer | Responsibility |
| --- | --- |
| `CodeEditorView` + `ScriptTemplates` | Authoring surface for MLX policy/control logic. |
| `SimulationControlsView` | Parameter entry (entity count) + lifecycle commands (run/stop). |
| `SimulationViewModel` | Real-time state machine; today it mocks RL updates, later it will ingest Python telemetry. |
| `SimulationView` | Visual renderer; consumes view-model state to draw agents, obstacles, and rewards. |
| MLX Script (`jumpTrainer`) | Defines the real training loop, network, optimizer, and environment dynamics. |

## Current Limitations
-   **Python still mocked**: Swift sim logic does not yet consume real MLX tensors; telemetry bridge is pending.
-   **No syntax highlighting**: `TextEditor` remains plain text.
-   **Single environment type**: Only the jump-over-rectangle scenario is visualized.
-   **Fixed layout**: Split ratio and panel sizes are static.

## Next Possible Steps
1.  **Execute MLX inline**:
    -   Add a `PythonBridge` service that runs the current script with `num_agents` injected at runtime.
    -   Stream policies or logits into Swift so the visualization responds to actual network output.
2.  **Inspector & Telemetry**:
    -   Show per-agent policy thresholds, losses, and gradient norms.
    -   Enable scrubbing through past episodes.
3.  **UX Enhancements**:
    -   Resizable splitter, syntax highlighting, linting, and template switching (e.g., other environments).
4.  **Physics Upgrade**:
    -   Port the renderer to SpriteKit/Metal for smoother animations and collision logic when scaling beyond 15 agents.


