# Ashen Echoes Horror Experience

This repository contains drop-in LuaU scripts that power a complete Roblox horror game called **Ashen Echoes**. You handcraft the geothermal facility in Studio; the scripts wire up interactions, UI, objectives, and the stalking/ambushing enemies that patrol it.

## TL;DR build steps

1. Create a new **Roblox Studio** place (R6 or R15 supported) and open the **Explorer** + **Properties** panels.
2. Hand-build the environment and required gameplay anchors:
   - Insert a `Model` named **`AshenEchoesMap`** under `Workspace`.
   - Inside it create the following folders (names can be changed in [`Config.lua`](./Roblox/ReplicatedStorage/Config.lua)) and populate them with your parts/models:

     | Folder | Required contents |
     | --- | --- |
     | `Doors` | One `Model` per usable door. Set the model `PrimaryPart` (or add a `Door` part) at the hinge. Optional: add a `Number` attribute `OpenAngle` (degrees) for the swing amount. |
     | `Fuses` | One `Model` or `Part` per collectible fuse. The scripts add prompts automatically. |
     | `HidingSpots` | One locker/closet `Model` per hiding spot. Ensure a `PrimaryPart` exists (the scripts will use it for teleporting players). |
     | `Switches` | Any wall consoles, breakers, or levers that should trigger the atmospheric cue. |
     | `PatrolNodes` | Drop `Part` markers where you want the Wraith to patrol. Only the positions are used, so you can make them invisible. |
     | `CrawlerNests` | Place `Part` markers where the Crawler should emerge from (vents, floor grates, etc.). |
     | `Spawns` | Place `Part` markers named for spawns (must include one called `WraithSpawn`). |

   - Add a generator model named **`GeneratorConsole`** somewhere inside `AshenEchoesMap`. If it contains a part named `Core`, the fuse deposit prompt will appear on it; otherwise the model’s `PrimaryPart` is used.
3. Mirror the folder structure from [`Roblox/`](./Roblox) inside your place:

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

   > **Tip:** Create the folders first (e.g. `Main` under `ServerScriptService`) then insert the correct Script/ModuleScript and paste the file contents.

4. Press **Play**. The scripts automatically:
   - attach polished health/stamina HUD, inventory display, and dynamic objective callouts,
   - hook your door/fuse/switch/locker assets with interaction prompts,
   - spawn the Wraith stalker and Crawler ambusher using your patrol nodes and nests.

## Feature overview

- **Hand-authored facility, scripted tension** – You control the architecture and props; the code animates the atmosphere, audio cues, and interactions.
- **Objectives** – Collect and install three fuses to power the generator and unlock the atrium lift. Objective text and inventory counters replicate to every player.
- **Interactive world** – Hinged doors, flicker switch, fuses, generator console, and fully functional hiding lockers.
- **Two enemy behaviors**:
  - **Wraith** stalks your patrol points, uses line-of-sight detection, then sprints and claws players.
  - **Crawler** lurks near its nests, detects sound, then executes leap ambushes with cooldown-driven retreats.
- **Player systems** – Sprinting stamina, flashlight toggle, damage feedback, hiding state, atmospheric tints, and ambient cues.
- **Atmosphere** – Lighting tweaks, fog, particles, soundscapes, UI styling, and screen-space effects craft a tense pacing arc.

## Optional customization

- Edit [`Config.lua`](./Roblox/ReplicatedStorage/Config.lua) to rename folders/objects the scripts look for, or to tweak enemy/player tuning.
- Duplicate or remove patrol nodes/nests/fuses in your map to rebalance pacing and difficulty.

Enjoy scaring your players!
