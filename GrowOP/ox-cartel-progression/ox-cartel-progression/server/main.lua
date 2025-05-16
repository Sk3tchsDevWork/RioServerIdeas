local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-cartel:drugSaleStat", function(drug)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local stats = Player.PlayerData.metadata["drug_stats"] or {}
    local unlocks = Player.PlayerData.metadata["drug_unlocks"] or {}

    stats[drug .. "_sold"] = (stats[drug .. "_sold"] or 0) + 1

    -- Check for unlocks
    for name, config in pairs(Config.DrugTiers) do
        if not unlocks[name] and config.required then
            local requiredStat = config.required.drug .. "_sold"
            if (stats[requiredStat] or 0) >= config.required.amount then
                unlocks[name] = true
                TriggerClientEvent("ox_lib:notify", src, {
                    title = "Cartel Progression",
                    description = config.label .. " unlocked!",
                    type = "success"
                })
            end
        end
    end

    Player.Functions.SetMetaData("drug_stats", stats)
    Player.Functions.SetMetaData("drug_unlocks", unlocks)
end)

QBCore.Functions.CreateCallback("ox-cartel:canAccessDrug", function(source, cb, drug)
    local Player = QBCore.Functions.GetPlayer(source)
    local unlocks = Player.PlayerData.metadata["drug_unlocks"] or {}
    if Config.DrugTiers[drug] and Config.DrugTiers[drug].alwaysUnlocked then
        cb(true)
    else
        cb(unlocks[drug] == true)
    end
end)
