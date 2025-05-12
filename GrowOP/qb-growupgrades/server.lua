local BunkerPlants, HeroinPlants, MethCooldowns = {}, {}, {}
local heroinPlantId = 0

-------------------------------------
-- 🧪 Grow System + Tier Unlocks
-------------------------------------
local function GetPlayerProgress(cid)
    local row = MySQL.single.await('SELECT * FROM player_drug_progress WHERE citizenid = ?', { cid })
    if not row then
        MySQL.insert.await('INSERT INTO player_drug_progress (citizenid) VALUES (?)', { cid })
        return { weed = 0, mushroom = 0, coca = 0 }
    end
    return row
end

RegisterNetEvent('qb-growupgrades:server:plantCrop', function(coords, cropType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local progress = GetPlayerProgress(cid)

    if (progress[cropType] or 0) < (Config.PlantTypes[cropType]?.requiredHarvests or 0) then
        TriggerClientEvent('QBCore:Notify', src, "You haven’t unlocked this crop yet.", "error")
        return
    end

    local id = MySQL.insert.await('INSERT INTO bunker_plants (coords, upgrades, owner, plantedAt, stage, watered, cropType) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        json.encode(coords), json.encode({}), cid, os.time(), 'small', false, cropType
    })

    BunkerPlants[id] = {
        coords = coords,
        upgrades = {},
        owner = src,
        plantedAt = os.time(),
        stage = "small",
        watered = false,
        cropType = cropType
    }

    TriggerClientEvent('qb-growupgrades:client:spawnPlantType', -1, id, coords, "small", cropType)
end)

RegisterNetEvent("qb-growupgrades:server:applyUpgrade", function(plantId, upgrade)
    local src = source
    if not Config.Upgrades[upgrade] then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem(upgrade, 1) then
        table.insert(BunkerPlants[plantId].upgrades, upgrade)
        MySQL.update.await('UPDATE bunker_plants SET upgrades = ? WHERE id = ?', { json.encode(BunkerPlants[plantId].upgrades), plantId })
        TriggerClientEvent('QBCore:Notify', src, "Upgrade applied.", "success")
    end
end)

RegisterNetEvent("qb-growupgrades:server:harvestPlant", function(id)
    local src = source
    local plant = BunkerPlants[id]
    if not plant or not plant.watered then
        TriggerClientEvent("QBCore:Notify", src, "Still growing or dry.", "error")
        return
    end

    local elapsed = os.time() - plant.plantedAt
    local baseTime, baseYield = 600, math.random(2, 4)
    local time, yield, heat = baseTime, baseYield, 0

    for _, u in ipairs(plant.upgrades) do
        local cfg = Config.Upgrades[u]
        if cfg then
            time = time * cfg.timeMultiplier
            yield = yield + (cfg.yieldBonus or 0)
            heat = heat + (cfg.heatReduction or 0)
        end
    end

    if elapsed < time then
        TriggerClientEvent("QBCore:Notify", src, "Not ready yet.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(src)
    local crop = plant.cropType or "weed"
    Player.Functions.AddItem(crop .. "_bag", yield)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[crop .. "_bag"], "add")

    BunkerPlants[id] = nil
    MySQL.query.await('DELETE FROM bunker_plants WHERE id = ?', { id })
    TriggerClientEvent("qb-growupgrades:client:removePlant", -1, id)
    MySQL.update.await(('UPDATE player_drug_progress SET ' .. crop .. ' = ' .. crop .. ' + 1 WHERE citizenid = ?'), { Player.PlayerData.citizenid })

    exports['qb-heatlevel']:AddPlayerHeat(src, heat)
end)

-------------------------------------
-- 💉 Heroin Field Logic
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:plantHeroin", function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player.Functions.GetItemByName(Config.HeroinGrow.seedItem) then return end

    local count = 0
    for _, v in pairs(HeroinPlants) do if v.owner == src then count += 1 end end
    if count >= Config.HeroinGrow.maxPlants then
        TriggerClientEvent("QBCore:Notify", src, "Too many heroin plants.", "error")
        return
    end

    Player.Functions.RemoveItem(Config.HeroinGrow.seedItem, 1)
    heroinPlantId += 1
    HeroinPlants[heroinPlantId] = {
        coords = coords,
        plantedAt = os.time(),
        owner = src
    }

    TriggerClientEvent("qb-growupgrades:client:spawnHeroinPlant", -1, heroinPlantId, coords)
end)

RegisterNetEvent("qb-growupgrades:server:harvestHeroin", function(id)
    local src = source
    local plant = HeroinPlants[id]
    if not plant or plant.owner ~= src or os.time() - plant.plantedAt < Config.HeroinGrow.growTime then return end

    HeroinPlants[id] = nil
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem("heroin_bag", Config.HeroinGrow.yield)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["heroin_bag"], "add")
    exports['qb-heatlevel']:AddPlayerHeat(src, Config.HeroinGrow.heatPerPlant)
end)

RegisterNetEvent("qb-growupgrades:server:scanHeroin", function(pos, radius)
    local src = source
    local found = {}

    for id, plant in pairs(HeroinPlants) do
        if #(pos - plant.coords) < radius then
            table.insert(found, { id = id, coords = plant.coords })
        end
    end

    if #found > 0 then
        TriggerClientEvent("QBCore:Notify", src, "Heroin plants found!", "error")
    else
        TriggerClientEvent("QBCore:Notify", src, "No heroin detected.", "success")
    end
end)

-------------------------------------
-- ⚗️ Meth Lab Logic
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:completeMethCook", function(success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local last = MethCooldowns[src] or 0
    if os.time() - last < (Config.MethLab.cooldownMinutes * 60) then
        TriggerClientEvent("QBCore:Notify", src, "Lab is cooling down.", "error")
        return
    end

    for _, req in pairs(Config.MethLab.requiredItems) do
        if not Player.Functions.RemoveItem(req.name, req.amount) then
            TriggerClientEvent("QBCore:Notify", src, "Missing ingredients.", "error")
            return
        end
    end

    MethCooldowns[src] = os.time()

    if not success then
        if math.random(100) <= Config.MethLab.failExplodeChance then
            AddExplosion(GetEntityCoords(GetPlayerPed(src)), 2, 1.0, true, false, 1.0)
            TriggerClientEvent("QBCore:Notify", src, "Boom. Lab exploded!", "error")
            return
        end
        TriggerClientEvent("QBCore:Notify", src, "Cook failed.", "error")
        return
    end

    local yield = Config.MethLab.successYield + math.random(0, 2)
    Player.Functions.AddItem(Config.MethLab.reward, yield)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.MethLab.reward], "add")
    exports['qb-heatlevel']:AddPlayerHeat(src, Config.MethLab.heatIncrease)
end)

-------------------------------------
-- 🧪 LSD Lab Logic
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:completeLSDCraft", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local lab = Config.LabRequirements.lsd
    local valid = true

    for _, req in pairs(lab.requiredItems) do
        if not Player.Functions.RemoveItem(req.name, req.amount) then valid = false end
    end

    if valid then
        Player.Functions.AddItem(lab.reward, lab.rewardAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[lab.reward], "add")
        TriggerClientEvent('QBCore:Notify', src, "LSD created!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Missing ingredients.", "error")
    end
end)

-------------------------------------
-- 💻 DEA Tablet Server Callbacks
-------------------------------------
lib.callback.register("qb-growupgrades:server:getHeatList", function(source)
    return {
        { id = "CIT123", heat = 92, coords = vector3(2942.1, 4624.5, 48.7) },
        { id = "CIT456", heat = 74, coords = vector3(1060.0, -3180.0, -39.0) }
    }
end)

lib.callback.register("qb-growupgrades:server:getPlayerIntel", function(source, cid)
    local intel = {
        ["CIT123"] = { heat = 92, lastCrop = "weed", coords = vector3(2942.1, 4624.5, 48.7) },
        ["CIT456"] = { heat = 71, lastCrop = "mushroom", coords = vector3(1060.0, -3180.0, -39.0) }
    }
    return intel[cid]
end)

RegisterNetEvent("qb-growupgrades:server:markForRaid", function(cid)
    print("RAID TRIGGERED ON", cid)
    local f = io.open("raid_logs.txt", "a")
    if f then
        f:write(("[" .. os.date() .. "] Raid triggered on " .. cid .. "\\n"))
        f:close()
    end
end)

-------------------------------------
-- 🎁 Tablet Access + Givetablet Command
-------------------------------------
QBCore.Functions.CreateCallback("qb-growupgrades:server:isDEA", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local job = Player?.PlayerData.job.name
    local item = Player?.Functions.GetItemByName(Config.TabletItem)

    for _, allowed in ipairs(Config.AllowedJobs) do
        if job == allowed and item then return cb(true) end
    end
    cb(false)
end)

QBCore.Commands.Add("givetablet", "Give DEA Tablet (admin only)", {{name="id", help="Player ID"}}, true, function(source, args)
    local id = tonumber(args[1])
    local Player = QBCore.Functions.GetPlayer(id)
    if Player then
        Player.Functions.AddItem(Config.TabletItem, 1)
        TriggerClientEvent("inventory:client:ItemBox", id, QBCore.Shared.Items[Config.TabletItem], "add")
        TriggerClientEvent("QBCore:Notify", source, "Tablet given to ID " .. id, "success")
    end
end, "admin")
