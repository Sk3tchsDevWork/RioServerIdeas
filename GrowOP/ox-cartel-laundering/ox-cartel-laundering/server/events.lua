local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}
local missionCooldowns = {}

RegisterNetEvent("ox-cartel:launderAttempt", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local now = os.time()

    if cooldowns[src] and now - cooldowns[src] < Config.Terminals[1].cooldown then
        TriggerClientEvent("ox_lib:notify", src, { title = "Crypto Terminal", description = "Cooldown active.", type = "error" })
        return
    end

    if amount < Config.Terminals[1].minAmount or amount > Config.Terminals[1].maxAmount then
        TriggerClientEvent("ox_lib:notify", src, { title = "Crypto Terminal", description = "Invalid amount.", type = "error" })
        return
    end

    if not Player.Functions.RemoveItem(Config.AllowedItem, amount) then
        TriggerClientEvent("ox_lib:notify", src, { title = "Crypto Terminal", description = "Could not remove.", type = "error" })
        return
    end

    local fee = math.floor(amount * (Config.Terminals[1].feePercent / 100))
    local net = amount - fee
    Player.Functions.AddItem(Config.PayoutItem, 1, false, { amount = net })
    cooldowns[src] = now

    TriggerClientEvent("ox_lib:notify", src, { title = "Crypto Terminal", description = "Laundered $" .. amount, type = "success" })

    local heat = Player.PlayerData.metadata["heatlevel"] or 0
    if heat >= Config.AlertHeatThreshold and amount >= Config.AlertAmount then
        for _, id in pairs(QBCore.Functions.GetPlayers()) do
            local p = QBCore.Functions.GetPlayer(id)
            if p and p.PlayerData.job.name == "dea" then
                TriggerClientEvent("ox_lib:notify", id, {
                    title = "DEA Alert",
                    description = "Large laundering event triggered.",
                    type = "alert"
                })
            end
        end
    end
end)

RegisterNetEvent("ox-cartel:exchangeWallet", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PayoutItem)
    if not item then
        TriggerClientEvent("ox_lib:notify", src, { description = "No crypto wallet found.", type = "error" })
        return
    end
    local amount = item.info.amount or 0
    local fee = math.floor(amount * (Config.Exchange.feePercent / 100))
    local net = amount - fee

    Player.Functions.RemoveItem(Config.PayoutItem, 1)
    Player.Functions.AddMoney("cash", net)

    TriggerClientEvent("ox_lib:notify", src, {
        title = "Exchange",
        description = "Converted wallet: $" .. net,
        type = "success"
    })
end)

RegisterNetEvent("ox-cartel:startLaunderJob", function()
    local src = source
    local now = os.time()
    if missionCooldowns[src] and now - missionCooldowns[src] < Config.LaunderMissions.cooldown then
        TriggerClientEvent("ox_lib:notify", src, { description = "You must wait before another job.", type = "error" })
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.LaunderMissions.item, 1, false, { amount = math.random(10000, 25000) })
    missionCooldowns[src] = now
    TriggerClientEvent("ox_lib:notify", src, { description = "Deliver this wallet to the drop spot!", type = "success" })
end)

RegisterNetEvent("ox-cartel:completeLaunderJob", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.LaunderMissions.item)
    if not item then
        TriggerClientEvent("ox_lib:notify", src, { description = "No wallet to deliver.", type = "error" })
        return
    end
    local payout = item.info.amount or 0
    Player.Functions.RemoveItem(Config.LaunderMissions.item, 1)
    Player.Functions.AddMoney("cash", payout)

    TriggerClientEvent("ox_lib:notify", src, {
        title = "Delivery Complete",
        description = "Received $" .. payout .. " clean.",
        type = "success"
    })
end)

RegisterNetEvent("ox-cartel:triggerAmbush", function(coords)
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local p = QBCore.Functions.GetPlayer(id)
        if p and p.PlayerData.job.name == "dea" then
            TriggerClientEvent("ox_lib:notify", id, {
                title = "DEA Alert",
                description = "High-value laundering drop detected!",
                type = "alert"
            })
            TriggerClientEvent("ox-cartel:deaBlip", id, coords)
        end
    end
end)
