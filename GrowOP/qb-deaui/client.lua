RegisterCommand('deaui', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name ~= Config.AllowedJob then return end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openUI' })
    TriggerServerEvent('qb-deaui:server:reportHeat', exports['qb-heatlevel']:GetPlayerHeat())
end)

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('setWaypoint', function(data)
    SetNewWaypoint(data.coords.x + 0.0, data.coords.y + 0.0)
    QBCore.Functions.Notify("Waypoint set to suspect.")
end)

RegisterNUICallback('markRaid', function(data)
    local suspect = data.suspect
    TriggerServerEvent('qb-deaui:server:markRaidDispatch', suspect)
end)
