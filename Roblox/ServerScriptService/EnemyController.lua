local EnemyController = {}

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Config"))
local Events = require(game:GetService("ReplicatedStorage"):WaitForChild("Events"))

local playerService
local assets

local enemies = {}

local function createEnemyModel(enemyType)
    local model = Instance.new("Model")
    model.Name = enemyType

    local root = Instance.new("Part")
    root.Name = "Root"
    root.Size = Vector3.new(4, 6, 4)
    root.Anchored = false
    root.CanCollide = true
    root.Color = enemyType == "Wraith" and Color3.fromRGB(120, 120, 160) or Color3.fromRGB(30, 30, 30)
    root.Material = enemyType == "Wraith" and Enum.Material.Neon or Enum.Material.Metal
    root.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "EnemyHumanoid"
    humanoid.MaxHealth = 200
    humanoid.Health = 200
    humanoid.WalkSpeed = Config.Enemies[enemyType].MoveSpeed
    humanoid.Parent = model

    model.PrimaryPart = root

    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 18
    light.Color = enemyType == "Wraith" and Color3.fromRGB(255, 100, 255) or Color3.fromRGB(255, 70, 70)
    light.Parent = root

    if enemyType == "Wraith" then
        local trail = Instance.new("Trail")
        trail.Name = "Aura"
        trail.Attachment0 = Instance.new("Attachment", root)
        trail.Attachment1 = Instance.new("Attachment", root)
        trail.Attachment1.Position = Vector3.new(0, 4, 0)
        trail.Color = ColorSequence.new(Color3.fromRGB(200, 80, 255), Color3.fromRGB(80, 10, 120))
        trail.Transparency = NumberSequence.new(0.4, 1)
        trail.Lifetime = 0.4
        trail.Parent = root
    else
        local particle = Instance.new("ParticleEmitter")
        particle.Name = "Embers"
        particle.Rate = 18
        particle.Texture = "rbxassetid://4844360585"
        particle.Lifetime = NumberRange.new(0.8, 1.2)
        particle.Speed = NumberRange.new(0, 1)
        particle.Parent = root
    end

    local sound = Instance.new("Sound")
    sound.Name = "Roar"
    sound.SoundId = enemyType == "Wraith" and "rbxassetid://183763515" or "rbxassetid://913376220"
    sound.Volume = 0.5
    sound.Parent = root

    local footstep = Instance.new("Sound")
    footstep.Name = "Footstep"
    footstep.SoundId = "rbxassetid://142120557"
    footstep.Volume = 0.2
    footstep.Looped = true
    footstep.Parent = root
    footstep:Play()

    return model, humanoid, root
end

local function spawnEnemy(enemyType, spawnPosition)
    local model, humanoid, root = createEnemyModel(enemyType)
    model.Parent = workspace
    model:SetPrimaryPartCFrame(CFrame.new(spawnPosition + Vector3.new(0, 5, 0)))

    local info = {
        Type = enemyType,
        Model = model,
        Humanoid = humanoid,
        Root = root,
        State = enemyType == "Crawler" and "Dormant" or "Patrolling",
        Target = nil,
        Cooldown = 0,
        PatrolGoal = nil,
    }

    enemies[#enemies + 1] = info
    return info
end

local function getNearestPlayer(position, range)
    local nearest
    local nearestDistance = range

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and not player:GetAttribute("IsHidden") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local distance = (root.Position - position).Magnitude
                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearest = player
                end
            end
        end
    end

    return nearest, nearestDistance
end

local function canSeeTarget(enemyRoot, targetRoot, peripheral)
    local direction = (targetRoot.Position - enemyRoot.Position)
    local distance = direction.Magnitude
    local lookVector = enemyRoot.CFrame.LookVector
    local dot = lookVector:Dot(direction.Unit)
    local angle = math.acos(math.clamp(dot, -1, 1))

    if angle > peripheral then
        return false
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {enemyRoot.Parent, workspace.Terrain}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(enemyRoot.Position, direction, rayParams)
    if result and result.Instance and result.Instance:IsDescendantOf(targetRoot.Parent) then
        return true
    end

    if not result then
        return true
    end

    return false
end

local function moveToPosition(info, position)
    if not info.Model or not info.Model.Parent then
        return
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 6,
        AgentCanJump = true,
    })

    path:ComputeAsync(info.Root.Position, position)
    local waypoints = path:GetWaypoints()
    for _, waypoint in ipairs(waypoints) do
        if not info.Model.Parent then
            break
        end
        info.Humanoid:MoveTo(waypoint.Position)
        info.Humanoid.MoveToFinished:Wait()
    end
end

local function playSound(root, soundName)
    local sound = root:FindFirstChild(soundName)
    if sound then
        sound:Play()
    end
end

local function updateWraith(info, deltaTime)
    local settings = Config.Enemies.Wraith
    info.Humanoid.WalkSpeed = settings.MoveSpeed

    if info.Cooldown > 0 then
        info.Cooldown -= deltaTime
    end

    local target, distance = getNearestPlayer(info.Root.Position, settings.VisionRange)
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and canSeeTarget(info.Root, targetRoot, settings.PeripheralVision) then
            info.State = "Chasing"
            info.Target = target
            info.Humanoid.WalkSpeed = settings.RunSpeed
            info.Humanoid:MoveTo(targetRoot.Position)
            if distance < 6 and info.Cooldown <= 0 then
                playerService.ApplyDamage(target, settings.Damage)
                Events.AmbientCue:FireClient(target, "WraithStrike")
                playSound(info.Root, "Roar")
                info.Cooldown = settings.AttackCooldown
            end
            return
        end
    end

    if info.State ~= "Patrolling" or not info.PatrolGoal then
        info.PatrolGoal = assets.PatrolPoints[math.random(1, #assets.PatrolPoints)]
        info.State = "Patrolling"
    end

    if info.PatrolGoal then
        info.Humanoid:MoveTo(info.PatrolGoal)
        if (info.Root.Position - info.PatrolGoal).Magnitude < 5 then
            info.PatrolGoal = assets.PatrolPoints[math.random(1, #assets.PatrolPoints)]
        end
    end
end

local function updateCrawler(info, deltaTime)
    local settings = Config.Enemies.Crawler

    if info.Cooldown > 0 then
        info.Cooldown -= deltaTime
    end

    if info.State == "Dormant" then
        local target, distance = getNearestPlayer(info.Root.Position, settings.HearRange)
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and distance < settings.VisionRange then
                info.State = "Ambushing"
                info.Target = target
                playSound(info.Root, "Roar")
            end
        end
    elseif info.State == "Ambushing" then
        if not info.Target or not info.Target.Character then
            info.State = "Dormant"
            return
        end

        local targetRoot = info.Target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            info.State = "Dormant"
            return
        end

        local direction = (targetRoot.Position - info.Root.Position).Unit
        info.Humanoid:Move(Vector3.new(direction.X, 0, direction.Z), true)
        info.Humanoid.WalkSpeed = settings.LeapSpeed

        if (info.Root.Position - targetRoot.Position).Magnitude < 5 and info.Cooldown <= 0 then
            playerService.ApplyDamage(info.Target, settings.Damage)
            Events.AmbientCue:FireClient(info.Target, "CrawlerStrike")
            info.Cooldown = settings.AmbushCooldown
            info.State = "Evading"
        end
    elseif info.State == "Evading" then
        if info.Cooldown <= settings.AmbushCooldown * 0.5 then
            info.Humanoid.WalkSpeed = settings.MoveSpeed
            info.State = "Dormant"
            info.Target = nil
            info.Cooldown = math.max(0, info.Cooldown - 0.5)
        end
    end
end

local function maintainEnemies(deltaTime)
    for index = #enemies, 1, -1 do
        local info = enemies[index]
        if not info.Model or not info.Model.Parent then
            table.remove(enemies, index)
        elseif info.Type == "Wraith" then
            updateWraith(info, deltaTime)
        else
            updateCrawler(info, deltaTime)
        end
    end
end

function EnemyController.Init(configModule, mapAssets, playerModule)
    assets = mapAssets
    playerService = playerModule

    local wraithSpawn = assets.Spawns and (assets.Spawns.Wraith or assets.Spawns[configModule.Map.WraithSpawnName])
    if not wraithSpawn then
        warn("[AshenEchoes] Wraith spawn point missing; defaulting to origin.")
        wraithSpawn = Vector3.new(0, 0, 0)
    end

    spawnEnemy("Wraith", wraithSpawn)

    if assets.CrawlerNests and #assets.CrawlerNests > 0 then
        for _, nest in ipairs(assets.CrawlerNests) do
            spawnEnemy("Crawler", nest.Position)
        end
    else
        warn("[AshenEchoes] No crawler nests found; spawning a crawler near the Wraith.")
        spawnEnemy("Crawler", wraithSpawn + Vector3.new(15, 0, 0))
    end

    if not assets.PatrolPoints or #assets.PatrolPoints == 0 then
        assets.PatrolPoints = {wraithSpawn}
    end

    RunService.Heartbeat:Connect(function(deltaTime)
        maintainEnemies(deltaTime)
    end)
end

return EnemyController
