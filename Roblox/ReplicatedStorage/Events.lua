local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(parent, className, name)
    local instance = parent:FindFirstChild(name)
    if instance then
        return instance
    end

    instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

local EventsFolder = getOrCreate(ReplicatedStorage, "Folder", "AshenEvents")

local Events = {
    ObjectiveUpdate = getOrCreate(EventsFolder, "RemoteEvent", "ObjectiveUpdate"),
    InventoryUpdate = getOrCreate(EventsFolder, "RemoteEvent", "InventoryUpdate"),
    PlayerHidden = getOrCreate(EventsFolder, "RemoteEvent", "PlayerHidden"),
    AmbientCue = getOrCreate(EventsFolder, "RemoteEvent", "AmbientCue"),
    StaminaUpdate = getOrCreate(EventsFolder, "RemoteEvent", "StaminaUpdate"),
    DamagePulse = getOrCreate(EventsFolder, "RemoteEvent", "DamagePulse"),
    ScreenTint = getOrCreate(EventsFolder, "RemoteEvent", "ScreenTint"),
}

return Events
