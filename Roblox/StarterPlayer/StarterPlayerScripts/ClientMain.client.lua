local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local events = require(ReplicatedStorage:WaitForChild("Events"))
local config = require(ReplicatedStorage:WaitForChild("Config"))

local gui
local healthBar
local staminaBar
local objectiveLabel
local inventoryLabel
local tintFrame
local hideLabel

local stamina = config.Player.MaxStamina
local sprinting = false
local flashlightOn = false

local function createUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "HorrorHUD"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local panel = Instance.new("Frame")
    panel.Name = "StatusPanel"
    panel.BackgroundTransparency = 0.4
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    panel.Size = UDim2.new(0, 320, 0, 120)
    panel.Position = UDim2.new(0, 20, 1, -140)
    panel.BorderSizePixel = 0
    panel.Parent = gui

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = config.GameName
    title.TextColor3 = Color3.fromRGB(255, 130, 100)
    title.TextSize = 26
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.Parent = panel

    local healthBackground = Instance.new("Frame")
    healthBackground.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
    healthBackground.BackgroundTransparency = 0.3
    healthBackground.BorderSizePixel = 0
    healthBackground.Size = UDim2.new(1, -40, 0, 18)
    healthBackground.Position = UDim2.new(0, 20, 0, 46)
    healthBackground.Parent = panel

    healthBar = Instance.new("Frame")
    healthBar.Name = "HealthFill"
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBackground

    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Text = "HEALTH"
    healthText.Font = Enum.Font.Gotham
    healthText.TextColor3 = Color3.fromRGB(255, 180, 180)
    healthText.TextSize = 12
    healthText.TextXAlignment = Enum.TextXAlignment.Left
    healthText.BackgroundTransparency = 1
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Parent = healthBackground

    local staminaBackground = healthBackground:Clone()
    staminaBackground.Position = UDim2.new(0, 20, 0, 76)
    staminaBackground.BackgroundColor3 = Color3.fromRGB(10, 30, 30)
    staminaBackground.Parent = panel

    staminaBar = staminaBackground.HealthFill
    staminaBar.BackgroundColor3 = Color3.fromRGB(120, 255, 220)
    staminaBar.Name = "StaminaFill"
    staminaBar.Parent = staminaBackground

    local staminaText = staminaBackground.HealthText
    staminaText.Text = "STAMINA"
    staminaText.TextColor3 = Color3.fromRGB(180, 255, 220)

    objectiveLabel = Instance.new("TextLabel")
    objectiveLabel.Name = "Objective"
    objectiveLabel.BackgroundTransparency = 0.3
    objectiveLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    objectiveLabel.TextColor3 = Color3.fromRGB(255, 230, 220)
    objectiveLabel.TextSize = 18
    objectiveLabel.Font = Enum.Font.GothamSemibold
    objectiveLabel.TextWrapped = true
    objectiveLabel.Size = UDim2.new(0.36, 0, 0, 70)
    objectiveLabel.Position = UDim2.new(0.62, -40, 1, -110)
    objectiveLabel.BorderSizePixel = 0
    objectiveLabel.Parent = gui

    inventoryLabel = Instance.new("TextLabel")
    inventoryLabel.Name = "Inventory"
    inventoryLabel.BackgroundTransparency = 1
    inventoryLabel.TextColor3 = Color3.fromRGB(255, 210, 160)
    inventoryLabel.Font = Enum.Font.Gotham
    inventoryLabel.TextSize = 18
    inventoryLabel.TextXAlignment = Enum.TextXAlignment.Right
    inventoryLabel.Size = UDim2.new(0, 220, 0, 40)
    inventoryLabel.Position = UDim2.new(1, -240, 0, 30)
    inventoryLabel.Parent = gui

    tintFrame = Instance.new("Frame")
    tintFrame.Name = "Tint"
    tintFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tintFrame.BackgroundTransparency = 1
    tintFrame.Size = UDim2.new(1, 0, 1, 0)
    tintFrame.Parent = gui

    hideLabel = Instance.new("TextLabel")
    hideLabel.Name = "HideStatus"
    hideLabel.BackgroundTransparency = 1
    hideLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
    hideLabel.TextSize = 20
    hideLabel.Font = Enum.Font.GothamBold
    hideLabel.Text = ""
    hideLabel.Size = UDim2.new(1, 0, 0, 40)
    hideLabel.Position = UDim2.new(0, 0, 0, 80)
    hideLabel.Parent = gui
end

local function updateStaminaBar()
    local ratio = math.clamp(stamina / config.Player.MaxStamina, 0, 1)
    staminaBar.Size = UDim2.new(ratio, 0, 1, 0)
end

local function attachFlashlight(character)
    local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if head and not head:FindFirstChild("Flashlight") then
        local light = Instance.new("SpotLight")
        light.Name = "Flashlight"
        light.Angle = 80
        light.Brightness = 3.4
        light.Range = 70
        light.Enabled = flashlightOn
        light.Parent = head
    end
end

local function toggleFlashlight()
    flashlightOn = not flashlightOn
    if player.Character then
        local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
        if head then
            local light = head:FindFirstChild("Flashlight")
            if light then
                light.Enabled = flashlightOn
            end
        end
    end
end

local function setTint(color)
    local tween = TweenService:Create(tintFrame, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5,
        BackgroundColor3 = color,
    })
    tween:Play()
    task.delay(0.6, function()
        if tintFrame then
            TweenService:Create(tintFrame, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        end
    end)
end

local function onCharacterAdded(character)
    character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
        local ratio = math.clamp(health / character.Humanoid.MaxHealth, 0, 1)
        healthBar.Size = UDim2.new(ratio, 0, 1, 0)
    end)
    attachFlashlight(character)
end

local function processInput(actionName, inputState)
    if actionName == "Sprint" then
        sprinting = inputState == Enum.UserInputState.Begin
    elseif actionName == "Flashlight" and inputState == Enum.UserInputState.Begin then
        toggleFlashlight()
    end
end

local function bindInputs()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            processInput("Sprint", Enum.UserInputState.Begin)
        elseif input.KeyCode == Enum.KeyCode.F then
            processInput("Flashlight", Enum.UserInputState.Begin)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftShift then
            processInput("Sprint", Enum.UserInputState.End)
        end
    end)
end

local function updateInventoryDisplay(data)
    inventoryLabel.Text = string.format("Fuses: %d / %d  |  Deposited: %d", data.CarriedFuses or 0, 1, data.Deposited or 0)
end

local function updateHideState(hidden)
    if hidden then
        hideLabel.Text = "Hidden"
        hideLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
    else
        hideLabel.Text = ""
    end
end

createUI()
bindInputs()

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

RunService.RenderStepped:Connect(function(deltaTime)
    if not player.Character then
        return
    end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if sprinting and stamina > 0 then
        humanoid.WalkSpeed = config.Player.SprintSpeed
        stamina = math.clamp(stamina - config.Player.StaminaDrain * deltaTime, 0, config.Player.MaxStamina)
        if stamina <= 0 then
            sprinting = false
        end
    else
        humanoid.WalkSpeed = config.Player.BaseWalkSpeed
        stamina = math.clamp(stamina + config.Player.StaminaRecovery * deltaTime, 0, config.Player.MaxStamina)
    end

    player:SetAttribute("Stamina", stamina)
    updateStaminaBar()
end)

events.ObjectiveUpdate.OnClientEvent:Connect(function(text)
    objectiveLabel.Text = text
end)

events.InventoryUpdate.OnClientEvent:Connect(function(data)
    updateInventoryDisplay(data)
end)

events.PlayerHidden.OnClientEvent:Connect(function(hidden)
    updateHideState(hidden)
end)

events.ScreenTint.OnClientEvent:Connect(function(color)
    setTint(color)
end)

events.DamagePulse.OnClientEvent:Connect(function()
    setTint(Color3.fromRGB(255, 60, 60))
end)

events.AmbientCue.OnClientEvent:Connect(function(cue)
    if cue == "LightCycle" then
        local blur = Instance.new("BlurEffect")
        blur.Size = 16
        blur.Parent = Lighting
        task.delay(1.2, function()
            if blur then
                blur:Destroy()
            end
        end)
    elseif cue == "WraithStrike" then
        objectiveLabel.Text = "It is right behind you!"
    elseif cue == "CrawlerStrike" then
        objectiveLabel.Text = "It lunged from the dark!"
    elseif cue == "ExitUnlocked" then
        objectiveLabel.Text = "The lift is open!"
    end
end)

player:GetAttributeChangedSignal("IsHidden"):Connect(function()
    updateHideState(player:GetAttribute("IsHidden"))
end)

updateHideState(player:GetAttribute("IsHidden"))
updateInventoryDisplay({CarriedFuses = 0, Deposited = 0})
objectiveLabel.Text = "Explore the facility and find fuses."
