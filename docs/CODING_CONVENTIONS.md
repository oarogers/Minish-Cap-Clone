# Coding Conventions

This document defines baseline conventions for this repository's Godot code and content.

## 1. Goals

- Keep features modular and portable between projects.
- Separate gameplay logic from presentation.
- Prefer explicit contracts over implicit node-path coupling.

## 2. Folder Rules

- `core/` is shared engine/gameplay infrastructure.
- `game/` contains project-specific gameplay/content implementations.
- A reusable feature should live in a self-contained folder with scripts, scenes, resources, and a local `README.md`.

## 3. Naming Standards

- **Scenes**: `snake_case.tscn`.
- **Scripts**: `snake_case.gd`.
- **Resources**: `snake_case.tres`.
- **Classes**: `PascalCase` via `class_name` when cross-feature reuse is expected.
- **Methods/vars/signals**: `snake_case`.
- **Constants**: `SCREAMING_SNAKE_CASE`.

## 4. Script Structure

Order script sections consistently:
1. `class_name`
2. `extends`
3. `signal` declarations
4. constants
5. exported variables
6. member variables
7. `_ready`, `_process`, `_physics_process`
8. public methods
9. private helpers (`_prefix`)

## 5. Type Safety

- Use typed GDScript for exported/member variables and function signatures.
- Avoid untyped dictionaries for critical game state; prefer dedicated `Resource` classes.

## 6. Decoupling Rules

- Gameplay scripts must not directly depend on mesh/material/animation internals.
- Presentation scripts listen to gameplay signals and update visuals.
- Avoid hardcoded absolute node paths crossing feature boundaries.

## 7. Signals and Events

- Prefer signals for feature boundaries.
- Signal names should be verb-first and explicit (e.g., `scene_change_requested`).
- Signal payloads should be stable and typed where possible.

## 8. Manager/System/Component Intent

- **Managers** orchestrate application-level transitions and contexts.
- **Systems** apply logic over many entities/components.
- **Components** are small capabilities attached to entities.

## 9. Input

- Input actions must be declared in `InputMap` and referenced by action name constants.
- Runtime input context toggles should be centralized in `InputContextManager`.

## 10. Testing and Validation

- Add smoke-test scenes for new major features.
- Keep reproducible checks under `scripts/`.
- Document external dependencies in each feature README.
