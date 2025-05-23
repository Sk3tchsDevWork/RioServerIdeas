Config = {}

Config.Terminals = {
    {
        coords = vector3(1175.0, -3195.0, 6.0),
        cooldown = 600,
        minAmount = 100,
        maxAmount = 5000,
        feePercent = 10,
        cryptoType = "monero_wallet"
    },
    {
        coords = vector3(1177.0, -3195.0, 6.0),
        cooldown = 600,
        minAmount = 500,
        maxAmount = 10000,
        feePercent = 5,
        cryptoType = "zcash_wallet"
    },
    {
        coords = vector3(1179.0, -3195.0, 6.0),
        cooldown = 600,
        minAmount = 1000,
        maxAmount = 20000,
        feePercent = 2,
        cryptoType = "bitcoin_wallet"
    }
}

Config.AlertHeatThreshold = 100
Config.AlertAmount = 3000

Config.Exchange = {
    coords = vector3(1180.0, -3190.0, 6.0),
    feePercent = 5
}

Config.LaunderMissions = {
    start = vector3(1165.0, -3200.0, 6.0),
    delivery = vector3(500.0, -2000.0, 24.0),
    item = "bitcoin_wallet",
    rewardMultiplier = 1.0,
    riskHeat = 100,
    cooldown = 1200
}
