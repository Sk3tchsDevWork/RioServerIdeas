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
