RegisterNetEvent("ox-cartel:deaBlip", function(coords, label)
    local PlayerData = exports['qb-core']:GetPlayerData()
    if PlayerData.job.name ~= "dea" then return end

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drug Activity: " .. label)
    EndTextCommandSetBlipName(blip)

    Wait(30000)
    RemoveBlip(blip)
end)
