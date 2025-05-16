local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("ox-cartel:gather", function(drug)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = Config.DrugTypes[drug]
    if not data then return end

    lib.callback('ox-cartel:canAccessDrug', src, function(allowed)
        if not allowed then
            TriggerClientEvent("ox_lib:notify", src, { description = "You haven't unlocked " .. drug .. " yet!", type = "error" })
            return
        end

        if data.job and Player.PlayerData.job.name ~= data.job then
            TriggerClientEvent("ox_lib:notify", src, { description = "You don't have access to this.", type = "error" })
            return
        end

        local amt = math.random(data.gather.amount[1], data.gather.amount[2])
        Player.Functions.AddItem(data.gather.item, amt)
        TriggerEvent("qb-heat:addHeat", data.gather.heat)
        TriggerClientEvent("ox_lib:notify", src, { description = "Gathered " .. amt .. "x " .. data.gather.item, type = "success" })
    end, drug)
end)

RegisterNetEvent("ox-cartel:process", function(drug)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = Config.DrugTypes[drug]
    if not data then return end

    lib.callback('ox-cartel:canAccessDrug', src, function(allowed)
        if not allowed then
            TriggerClientEvent("ox_lib:notify", src, { description = "You haven't unlocked " .. drug .. " yet!", type = "error" })
            return
        end

        if data.job and Player.PlayerData.job.name ~= data.job then
            TriggerClientEvent("ox_lib:notify", src, { description = "You don't have access to this.", type = "error" })
            return
        end

        local item = Player.Functions.GetItemByName(data.process.input)
        if not item or item.amount < data.process.amount then
            TriggerClientEvent("ox_lib:notify", src, { description = "Not enough materials.", type = "error" })
            return
        end

        Player.Functions.RemoveItem(data.process.input, data.process.amount)
        Player.Functions.AddItem(data.process.output, 1)
        TriggerEvent("qb-heat:addHeat", data.process.heat)
        TriggerClientEvent("ox_lib:notify", src, { description = "Processed " .. data.label, type = "success" })
    end, drug)
end)

RegisterNetEvent("ox-cartel:sell", function(drug)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = Config.DrugTypes[drug]
    if not data then return end

    lib.callback('ox-cartel:canAccessDrug', src, function(allowed)
        if not allowed then
            TriggerClientEvent("ox_lib:notify", src, { description = "You haven't unlocked " .. drug .. " yet!", type = "error" })
            return
        end

        local item = Player.Functions.GetItemByName(data.sell.item)
        if not item or item.amount < 1 then
            TriggerClientEvent("ox_lib:notify", src, { description = "You have nothing to sell.", type = "error" })
            return
        end

        Player.Functions.RemoveItem(data.sell.item, 1)
        local reward = math.random(data.sell.price[1], data.sell.price[2])
        Player.Functions.AddMoney("cash", reward)
        TriggerEvent("qb-heat:addHeat", data.sell.heat)
        TriggerClientEvent("ox_lib:notify", src, { description = "Sold for $" .. reward, type = "success" })
        TriggerEvent("ox-cartel:drugSaleStat", drug)

        if math.random(1, 100) <= 20 then
            local coords = GetEntityCoords(GetPlayerPed(src))
            TriggerClientEvent("ox-cartel:deaBlip", -1, coords, data.label)
        end
    end, drug)
end)
