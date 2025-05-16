local spawnedPlants = {}

RegisterNUICallback("closeTablet", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("setWaypoint", function(data, cb)
    SetNewWaypoint(data.x, data.y)
    QBCore.Functions.Notify("Waypoint set.", "success")
    cb({})
end)

RegisterNUICallback("triggerRaid", function(data, cb)
    TriggerServerEvent("qb-growupgrades:server:markForRaid", data.playerId)
    cb({})
end)

RegisterNUICallback("launchDrone", function(_, cb)
    local pos = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("qb-growupgrades:server:droneScan", pos, Config.Drone.scanRange)
    QBCore.Functions.Notify("Drone launched.", "success")
    cb({})
end)

RegisterCommand("deatablet", function()
    QBCore.Functions.TriggerCallback("qb-growupgrades:server:isDEA", function(allowed)
        if not allowed then
            QBCore.Functions.Notify("Access denied. DEA only.", "error")
            return
        end

        -- Replace qb-menu with NUI
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openTablet",
            data = {} -- You can inject suspect lists, evidence logs, etc. here
        })
    end)
end)

-------------------------------------
-- 🌿 Planting & Interaction
-------------------------------------
RegisterNetEvent('qb-growupgrades:client:spawnPlantType', function(plantId, coords, stage, cropType)
    local model = Config.PlantTypes[cropType]?.model[stage] or `prop_weed_01`
    local plant = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)
    FreezeEntityPosition(plant, true)
    spawnedPlants[plantId] = plant

    exports['qb-target']:AddTargetEntity(plant, {
        options = {
            {
                icon = "fas fa-leaf",
                label = "Harvest Plant",
                action = function()
                    TriggerServerEvent("qb-growupgrades:server:harvestPlant", plantId)
                end
            },
            {
                icon = "fas fa-tools",
                label = "Apply Upgrade",
                action = function()
                    TriggerEvent("qb-growupgrades:client:chooseUpgrade", plantId)
                end
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent('qb-growupgrades:client:removePlant', function(plantId)
    if spawnedPlants[plantId] then
        DeleteEntity(spawnedPlants[plantId])
        spawnedPlants[plantId] = nil
        QBCore.Functions.Notify("Evidence collected and plant removed.", "success")
    end
end)

RegisterNetEvent('qb-growupgrades:client:chooseUpgrade', function(plantId)
    local dialog = exports['qb-input']:ShowInput({
        header = "Apply Upgrade to Plant",
        submitText = "Apply",
        inputs = {
            {
                text = "Upgrade",
                name = "upgrade",
                type = "select",
                options = {
                    { label = "Grow Light", value = "grow_light" },
                    { label = "Hydro Kit", value = "hydro_kit" },
                    { label = "Filter Vent", value = "filter_vent" }
                }
            }
        }
    })

    if dialog and dialog.upgrade then
        TriggerServerEvent('qb-growupgrades:server:applyUpgrade', plantId, dialog.upgrade)
    end
end)

-------------------------------------
-- ⚗️ Meth Lab Cook + Minigame
-------------------------------------
RegisterCommand("cookmeth", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for _, coords in pairs(Config.MethLabLocations) do
        if #(pos - coords) < 2.0 then
            TriggerEvent("qb-growupgrades:client:startMethCook")
            return
        end
    end
    QBCore.Functions.Notify("Not near a meth lab.", "error")
end)

RegisterNetEvent("qb-growupgrades:client:startMethCook", function()
    exports['ps-ui']:Circle(function(success)
        if success then
            TriggerServerEvent("qb-growupgrades:server:completeMethCook", true)
        else
            -- Simulate explosion failure
            AddExplosion(GetEntityCoords(PlayerPedId()), 2, 5.0, true, false, 1.0)
            ApplyDamageToPed(PlayerPedId(), 50, false)
            QBCore.Functions.Notify("You failed the cook and caused an explosion!", "error")
            TriggerServerEvent("qb-growupgrades:server:completeMethCook", false)
        end
    end, 2, 10)
end)

RegisterNetEvent("qb-growupgrades:client:startMethCook", function()
    exports['ps-ui']:Circle(function(success)
        TriggerServerEvent("qb-growupgrades:server:completeMethCook", success)
    end, 2, 10)
end)



-------------------------------------
-- 💉 Heroin Grow Plant
-------------------------------------
RegisterCommand("plantheroin", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for _, coords in pairs(Config.HeroinFields) do
        if #(pos - coords) < 30.0 then
            TriggerServerEvent("qb-growupgrades:server:plantHeroin", pos)
            return
        end
    end
    QBCore.Functions.Notify("Not in a valid heroin field.", "error")
end)

RegisterNetEvent("qb-growupgrades:client:spawnHeroinPlant", function(id, pos)
    local plant = CreateObject(`prop_weed_02`, pos.x, pos.y, pos.z - 1.0, true, true, false)
    FreezeEntityPosition(plant, true)
    exports['qb-target']:AddTargetEntity(plant, {
        options = {
            {
                icon = "fas fa-syringe",
                label = "Harvest Heroin",
                action = function()
                    TriggerServerEvent("qb-growupgrades:server:harvestHeroin", id)
                end
            }
        },
        distance = 2.5
    })
end)

-------------------------------------
-- 🛰️ DEA Drone Scan Command
-------------------------------------
RegisterCommand("scanheroin", function()
    local pos = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("qb-growupgrades:server:scanHeroin", pos, 50.0)
end)

-------------------------------------
-- 🧪 LSD Lab Craft
-------------------------------------
RegisterCommand('enterlsdlab', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local lab = Config.LabLocations.lsd
    if #(pos - lab) < 2.0 then
        TriggerEvent('qb-growupgrades:client:startLSDCraft')
    else
        QBCore.Functions.Notify("You're not near the LSD lab.", "error")
    end
end)

RegisterNetEvent('qb-growupgrades:client:startLSDCraft', function()
    local lab = Config.LabRequirements.lsd
    QBCore.Functions.Progressbar("craft_lsd", "Synthesizing LSD...", lab.craftTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = "amb@world_human_chemistry_lab@male@base",
        anim = "base",
        flags = 49
    }, {}, {}, function()
        TriggerServerEvent("qb-growupgrades:server:completeLSDCraft")
    end, function()
        QBCore.Functions.Notify("Cancelled LSD synthesis.", "error")
    end)
end)

-------------------------------------
-- 💻 DEA Tablet (qb-menu based)
-------------------------------------
RegisterCommand("deatablet", function()
    QBCore.Functions.TriggerCallback("qb-growupgrades:server:isDEA", function(allowed)
        if not allowed then
            QBCore.Functions.Notify("Access denied. DEA only.", "error")
            return
        end

        local function openMainTablet()
            exports['qb-menu']:openMenu({
                { header = "DEA Tablet", isMenuHeader = true },
                { header = "🔍 Flagged Players", txt = "View heat levels", params = { event = "qb-growupgrades:client:tabletHeatMenu" } },
                { header = "🔎 Lookup Player", txt = "Search by Citizen ID", params = { event = "qb-growupgrades:client:lookupPlayerIntel" } },
                { header = "🪖 Evidence Log", txt = "Browse confiscated items", params = { event = "qb-growupgrades:client:viewEvidence" } },
                { header = "🚁 Drone Scan", txt = "Scan heroin field", params = { event = "qb-growupgrades:client:launchDrone" } },
            })
        end

        RegisterNetEvent("qb-growupgrades:client:tabletHeatMenu", function()
            local heatList = lib.callback.await("qb-growupgrades:server:getHeatList", false)
            if not heatList or #heatList == 0 then
                QBCore.Functions.Notify("No flagged players.", "info")
                return
            end
            local menu = {
                { header = "Back to Tablet", txt = "Return to main menu", params = { event = "deatablet" } },
                { header = "Flagged Player List", isMenuHeader = true }
            }
            for _, v in ipairs(heatList) do
                table.insert(menu, {
                    header = string.format("%s | Heat: %d", v.id, v.heat),
                    txt = "📍 GPS | 🚨 Raid",
                    params = { event = "qb-growupgrades:client:tabletSuspectAction", args = v }
                })
            end
            exports['qb-menu']:openMenu(menu)
        end)

        openMainTablet()
    end)
end)

RegisterNetEvent("qb-growupgrades:client:lookupPlayerIntel", function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Player Lookup",
        submitText = "Search",
        inputs = {
            { text = "Citizen ID", name = "cid", type = "text", isRequired = true }
        }
    })

    if dialog and dialog.cid then
        local info = lib.callback.await("qb-growupgrades:server:getPlayerIntel", false, dialog.cid)
        if info then
            QBCore.Functions.Notify("Heat: " .. info.heat .. ", Last Crop: " .. info.lastCrop, "primary")
            SetNewWaypoint(info.coords.x, info.coords.y)
        else
            QBCore.Functions.Notify("No data found.", "error")
        end
    end
end)

RegisterNetEvent("qb-growupgrades:client:spawnDrone", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local droneModel = `prop_drone_01`
    RequestModel(droneModel)
    while not HasModelLoaded(droneModel) do Wait(10) end

    local drone = CreateObject(droneModel, coords.x, coords.y, coords.z + 2.0, true, true, true)
    SetEntityAsMissionEntity(drone, true, true)
    PlaceObjectOnGroundProperly(drone)

    AttachEntityToEntity(drone, playerPed, GetPedBoneIndex(playerPed, 0x0), 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    QBCore.Functions.Notify("Drone deployed. Use it to scout the area.", "success")
end)

RegisterNetEvent("qb-growupgrades:client:spawnCheckpoint", function(coords)
    local checkpoint = AddBlipForRadius(coords.x, coords.y, coords.z, Config.CheckpointRadius)
    SetBlipColour(checkpoint, 1) -- Red color
    SetBlipAlpha(checkpoint, 128)

    -- Notify the player
    QBCore.Functions.Notify("Checkpoint created. Search vehicles within the area.", "info")

    -- Monitor vehicles in the area
    CreateThread(function()
        while DoesBlipExist(checkpoint) do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if #(playerCoords - coords) < Config.CheckpointRadius then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if vehicle ~= 0 then
                    QBCore.Functions.Notify("Press [E] to search the vehicle.", "info")
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent("qb-growupgrades:server:searchVehicle", GetVehicleNumberPlateText(vehicle))
                    end
                end
            end

            Wait(1000)
        end
    end)
end)

RegisterNetEvent("qb-growupgrades:client:startShipment", function()
    local playerPed = PlayerPedId()
    local startCoords = GetEntityCoords(playerPed)
    local endCoords = vector3(2000.0, 3000.0, 40.0) -- Example delivery location

    -- Create a blip for the delivery location
    local deliveryBlip = AddBlipForCoord(endCoords)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 2) -- Green color
    SetBlipRoute(deliveryBlip, true)

    -- Notify the player
    QBCore.Functions.Notify("Deliver the shipment to the marked location.", "success")

    -- Monitor delivery
    CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(playerPed)
            if #(playerCoords - endCoords) < 10.0 then
                QBCore.Functions.Notify("Shipment delivered successfully!", "success")
                RemoveBlip(deliveryBlip)
                TriggerServerEvent("qb-growupgrades:server:completeShipment")
                break
            end
            Wait(1000)
        end
    end)
end)

RegisterNetEvent("qb-growupgrades:client:removePlant", function(plantId)
    -- Remove the plant from the world
    local plant = BunkerPlants[plantId]
    if plant then
        DeleteEntity(plant)
        BunkerPlants[plantId] = nil
        QBCore.Functions.Notify("Evidence collected and plant removed.", "success")
    end
end)

RegisterNetEvent("qb-growupgrades:client:bribeNPC", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Find nearby NPCs
    local npc = GetClosestPed(coords.x, coords.y, coords.z, 5.0, true, false, false, false, false, false)
    if npc then
        -- Trigger the server event to process the bribe
        TriggerServerEvent("qb-growupgrades:server:bribe", 5000) -- Example bribe amount
    else
        QBCore.Functions.Notify("No NPCs nearby to bribe.", "error")
    end
end)


-- [GEN2 CARTEL RADIO + DRONE + EVIDENCE UI]
RegisterCommand("cartelradio", function(_, args)
    local msg = table.concat(args, " ")
    if msg and msg ~= "" then
        TriggerServerEvent("qb-growupgrades:server:cartelRadio", msg)
    end
end)

RegisterNetEvent("qb-growupgrades:client:launchDrone", function()
    local cooldown = lib.callback.await("qb-growupgrades:server:getDroneCooldown", false)
    if cooldown then
        QBCore.Functions.Notify("Drone cooldown active.", "error")
        return
    end
    local pos = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("qb-growupgrades:server:droneScan", pos, Config.Drone.scanRange)
    QBCore.Functions.Notify("Drone launched.")
end)

RegisterNetEvent("qb-growupgrades:client:viewEvidence", function()
    local info = lib.callback.await("qb-growupgrades:server:getEvidence", false)
    if not info or #info == 0 then
        QBCore.Functions.Notify("No evidence on file.", "error")
        return
    end
    for _, record in pairs(info) do
        QBCore.Functions.Notify("[" .. record.cid .. "] - " .. record.item)
    end
end)
