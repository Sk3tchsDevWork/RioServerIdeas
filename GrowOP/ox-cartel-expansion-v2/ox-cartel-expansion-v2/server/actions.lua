local QBCore = exports['qb-core']:GetCoreObject()
local launderCooldowns = {}

RegisterNetEvent("ox-cartel:target:complete", function(type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if type == "gather" then
        Player.Functions.AddItem("weed_leaf", 1)
    elseif type == "process" then
        if Player.Functions.RemoveItem("weed_leaf", 1) then
            Player.Functions.AddItem("weed_bag", 1)
        end
    elseif type == "sell" then
        if Player.Functions.RemoveItem("weed_bag", 1) then
            Player.Functions.AddMoney("cash", math.random(120, 160))
            TriggerEvent("qb-heat:addHeat", 10)
        end
    end
end)

RegisterNetEvent("ox-cartel:target:launderMoney", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local last = launderCooldowns[src] or 0
    if os.time() - last < Config.Launder.cooldown then
        TriggerClientEvent("ox_lib:notify", src, { description = "Laundering is cooling down...", type = "error" })
        return
    end

    launderCooldowns[src] = os.time()
    local amt = math.random(Config.Launder.amount[1], Config.Launder.amount[2])
    Player.Functions.AddMoney("cash", amt)
    TriggerClientEvent("ox_lib:notify", src, { description = "Laundered $" .. amt, type = "success" })
end)
