CreateThread(function()
    for _, target in pairs(Config.Targets) do
        exports.ox_target:addBoxZone({
            coords = target.coords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = target.name,
                    label = target.label,
                    icon = target.icon,
                    event = target.event
                }
            }
        })
    end
end)

RegisterNetEvent("ox-cartel:target:gather", function()
    local success = lib.skillCheck({'easy', 'easy', 'medium'}, {'1', '2', '3'})
    if success then
        TriggerServerEvent("ox-cartel:target:complete", "gather")
    else
        TriggerServerEvent("qb-heat:addHeat", 5)
        lib.notify({ title = "Failed", description = "You attracted attention!", type = "error" })
    end
end)

RegisterNetEvent("ox-cartel:target:process", function()
    local success = lib.skillCheck({'easy', 'medium', 'medium'}, {'2', '3', '4'})
    if success then
        TriggerServerEvent("ox-cartel:target:complete", "process")
    else
        TriggerServerEvent("qb-heat:addHeat", 10)
        lib.notify({ title = "Failed", description = "You spilled the product!", type = "error" })
    end
end)

RegisterNetEvent("ox-cartel:target:sell", function()
    local success = lib.skillCheck({'medium', 'medium', 'hard'}, {'2', '3', '4'})
    if success then
        TriggerServerEvent("ox-cartel:target:complete", "sell")
    else
        TriggerServerEvent("qb-heat:addHeat", 15)
        lib.notify({ title = "Failed", description = "DEA might be watching...", type = "error" })
    end
end)

RegisterNetEvent("ox-cartel:target:launder", function()
    TriggerServerEvent("ox-cartel:target:launderMoney")
end)
