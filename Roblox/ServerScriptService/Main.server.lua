local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Events = require(ReplicatedStorage:WaitForChild("Events"))

local MapBuilder = require(script:WaitForChild("MapBuilder"))
local ObjectiveController = require(script:WaitForChild("ObjectiveController"))
local PlayerService = require(script:WaitForChild("PlayerService"))
local EnemyController = require(script:WaitForChild("EnemyController"))

local mapAssets = MapBuilder.Build(Config)
ObjectiveController.Init(Config, mapAssets)
PlayerService.Init(ObjectiveController, mapAssets)
EnemyController.Init(Config, mapAssets, PlayerService)

Lighting.Ambient = Color3.fromRGB(20, 20, 25)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
Lighting.Brightness = 1.2
Lighting.FogColor = Color3.fromRGB(15, 15, 20)
Lighting.FogStart = 60
Lighting.FogEnd = 280
Lighting.ClockTime = 0
Lighting.EnvironmentDiffuseScale = 0.1
Lighting.EnvironmentSpecularScale = 0.4

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.4
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(60, 80, 120)
atmosphere.Decay = Color3.fromRGB(0, 0, 0)
atmosphere.Parent = Lighting

Events.ObjectiveUpdate:FireAllClients("Collect the facility fuses. Stay in the light.")
