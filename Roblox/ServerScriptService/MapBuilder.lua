local MapBuilder = {}

local TweenService = game:GetService("TweenService")

local function ensurePrimaryPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            model.PrimaryPart = descendant
            return descendant
        end
    end

    return nil
end

local function ensurePrompt(parent, actionText, objectText, maxDistance)
    local prompt = nil
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            prompt = child
            break
        end
    end

    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0.3
        prompt.Parent = parent
    end

    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.MaxActivationDistance = maxDistance or prompt.MaxActivationDistance

    if prompt.MaxActivationDistance == 0 then
        prompt.MaxActivationDistance = 10
    end

    return prompt
end

local function configureDoor(model)
    local doorPart = model:FindFirstChild("Door")
    if not doorPart then
        doorPart = ensurePrimaryPart(model)
    elseif doorPart:IsA("BasePart") == false then
        doorPart = ensurePrimaryPart(model)
    end

    if not doorPart then
        warn(string.format("[AshenEchoes] Door model '%s' is missing a usable BasePart", model:GetFullName()))
        return nil
    end

    local prompt = ensurePrompt(doorPart, "Toggle", "Door", 10)
    local closedCFrame = doorPart.CFrame
    local openAngle = doorPart:GetAttribute("OpenAngle") or 90
    local openCFrame = closedCFrame * CFrame.Angles(0, math.rad(openAngle), 0)

    local openValue = model:FindFirstChild("IsOpen")
    if not openValue then
        openValue = Instance.new("BoolValue")
        openValue.Name = "IsOpen"
        openValue.Value = false
        openValue.Parent = model
    end

    prompt.Triggered:Connect(function()
        if not doorPart or not doorPart.Parent then
            return
        end

        local targetCFrame
        if openValue.Value then
            targetCFrame = closedCFrame
        else
            targetCFrame = openCFrame
        end

        local tween = TweenService:Create(doorPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            CFrame = targetCFrame,
        })
        tween.Completed:Connect(function()
            doorPart.CanCollide = not openValue.Value
        end)
        tween:Play()

        doorPart.CanCollide = false
        openValue.Value = not openValue.Value
    end)

    return {
        Model = model,
        DoorPart = doorPart,
        Prompt = prompt,
        ClosedCFrame = closedCFrame,
        OpenCFrame = openCFrame,
        StateValue = openValue,
    }
end

local function registerFuse(instance, index)
    local basePart = instance
    if instance:IsA("Model") then
        basePart = ensurePrimaryPart(instance)
    end

    if not basePart or not basePart:IsA("BasePart") then
        warn(string.format("[AshenEchoes] Fuse %s is missing a BasePart to attach the prompt", instance:GetFullName()))
        return nil
    end

    local prompt = ensurePrompt(basePart, "Take", "Fuse", 8)
    return {
        Model = instance,
        Prompt = prompt,
        Index = index,
    }
end

local function registerHidingSpot(model)
    local primary = ensurePrimaryPart(model)
    if not primary then
        warn(string.format("[AshenEchoes] Hiding spot '%s' needs a PrimaryPart", model:GetFullName()))
        return nil
    end

    local door = model:FindFirstChild("Door")
    local promptPart = (door and door:IsA("BasePart")) and door or primary
    local prompt = ensurePrompt(promptPart, "Hide", "Locker", 10)

    return {
        Model = model,
        Prompt = prompt,
    }
end

local function registerSwitch(instance)
    local basePart = instance
    if instance:IsA("Model") then
        basePart = ensurePrimaryPart(instance)
    end

    if not basePart or not basePart:IsA("BasePart") then
        warn(string.format("[AshenEchoes] Switch '%s' requires a BasePart", instance:GetFullName()))
        return nil
    end

    local prompt = ensurePrompt(basePart, "Toggle", "Switch", 10)
    return {
        Model = instance,
        Prompt = prompt,
    }
end

local function getFolder(root, name)
    if not root then
        return nil
    end
    local folder = root:FindFirstChild(name)
    if not folder then
        warn(string.format("[AshenEchoes] Expected folder '%s' under %s", name, root:GetFullName()))
        return nil
    end
    return folder
end

function MapBuilder.Build(config)
    local mapSettings = config.Map
    local root = workspace:FindFirstChild(mapSettings.RootModelName)
    if not root then
        warn(string.format("[AshenEchoes] Place a Model named '%s' in workspace containing the handcrafted map.", mapSettings.RootModelName))
        return {
            Doors = {},
            PatrolPoints = {},
            FuseEntries = {},
            Generator = nil,
            GeneratorPrompt = nil,
            HidingEntries = {},
            SwitchEntries = {},
            CrawlerNests = {},
            Spawns = {},
        }
    end

    local assets = {
        FacilityModel = root,
        Doors = {},
        PatrolPoints = {},
        FuseEntries = {},
        Generator = nil,
        GeneratorPrompt = nil,
        HidingEntries = {},
        SwitchEntries = {},
        CrawlerNests = {},
        Spawns = {},
    }

    local doorsFolder = getFolder(root, mapSettings.DoorFolderName)
    if doorsFolder then
        for _, doorModel in ipairs(doorsFolder:GetChildren()) do
            if doorModel:IsA("Model") then
                local entry = configureDoor(doorModel)
                if entry then
                    assets.Doors[doorModel.Name] = entry
                end
            end
        end
    end

    local fuseFolder = getFolder(root, mapSettings.FuseFolderName)
    if fuseFolder then
        local index = 0
        for _, fuse in ipairs(fuseFolder:GetChildren()) do
            if fuse:IsA("Model") or fuse:IsA("BasePart") then
                index += 1
                local entry = registerFuse(fuse, index)
                if entry then
                    table.insert(assets.FuseEntries, entry)
                end
            end
        end
    end

    local generatorModel = root:FindFirstChild(mapSettings.GeneratorName, true)
    if generatorModel then
        assets.Generator = generatorModel
        local promptPart = generatorModel:FindFirstChild(mapSettings.GeneratorPromptPartName, true)
        if promptPart and promptPart:IsA("BasePart") then
            assets.GeneratorPrompt = ensurePrompt(promptPart, "Install", "Fuse", 10)
        else
            local target = ensurePrimaryPart(generatorModel)
            if target then
                assets.GeneratorPrompt = ensurePrompt(target, "Install", "Fuse", 10)
            end
        end
    else
        warn(string.format("[AshenEchoes] Could not find generator model '%s'", mapSettings.GeneratorName))
    end

    local hidingFolder = getFolder(root, mapSettings.HidingFolderName)
    if hidingFolder then
        for _, hidingModel in ipairs(hidingFolder:GetChildren()) do
            if hidingModel:IsA("Model") then
                local entry = registerHidingSpot(hidingModel)
                if entry then
                    table.insert(assets.HidingEntries, entry)
                end
            end
        end
    end

    local switchFolder = getFolder(root, mapSettings.SwitchFolderName)
    if switchFolder then
        for _, switchInstance in ipairs(switchFolder:GetChildren()) do
            if switchInstance:IsA("Model") or switchInstance:IsA("BasePart") then
                local entry = registerSwitch(switchInstance)
                if entry then
                    table.insert(assets.SwitchEntries, entry)
                end
            end
        end
    end

    local patrolFolder = getFolder(root, mapSettings.PatrolFolderName)
    if patrolFolder then
        for _, node in ipairs(patrolFolder:GetChildren()) do
            if node:IsA("BasePart") then
                table.insert(assets.PatrolPoints, node.Position)
            end
        end
    end

    local nestFolder = getFolder(root, mapSettings.CrawlerNestFolderName)
    if nestFolder then
        for _, nest in ipairs(nestFolder:GetChildren()) do
            if nest:IsA("BasePart") then
                table.insert(assets.CrawlerNests, {
                    Name = nest.Name,
                    Position = nest.Position,
                })
            end
        end
    end

    local spawnFolder = getFolder(root, mapSettings.SpawnFolderName)
    if spawnFolder then
        for _, spawn in ipairs(spawnFolder:GetChildren()) do
            if spawn:IsA("BasePart") then
                assets.Spawns[spawn.Name] = spawn.Position
            end
        end
    end

    if not assets.Spawns.Wraith and spawnFolder and mapSettings.WraithSpawnName then
        local spawnPart = spawnFolder:FindFirstChild(mapSettings.WraithSpawnName)
        if spawnPart and spawnPart:IsA("BasePart") then
            assets.Spawns.Wraith = spawnPart.Position
        end
    end

    return assets
end

return MapBuilder
