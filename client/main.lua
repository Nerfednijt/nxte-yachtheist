local QBCore = exports['qb-core']:GetCoreObject()

local yachtBlip = nil
local CopCount = 0
local isActive = false
local Buyer = nil
local Hack1 = false
local Hack2 = false
local Loot1 = false 
local Loot2 = false
---------------
-- FUNCTIONS --
---------------
local function HeistBlip()
    yachtBlip = AddBlipForCoord(-2070.56, -1022.4, 11.91)
    SetBlipSprite(yachtBlip, 587)
    SetBlipColour(yachtBlip, 66)
    SetBlipDisplay(yachtBlip, 4)
    SetBlipScale(yachtBlip, 0.8)
    SetBlipAsShortRange(yachtBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Yacht')
    EndTextCommandSetBlipName(yachtBlip)
    SetBlipRoute(yachtBlip, true)
end

-- function to call cops
local function CallCops()
 -- your code here
end

-- for hack1
local function OnHack1Done(success)
    if success then 
        if Config.PedOnHack1 then
            TriggerEvent('nxte-yacht:client:SpawnNPC', 1)
        end
        QBCore.Functions.Notify('Successfully disabled the camera\'s', 'success')
        TriggerServerEvent('QBCore:Server:RemoveItem', Config.Hack1Item, 1, slot, info)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Hack1Item], 'remove')
        TriggerServerEvent('nxte-yacht:server:SetHack1', true)
        CallCops()
    else
        QBCore.Functions.Notify('You failed to hack the camera\'s!', 'error')
        TriggerServerEvent('QBCore:Server:RemoveItem', Config.Hack1Item, 1, slot, info)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Hack1Item], 'remove')
        CallCops()
    end
end

-- for hack2
local function OnHack2Done(success)
    if success then 
        if Config.PedOnHack2 then
            TriggerEvent('nxte-yacht:client:SpawnNPC', 2)
        end
        CallCops()
        QBCore.Functions.Notify('Successfully disabled the security lock', 'success')
        TriggerServerEvent('QBCore:Server:RemoveItem', Config.Hack2Item, 1, slot, info)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Hack2Item], 'remove')
        TriggerServerEvent('nxte-yacht:server:SetHack2', true)
    else
        CallCops()
        QBCore.Functions.Notify('You failed to hack the security lock', 'error')
        TriggerServerEvent('QBCore:Server:RemoveItem', Config.Hack2Item, 1, slot, info)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Hack2Item], 'remove')
    end
end


--------------
--- EVENTS ---
--------------
-- sync all info on player Load to prevent exploiting 
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('nxte-yacht:server:OnPlayerLoad')
end)

-- heist start
RegisterNetEvent('nxte-yacht:client:startheist', function()
    TriggerServerEvent('nxte-yacht:server:GetActive')
    TriggerServerEvent('nxte-yacht:server:GetCops')
    local Player = QBCore.Functions.GetPlayerData()
    local cash = Player.money.cash
    local ped = PlayerPedId()
    SetEntityCoords(ped, vector3(-1117.76, -1488.25, 3.7))
    SetEntityHeading(ped, 219.73)
    TriggerEvent('animations:client:EmoteCommandStart', {"knock"})
    QBCore.Functions.Progressbar("Knock", "Knocking on door...", 4000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        if CopCount >= Config.MinCop then
            if not isActive then 
                if cash >= Config.HeistPrice then
                    HeistBlip()
                    Buyer = Player.citizenid
                    QBCore.Functions.Notify('You purchased the GPS locations for $'..Config.HeistPrice.. '', 'success')
                    TriggerServerEvent('nxte-yacht:server:SetActive', true)
                    TriggerServerEvent('nxte-yacht:server:removemoney', Config.HeistPrice)
                else 
                    QBCore.Functions.Notify('Am i working with an amature here ?? YES i want it in cash','error')
                end
            else 
                local random =  math.random(1, 4)
                if random == 1 then
                    QBCore.Functions.Notify('No one is home come back later', 'error')
                elseif random == 2 then 
                    QBCore.Functions.Notify('Leave me alone im asleep', 'error')
                elseif random == 3 then 
                    QBCore.Functions.Notify('You realise how late it is ?? go away', 'error')
                elseif random == 4 then 
                    QBCore.Functions.Notify('Uuuh... kinda busy right now', 'error')
                end
            end
        else 
            QBCore.Functions.Notify('There is not enough police', 'error')
        end
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

-- hack 1 
RegisterNetEvent('nxte-yacht:client:hack1', function()
    TriggerServerEvent('nxte-yacht:server:GetHack1')
    if isActive then
        if not Hack1 then
            if QBCore.Functions.HasItem(Config.Hack1Item) then
                TriggerEvent('nxte-yacht:anim:hack1')
            else 
                QBCore.Functions.Notify('You do not have the required tool to do this hack', 'error')
            end
        else 
            QBCore.Functions.Notify('This computer is already hacked', 'error')
        end
    else 
        QBCore.Functions.Notify('You currenlty can not do this', 'error')
    end

end)

-- anim for hack1
RegisterNetEvent('nxte-yacht:anim:hack1', function()
    local loc = {x,y,z,h} 
    loc.x = -2078.16
    loc.y = -1016.49
    loc.z = 7.1
    loc.h = 75.69

    local animDict = 'anim@heists@ornate_bank@hack'
    RequestAnimDict(animDict)
    RequestModel('hei_prop_hst_laptop')
    RequestModel('hei_p_m_bag_var22_arm_s')

    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded('hei_prop_hst_laptop')
        or not HasModelLoaded('hei_p_m_bag_var22_arm_s') do
        Wait(100)
    end

    local ped = PlayerPedId()
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    SetPedComponentVariation(ped, 5, Config.HideBagID, 1, 1)
    SetEntityHeading(ped, loc.h)
    local animPos = GetAnimInitialOffsetPosition(animDict, 'hack_enter', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, 'hack_loop', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, 'hack_exit', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)

    FreezeEntityPosition(ped, true)
    local netScene = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), targetPosition, 1, 1, 0)
    local laptop = CreateObject(GetHashKey('hei_prop_hst_laptop'), targetPosition, 1, 1, 0)

    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, 'hack_enter', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, 'hack_enter_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, 'hack_enter_laptop', 4.0, -8.0, 1)

    local netScene2 = NetworkCreateSynchronisedScene(animPos2, targetRotation, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, 'hack_loop', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, 'hack_loop_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, 'hack_loop_laptop', 4.0, -8.0, 1)

    local netScene3 = NetworkCreateSynchronisedScene(animPos3, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, 'hack_exit', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, 'hack_exit_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, 'hack_exit_laptop', 4.0, -8.0, 1)

    Wait(200)
    NetworkStartSynchronisedScene(netScene)
    Wait(6300)
    NetworkStartSynchronisedScene(netScene2)
    Wait(2000)

    exports['hacking']:OpenHackingGame(Config.Hack1Time, Config.Hack1Squares, Config.Hack1Repeat, function(success)
        NetworkStartSynchronisedScene(netScene3)
        NetworkStopSynchronisedScene(netScene3)
        DeleteObject(bag)
        SetPedComponentVariation(ped, 5, Config.BagUseID, 0, 1)
        DeleteObject(laptop)
        FreezeEntityPosition(ped, false)
        OnHack1Done(success)
    end)
end)

-- hack 2
RegisterNetEvent('nxte-yacht:client:hack2', function()
    TriggerServerEvent('nxte-yacht:server:GetHack2')
    Citizen.Wait(1000)
    if isActive then 
        if Hack1 then 
            if not Hack2 then 
                if QBCore.Functions.HasItem(Config.Hack2Item) then
                    TriggerEvent('nxte-yacht:anim:hack2')
                else 
                    QBCore.Functions.Notify('You do not have the required tool to do this hack', 'error')
                end
            else 
                QBCore.Functions.Notify('This panel is already hacked', 'error')
            end
        else 
            QBCore.Functions.Notify('The camera\'s are still active', 'error')
        end
    else 
        QBCore.Functions.Notify('You currenlty can not do this', 'error')
    end
end)

-- anim for hack2
RegisterNetEvent('nxte-yacht:anim:hack2', function()
    local loc = {x,y,z,h} 
    loc.x = -2055.3
    loc.y = -1028.21
    loc.z = 3.8
    loc.h = 75.69

    local animDict = 'anim@heists@ornate_bank@hack'
    RequestAnimDict(animDict)
    RequestModel('hei_prop_hst_laptop')
    RequestModel('hei_p_m_bag_var22_arm_s')

    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded('hei_prop_hst_laptop')
        or not HasModelLoaded('hei_p_m_bag_var22_arm_s') do
        Wait(100)
    end

    local ped = PlayerPedId()
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    SetPedComponentVariation(ped, 5, Config.HideBagID, 1, 1)
    SetEntityHeading(ped, loc.h)
    local animPos = GetAnimInitialOffsetPosition(animDict, 'hack_enter', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, 'hack_loop', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, 'hack_exit', loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)

    FreezeEntityPosition(ped, true)
    local netScene = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), targetPosition, 1, 1, 0)
    local laptop = CreateObject(GetHashKey('hei_prop_hst_laptop'), targetPosition, 1, 1, 0)

    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, 'hack_enter', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, 'hack_enter_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, 'hack_enter_laptop', 4.0, -8.0, 1)

    local netScene2 = NetworkCreateSynchronisedScene(animPos2, targetRotation, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, 'hack_loop', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, 'hack_loop_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, 'hack_loop_laptop', 4.0, -8.0, 1)

    local netScene3 = NetworkCreateSynchronisedScene(animPos3, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, 'hack_exit', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, 'hack_exit_bag', 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, 'hack_exit_laptop', 4.0, -8.0, 1)

    Wait(200)
    NetworkStartSynchronisedScene(netScene)
    Wait(6300)
    NetworkStartSynchronisedScene(netScene2)
    Wait(2000)

    exports['hacking']:OpenHackingGame(Config.Hack2Time, Config.Hack2Squares, Config.Hack2Repeat, function(success)
        NetworkStartSynchronisedScene(netScene3)
        NetworkStopSynchronisedScene(netScene3)
        DeleteObject(bag)
        SetPedComponentVariation(ped, 5, Config.BagUseID, 0, 1)
        DeleteObject(laptop)
        FreezeEntityPosition(ped, false)
        OnHack2Done(success)
    end)
end)

RegisterNetEvent('nxte-yacht:client:loot1', function()
    TriggerServerEvent('nxte-yacht:server:GetLoot1')
    local ped = PlayerPedId()
    SetEntityCoords(ped, vector3(-2087.54, -1019.77, 8.97))
    SetEntityHeading(ped, 249.15)
    TriggerEvent('animations:client:EmoteCommandStart', {"medic"})
    QBCore.Functions.Progressbar("loot", "Searching closet...", 10000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if isActive then 
            if Hack2 then 
                if not Loot1 then 
                    local random = math.random(1,10)
                    if random >= 2 then -- normal loot 
                        local chance = math.random(Config.Loot1AmountMin,Config.Loot1AmountMax)
                        TriggerServerEvent('QBCore:Server:AddItem', Config.Loot1Item, chance, slot, info)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Loot1Item], 'add')
                        TriggerServerEvent('nxte-yacht:server:SetLoot1', true)
                    else -- rare loot 
                        local chance = math.random(Config.Loot1RareAmountMin,Config.Loot1RareAmountMax)
                        TriggerServerEvent('QBCore:Server:AddItem', Config.Loot1RareItem, chance, slot, info)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.LootRare1Item], 'add')
                        TriggerServerEvent('nxte-yacht:server:SetLoot1', true)
                    end
                else
                    QBCore.Functions.Notify('The closet is already emptied' , 'error')
                end
            else
                QBCore.Functions.Notify('The lock is still active' , 'error')
            end
        else 
            QBCore.Functions.Notify('You can\'t search this closet right now' , 'error')
        end
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.Notify('Cancelled searching the closet', 'error')
    end)
end)

-- loot 2
RegisterNetEvent('nxte-yacht:client:loot2', function()
    TriggerServerEvent('nxte-yacht:server:GetLoot2')
    local ped = PlayerPedId()
    SetEntityCoords(ped, vector3(-2083.55, -1017.99, 11.9))
    SetEntityHeading(ped, 249.15)
    TriggerEvent('animations:client:EmoteCommandStart', {"medic"})
    QBCore.Functions.Progressbar("loot", "Searching closet...", 10000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if isActive then 
            if Hack2 then 
                if not Loot2 then 
                    local random = math.random(1,10)
                    if random >= 2 then -- normal loot 
                        local chance = math.random(Config.Loot2AmountMin,Config.Loot2AmountMax)
                        TriggerServerEvent('QBCore:Server:AddItem', Config.Loot2Item, chance, slot, info)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.Loot2Item], 'add')
                        TriggerServerEvent('nxte-yacht:server:SetLoot2', true)
                    else -- rare loot 
                        local chance = math.random(Config.Loot2RareAmountMin,Config.Loot2RareAmountMax)
                        TriggerServerEvent('QBCore:Server:AddItem', Config.Loot2RareItem, chance, slot, info)
                        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[Config.LootRare2Item], 'add')
                        TriggerServerEvent('nxte-yacht:server:SetLoot2', true)
                    end
                else
                    QBCore.Functions.Notify('The closet is already emptied' , 'error')
                end
            else
                QBCore.Functions.Notify('The lock is still active' , 'error')
            end
        else 
            QBCore.Functions.Notify('You can\'t search this closet right now' , 'error')
        end
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.Notify('Cancelled searching the closet', 'error')
    end)
end)

-------------------
--- SERVER INFO ---
-------------------

-- how many on duty cops ?
RegisterNetEvent('nxte-yacht:client:GetCops',function(amount)
    CopCount = amount
end)

-- is heist already active ?
RegisterNetEvent('nxte-yacht:client:SetActive',function(status)
    isActive = status
end)

-- is hack 1 already done ?
RegisterNetEvent('nxte-yacht:client:SetHack1',function(status)
    Hack1 = status
end)

-- is hack 2 already done ?
RegisterNetEvent('nxte-yacht:client:SetHack2',function(status)
    Hack2 = status
end)

-- is loot 1 already done ?
RegisterNetEvent('nxte-yacht:client:SetLoot1',function(status)
    Loot1 = status
end)

-- is loot 2 already done ?
RegisterNetEvent('nxte-yacht:client:SetLoot2',function(status)
    Loot2 = status
end)

-- set NPC data
RegisterNetEvent('nxte-yacht:client:SpawnNPC', function(position)
    QBCore.Functions.TriggerCallback('nxte-yacht:server:SpawnNPC', function(netIds, position)
        Wait(1000)
        local ped = PlayerPedId()
        for i=1, #netIds, 1 do
            local npc = NetworkGetEntityFromNetworkId(netIds[i])
            SetPedDropsWeaponsWhenDead(npc, false)
            GiveWeaponToPed(npc, Config.PedGun, 250, false, true)
            SetPedMaxHealth(npc, 500)
            SetPedArmour(npc, 200)
            SetCanAttackFriendly(npc, true, false)
            TaskCombatPed(npc, ped, 0, 16)
            SetPedCombatAttributes(npc, 46, true)
            SetPedCombatAttributes(npc, 0, false)
            SetPedCombatAbility(npc, 100)
            SetPedAsCop(npc, true)
            SetPedRelationshipGroupHash(npc, `HATES_PLAYER`)
            SetPedAccuracy(npc, 60)
            SetPedFleeAttributes(npc, 0, 0)
            SetPedKeepTask(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
        end
    end, position)
end)

-- Check if player is dead to stop mission
Citizen.CreateThread(function()
    while true do
        if isActive then
            local Player = QBCore.Functions.GetPlayerData()
            local Playerid = Player.citizenid
            if Playerid == Buyer then
                if Player.metadata["inlaststand"] or Player.metadata["isdead"] then
                    QBCore.Functions.Notify('Mission Failed', 'error')
                    TriggerServerEvent('nxte-yacht:server:ResetHeist')
                    RemoveBlip(yachtBlip)
                    Citizen.Wait(2000)
                    Buyer = nil
                end
            end
        end
        Citizen.Wait(5000)
    end
end)

-- check if mission is complete to reset
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        if Loot1 and Loot2 then 
            RemoveBlip(yachtBlip)
            Citizen.Wait(Config.TimeOut*60000)
            TriggerServerEvent('nxte-yacht:server:ResetHeist')
        end
    end
end)
