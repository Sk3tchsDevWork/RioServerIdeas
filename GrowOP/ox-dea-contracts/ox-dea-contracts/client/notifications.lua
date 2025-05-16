RegisterNetEvent("ox-dea:notifyRaid", function(name, coords)
    lib.notify({
        title = "DEA Contract",
        description = "High-Risk Suspect: " .. name,
        type = "alert"
    })

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("DEA Raid Target")
    EndTextCommandSetBlipName(blip)

    SetTimeout(Config.BlipDuration, function()
        RemoveBlip(blip)
    end)
end)
