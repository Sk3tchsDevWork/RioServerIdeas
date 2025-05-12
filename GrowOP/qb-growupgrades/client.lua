local spawnedPlants = {}

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
        TriggerEvent("qb-growupgrades:client:openDEATabletMenu")
    end)
end)

RegisterNetEvent("qb-growupgrades:client:openDEATabletMenu", function()
    exports['qb-menu']:openMenu({
        {
            header = "📊 Heat Panel",
            txt = "Track players with high heat",
            params = {
                event = "qb-growupgrades:client:tabletHeatMenu"
            }
        },
        {
            header = "🚨 Raid Management",
            txt = "Trigger raid on heat suspects",
            params = {
                event = "qb-growupgrades:client:tabletHeatMenu"
            }
        },
        {
            header = "🧠 Player Lookup",
            txt = "Search by Citizen ID",
            params = {
                event = "qb-growupgrades:client:lookupPlayerIntel"
            }
        },
        {
            header = "🛰️ Surveillance",
            txt = "Scan heroin fields nearby",
            params = {
                event = "",
                onSelect = function()
                    ExecuteCommand("scanheroin")
                end
            }
        },
        {
            header = "📁 Evidence Logs (WIP)",
            disabled = true
        }
    })
end)

RegisterNetEvent("qb-growupgrades:client:tabletHeatMenu", function()
    local heatList = lib.callback.await("qb-growupgrades:server:getHeatList", false)
    local menu = {}

    for _, v in ipairs(heatList) do
        table.insert(menu, {
            header = string.format("ID: %s | Heat: %d", v.id, v.heat),
            txt = "📍 GPS | 🚨 Raid",
            params = {
                event = "qb-growupgrades:client:tabletSuspectAction",
                args = v
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("qb-growupgrades:client:tabletSuspectAction", function(data)
    exports['qb-menu']:openMenu({
        {
            header = "Set GPS",
            txt = "Waypoint to grow area",
            params = {
                onSelect = function()
                    SetNewWaypoint(data.coords.x, data.coords.y)
                    QBCore.Functions.Notify("Waypoint set.")
                end
            }
        },
        {
            header = "Trigger Raid",
            txt = "Mark for DEA raid",
            params = {
                isServer = true,
                event = "qb-growupgrades:server:markForRaid",
                args = data.id
            }
        }
    })
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
