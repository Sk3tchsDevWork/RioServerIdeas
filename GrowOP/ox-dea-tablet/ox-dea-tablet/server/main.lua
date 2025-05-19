local json = require("json")

RegisterServerEvent("__cfx_internal:httpRequest")
AddEventHandler("__cfx_internal:httpRequest", function(req, cb)
    if req.path == "/getEvidence" then
        local file = io.open("./evidence_logs.json", "r")
        local data = file and json.decode(file:read("*a")) or {}
        if file then file:close() end
        cb(200, json.encode(data), { ["Content-Type"] = "application/json" })

    elseif req.path == "/getContracts" then
        local file = io.open("./contracts.json", "r")
        local data = file and json.decode(file:read("*a")) or {}
        if file then file:close() end
        cb(200, json.encode(data), { ["Content-Type"] = "application/json" })

    elseif req.path == "/saveCase" then
    local body = json.decode(req.body or "{}")
    local caseFile = io.open("./cases.json", "r")
    local cases = caseFile and json.decode(caseFile:read("*a")) or {}
    if caseFile then caseFile:close() end

    local evFile = io.open("./evidence_logs.json", "r")
    local evidence = evFile and json.decode(evFile:read("*a")) or {}
    if evFile then evFile:close() end

    local linked = {}
    for _, i in ipairs(body.links or {}) do
        if evidence[i + 1] then table.insert(linked, evidence[i + 1]) end
    end

    table.insert(cases, {
        case_id = body.id,
        suspect = body.suspect,
        notes = body.notes,
        linkedEvidence = linked,
        time = os.date("%Y-%m-%d %H:%M:%S")
    })

    local save = io.open("./cases.json", "w+")
    if save then
        save:write(json.encode(cases))
        save:close()
    end
        local embeds = {{
        title = "New Case for DEA Commander Review: " .. body.id,
        description = "**Suspect:** " .. body.suspect .. "\n**Notes:** " .. body.notes,
        fields = {},
        color = 3447003
    }}

    for _, ev in ipairs(linked) do
        table.insert(embeds[1].fields, {
            name = ev.agent .. " seized $" .. ev.amount,
            value = ev.time
        })
    end

    for _, img in ipairs(body.images or {}) do
        if img ~= "" then
            embeds[#embeds + 1] = { image = { url = img } }
        end
    end

    PerformHttpRequest("YOUR_DISCORD_WEBHOOK_HERE", function(err, text, headers) end, "POST", json.encode({
        username = "DEA Tablet",
        embeds = embeds
    }), {["Content-Type"] = "application/json"})

        cb(200, "OK", {})
        local body = json.decode(req.body or "{}")
        local caseFile = io.open("./cases.json", "r")
        local cases = caseFile and json.decode(caseFile:read("*a")) or {}
        if caseFile then caseFile:close() end
        table.insert(cases, {
            case_id = body.id,
            suspect = body.suspect,
            notes = body.notes,
            time = os.date("%Y-%m-%d %H:%M:%S")
        })
        local save = io.open("./cases.json", "w+")
        if save then
            save:write(json.encode(cases))
            save:close()
        end
            local embeds = {{
        title = "New Case for DEA Commander Review: " .. body.id,
        description = "**Suspect:** " .. body.suspect .. "\n**Notes:** " .. body.notes,
        fields = {},
        color = 3447003
    }}

    for _, ev in ipairs(linked) do
        table.insert(embeds[1].fields, {
            name = ev.agent .. " seized $" .. ev.amount,
            value = ev.time
        })
    end

    for _, img in ipairs(body.images or {}) do
        if img ~= "" then
            embeds[#embeds + 1] = { image = { url = img } }
        end
    end

    PerformHttpRequest("YOUR_DISCORD_WEBHOOK_HERE", function(err, text, headers) end, "POST", json.encode({
        username = "DEA Tablet",
        embeds = embeds
    }), {["Content-Type"] = "application/json"})

        cb(200, "OK", {})
    elseif req.path == "/getCases" then
    local f = io.open("./cases.json", "r")
    local cases = f and json.decode(f:read("*a")) or {}
    if f then f:close() end
    cb(200, json.encode(cases), { ["Content-Type"] = "application/json" })

    elseif req.path == "/commanderAction" then
    local body = json.decode(req.body or "{}")
    local log = string.format("Commander reviewed case %s: %s", body.id, body.action)
    print(log)

    PerformHttpRequest("YOUR_DISCORD_WEBHOOK_HERE", function(err, text, headers) end, "POST", json.encode({
        username = "DEA Commander",
        embeds = {{
            title = "Commander Action on Case",
            description = log,
            color = (body.action == "approve") and 3066993 or 15158332
        }}
    }), {["Content-Type"] = "application/json"})

    cb(200, "OK", {})

    else
        cb(404, "Not Found", {})
    end
end)
