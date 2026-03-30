# Minish Cap 3D (Godot) — Project Plan

## 1) Vision and Constraints

- **Target**: A 3D reinterpretation of *The Legend of Zelda: The Minish Cap* with toy-diorama readability (similar camera/readability goals as Link's Awakening remake), while remaining legally distinct in shipped assets.
- **Engine**: Godot (recommend 4.3+).
- **Primary dev machine**: Steam Deck (Linux), so workflows should prioritize low-friction tooling, conservative editor/plugin usage, and automation scripts that run offline.

### Practical constraints for Steam Deck

- Prefer **typed GDScript** over heavy C# pipelines at first (faster iteration, no .NET setup pain on Deck).
- Keep import sizes low (small textures during prototyping, deferred high-res passes).
- Use reproducible scripts for setup/checks (`./scripts/*.sh`) so you can recover quickly after SD card / OS updates.
- Keep editor plugins minimal; if used, pin versions and commit plugin source.

---

## 2) Core Design Principles

1. **Composition over inheritance**
   - Build gameplay from small reusable components (`Health`, `Hitbox`, `Interactor`, `InventoryHolder`) attached to scenes.
2. **Data-driven behavior**
   - Use `Resource` assets for tunables and definitions (`EnemyDefinition`, `ItemDefinition`, `RoomDefinition`).
3. **Logic/visual split**
   - Gameplay simulation scripts should not depend on specific meshes/materials/animations.
   - Visual scenes consume state/events from gameplay components.
4. **Feature folders that are copy-pastable**
   - Every feature has a local folder containing scene(s), scripts, resources, tests, and README.
5. **Explicit boundaries**
   - Shared core APIs in `core/`; game-specific content in `game/`.
   - Avoid cross-feature imports except through `core` contracts.

---

## 3) Recommended Folder Architecture

```text
res://
  core/
    app/
      game_root.tscn
      game_root.gd
    systems/
      save_system/
      scene_flow/
      event_bus/
      audio_system/
      debug_overlay/
    components/
      health/
      damage_receiver/
      hurtbox/
      hitbox/
      interaction/
      locomotion/
    data/
      defs/
      ids/
    util/
      math/
      timing/
      godot_wrappers/

  game/
    player/
      player_logic.tscn
      player_visual.tscn
      player_controller.gd
      player_anim_driver.gd
      resources/
      tests/
      README.md
    enemies/
      chu_chu/
      octorok/
    items/
      sword/
      bombs/
      gust_jar/
    world/
      room_chunks/
      dungeon_templates/
      overworld/
    ui/
      hud/
      inventory/
    content_db/
      item_defs/
      enemy_defs/
      fx_profiles/

  addons/ (optional, pinned)
  scripts/
    check.sh
    run_tests.sh
    package_feature.sh
  docs/
    PROJECT_PLAN.md
    ARCHITECTURE.md
    CONTENT_PIPELINE.md
```

### Copy/paste portability rule

Each reusable feature folder should include:
- `README.md` (dependencies, signals, required groups, input actions)
- `*.tscn` + scripts + resources
- local test scene(s)
- **no hardcoded global paths** outside documented contracts

---

## 4) Layered Runtime Architecture

## A) App Layer
- Bootstraps services and scene flow.
- Owns singleton registration and high-level state transitions (title -> gameplay -> pause -> map).

## B) Domain Layer (pure gameplay intent)
- Player/enemy/item state, combat rules, interaction rules.
- Should be mostly independent from render details.

## C) Integration Layer
- Bridges Godot node lifecycle, physics callbacks, animation tree hooks, audio playback.

## D) Presentation Layer
- Meshes, skeletons, animation trees, VFX/SFX emitters, camera rigs, UI.

Use one-way flow when possible:
- Input -> Domain Commands -> State changes -> Events -> Presentation reacts.

---

## 5) Managers, Systems, Components (clear roles)

## Managers (orchestrate, no heavy per-frame logic)
- `GameStateManager`: game mode, pause, transitions.
- `SceneFlowManager`: room transitions, dungeon entrances, spawn points.
- `SaveManager`: profile slot serialization, checkpointing.
- `InputContextManager`: remapping and context-sensitive action maps.

## Systems (process sets of components)
- `CombatSystem`: resolves attack windows, damage application, invulnerability.
- `InteractionSystem`: talk/pickup/push/pull/trigger.
- `QuestSystem`: flags, progression gates.
- `AISystem`: high-level enemy behavior stepping.

## Components (small attachable capability)
- `HealthComponent`
- `DamageReceiverComponent`
- `HitboxComponent`
- `HurtboxComponent`
- `InteractorComponent`
- `InventoryComponent`
- `LocomotionComponent`

## Data Assets (Resource-driven)
- `ItemDefinition.tres`
- `EnemyDefinition.tres`
- `RoomEncounterDefinition.tres`
- `LootTableDefinition.tres`

---

## 6) Logic vs Visual Split Pattern (Godot scene composition)

For every complex actor (player/enemy/boss):

- `*_logic.tscn`
  - collision, gameplay components, authoritative state.
- `*_visual.tscn`
  - mesh/skeleton/animation/VFX only.
- `*_view_adapter.gd`
  - listens to gameplay signals and drives animation parameters.

This keeps gameplay testable and allows swapping art styles without rewriting mechanics.

---

## 7) Eventing and Contracts

- Create a lightweight `EventBus` (signal hub) for cross-feature communication.
- Prefer narrow typed payload objects (Resources/classes) over many loose parameters.
- Define interface-like contracts by documented methods/signals (Godot groups can assist).

Rules:
- Feature code can emit events globally.
- Feature code may subscribe to global events only in entry points/adapters.
- Core systems should avoid direct references to game-content scene paths.

---

## 8) Data, Save, and IDs

- Assign stable IDs for rooms, entities, chests, switches.
- Save format:
  - `meta` (version, timestamp)
  - `player_state`
  - `world_state` (flags, opened chests, solved puzzles)
  - `inventory_state`
- Use versioned migrations (`save_version`) to keep old saves compatible.
- Keep deterministic naming conventions (`room_<region>_<index>`).

---

## 9) Vertical Slices (milestone plan)

## Slice 0 — Foundations (1–2 weeks)
- Project skeleton + folder contracts.
- Input map + camera rig + room loading baseline.
- Basic player movement with one attack and one interact action.

## Slice 1 — Combat loop (2–3 weeks)
- Enemy archetype (e.g., ChuChu).
- Hitbox/hurtbox + damage + knockback + i-frames.
- Health UI + death/respawn.

## Slice 2 — Dungeon room loop (2–3 weeks)
- Room transitions + key/lock door + chest + switch puzzle.
- Save/load for room completion state.

## Slice 3 — Item-driven traversal (3–4 weeks)
- One tool item (Gust Jar equivalent behaviorally).
- Data-driven interactables that react to tool tags.

## Slice 4 — Production baseline
- Content authoring templates.
- Performance pass for Steam Deck.
- Build/release automation.

---

## 10) Steam Deck-first Workflow

- Use desktop mode + external keyboard for heavy editing.
- Keep Godot cache/project on SSD where possible.
- Cap viewport quality in editor for responsiveness.
- Profile often on-device (frame time budget target: 16.6ms for 60fps, fallback 33.3ms for 30fps).

### Input and controls
- Define action map for controller-first play from day one.
- Add deadzone/aim curve config resources so tuning is data-driven.

### Performance budget suggestions
- Limit dynamic lights/shadows in gameplay camera.
- Aggressive LOD and occlusion/cull masks.
- Prefer baked/static lighting for interiors where feasible.
- Reuse materials and texture atlases to cut draw calls.

---

## 11) Quality Gates and Tooling

- `scripts/check.sh`
  - GDScript formatting/lint (if configured)
  - asset naming checks
  - missing reference checks
- `scripts/run_tests.sh`
  - unit-like tests for domain logic
  - smoke test scenes for room transitions/combat
- CI (later) can run headless Godot test scenes.

Definition of done for any feature folder:
- README with dependencies.
- At least one automated or scripted validation.
- No hard dependency on unrelated game content path.
- Public signals/methods documented.

---

## 12) Reusable Feature Template

Each feature folder should follow:

```text
feature_x/
  feature_x.tscn
  feature_x.gd
  feature_x_config.gd (Resource)
  feature_x_view.tscn (optional)
  tests/
    test_feature_x.tscn
  README.md
```

README checklist:
- Purpose
- Required input actions
- Required autoloads
- Signals emitted
- External events consumed
- Setup steps in a new project

---

## 13) Risk Register (early)

1. **Scope creep**
   - Mitigation: keep strict slice goals; only one new mechanic at a time.
2. **Performance regressions on Deck**
   - Mitigation: profile every slice and keep a tracked budget.
3. **Tight coupling between gameplay and art scenes**
   - Mitigation: enforce logic/visual split reviews.
4. **Save incompatibility**
   - Mitigation: versioned save schema from first playable.

---

## 14) First Week Action Plan (practical)

Day 1–2:
- Create folder skeleton and coding conventions doc.
- Implement `GameRoot`, `SceneFlowManager`, `InputContextManager` skeletons.

Day 3–4:
- Implement player logic scene + visual scene + adapter.
- Add camera and target lock prototype.

Day 5–7:
- Build one test room with transitions and one enemy.
- Add basic save for player spawn + one world flag.
- Write README for player and room feature folders.

If all week-1 goals pass, proceed to Slice 1 combat hardening.
