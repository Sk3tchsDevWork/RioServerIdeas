CreateThread(function()
    for _, terminal in pairs(Config.Terminals) do
        exports.ox_target:addBoxZone({
            coords = terminal.coords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = "crypto_launder",
                    icon = "fas fa-laptop-code",
                    label = "Access Crypto Terminal",
                    event = "ox-cartel:launder"
                }
            }
        })
    end

    exports.ox_target:addBoxZone({
        coords = Config.Exchange.coords,
        size = vec3(1.5, 1.5, 1.5),
        rotation = 45,
        debug = false,
        options = {
            {
                name = "crypto_exchange",
                icon = "fas fa-hand-holding-usd",
                label = "Exchange Crypto to Cash",
                event = "ox-cartel:exchangeCrypto"
            }
        }
    })

    exports.ox_target:addBoxZone({
        coords = Config.LaunderMissions.start,
        size = vec3(1.5, 1.5, 1.5),
        rotation = 45,
        debug = false,
        options = {
            {
                name = "launder_mission",
                icon = "fas fa-truck",
                label = "Start Launder Delivery",
                event = "ox-cartel:startLaunderJob"
            }
        }
    })
end)

RegisterNetEvent("ox-cartel:launder", function()
    lib.callback('ox_inventory:getItemCount', false, function(count)
        if count <= 0 then
            lib.notify({ title = "Crypto Terminal", description = "No dirty money found.", type = "error" })
            return
        end
        TriggerServerEvent("ox-cartel:launderAttempt", count)
    end, Config.AllowedItem)
end)

RegisterNetEvent("ox-cartel:exchangeCrypto", function()
    TriggerServerEvent("ox-cartel:exchangeWallet")
end)

RegisterNetEvent("ox-cartel:startLaunderJob", function()
    TriggerServerEvent("ox-cartel:startLaunderJob")
end)

RegisterNetEvent("ox-cartel:deliverLaunderItem", function()
    TriggerServerEvent("ox-cartel:completeLaunderJob")
end)

RegisterNetEvent("ox-cartel:deaBlip", function(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Launder Drop")
    EndTextCommandSetBlipName(blip)
    Wait(60000)
    RemoveBlip(blip)
end)
