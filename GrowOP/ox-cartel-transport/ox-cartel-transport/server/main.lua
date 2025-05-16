local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-cartel-transport:triggerHeat", function(plate, coords)
    local src = source
    TriggerEvent("qb-heat:addHeat", 25)

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(id)
        if player and player.PlayerData.job.name == "dea" then
            TriggerClientEvent("ox-cartel-transport:deaBlip", id, plate, coords)
        end
    end
end)
