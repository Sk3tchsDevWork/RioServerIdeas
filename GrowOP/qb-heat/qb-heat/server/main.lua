local QBCore = exports['qb-core']:GetCoreObject()
local activeContracts = {}

RegisterNetEvent("qb-heat:addHeat", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local currentHeat = Player.PlayerData.metadata["heatlevel"] or 0
    local newHeat = math.min(currentHeat + amount, 150)
    Player.Functions.SetMetaData("heatlevel", newHeat)

    if currentHeat < 100 and newHeat >= 100 and not activeContracts[src] then
        activeContracts[src] = true
        TriggerClientEvent("ox-dea:checkHeat", src)
    end
end)

RegisterNetEvent("qb-heat:removeHeat", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local currentHeat = Player.PlayerData.metadata["heatlevel"] or 0
    local newHeat = math.max(currentHeat - amount, 0)
    Player.Functions.SetMetaData("heatlevel", newHeat)
end)

QBCore.Functions.CreateCallback("qb-heat:getHeat", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(0) end

    cb(Player.PlayerData.metadata["heatlevel"] or 0)
end)
