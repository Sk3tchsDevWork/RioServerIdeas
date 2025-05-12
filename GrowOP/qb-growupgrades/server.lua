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

-------------------------------------
-- 🚁 Surveillance Drone for DEA
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:deployDrone", function()
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if not job or not Config.AllowedJobs[job] then
        TriggerClientEvent("QBCore:Notify", src, "You are not authorized to deploy a drone.", "error")
        return
    end

    TriggerClientEvent("qb-growupgrades:client:spawnDrone", src)
end)

-------------------------------------
-- 🔥 Player Tracking for DEA
-------------------------------------
lib.callback.register("qb-growupgrades:server:getFlaggedPlayers", function(source)
    local flaggedPlayers = {}
    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(player)
        if Player then
            local heat = exports['qb-heatlevel']:GetPlayerHeat(player)
            if heat and heat > Config.HeatThreshold then
                table.insert(flaggedPlayers, {
                    id = Player.PlayerData.citizenid,
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    coords = GetEntityCoords(GetPlayerPed(player)),
                    heat = heat
                })
            end
        end
    end
    return flaggedPlayers
end)

-------------------------------------
-- 🛑 Evidence Collection for DEA
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:collectEvidence", function(plantId)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if not job or not Config.AllowedJobs[job] then
        TriggerClientEvent("QBCore:Notify", src, "You are not authorized to collect evidence.", "error")
        return
    end

    if not BunkerPlants[plantId] then
        TriggerClientEvent("QBCore:Notify", src, "No evidence found at this location.", "error")
        return
    end

    BunkerPlants[plantId] = nil
    TriggerClientEvent("qb-growupgrades:client:removePlant", -1, plantId)
    TriggerClientEvent("QBCore:Notify", src, "Evidence collected successfully.", "success")
end)

-------------------------------------
-- 🛡️ Stealth Upgrades for Drug Lords
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:purchaseUpgrade", function(upgrade)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    local upgradeConfig = Config.StealthUpgrades[upgrade]
    if not upgradeConfig then
        TriggerClientEvent("QBCore:Notify", src, "Invalid upgrade.", "error")
        return
    end

    if Player.Functions.RemoveMoney("cash", upgradeConfig.cost) then
        Player.Functions.AddItem(upgrade, 1)
        TriggerClientEvent("QBCore:Notify", src, upgradeConfig.label .. " purchased successfully.", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "Not enough money.", "error")
    end
end)

local function applyStealthUpgrades(player, baseHeat)
    local upgrades = player.Functions.GetItemsByName("heat_reduction")
    if upgrades and #upgrades > 0 then
        for _, upgrade in ipairs(upgrades) do
            baseHeat = baseHeat * (1 - (Config.StealthUpgrades["heat_reduction"].reduction / 100))
        end
    end
    return baseHeat
end

RegisterNetEvent("qb-growupgrades:server:generateHeat", function(action)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    local baseHeat = Config.HeatValues[action] or 0
    local finalHeat = applyStealthUpgrades(Player, baseHeat)

    exports['qb-heatlevel']:AddPlayerHeat(src, finalHeat)
    TriggerClientEvent("QBCore:Notify", src, "Heat generated: " .. math.floor(finalHeat), "info")
end)

-------------------------------------
-- 🚧 DEA Checkpoints
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:createCheckpoint", function(coords)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if not job or not Config.AllowedJobs[job] then
        TriggerClientEvent("QBCore:Notify", src, "You are not authorized to create checkpoints.", "error")
        return
    end

    TriggerClientEvent("qb-growupgrades:client:spawnCheckpoint", -1, coords)
end)

RegisterNetEvent("qb-growupgrades:server:searchVehicle", function(plate)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    -- Example logic: Check if the vehicle is carrying drugs
    local isCarryingDrugs = math.random(1, 100) <= 50 -- 50% chance
    if isCarryingDrugs then
        TriggerClientEvent("QBCore:Notify", src, "Drugs found in the vehicle!", "success")
        -- Add logic to confiscate drugs or arrest the player
    else
        TriggerClientEvent("QBCore:Notify", src, "No drugs found in the vehicle.", "info")
    end
end)

-------------------------------------
-- 🚚 Drug Shipments
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:startShipment", function()
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    TriggerClientEvent("qb-growupgrades:client:startShipment", src)
    TriggerClientEvent("QBCore:Notify", -1, "A drug shipment is in progress. DEA agents, intercept it!", "info")
end)

-------------------------------------
-- 💰 Bribery System
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:bribe", function(amount)
    local src = source
    local Player = validatePlayer(src)
    if not Player then return end

    if Player.Functions.RemoveMoney("cash", amount) then
        exports['qb-heatlevel']:ReducePlayerHeat(src, amount / 100) -- Reduce heat based on bribe amount
        TriggerClientEvent("QBCore:Notify", src, "Bribe successful. Heat reduced.", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "Not enough money for a bribe.", "error")
    end
end)