local growTimers = {}

RegisterNetEvent("qb-growupgrades:client:updatePlantTimer", function(plantId, timeLeft)
    local stage = "unknown"
    if timeLeft <= 0 then
        stage = "Large"
    elseif timeLeft < 300 then
        stage = "Medium"
    else
        stage = "Small"
    end

    growTimers[plantId] = {
        id = plantId,
        timeLeft = string.format("%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60),
        stage = stage,
        cropType = "Plant"
    }

    SendNUIMessage({
        type = "updatePlants",
        plants = table.values(growTimers)
    })
end)

-- Helper to convert table to values list
table.values = function(t)
    local r = {}
    for _, v in pairs(t) do r[#r+1] = v end
    return r
end
