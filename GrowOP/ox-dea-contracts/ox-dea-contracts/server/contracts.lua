local QBCore = exports['qb-core']:GetCoreObject()
local activeContracts = {}

RegisterNetEvent("ox-dea:checkHeat", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local heat = Player.PlayerData.metadata["heatlevel"] or 0
    if heat >= Config.HeatThreshold and not activeContracts[src] then
        activeContracts[src] = true
        TriggerEvent("ox-dea:sendContract", Player)
    end
end)

RegisterNetEvent("ox-dea:sendContract", function(player)
    local name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    local coords = GetEntityCoords(GetPlayerPed(player.PlayerData.source))

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local DEA = QBCore.Functions.GetPlayer(id)
        if DEA and DEA.PlayerData.job.name == Config.DeaJob then
            TriggerClientEvent("ox-dea:notifyRaid", id, name, coords)
        end
    end
end)
