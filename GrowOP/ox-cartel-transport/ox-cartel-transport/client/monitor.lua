local highRiskFlagged = false

CreateThread(function()
    while true do
        Wait(3000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) and not highRiskFlagged then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                local plate = GetVehicleNumberPlateText(vehicle)
                lib.callback('ox_inventory:getInventoryItems', false, function(items)
                    local drugCount = 0
                    for _, item in pairs(items or {}) do
                        if lib.table.contains(Config.DrugItems, item.name) and not item.metadata or not item.metadata.hidden then
                            drugCount += item.count
                        end
                    end

                    if drugCount >= Config.HighRiskThreshold then
                        highRiskFlagged = true
                        TriggerServerEvent("ox-cartel-transport:triggerHeat", plate, GetEntityCoords(vehicle))
                        lib.notify({
                            title = "Cartel Transport",
                            description = "Your stash van has been flagged as high risk.",
                            type = "error"
                        })
                    end
                end, plate, 'trunk')
            end
        end
    end
end)
