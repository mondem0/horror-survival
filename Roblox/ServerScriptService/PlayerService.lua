local PlayerService = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"))
local Events = require(game:GetService("ReplicatedStorage"):WaitForChild("Events"))

local objectiveController
local mapAssets

local function configureCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.MaxHealth = Config.Player.MaxHealth
    humanoid.Health = Config.Player.MaxHealth
    humanoid.WalkSpeed = Config.Player.BaseWalkSpeed
    humanoid.JumpPower = 50

    humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth <= 0 then
            return
        end
    end)

    local root = character:WaitForChild("HumanoidRootPart")
    if not root:FindFirstChild("Ambient") then
        local sound = Instance.new("Sound")
        sound.Name = "Ambient"
        sound.SoundId = "rbxassetid://1842226385"
        sound.Volume = 0.05
        sound.Looped = true
        sound.Parent = root
        sound:Play()
    end
end

local function moveToCFrame(character, targetCFrame)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = targetCFrame
    end
end

local function onPlayerAdded(player)
    player:SetAttribute("IsHidden", false)
    player:SetAttribute("CarryingFuse", false)
    player:SetAttribute("Stamina", Config.Player.MaxStamina)

    Events.StaminaUpdate:FireClient(player, Config.Player.MaxStamina, Config.Player.MaxStamina)
    objectiveController.OnPlayerAdded(player)

    player.CharacterAdded:Connect(function(character)
        configureCharacter(character)
    end)

    if player.Character then
        configureCharacter(player.Character)
    end
end

function PlayerService.Init(objectiveModule, assets)
    objectiveController = objectiveModule
    mapAssets = assets

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    if mapAssets and mapAssets.HidingEntries then
        for _, entry in ipairs(mapAssets.HidingEntries) do
            if entry.Prompt then
                entry.Prompt.Triggered:Connect(function(player)
                    if not player.Character then
                        return
                    end

                    local currentlyHidden = player:GetAttribute("IsHidden")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if currentlyHidden then
                        PlayerService.SetHidden(player, false)
                        if humanoid then
                            humanoid.WalkSpeed = Config.Player.BaseWalkSpeed
                        end
                        moveToCFrame(player.Character, entry.Model.PrimaryPart.CFrame * CFrame.new(0, 0, 6))
                    else
                        PlayerService.SetHidden(player, true)
                        if humanoid then
                            humanoid.WalkSpeed = 0
                        end
                        moveToCFrame(player.Character, entry.Model.PrimaryPart.CFrame * CFrame.new(0, -2, 0))
                    end
                end)
            end
        end
    end
end

function PlayerService.SetHidden(player, hidden)
    player:SetAttribute("IsHidden", hidden)
    Events.PlayerHidden:FireClient(player, hidden)
end

function PlayerService.ApplyDamage(player, amount)
    if not player.Character then
        return
    end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end
    humanoid:TakeDamage(amount)
    Events.DamagePulse:FireClient(player, amount)
end

return PlayerService
