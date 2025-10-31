local ObjectiveController = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local EventsModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Events"))

local config
local assets
local state = {
    FuseDeposited = 0,
    Completed = false,
}

local function updateObjectiveText()
    if state.Completed then
        EventsModule.ObjectiveUpdate:FireAllClients("Exit unlocked. Reach the lift gate in the atrium!")
    else
        local remaining = config.Objectives.TotalFuses - state.FuseDeposited
        EventsModule.ObjectiveUpdate:FireAllClients(string.format("Install %d more fuse(s) into the generator", remaining))
    end
end

local function updateInventory(player)
    local carrying = player:GetAttribute("CarryingFuse") and 1 or 0
    EventsModule.InventoryUpdate:FireClient(player, {
        CarriedFuses = carrying,
        Deposited = state.FuseDeposited,
        Required = config.Objectives.TotalFuses,
    })
end

local function handleExitUnlock()
    local doorEntry = assets.Doors[config.Objectives.ExitDoorName]
    if not doorEntry or not doorEntry.DoorPart then
        return
    end

    state.Completed = true
    updateObjectiveText()

    local doorPart = doorEntry.DoorPart
    local openCFrame = doorEntry.OpenCFrame or (doorPart.CFrame * CFrame.Angles(0, math.rad(90), 0))
    local tween = TweenService:Create(doorPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        CFrame = openCFrame,
    })
    tween.Completed:Connect(function()
        doorPart.CanCollide = false
    end)
    tween:Play()

    if doorEntry.StateValue then
        doorEntry.StateValue.Value = true
    end
    if doorEntry.Prompt then
        doorEntry.Prompt.Enabled = false
    end

    EventsModule.ScreenTint:FireAllClients(Color3.fromRGB(255, 150, 100))
    EventsModule.AmbientCue:FireAllClients("ExitUnlocked")
end

function ObjectiveController.Init(configModule, mapAssets)
    config = configModule
    assets = mapAssets

    for _, entry in ipairs(assets.FuseEntries) do
        entry.Prompt.Triggered:Connect(function(player)
            if player:GetAttribute("CarryingFuse") then
                return
            end
            local fuseModel = entry.Model
            if fuseModel and fuseModel.Parent then
                fuseModel.Parent = nil
            end
            player:SetAttribute("CarryingFuse", true)
            updateInventory(player)
            EventsModule.ObjectiveUpdate:FireClient(player, "Deliver the fuse to the generator")
        end)
    end

    if assets.GeneratorPrompt then
        assets.GeneratorPrompt.Triggered:Connect(function(player)
            if not player:GetAttribute("CarryingFuse") then
                EventsModule.ObjectiveUpdate:FireClient(player, "You need to be holding a fuse")
                return
            end

            player:SetAttribute("CarryingFuse", false)
            state.FuseDeposited += 1
            updateInventory(player)

            EventsModule.ScreenTint:FireClient(player, Color3.fromRGB(255, 120, 120))
            EventsModule.ObjectiveUpdate:FireClient(player, "Fuse installed. Keep going!")

            if state.FuseDeposited >= config.Objectives.TotalFuses then
                handleExitUnlock()
            else
                updateObjectiveText()
            end
        end)
    end

    for _, switch in ipairs(assets.SwitchEntries) do
        switch.Prompt.Triggered:Connect(function(player)
            EventsModule.AmbientCue:FireAllClients("LightCycle")
            EventsModule.ScreenTint:FireAllClients(Color3.fromRGB(120, 160, 255))
        end)
    end

    updateObjectiveText()
end

function ObjectiveController.OnPlayerAdded(player)
    player:SetAttribute("CarryingFuse", false)
    updateInventory(player)
end

function ObjectiveController.GetFuseProgress()
    return state.FuseDeposited, config.Objectives.TotalFuses
end

return ObjectiveController
