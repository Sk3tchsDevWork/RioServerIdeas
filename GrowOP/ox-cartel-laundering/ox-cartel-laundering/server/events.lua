local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

RegisterNetEvent("ox-cartel:launderAttempt", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local now = os.time()

    if cooldowns[src] and now - cooldowns[src] < Config.Terminals[1].cooldown then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Crypto Terminal",
            description = "Please wait before laundering again.",
            type = "error"
        })
        return
    end

    if amount < Config.Terminals[1].minAmount or amount > Config.Terminals[1].maxAmount then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Crypto Terminal",
            description = "Invalid amount for laundering.",
            type = "error"
        })
        return
    end

    if not Player.Functions.RemoveItem(Config.AllowedItem, amount) then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Crypto Terminal",
            description = "Failed to remove dirty money.",
            type = "error"
        })
        return
    end

    local fee = math.floor(amount * (Config.Terminals[1].feePercent / 100))
    local net = amount - fee

    Player.Functions.AddItem(Config.PayoutItem, 1, false, { amount = net })
    cooldowns[src] = now

    TriggerClientEvent("ox_lib:notify", src, {
        title = "Crypto Terminal",
        description = "Laundered $" .. amount .. " → Crypto: $" .. net,
        type = "success"
    })

    local heat = Player.PlayerData.metadata["heatlevel"] or 0
    if heat >= Config.AlertHeatThreshold and amount >= Config.AlertAmount then
        for _, id in pairs(QBCore.Functions.GetPlayers()) do
            local p = QBCore.Functions.GetPlayer(id)
            if p and p.PlayerData.job.name == "dea" then
                TriggerClientEvent("ox_lib:notify", id, {
                    title = "DEA Alert",
                    description = "High-volume laundering detected at terminal.",
                    type = "alert"
                })
            end
        end
    end
end)
