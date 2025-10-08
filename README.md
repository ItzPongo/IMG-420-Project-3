# Project 3 — Flocking Integration (Survival Shooter)

## Overview
This project implements **Craig Reynolds' Boids** algorithm and integrates it into the previously submitted project2. Flocking can be used in multiple ways, but this project has groups of enemies that chase the player until they reach them or die, flocks spawned by an in-game event of randomly spawning 0-2 upon an enemy death. The implementation and integration are done in **C#** per assignment requirements.

---

## Basic Requirements
1. **Boids algorithm implemented**
   - Full implementation of Separation, Alignment, and Cohesion with per-boid perception and tunable weights.

2. **Integrated with game**
   - Flocking is demonstrated as an enemy behavior in the main game and via a `EnemyBoids.cs` script.

---

## What was added / changed
- Added C# flocking implementation (`gdextension/src/EnemyBoid.cs`).
- Integrates boids as enemies that can pursue the player while staying cohesive as a group.
- Keeps Player / Pistol / Bullet behavior from Project2 and connects bullet damage to boid health.

---

## Files & structure
- `gdextension/src/EnemyBoid.cs` — Boid behavior.
- `scenes/Enemy.tscn` — Boid scene instance used by `EnemyBoids`.
- `scenes/Main.tscn` — Main game scene.
- `scenes/Player.tscn`, `scenes/pistol.tscn`, `scenes/bullet.tscn` — retained from Project2.
- `Project2.csproj` — Ensure `Sdk="Godot.NET.Sdk/<version>"` matches your Godot Mono installation.

---

## How flocking is used in this game
- **Enemy Flocks that chase the player until death.**
  - This produces a chaotic rush towards the player and a different challenge than single followed certain paths.

---

## Editor-exposed / tunable parameters (examples)
- **EnemyBoid (per instance / template):** `perceptionRadius`, `separationWeight`, `alignmentWeight`, `cohesionWeight`, `maxSpeed`, `maxForce`.
- **FlockManager:** `boidScene` (PackedScene), `flockSize`, `spawnRadius`, `spawnOnEvent` (bool), `chaseDuration`.
- **Pistol / Bullet:** `bullet_scene` (PackedScene), `bullet.speed`, `bullet.damage` (unchanged from Project2).

---

## Signals & integration points
- `Player` emits `died` → connected to `Main.player_died()` (game-over sequence).
- `EnemyBoid` raises a death event (e.g., `EnemyDied`) → `Main._on_enemy_died()` increments score and may spawn 0–3 additional boids.
- Bullets apply damage to boids through the boid health API.

---

## How to run
1. Use **Godot Mono** (the C#/.NET-enabled Godot) matching your installed version.
2. Open the project folder in Godot. If you see assembly errors, verify `Project2.csproj`'s Sdk version and update to the Godot Mono version you have installed.
3. Set `main.tscn` as the main scene (Project Settings → Run → Main Scene).
4. Run the project.

---

## Testing checklist
- [ ] Flocking rules implemented.
- [ ] Flocks spawn and can chase the player.
- [ ] `Player.died` triggers game over via `Main.player_died()`.
- [ ] Killing boids spawns additional boids.
- [ ] Project compiles in Godot Mono without unresolved assembly issues.

---

## Troubleshooting / common fixes
- **Missing assemblies / compile errors:** Open the `.csproj` and set `Sdk="Godot.NET.Sdk/<your-version>"` to match your Godot Mono binary.

---
