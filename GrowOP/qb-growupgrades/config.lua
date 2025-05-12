-------------------------------------
-- 🧪 Plant Types & Tier Unlocks
-------------------------------------
Config.PlantTypes = {
    ["weed"] = {
        label = "Weed",
        model = {
            small = `prop_weed_01`,
            medium = `prop_weed_02`,
            large = `prop_weed_03`
        },
        requiredHarvests = 0 -- Number of harvests required to unlock this plant type
    },
    ["mushroom"] = {
        label = "Mushrooms",
        model = {
            small = `prop_plant_01b`,
            medium = `prop_plant_01a`,
            large = `prop_plant_01c`
        },
        requiredHarvests = 20
    },
    ["coca"] = {
        label = "Coca Plant",
        model = {
            small = `prop_plant_cane_01a`,
            medium = `prop_plant_cane_02a`,
            large = `prop_plant_cane_03a`
        },
        requiredHarvests = 40
    }
}

-------------------------------------
-- 🔧 Grow Upgrades
-------------------------------------
Config.Upgrades = {
    grow_light = { timeMultiplier = 0.75, yieldBonus = 0, heatReduction = 0 },
    hydro_kit  = { timeMultiplier = 1.0,  yieldBonus = 2, heatReduction = 0 },
    filter_vent = { timeMultiplier = 1.0, yieldBonus = 0, heatReduction = 10 }
}

-------------------------------------
-- 🧪 Meth Lab Configuration
-------------------------------------
Config.MethLabLocations = {
    vector3(1391.0, 3607.0, 38.9) -- Replace with real interior/RV location
}

Config.MethLab = {
    requiredItems = {
        { name = "ephedrine", amount = 1 },
        { name = "pseudoephedrine", amount = 1 },
        { name = "chem_kit", amount = 1 }
    },
    time = 10000, -- Time in milliseconds to complete meth cooking
    successYield = 2, -- Amount of meth produced on success
    failExplodeChance = 35, -- Percentage chance of explosion on failure
    reward = "meth_bag",
    cooldownMinutes = 20, -- Cooldown time in minutes between meth cooking attempts
    heatIncrease = 25 -- Heat added to the player on successful meth cooking
}

-------------------------------------
-- 💉 Heroin Field Configuration
-------------------------------------
Config.HeroinFields = {
    { coords = vector3(2942.1, 4624.5, 48.7), label = "Northern Field" },
    { coords = vector3(2880.6, 4571.8, 47.0), label = "Eastern Field" }
}

Config.HeroinGrow = {
    seedItem = "poppy_seed", -- Item required to plant heroin
    growTime = 15 * 60, -- Time in seconds for the plant to grow
    yield = 2, -- Amount of heroin produced per plant
    maxPlants = 6, -- Maximum number of plants a player can grow
    heatPerPlant = 10, -- Heat generated per plant
    cooldownMinutes = 10 -- Cooldown time in minutes between planting attempts
}

-------------------------------------
-- 🧪 LSD Lab
-------------------------------------
Config.LabLocations = {
    lsd = vector3(1025.3, -2287.6, 30.6) -- Location of the LSD lab
}

Config.LabRequirements = {
    lsd = {
        requiredItems = {
            { name = "acid", amount = 1 },
            { name = "mushroom_spore", amount = 2 }
        },
        craftTime = 10000, -- Time in milliseconds to craft LSD
        reward = "lsd_bag", -- Item rewarded on successful crafting
        rewardAmount = 2 -- Amount of the reward item
    }
}

-------------------------------------
-- 🛑 DEA Tablet Access
-------------------------------------
Config.AllowedJobs = {
    "dea", "police", "fbi" -- Jobs allowed to access the DEA tablet
}

Config.TabletItem = "dea_tablet" -- Item required to use the DEA tablet

-------------------------------------
-- 🔥 Heat System
-------------------------------------
Config.HeatThreshold = 50 -- Heat level at which players are flagged for DEA attention