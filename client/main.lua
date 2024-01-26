-----------------For support, scripts, and more----------------
--------------- https://discord.gg/AeCVP2F8h7  -------------
---------------------------------------------------------------

QBCore, ESX = nil, nil
local PlayerJob = nil

local PlayerBlips = {}
local blipsRunning = false

if Config.Framework == "qb" then
    QBCore = exports[Config.FrameworkTriggers["qb"].ResourceName]:GetCoreObject()
elseif Config.Framework == "esx" then
    local status, errorMsg = pcall(function() ESX = exports[Config.FrameworkTriggers["esx"].ResourceName]:getSharedObject() end)
    if (ESX == nil) then
        while ESX == nil do
            Wait(100)
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        end
    end
end

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerLoaded)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerLoaded, function()
    if Config.Framework == "qb" then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    elseif Config.Framework == "esx" then
        PlayerJob = ESX.GetPlayerData().job
    end
    if IsValidJob(PlayerJob.name) then
        StartBlipThread()
    end
end)

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerUnload)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerUnload, function()
    PlayerLoaded = false
    PlayerJob = nil
end)

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].OnJobUpdate)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].OnJobUpdate, function(job)
    PlayerJob = job
    if IsValidJob(PlayerJob.name) then
        StartBlipThread()
    else
        StopBlipThread()
    end
end)

AddEventHandler("onResourceStart", function(name)
    Wait(1000)
    if name == GetCurrentResourceName() then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        if IsValidJob(PlayerJob.name) then
            StartBlipThread()
        end
    end
end)

function IsValidJob(name)
    for k, v in pairs(Config.JobNames) do
        if v == name then
            return true
        end
    end
    return false
end

local function CreatePlayerBlips(id, label, coords, heading)
    local id = tonumber(id)
    if not heading then
        return
    end
    local color = Config.BlipInfo.color
    local ped = GetPlayerPed(id)
    local blip = GetBlipFromEntity(ped)
    if not DoesBlipExist(blip) then
        if NetworkIsPlayerActive(id) then
            blip = AddBlipForEntity(ped)
            SetBlipSprite(blip, Config.BlipInfo.sprite)
            SetBlipColour(blip, color)
        else
            blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, Config.BlipInfo.sprite)
            SetBlipColour(blip, color)
        end
        SetBlipCategory(blip, 7)
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(heading))
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, Config.ShortRangeBlips)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
        PlayerBlips[#PlayerBlips+1] = blip
    end
end


function StartBlipThread()
    if blipsRunning then
        return
    end
    CreateThread(function()
        if not blipsRunning then
            blipsRunning = true
            while blipsRunning do
                local blips = lib.callback.await("doc-blips:server:getBlipsForPrisoners", false)
                if PlayerBlips then
                    for k, v in pairs(PlayerBlips) do
                        RemoveBlip(v)
                    end
                end
                PlayerBlips = {}
                for k, v in pairs(blips) do
                    local id = GetPlayerFromServerId(v.id)
                    CreatePlayerBlips(id, v.name, v.coords, v.heading)
                end
                Wait(2000)
            end
        else
            if PlayerBlips then
                for k, v in pairs(PlayerBlips) do
                    RemoveBlip(v)
                end
            end
            blipsRunning = false
            Wait(100)
        end
    end)
end

function StopBlipThread()
    if PlayerBlips then
        for k, v in pairs(PlayerBlips) do
            RemoveBlip(v)
        end
    end
    blipsRunning = false
end
