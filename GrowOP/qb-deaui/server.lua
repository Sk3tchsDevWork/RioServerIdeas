local PlayerHeat = {}

RegisterServerEvent("qb-deaui:server:reportHeat")
AddEventHandler("qb-deaui:server:reportHeat", function(heat)
    PlayerHeat[source] = heat
end)

QBCore.Functions.CreateCallback('qb-deaui:server:getSuspects', function(source, cb)
    local suspects = {}
    local DEAcoords = GetEntityCoords(GetPlayerPed(source))

    for id, heat in pairs(PlayerHeat) do
        if heat >= Config.HeatThreshold then
            local Player = QBCore.Functions.GetPlayer(id)
            if Player then
                local coords = GetEntityCoords(GetPlayerPed(id))
                table.insert(suspects, {
                    id = id,
                    name = Player.PlayerData.name,
                    heat = heat,
                    coords = coords,
                    distance = #(coords - DEAcoords)
                })
            end
        end
    end
    cb(suspects)
end)

RegisterNetEvent('qb-deaui:server:markRaidDispatch', function(suspect)
    TriggerClientEvent('qb-dispatch:client:SendAlert', -1, {
        id = suspect.id,
        title = "Marked for Raid",
        coords = vector3(suspect.coords.x, suspect.coords.y, suspect.coords.z),
        description = suspect.name .. " marked as a raid target by DEA.",
        type = "police",
        icon = "info"
    })
end)
