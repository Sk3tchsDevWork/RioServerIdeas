CreateThread(function()
    for _, hideout in pairs(Config.Hideouts) do
        -- Stash target
        exports.ox_target:addBoxZone({
            coords = hideout.stash.coords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = "stash_" .. hideout.stash.label,
                    icon = "fas fa-box-open",
                    label = "Open Stash",
                    onSelect = function()
                        TriggerServerEvent("ox-cartel:openStash", hideout.stash.label)
                    end
                }
            }
        })

        -- Panic alarm target
        exports.ox_target:addBoxZone({
            coords = hideout.alarm.coords,
            size = vec3(1.0, 1.0, 1.0),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = "panic_alarm_" .. hideout.alarm.label,
                    icon = hideout.alarm.icon,
                    label = hideout.alarm.label,
                    event = hideout.alarm.event
                }
            }
        })
    end
end)
