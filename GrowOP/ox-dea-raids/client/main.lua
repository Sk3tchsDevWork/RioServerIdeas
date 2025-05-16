CreateThread(function()
    for _, door in pairs(Config.RaidDoors) do
        exports.ox_target:addBoxZone({
            coords = door.coords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = "raid_door_" .. door.id,
                    icon = "fas fa-door-open",
                    label = "Breach Cartel Door",
                    job = door.job,
                    event = "ox-dea:breachDoor",
                    args = { id = door.id }
                }
            }
        })
    end
end)

RegisterNetEvent("ox-dea:openDoor", function(doorId)
    exports['ox_doorlock']:forceUnlock(doorId, true)
    Wait(60000)
    exports['ox_doorlock']:forceUnlock(doorId, false)
end)
