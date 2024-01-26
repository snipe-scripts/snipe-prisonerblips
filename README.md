# Discord : https://discord.gg/AeCVP2F8h7
# Store : https://snipe.tebex.io

# Introduction

- This script will show the blips for cops for people who are jailed

# Installation

- It supports only QBCore and ESX. Rest can edit the script to make it work with their framework.
- Add the following to your server.cfg

```
ensure snipe-jailblips
```

# Server Exports
- You need to utilize the two exports in your jail script to make it work. The exports are:

```lua
-- source is the player who is jailed
-- name is the name of the player who is jailed
exports["snipe-prisonerblips"]:AddPrisoner(source, name) -- Adds the blip for the player who is jailed
```

```lua
-- source is the player who is jailed
exports["snipe-prisonerblips"]:RemovePrisoner(source) -- Removes the blip for the player who is jailed
```

# Example

## qb-prison (replace in server/main.lua)

```lua
RegisterNetEvent('prison:server:SetJailStatus', function(jailTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("injail", jailTime)
    if jailTime > 0 then
        if Player.PlayerData.job.name ~= "unemployed" then
            Player.Functions.SetJob("unemployed")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("info.lost_job"))
        end
        exports["snipe-prisonerblips"]:AddPrisoner(src, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) -- Added
    else
        GotItems[source] = nil
        exports["snipe-prisonerblips"]:RemovePrisoner(src) -- Added
    end
end)

```