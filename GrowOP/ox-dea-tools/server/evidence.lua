local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-dea:doSearch", function(type, targetId)
    local src = source
    local DEA = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not DEA or DEA.PlayerData.job.name ~= "dea" then return end
    if not Target then return end

    local found = false
    local seizedValue = 0

    for _, item in pairs(Target.PlayerData.items) do
        if item.name == "weed_bag" or item.name == "cocaine_bag" or item.name == "markedbills" then
            found = true
            seizedValue = seizedValue + (item.count * 100) -- rough value
            Target.Functions.RemoveItem(item.name, item.count)
        end
    end

    if found then
        DEA.Functions.AddItem(Config.EvidenceItem, 1, false, { value = seizedValue, suspect = Target.PlayerData.charinfo.firstname })
DEA.Functions.AddMoney("cash", Config.Reward.money)
TriggerEvent("ox-dea:logEvidence", DEA.PlayerData.charinfo.firstname, Target.PlayerData.charinfo.firstname, seizedValue)
        DEA.Functions.AddMoney("cash", Config.Reward.money)
        TriggerClientEvent("ox_lib:notify", src, { description = "Evidence secured. $" .. seizedValue .. " worth seized.", type = "success" })
    else
        TriggerClientEvent("ox_lib:notify", src, { description = "No illegal items found.", type = "inform" })
    end
end)

RegisterNetEvent("ox-dea:scanVehicle", function(plate)
    local src = source
    local DEA = QBCore.Functions.GetPlayer(src)
    if not DEA or DEA.PlayerData.job.name ~= "dea" then return end

    local items = exports.ox_inventory:GetInventoryItems("trunk:" .. plate)
    local found = false
    local seizedValue = 0

    for _, item in pairs(items or {}) do
        if item.name == "weed_bag" or item.name == "cocaine_bag" or item.name == "markedbills" then
            found = true
            seizedValue = seizedValue + (item.count * 100)
        end
    end

    if found then
        DEA.Functions.AddItem(Config.EvidenceItem, 1, false, { value = seizedValue, vehicle = plate })
DEA.Functions.AddMoney("cash", Config.Reward.money)
TriggerEvent("ox-dea:logEvidence", DEA.PlayerData.charinfo.firstname, plate, seizedValue)
        DEA.Functions.AddMoney("cash", Config.Reward.money)
        TriggerClientEvent("ox_lib:notify", src, { description = "Evidence logged from vehicle: $" .. seizedValue, type = "success" })
    else
        TriggerClientEvent("ox_lib:notify", src, { description = "No contraband found.", type = "inform" })
    end
end)
