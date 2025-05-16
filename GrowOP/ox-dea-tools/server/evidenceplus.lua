local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")
local evidenceLogFile = "./evidence_logs.json"
local webhook = "YOUR_DISCORD_WEBHOOK_HERE" -- Replace with your webhook

-- Append new evidence log to JSON file
function LogEvidence(data)
    local logs = {}
    local file = io.open(evidenceLogFile, "r")
    if file then
        logs = json.decode(file:read("*a")) or {}
        file:close()
    end

    table.insert(logs, data)

    local fileW = io.open(evidenceLogFile, "w+")
    if fileW then
        fileW:write(json.encode(logs))
        fileW:close()
    end
end

-- Send to Discord
function SendToDiscord(data)
    local msg = string.format("**DEA EVIDENCE LOG**\nAgent: %s\nSuspect/Vehicle: %s\nSeized Value: $%d\nTime: %s",
        data.agent, data.suspect, data.amount, os.date("%Y-%m-%d %H:%M:%S"))

    PerformHttpRequest(webhook, function(err, text, headers) end, "POST", json.encode({
        username = "DEA Evidence Logger",
        embeds = {{
            title = "Evidence Seizure",
            description = msg,
            color = 16711680
        }}
    }), {["Content-Type"] = "application/json"})
end

-- Hook into evidence bag creation
RegisterNetEvent("ox-dea:logEvidence", function(agent, suspect, amount)
    local logData = {
        agent = agent,
        suspect = suspect,
        amount = amount,
        time = os.time()
    }
    LogEvidence(logData)
    SendToDiscord(logData)
end)
