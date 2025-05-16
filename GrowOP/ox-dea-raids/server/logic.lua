local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-dea:breachDoor", function(data)
    local src = source
    local doorId = data.id
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player.PlayerData.job.name ~= "dea" then return end

    local highHeat = false
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local p = QBCore.Functions.GetPlayer(id)
        if p then
            local heat = p.PlayerData.metadata["heatlevel"] or 0
            if heat >= Config.HeatThreshold then
                highHeat = true
                break
            end
        end
    end

    if highHeat then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "DEA Breach",
            description = "Breach authorized. Go go go!",
            type = "success"
        })
        TriggerClientEvent("ox-dea:openDoor", src, doorId)
    else
        TriggerClientEvent("ox_lib:notify", src, {
            title = "DEA Breach",
            description = "No valid cartel suspects with high heat found.",
            type = "error"
        })
    end
end)
