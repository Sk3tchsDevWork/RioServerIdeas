Config = {}

Config.Launder = {
    coords = vector3(1175.0, -3195.0, 6.0),
    amount = {500, 2000},
    cooldown = 600
}

Config.Targets = {
    {
        name = "npc_gather",
        coords = vector3(2221.0, 5576.0, 53.0),
        label = "Harvest Weed",
        event = "ox-cartel:target:gather",
        icon = "fas fa-seedling"
    },
    {
        name = "npc_process",
        coords = vector3(1386.0, -2079.0, 52.0),
        label = "Process Weed",
        event = "ox-cartel:target:process",
        icon = "fas fa-cannabis"
    },
    {
        name = "npc_sell",
        coords = vector3(1240.0, -3300.0, 5.0),
        label = "Sell Weed",
        event = "ox-cartel:target:sell",
        icon = "fas fa-hand-holding-usd"
    },
    {
        name = "npc_launder",
        coords = vector3(1175.0, -3195.0, 6.0),
        label = "Launder Money",
        event = "ox-cartel:target:launder",
        icon = "fas fa-money-bill-wave"
    }
}
