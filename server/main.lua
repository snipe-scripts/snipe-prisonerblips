local activePrisoners = {}
local pedHandles = {}

lib.callback.register("doc-blips:server:getBlipsForPrisoners", function(source)
    local returnData = {}
    for k, v in pairs(activePrisoners) do
        if not pedHandles[v.id] then
            local ped = GetPlayerPed(v.id)
            pedHandles[v.id] = ped
        end
        local coords = GetEntityCoords(pedHandles[v.id])
        local heading = GetEntityHeading(pedHandles[v.id])
        local sendName = "[Prisoner]:"..v.name
        returnData[#returnData+1] = {id = v.id, name = sendName, coords = coords, heading = heading}
    end
    return returnData
end)

local function PrisonerExist(source)
    for k, v in pairs(activePrisoners) do
        if v.id == source then
            return true
        end
    end
    return false
end

local function AddPrisoner(source, name)
    if PrisonerExist(source) then
        return
    end
    activePrisoners[#activePrisoners+1] = {id = source, name = name}
end

local function RemovePrisoner(source)
    for k, v in pairs(activePrisoners) do
        if v.id == source then
            table.remove(activePrisoners, k)
            break
        end
    end
end

exports("AddPrisoner", AddPrisoner)
exports("RemovePrisoner", RemovePrisoner)

AddEventHandler("playerDropped", function()
    RemovePrisoner(source)
end)