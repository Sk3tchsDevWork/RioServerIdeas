RegisterNetEvent("ox-cartel-transport:deaBlip", function(plate, coords)
    lib.notify({
        title = "DEA Alert",
        description = "Suspicious van detected: Plate " .. plate,
        type = "alert"
    })

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Flagged Transport")
    EndTextCommandSetBlipName(blip)

    Wait(45000)
    RemoveBlip(blip)
end)
