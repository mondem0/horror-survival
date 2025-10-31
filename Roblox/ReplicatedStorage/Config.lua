local Config = {}

Config.GameName = "Ashen Echoes"
Config.Description = "Navigate the abandoned geothermal facility, gather fuses to reignite the core, and escape before the entities consume the heat that keeps you alive."

Config.Map = {
    BaseHeight = 0,
    Rooms = {
        {
            Name = "Atrium",
            Position = Vector3.new(0, 0, 0),
            Size = Vector3.new(70, 20, 70),
            Color = Color3.fromRGB(45, 45, 60),
            LightColor = Color3.fromRGB(170, 200, 255),
            LightBrightness = 2.6,
            Props = {
                {Type = "PipeCluster", Offset = Vector3.new(-20, 0, 10)},
                {Type = "CrateStack", Offset = Vector3.new(15, 0, -18)},
            },
            PatrolNodes = {
                Vector3.new(0, 0, 0),
                Vector3.new(20, 0, 18),
                Vector3.new(-25, 0, -22),
            },
        },
        {
            Name = "Laboratory",
            Position = Vector3.new(90, 0, 0),
            Size = Vector3.new(60, 20, 60),
            Color = Color3.fromRGB(40, 35, 55),
            LightColor = Color3.fromRGB(255, 160, 120),
            LightBrightness = 1.8,
            Props = {
                {Type = "Console", Offset = Vector3.new(-10, 0, 0)},
                {Type = "ServerRack", Offset = Vector3.new(18, 0, 15)},
            },
            PatrolNodes = {
                Vector3.new(90, 0, -18),
                Vector3.new(115, 0, 15),
                Vector3.new(65, 0, 18),
            },
        },
        {
            Name = "CrewQuarters",
            Position = Vector3.new(-90, 0, 0),
            Size = Vector3.new(60, 20, 60),
            Color = Color3.fromRGB(35, 35, 40),
            LightColor = Color3.fromRGB(255, 200, 160),
            LightBrightness = 1.2,
            Props = {
                {Type = "Beds", Offset = Vector3.new(10, 0, -10)},
                {Type = "Lockers", Offset = Vector3.new(-15, 0, 20)},
            },
            PatrolNodes = {
                Vector3.new(-95, 0, -20),
                Vector3.new(-60, 0, 15),
                Vector3.new(-115, 0, 20),
            },
        },
        {
            Name = "GeneratorRoom",
            Position = Vector3.new(0, 0, -100),
            Size = Vector3.new(70, 20, 70),
            Color = Color3.fromRGB(30, 25, 30),
            LightColor = Color3.fromRGB(255, 80, 60),
            LightBrightness = 1.6,
            Props = {
                {Type = "Generator", Offset = Vector3.new(0, 0, 10)},
                {Type = "FuelTanks", Offset = Vector3.new(-20, 0, -15)},
            },
            PatrolNodes = {
                Vector3.new(10, 0, -120),
                Vector3.new(-25, 0, -95),
                Vector3.new(25, 0, -80),
            },
        },
        {
            Name = "Maintenance",
            Position = Vector3.new(0, 0, 100),
            Size = Vector3.new(60, 20, 60),
            Color = Color3.fromRGB(25, 25, 28),
            LightColor = Color3.fromRGB(200, 255, 200),
            LightBrightness = 1.4,
            Props = {
                {Type = "Workbench", Offset = Vector3.new(-10, 0, -15)},
                {Type = "ToolWall", Offset = Vector3.new(18, 0, 10)},
            },
            PatrolNodes = {
                Vector3.new(-20, 0, 105),
                Vector3.new(20, 0, 85),
                Vector3.new(0, 0, 120),
            },
        },
    },
    Doors = {
        {Name = "AtriumLabDoor", From = "Atrium", To = "Laboratory", Offset = Vector3.new(35, 0, -20), Orientation = Vector3.new(0, 90, 0)},
        {Name = "AtriumCrewDoor", From = "Atrium", To = "CrewQuarters", Offset = Vector3.new(-35, 0, 20), Orientation = Vector3.new(0, 90, 0)},
        {Name = "AtriumGeneratorDoor", From = "Atrium", To = "GeneratorRoom", Offset = Vector3.new(0, 0, -35), Orientation = Vector3.new(0, 0, 0)},
        {Name = "AtriumMaintenanceDoor", From = "Atrium", To = "Maintenance", Offset = Vector3.new(0, 0, 35), Orientation = Vector3.new(0, 0, 0)},
    },
    HidingSpots = {
        {Name = "LockerA", Room = "CrewQuarters", Offset = Vector3.new(-20, 0, 18)},
        {Name = "LockerB", Room = "Maintenance", Offset = Vector3.new(18, 0, 12)},
        {Name = "LockerC", Room = "Laboratory", Offset = Vector3.new(20, 0, -12)},
    },
    Switches = {
        {Name = "AtriumSwitch", Room = "Atrium", Offset = Vector3.new(25, 0, 30), Description = "Cycle Emergency Lighting"},
    },
    FuseLocations = {
        {Room = "Laboratory", Offset = Vector3.new(-15, 0, 10)},
        {Room = "CrewQuarters", Offset = Vector3.new(15, 0, -15)},
        {Room = "Maintenance", Offset = Vector3.new(-12, 0, 12)},
        {Room = "Maintenance", Offset = Vector3.new(0, 0, -18)},
    },
    CrawlerNests = {
        Vector3.new(90, 0, 25),
        Vector3.new(-90, 0, -25),
        Vector3.new(0, 0, 90),
        Vector3.new(0, 0, -125),
    }
}

Config.Objectives = {
    TotalFuses = 3,
    ExitDoorName = "AtriumGeneratorDoor",
}

Config.Player = {
    BaseWalkSpeed = 12,
    SprintSpeed = 18,
    MaxStamina = 100,
    StaminaDrain = 23,
    StaminaRecovery = 14,
    MaxHealth = 100,
}

Config.Enemies = {
    Wraith = {
        SpawnRoom = "GeneratorRoom",
        MoveSpeed = 13,
        RunSpeed = 19,
        VisionRange = 110,
        PeripheralVision = math.rad(70),
        HearRange = 70,
        Damage = 25,
        AttackCooldown = 2.8,
    },
    Crawler = {
        MoveSpeed = 8,
        LeapSpeed = 26,
        VisionRange = 65,
        HearRange = 100,
        AmbushCooldown = 6,
        Damage = 35,
    },
}

return Config
