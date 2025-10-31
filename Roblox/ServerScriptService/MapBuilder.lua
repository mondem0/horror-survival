local MapBuilder = {}

local TweenService = game:GetService("TweenService")

local function createBasePart(name, size, position, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Anchored = true
    part.CanCollide = true
    part.Position = position
    part.Color = color
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    return part
end

local function addLight(parent, color, brightness)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = 45
    light.Shadows = true
    light.Parent = parent
    return light
end

local function createProp(parent, propType, cframe)
    if propType == "PipeCluster" then
        for i = 1, 3 do
            local pipe = createBasePart("Pipe", Vector3.new(2, 10, 2), cframe.Position + Vector3.new(i * 3, 5, -2), Color3.fromRGB(60, 60, 70))
            pipe.Material = Enum.Material.Metal
            pipe.Parent = parent
        end
    elseif propType == "CrateStack" then
        for i = 0, 2 do
            local crate = createBasePart("Crate", Vector3.new(6, 4, 6), cframe.Position + Vector3.new(0, 2 + i * 4, 0), Color3.fromRGB(90, 70, 45))
            crate.Material = Enum.Material.Wood
            crate.Parent = parent
        end
    elseif propType == "Console" then
        local desk = createBasePart("Console", Vector3.new(12, 5, 6), cframe.Position + Vector3.new(0, 2.5, 0), Color3.fromRGB(30, 30, 30))
        desk.Material = Enum.Material.Metal
        desk.Parent = parent
        local screen = createBasePart("Screen", Vector3.new(10, 6, 1), desk.Position + Vector3.new(0, 4, -3), Color3.fromRGB(0, 170, 255))
        screen.Material = Enum.Material.Neon
        screen.Parent = parent
    elseif propType == "ServerRack" then
        for i = -1, 1 do
            local rack = createBasePart("ServerRack", Vector3.new(4, 16, 4), cframe.Position + Vector3.new(i * 6, 8, 0), Color3.fromRGB(20, 20, 20))
            rack.Material = Enum.Material.Metal
            rack.Parent = parent
        end
    elseif propType == "Beds" then
        for i = -1, 1 do
            local bed = createBasePart("Bed", Vector3.new(16, 2, 6), cframe.Position + Vector3.new(i * 14, 1, 0), Color3.fromRGB(150, 150, 150))
            bed.Material = Enum.Material.Fabric
            bed.Parent = parent
        end
    elseif propType == "Lockers" then
        for i = -1, 1 do
            local locker = createBasePart("Locker", Vector3.new(4, 14, 4), cframe.Position + Vector3.new(i * 5, 7, 0), Color3.fromRGB(50, 60, 70))
            locker.Material = Enum.Material.Metal
            locker.Parent = parent
        end
    elseif propType == "Generator" then
        local base = createBasePart("GeneratorBase", Vector3.new(20, 6, 20), cframe.Position + Vector3.new(0, 3, 0), Color3.fromRGB(80, 20, 20))
        base.Material = Enum.Material.Metal
        base.Parent = parent
        local core = createBasePart("GeneratorCore", Vector3.new(8, 14, 8), base.Position + Vector3.new(0, 10, 0), Color3.fromRGB(255, 120, 80))
        core.Material = Enum.Material.Neon
        core.Parent = parent
    elseif propType == "FuelTanks" then
        for i = -1, 1 do
            local tank = createBasePart("FuelTank", Vector3.new(6, 16, 6), cframe.Position + Vector3.new(i * 8, 8, 0), Color3.fromRGB(80, 50, 40))
            tank.Material = Enum.Material.Metal
            tank.Parent = parent
        end
    elseif propType == "Workbench" then
        local bench = createBasePart("Workbench", Vector3.new(16, 4, 8), cframe.Position + Vector3.new(0, 2, 0), Color3.fromRGB(70, 50, 40))
        bench.Material = Enum.Material.Wood
        bench.Parent = parent
    elseif propType == "ToolWall" then
        local wall = createBasePart("ToolWall", Vector3.new(2, 12, 16), cframe.Position + Vector3.new(0, 6, 0), Color3.fromRGB(25, 25, 25))
        wall.Material = Enum.Material.Metal
        wall.Parent = parent
    end
end

local function buildRoom(model, room, doorOffsets)
    local center = room.Position
    local floor = createBasePart(room.Name .. "Floor", Vector3.new(room.Size.X, 1, room.Size.Z), center + Vector3.new(0, -0.5 + room.Size.Y * 0.5, 0), room.Color)
    floor.Material = Enum.Material.Concrete
    floor.Parent = model
    addLight(floor, room.LightColor, room.LightBrightness)

    local halfX = room.Size.X / 2
    local halfZ = room.Size.Z / 2
    local height = room.Size.Y

    local function createSegmentedWall(orientation)
        local relevant = {}
        if doorOffsets then
            for _, offset in ipairs(doorOffsets) do
                if orientation == "PositiveX" and math.abs(offset.X - halfX) < 4 then
                    table.insert(relevant, offset.Z)
                elseif orientation == "NegativeX" and math.abs(offset.X + halfX) < 4 then
                    table.insert(relevant, offset.Z)
                elseif orientation == "PositiveZ" and math.abs(offset.Z - halfZ) < 4 then
                    table.insert(relevant, offset.X)
                elseif orientation == "NegativeZ" and math.abs(offset.Z + halfZ) < 4 then
                    table.insert(relevant, offset.X)
                end
            end
        end
        table.sort(relevant)

        local doorHalfWidth = 4
        local segments = {}
        local length = (orientation == "PositiveX" or orientation == "NegativeX") and room.Size.Z or room.Size.X
        local start = -length / 2

        local function addSegment(segStart, segEnd)
            if segEnd <= segStart then
                return
            end
            local segLength = segEnd - segStart
            if orientation == "PositiveX" or orientation == "NegativeX" then
                local x = orientation == "PositiveX" and center.X + halfX or center.X - halfX
                local z = center.Z + segStart + segLength / 2
                local wall = createBasePart("Wall", Vector3.new(2, height, segLength), Vector3.new(x, center.Y + height / 2, z), room.Color)
                wall.Parent = model
            else
                local z = orientation == "PositiveZ" and center.Z + halfZ or center.Z - halfZ
                local x = center.X + segStart + segLength / 2
                local wall = createBasePart("Wall", Vector3.new(segLength, height, 2), Vector3.new(x, center.Y + height / 2, z), room.Color)
                wall.Parent = model
            end
        end

        for _, value in ipairs(relevant) do
            addSegment(start, value - doorHalfWidth)
            start = value + doorHalfWidth
        end
        addSegment(start, length / 2)
    end

    createSegmentedWall("PositiveX")
    createSegmentedWall("NegativeX")
    createSegmentedWall("PositiveZ")
    createSegmentedWall("NegativeZ")

    local propFolder = Instance.new("Folder")
    propFolder.Name = room.Name .. "Props"
    propFolder.Parent = model

    if room.Props then
        for _, prop in ipairs(room.Props) do
            createProp(propFolder, prop.Type, CFrame.new(center + prop.Offset + Vector3.new(0, room.Size.Y * 0.5, 0)))
        end
    end
end

local function createProximityPrompt(parent, actionText, objectText)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.3
    prompt.Enabled = true
    prompt.MaxActivationDistance = 12
    prompt.Parent = parent
    return prompt
end

local function createDoor(folder, doorConfig, roomLookup)
    local basePosition = roomLookup[doorConfig.From] + doorConfig.Offset

    local frame = Instance.new("Model")
    frame.Name = doorConfig.Name
    frame.Parent = folder

    local framePart = createBasePart("Frame", Vector3.new(8, 14, 2), basePosition + Vector3.new(0, 7, 0), Color3.fromRGB(25, 25, 30))
    framePart.Parent = frame

    local doorPart = createBasePart("Door", Vector3.new(6, 12, 1), basePosition + Vector3.new(0, 6, 0), Color3.fromRGB(60, 60, 80))
    doorPart.Material = Enum.Material.Metal
    doorPart.Parent = frame

    frame.PrimaryPart = doorPart
    if doorConfig.Orientation then
        frame:SetPrimaryPartCFrame(CFrame.new(basePosition + Vector3.new(0, 6, 0)) * CFrame.Angles(0, math.rad(doorConfig.Orientation.Y), 0))
    else
        frame:SetPrimaryPartCFrame(CFrame.new(basePosition + Vector3.new(0, 6, 0)))
    end

    local openValue = Instance.new("BoolValue")
    openValue.Name = "IsOpen"
    openValue.Value = false
    openValue.Parent = frame

    local prompt = createProximityPrompt(doorPart, "Toggle", "Door")

    local closedCFrame = doorPart.CFrame
    local openCFrame = closedCFrame * CFrame.Angles(0, math.rad(90), 0)

    prompt.Triggered:Connect(function(player)
        if not doorPart or not doorPart.Parent then
            return
        end
        if openValue.Value then
            local tween = TweenService:Create(doorPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = closedCFrame})
            tween.Completed:Connect(function()
                doorPart.CanCollide = true
            end)
            tween:Play()
            openValue.Value = false
        else
            local tween = TweenService:Create(doorPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = openCFrame})
            tween.Completed:Connect(function()
                doorPart.CanCollide = false
            end)
            tween:Play()
            doorPart.CanCollide = false
            openValue.Value = true
        end
    end)

    return frame
end

local function createFuse(folder, position, index)
    local fuseModel = Instance.new("Model")
    fuseModel.Name = "Fuse" .. index
    fuseModel.Parent = folder

    local fusePart = createBasePart("FuseBody", Vector3.new(2, 4, 2), position + Vector3.new(0, 2, 0), Color3.fromRGB(220, 220, 255))
    fusePart.Material = Enum.Material.Neon
    fusePart.Parent = fuseModel

    local prompt = createProximityPrompt(fusePart, "Take", "Fuse")
    prompt.MaxActivationDistance = 8

    return fuseModel, prompt
end

local function createGenerator(folder, position)
    local generator = Instance.new("Model")
    generator.Name = "Generator"
    generator.Parent = folder

    local base = createBasePart("GeneratorBase", Vector3.new(20, 6, 20), position + Vector3.new(0, 3, 0), Color3.fromRGB(80, 25, 25))
    base.Material = Enum.Material.Metal
    base.Parent = generator

    local core = createBasePart("GeneratorCore", Vector3.new(8, 14, 8), base.Position + Vector3.new(0, 10, 0), Color3.fromRGB(255, 120, 80))
    core.Material = Enum.Material.Neon
    core.Parent = generator

    local prompt = createProximityPrompt(core, "Install", "Fuse")
    prompt.MaxActivationDistance = 10

    return generator, prompt
end

local function createHidingSpot(folder, name, position)
    local locker = Instance.new("Model")
    locker.Name = name
    locker.Parent = folder

    local shell = createBasePart("Shell", Vector3.new(8, 14, 6), position + Vector3.new(0, 7, 0), Color3.fromRGB(45, 45, 55))
    shell.Material = Enum.Material.Metal
    shell.Parent = locker

    local door = createBasePart("Door", Vector3.new(2, 12, 6), position + Vector3.new(3, 6, 0), Color3.fromRGB(60, 60, 75))
    door.Material = Enum.Material.Metal
    door.Parent = locker

    locker.PrimaryPart = shell

    local prompt = createProximityPrompt(door, "Hide", "Locker")
    prompt.MaxActivationDistance = 10

    return locker, prompt
end

local function createSwitch(folder, switchConfig, roomLookup)
    local position = roomLookup[switchConfig.Room] + switchConfig.Offset
    local panel = createBasePart(switchConfig.Name .. "Panel", Vector3.new(2, 6, 8), position + Vector3.new(0, 3, 0), Color3.fromRGB(30, 30, 35))
    panel.Material = Enum.Material.Metal
    panel.Parent = folder

    local prompt = createProximityPrompt(panel, "Toggle", switchConfig.Description or "Switch")
    prompt.MaxActivationDistance = 10

    return panel, prompt
end

function MapBuilder.Build(config)
    local facility = Instance.new("Model")
    facility.Name = "AshenFacility"
    facility.Parent = workspace

    local roomLookup = {}
    for _, room in ipairs(config.Map.Rooms) do
        roomLookup[room.Name] = room.Position
    end

    local doorOffsetsByRoom = {}
    if config.Map.Doors then
        for _, doorConfig in ipairs(config.Map.Doors) do
            doorOffsetsByRoom[doorConfig.From] = doorOffsetsByRoom[doorConfig.From] or {}
            table.insert(doorOffsetsByRoom[doorConfig.From], doorConfig.Offset)

            local toPosition = roomLookup[doorConfig.To]
            if toPosition then
                local worldPosition = roomLookup[doorConfig.From] + doorConfig.Offset
                doorOffsetsByRoom[doorConfig.To] = doorOffsetsByRoom[doorConfig.To] or {}
                table.insert(doorOffsetsByRoom[doorConfig.To], worldPosition - toPosition)
            end
        end
    end

    local patrolPoints = {}

    for _, room in ipairs(config.Map.Rooms) do
        buildRoom(facility, room, doorOffsetsByRoom[room.Name])
        if room.PatrolNodes then
            for _, node in ipairs(room.PatrolNodes) do
                table.insert(patrolPoints, node)
            end
        end
    end

    local doorFolder = Instance.new("Folder")
    doorFolder.Name = "Doors"
    doorFolder.Parent = facility

    local doorsByName = {}
    if config.Map.Doors then
        for _, doorConfig in ipairs(config.Map.Doors) do
            local door = createDoor(doorFolder, doorConfig, roomLookup)
            doorsByName[doorConfig.Name] = door
        end
    end

    local fuseFolder = Instance.new("Folder")
    fuseFolder.Name = "Fuses"
    fuseFolder.Parent = facility

    local fuseEntries = {}
    if config.Map.FuseLocations then
        for index, fuse in ipairs(config.Map.FuseLocations) do
            local position = roomLookup[fuse.Room] + fuse.Offset
            local model, prompt = createFuse(fuseFolder, position, index)
            fuseEntries[#fuseEntries + 1] = {Model = model, Prompt = prompt, Position = position}
        end
    end

    local generatorFolder = Instance.new("Folder")
    generatorFolder.Name = "Generator"
    generatorFolder.Parent = facility

    local generator, generatorPrompt = createGenerator(generatorFolder, roomLookup["GeneratorRoom"] + Vector3.new(0, 0, 0))

    local hidingFolder = Instance.new("Folder")
    hidingFolder.Name = "HidingSpots"
    hidingFolder.Parent = facility

    local hidingEntries = {}
    if config.Map.HidingSpots then
        for _, hiding in ipairs(config.Map.HidingSpots) do
            local position = roomLookup[hiding.Room] + hiding.Offset
            local model, prompt = createHidingSpot(hidingFolder, hiding.Name, position)
            hidingEntries[#hidingEntries + 1] = {Model = model, Prompt = prompt}
        end
    end

    local switchFolder = Instance.new("Folder")
    switchFolder.Name = "Switches"
    switchFolder.Parent = facility

    local switchEntries = {}
    if config.Map.Switches then
        for _, switchConfig in ipairs(config.Map.Switches) do
            local panel, prompt = createSwitch(switchFolder, switchConfig, roomLookup)
            switchEntries[#switchEntries + 1] = {Panel = panel, Prompt = prompt, Config = switchConfig}
        end
    end

    local crawlerNests = {}
    if config.Map.CrawlerNests then
        for _, nest in ipairs(config.Map.CrawlerNests) do
            local marker = createBasePart("CrawlerNest", Vector3.new(6, 2, 6), nest + Vector3.new(0, 1, 0), Color3.fromRGB(15, 15, 15))
            marker.Material = Enum.Material.Rock
            marker.Parent = facility
            marker.Transparency = 0.4
            marker.CanCollide = false
            table.insert(crawlerNests, marker)
        end
    end

    return {
        FacilityModel = facility,
        RoomLookup = roomLookup,
        Doors = doorsByName,
        PatrolPoints = patrolPoints,
        FuseEntries = fuseEntries,
        Generator = generator,
        GeneratorPrompt = generatorPrompt,
        HidingEntries = hidingEntries,
        SwitchEntries = switchEntries,
        CrawlerNests = crawlerNests,
    }
end

return MapBuilder
