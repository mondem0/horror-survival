local Config = {}

Config.GameName = "Ashen Echoes"
Config.Description = "Navigate the abandoned geothermal facility, gather fuses to reignite the core, and escape before the entities consume the heat that keeps you alive."

Config.Map = {
    RootModelName = "AshenEchoesMap",
    DoorFolderName = "Doors",
    FuseFolderName = "Fuses",
    SwitchFolderName = "Switches",
    HidingFolderName = "HidingSpots",
    GeneratorName = "GeneratorConsole",
    GeneratorPromptPartName = "Core",
    PatrolFolderName = "PatrolNodes",
    CrawlerNestFolderName = "CrawlerNests",
    SpawnFolderName = "Spawns",
    WraithSpawnName = "WraithSpawn",
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
