
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
        requiredHarvests = 0
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
    time = 10000,
    successYield = 2,
    failExplodeChance = 35,
    reward = "meth_bag",
    cooldownMinutes = 20,
    heatIncrease = 25
}

-------------------------------------
-- 💉 Heroin Field Configuration
-------------------------------------
Config.HeroinFields = {
    vector3(2942.1, 4624.5, 48.7),
    vector3(2880.6, 4571.8, 47.0)
}

Config.HeroinGrow = {
    seedItem = "poppy_seed",
    growTime = 15 * 60,
    yield = 2,
    maxPlants = 6,
    heatPerPlant = 10
}

-------------------------------------
-- 🧪 LSD Lab
-------------------------------------
Config.LabLocations = {
    lsd = vector3(1025.3, -2287.6, 30.6)
}

Config.LabRequirements = {
    lsd = {
        requiredItems = {
            { name = "acid", amount = 1 },
            { name = "mushroom_spore", amount = 2 }
        },
        craftTime = 10000,
        reward = "lsd_bag",
        rewardAmount = 2
    }
}

-------------------------------------
-- 🛑 DEA Tablet Access
-------------------------------------
Config.AllowedJobs = {
    "dea"
}

Config.TabletItem = "dea_tablet"
