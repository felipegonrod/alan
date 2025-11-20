# ALAN Project Update

## Overview
This update introduces a split-view interface designed for a simulation environment. The UI adopts a "Palantir-style" aesthetic: minimalist, brutalist, and metallic dark mode.

## Changes Implemented
1.  **Split Layout**: The main view is divided into two vertical sections:
    -   **Upper Section**: Code Editor.
    -   **Lower Section**: Simulation Viewport.
2.  **Design System**:
    -   Implemented a dark, metallic theme (`Theme` struct).
    -   Custom colors for background, panels, borders, and accents.
    -   Monospaced fonts for code and technical headers.
3.  **Code Editor**:
    -   Added `CodeEditorView` with a `TextEditor`.
    -   Pre-loaded with a default Python/MLX script "Hello World".
    -   Styled with specific technical headers (e.g., "SCRIPT.PY").
4.  **Simulation View**:
    -   Added `SimulationView` using SwiftUI `Canvas`.
    -   Renders a grid background, a ground line, and a red circle.
    -   Includes shadow and stroke details for better visual separation.
5.  **Modular Architecture**:
    -   Extracted `Theme`, `SystemHeaderView`, `CodeEditorView`, and `SimulationView` into dedicated files.
    -   Keeps `ContentView` focused on layout composition and future scaling.

## Current Limitations
-   **No Execution**: The Python code in the editor is currently static text. It does not execute or interact with a Python interpreter.
-   **No Syntax Highlighting**: The editor is a standard plain text field; it lacks color coding for keywords or syntax analysis.
-   **Static Simulation**: The "simulation" is a drawing. The red circle does not move, respond to physics, or react to the code.
-   **Layout Fixed**: The split ratio is currently 50/50 (implied by `VStack` layout) and not resizable by the user.

## Next Possible Steps
1.  **Python Integration**:
    -   Embed a Python runtime (e.g., PythonKit or a lightweight WASM-based Python if targeting iOS/Web) to execute the script.
    -   Map `mlx` commands to internal Swift functions.
2.  **Syntax Highlighting**:
    -   Replace `TextEditor` with a `UIViewRepresentable` wrapping `UITextView` (iOS) or `NSTextView` (macOS) to support attributed strings for syntax highlighting.
3.  **Physics & Animation**:
    -   Migrate the simulation view to **SpriteKit** or **SceneKit** for real physics and animation loops.
    -   Allow the Python script to control entities in the scene (e.g., `circle.move(x=10)`).
4.  **Resizable Layout**:
    -   Implement a draggable divider between the code editor and the simulation view.


