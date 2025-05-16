Config = {}

Config.Hideouts = {
    {
        job = "cartel",
        door = {
            coords = vector3(1087.0, -3187.0, -39.0),
            heading = 90.0,
            id = "cartel_hideout_door"
        },
        stash = {
            coords = vector3(1090.0, -3190.0, -38.0),
            label = "cartel_hideout_stash",
            slots = 30,
            weight = 100000
        },
        alarm = {
            coords = vector3(1092.0, -3192.0, -38.0),
            event = "ox-cartel:triggerPanic",
            label = "Trigger Panic Alarm",
            icon = "fas fa-bell"
        }
    }
}
