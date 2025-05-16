RegisterNetEvent("ox-dea:searchTarget", function(type, target)
    TriggerServerEvent("ox-dea:doSearch", type, target)
end)

-- Scanner tool (client-side logic)
RegisterNetEvent("ox-dea:useScanner", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, true)
    local pos = GetEntityCoords(ped)

    if veh ~= 0 then
        TriggerServerEvent("ox-dea:scanVehicle", GetVehicleNumberPlateText(veh))
    else
        TriggerServerEvent("ox_lib:notify", source, {
            title = "DEA Scanner",
            description = "No vehicle found nearby.",
            type = "error"
        })
    end
end)
