Config = {}

-- Drug progression config
Config.DrugTiers = {
    weed = {
        label = "Weed",
        alwaysUnlocked = true,
    },
    cocaine = {
        label = "Cocaine",
        required = { drug = "weed", amount = 50 },
    },
    meth = {
        label = "Meth",
        required = { drug = "cocaine", amount = 30 },
    },
    lsd = {
        label = "LSD",
        required = { drug = "meth", amount = 25 },
    },
    heroin = {
        label = "Heroin",
        required = { drug = "lsd", amount = 20 },
    }
}
