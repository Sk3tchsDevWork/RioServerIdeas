Config = {}

Config.DrugTypes = {
    weed = {
        label = "Weed",
        job = nil,
        gather = {
            item = "weed_leaf",
            coords = vector3(2220.0, 5577.0, 53.0),
            amount = {1, 3},
            heat = 3,
            time = 3000,
        },
        process = {
            input = "weed_leaf",
            output = "weed_bag",
            coords = vector3(1387.0, -2079.0, 52.0),
            amount = 1,
            heat = 5,
            time = 5000,
        },
        sell = {
            item = "weed_bag",
            price = {120, 160},
            coords = vector3(1240.0, -3300.0, 5.0),
            cooldown = 300,
            heat = 10,
        }
    },
    coke = {
        label = "Cocaine",
        job = "cartel",
        gather = {
            item = "coca_leaf",
            coords = vector3(2947.0, 2783.0, 40.0),
            amount = {1, 2},
            heat = 4,
            time = 4000,
        },
        process = {
            input = "coca_leaf",
            output = "cocaine_bag",
            coords = vector3(1087.0, -3187.0, -38.0),
            amount = 1,
            heat = 8,
            time = 6000,
        },
        sell = {
            item = "cocaine_bag",
            price = {180, 250},
            coords = vector3(1240.0, -3300.0, 5.0),
            cooldown = 300,
            heat = 12,
        }
    }
}

Config.TransportThreshold = 10
Config.HeatOnMove = 25
Config.DeliveryPoint = vector3(1200.0, -3100.0, 6.0)

Config.DrugItems = {
    'cocaine_bag',
    'weed_bag',
    'meth_bag',
    'lsd_tab',
    'heroin_wrap'
}
