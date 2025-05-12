local BunkerPlants, HeroinPlants, MethCooldowns = {}, {}, {}
local heroinPlantId = 0

-------------------------------------
-- 🧪 Helper Functions
-------------------------------------
local function logRaidEvent(cid)
    local logMessage = string.format("[%s] Raid triggered on %s\n", os.date("%Y-%m-%d %H:%M:%S"), cid)
    local f = io.open("raid_logs.txt", "a")
    if f then
        f:write(logMessage)
        f:close()
    else
        print("Failed to write to raid_logs.txt")
    end
end

local function validatePlayer(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        TriggerClientEvent("QBCore:Notify", src, "Player not found.", "error")
        return nil
    end
    return Player
end

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
    local Player = validatePlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local progress = GetPlayerProgress(cid)

    if not Config.PlantTypes[cropType] then
        TriggerClientEvent('QBCore:Notify', src, "Invalid crop type.", "error")
        return
    end

    if (progress[cropType] or 0) < (Config.PlantTypes[cropType]?.requiredHarvests or 0) then
        TriggerClientEvent('QBCore:Notify', src, "You haven’t unlocked this crop yet.", "error")
        return
    end

    local id = MySQL.insert.await('INSERT INTO bunker_plants (coords, upgrades, owner, plantedAt, stage, watered, cropType) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        json.encode(coords), json.encode({}), cid, os.time(), 'small', false, cropType
    })

    if not id then
        TriggerClientEvent('QBCore:Notify', src, "Failed to plant crop. Try again later.", "error")
        return
    end

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

-------------------------------------
-- ⚗️ Meth Lab Logic
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:completeMethCook", function(success)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

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
            local pedCoords = GetEntityCoords(GetPlayerPed(src))
            AddExplosion(pedCoords, 2, 1.0, true, false, 1.0)
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
    local Player = validatePlayer(src)
    if not Player then return end

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
    local heatList = MySQL.query.await('SELECT citizenid, heat, last_known_coords FROM player_heat WHERE heat > ?', { Config.HeatThreshold })
    if not heatList then return {} end

    local result = {}
    for _, row in ipairs(heatList) do
        table.insert(result, {
            id = row.citizenid,
            heat = row.heat,
            coords = json.decode(row.last_known_coords)
        })
    end
    return result
end)

lib.callback.register("qb-growupgrades:server:getPlayerIntel", function(source, cid)
    local intel = MySQL.single.await('SELECT heat, last_crop, last_known_coords FROM player_heat WHERE citizenid = ?', { cid })
    if not intel then return nil end

    return {
        heat = intel.heat,
        lastCrop = intel.last_crop,
        coords = json.decode(intel.last_known_coords)
    }
end)

RegisterNetEvent("qb-growupgrades:server:markForRaid", function(cid)
    logRaidEvent(cid)
    TriggerClientEvent("QBCore:Notify", source, "Raid marked for Citizen ID: " .. cid, "success")
end)

-------------------------------------
-- 🎁 Tablet Access + Givetablet Command
-------------------------------------
QBCore.Functions.CreateCallback("qb-growupgrades:server:isDEA", function(source, cb)
    local Player = validatePlayer(source)
    if not Player then return cb(false) end

    local job = Player.PlayerData.job.name
    local item = Player.Functions.GetItemByName(Config.TabletItem)

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