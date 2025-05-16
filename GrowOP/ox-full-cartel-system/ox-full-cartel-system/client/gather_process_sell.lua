local cooldowns = {}

for drug, data in pairs(Config.DrugTypes) do
    local gatherZone = CircleZone:Create(data.gather.coords, 2.0, { name = drug .. '_gather', debugPoly = false })
    gatherZone:onPlayerInOut(function(isInside)
        if isInside then
            lib.showTextUI("[E] Gather " .. data.label)
            while isInside do
                Wait(0)
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("ox-cartel:gather", drug)
                end
            end
            lib.hideTextUI()
        end
    end)

    local processZone = CircleZone:Create(data.process.coords, 2.0, { name = drug .. '_process', debugPoly = false })
    processZone:onPlayerInOut(function(isInside)
        if isInside then
            lib.showTextUI("[E] Process " .. data.label)
            while isInside do
                Wait(0)
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("ox-cartel:process", drug)
                end
            end
            lib.hideTextUI()
        end
    end)

    local sellZone = CircleZone:Create(data.sell.coords, 2.0, { name = drug .. '_sell', debugPoly = false })
    sellZone:onPlayerInOut(function(isInside)
        if isInside then
            lib.showTextUI("[E] Sell " .. data.label)
            while isInside do
                Wait(0)
                if IsControlJustReleased(0, 38) then
                    if not cooldowns[drug] or (os.time() - cooldowns[drug]) > data.sell.cooldown then
                        cooldowns[drug] = os.time()
                        TriggerServerEvent("ox-cartel:sell", drug)
                    else
                        lib.notify({ title = "Dealer", description = "Come back later.", type = "error" })
                    end
                end
            end
            lib.hideTextUI()
        end
    end)
end
