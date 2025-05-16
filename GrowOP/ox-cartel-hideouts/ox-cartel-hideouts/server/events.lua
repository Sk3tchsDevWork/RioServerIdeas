local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-cartel:openStash", function(stashName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.job.name == "cartel" then
        TriggerClientEvent("ox_inventory:openInventory", src, {
            type = "stash",
            id = stashName,
            label = "Cartel Hideout",
            slots = 30
        })
    end
end)

RegisterNetEvent("ox-cartel:triggerPanic", function()
    local src = source
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player and Player.PlayerData.job.name == "cartel" and id ~= src then
            TriggerClientEvent("ox_lib:notify", id, {
                title = "Panic Alarm",
                description = "A cartel member triggered the panic button!",
                type = "alert"
            })
        end
    end
end)
