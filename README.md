# Ashen Echoes Horror Experience

This repository contains drop-in LuaU scripts that build a complete Roblox horror game called **Ashen Echoes**. The experience features a procedurally constructed geothermal facility, an objective-driven progression loop, and two distinct enemy archetypes (a stalking **Wraith** and an ambushing **Crawler**).

## TL;DR build steps

1. Create a new **Roblox Studio** place (R6 or R15 supported) and open **Explorer** + **Properties** panels.
2. Mirror the folder structure from [`Roblox/`](./Roblox) inside your place:

   | Roblox service | In-studio location | File to paste |
   | --- | --- | --- |
   | `ReplicatedStorage` | `ReplicatedStorage/Config` | [`Roblox/ReplicatedStorage/Config.lua`](./Roblox/ReplicatedStorage/Config.lua) (ModuleScript) |
   | `ReplicatedStorage` | `ReplicatedStorage/Events` | [`Roblox/ReplicatedStorage/Events.lua`](./Roblox/ReplicatedStorage/Events.lua) (ModuleScript) |
   | `ServerScriptService` | `ServerScriptService/Main` | [`Roblox/ServerScriptService/Main.server.lua`](./Roblox/ServerScriptService/Main.server.lua) (Script) |
   | `ServerScriptService/Main` | `ServerScriptService/Main/MapBuilder` | [`Roblox/ServerScriptService/MapBuilder.lua`](./Roblox/ServerScriptService/MapBuilder.lua) (ModuleScript) |
   | `ServerScriptService/Main` | `ServerScriptService/Main/ObjectiveController` | [`Roblox/ServerScriptService/ObjectiveController.lua`](./Roblox/ServerScriptService/ObjectiveController.lua) (ModuleScript) |
   | `ServerScriptService/Main` | `ServerScriptService/Main/PlayerService` | [`Roblox/ServerScriptService/PlayerService.lua`](./Roblox/ServerScriptService/PlayerService.lua) (ModuleScript) |
   | `ServerScriptService/Main` | `ServerScriptService/Main/EnemyController` | [`Roblox/ServerScriptService/EnemyController.lua`](./Roblox/ServerScriptService/EnemyController.lua) (ModuleScript) |
   | `StarterPlayer` | `StarterPlayer/StarterPlayerScripts/ClientMain` | [`Roblox/StarterPlayer/StarterPlayerScripts/ClientMain.client.lua`](./Roblox/StarterPlayer/StarterPlayerScripts/ClientMain.client.lua) (LocalScript) |

   > **Tip:** In Explorer, create the folders first (e.g. `Main` under `ServerScriptService`) then insert the correct Script/ModuleScript and paste the file contents.

3. Press **Play**. The scripts automatically:
   - build the entire facility (five rooms, props, lighting, and hiding lockers),
   - spawn interactable doors, fuses, generator, and switches,
   - create polished health/stamina HUD, inventory display, and dynamic objective callouts,
   - spawn the Wraith stalker and Crawler ambusher with independent AI loops.

No manual part placement is required; everything is generated and wired up when the server starts.

## Feature overview

- **Dynamic facility layout** – Each run assembles rooms, patrol nodes, light sources, props, and ambiance strictly through LuaU.
- **Objectives** – Collect and install three fuses to power the generator and unlock the atrium lift. Objective text and inventory counters replicate to every player.
- **Interactive world** – Hinged doors, flicker switch, fuses, generator console, and fully functional hiding lockers.
- **Two enemy behaviors**:
  - **Wraith** stalks patrol points, uses line-of-sight detection, then sprints and claws players.
  - **Crawler** lurks at vents, detects sound, then executes leap ambushes with cooldown-driven retreats.
- **Player systems** – Sprinting stamina, flashlight toggle, damage feedback, hiding state, atmospheric tints, and ambient cues.
- **Atmosphere** – Lighting, fog, particles, soundscapes, UI styling, and screen-space effects craft a tense pacing arc.

## Optional customization

- Edit [`Config.lua`](./Roblox/ReplicatedStorage/Config.lua) to adjust room positions, lighting colors, patrol points, enemy tuning, and player movement.
- Add more rooms or fuses by duplicating entries in the configuration arrays; the builder consumes them automatically.

Enjoy scaring your players!
