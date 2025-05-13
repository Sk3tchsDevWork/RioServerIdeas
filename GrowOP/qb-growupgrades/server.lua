
-- Resource: qb-growupgrades
-- Enhanced Server Logic with Fixes and Persistence

local BunkerPlants, HeroinPlants, MethCooldowns = {}, {}, {}
local heroinPlantId = 0

-------------------------------------
-- 🧹 Start Cleanup Thread
-------------------------------------
CreateThread(function()
    while true do
        MySQL.query("DELETE FROM bunker_plants WHERE plantedAt < ?", { os.time() - (24 * 60 * 60) })
        Wait(3600000)
    end
end)

-------------------------------------
-- 🧪 Save Upgrades to DB
-------------------------------------
RegisterNetEvent('qb-growupgrades:server:applyUpgrade', function(plantId, upgrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not BunkerPlants[plantId] then return end

    -- Apply upgrade
    table.insert(BunkerPlants[plantId].upgrades, upgrade)

    MySQL.update('UPDATE bunker_plants SET upgrades = ? WHERE id = ?', {
        json.encode(BunkerPlants[plantId].upgrades), plantId
    })

    TriggerClientEvent('QBCore:Notify', src, 'Upgrade applied successfully.', 'success')
end)

-------------------------------------
-- 🧪 Reapply Upgrades on Load
-------------------------------------
CreateThread(function()
    local results = MySQL.query.await('SELECT * FROM bunker_plants')
    for _, row in ipairs(results) do
        local id = row.id
        BunkerPlants[id] = {
            coords = json.decode(row.coords),
            upgrades = json.decode(row.upgrades or '[]'),
            owner = row.owner,
            plantedAt = row.plantedAt,
            stage = row.stage,
            watered = row.watered,
            cropType = row.cropType
        }
        TriggerClientEvent('qb-growupgrades:client:spawnPlantType', -1, id, BunkerPlants[id].coords, row.stage, row.cropType)
    end
end)

-------------------------------------
-- 🔥 Add Heat from Heroin Planting
-------------------------------------
RegisterNetEvent("qb-growupgrades:server:plantHeroin", function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Player.Functions.RemoveItem(Config.HeroinGrow.seedItem, 1) then
        TriggerClientEvent("QBCore:Notify", src, "Missing poppy seed.", "error")
        return
    end

    heroinPlantId += 1
    HeroinPlants[heroinPlantId] = {
        owner = Player.PlayerData.citizenid,
        coords = coords,
        plantedAt = os.time()
    }
    TriggerClientEvent("qb-growupgrades:client:spawnHeroinPlant", -1, heroinPlantId, coords)
    TriggerEvent("qb-growupgrades:server:generateHeat", "plantCrop")
end)

-------------------------------------
-- 🧠 Name-based DEA Tablet Lookup
-------------------------------------
lib.callback.register("qb-growupgrades:server:getPlayerIntelByName", function(_, name)
    local result = MySQL.single.await('SELECT heat, last_crop, last_known_coords FROM player_heat WHERE CONCAT(charinfo->>'$.firstname', " ", charinfo->>'$.lastname') = ?', { name })
    if not result then return nil end
    return {
        heat = result.heat,
        lastCrop = result.last_crop,
        coords = json.decode(result.last_known_coords)
    }
end)

-------------------------------------
-- 🧪 Admin Debug Plant Command
-------------------------------------
RegisterCommand("debugPlantList", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == "admin" then
        print("---- Current Bunker Plants ----")
        for id, plant in pairs(BunkerPlants) do
            print(string.format("[ID %s] Crop: %s | Upgrades: %s", id, plant.cropType, json.encode(plant.upgrades)))
        end
    end
end, false)
