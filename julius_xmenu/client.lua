local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = nil


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(0)
	end

	PlayerData = ESX.GetPlayerData()
end)


local enable = false
function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable
 
        if enable then
            SendNUIMessage({
                action = 'open'
            })
            SetTimecycleModifier("BloomMid")
        else
            SetTimecycleModifier("")
            SetTransitionTimecycleModifier("")    
            SendNUIMessage({
                action = 'close'
            })
        end
   
end
function startAttitude(lib, anim)
	ESX.Streaming.RequestAnimSet(lib, function()
		SetPedMovementClipset(PlayerPedId(), anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(PlayerPedId(), anim, 0, false)
end


RegisterNUICallback('kofferraum', function(data, cb)
    toggleField(false)

    ExecuteCommand("openTrunk")

    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET")
end)



RegisterNUICallback('seil', function(data, cb)
    toggleField(false)

    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET")

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 1.0 then
        TriggerEvent("juliusnotify", "#40fdfe", "INFO", "Keine Spieler in der Nähe!")
    else
            TriggerServerEvent('julius_fesseln:rope', GetPlayerServerId(closestPlayer))
    end
end)

RegisterNUICallback('autoschlussel', function(data, cb)
    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET")

    toggleField(false)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    local hasAlreadyLocked = false
    cars = ESX.Game.GetVehiclesInArea(coords, 30)
    local carstrie = {}
    local cars_dist = {}		
    notowned = 0
    if #cars == 0 then
        TriggerEvent("juliusnotify", "#FF0000", "BENACHRICHTIGUNG", "Keins deiner Fahrzeuge in der Nähe!")
    else
        for j=1, #cars, 1 do
            local coordscar = GetEntityCoords(cars[j])
            local distance = Vdist(coordscar.x, coordscar.y, coordscar.z, coords.x, coords.y, coords.z)
            table.insert(cars_dist, {cars[j], distance})
        end
        for k=1, #cars_dist, 1 do
            local z = -1
            local distance, car = 999
            for l=1, #cars_dist, 1 do
                if cars_dist[l][2] < distance then
                    distance = cars_dist[l][2]
                    car = cars_dist[l][1]
                    z = l
                end
            end
            if z ~= -1 then
                table.remove(cars_dist, z)
                table.insert(carstrie, car)
            end
        end
        for i=1, #carstrie, 1 do
            local plate = ESX.Math.Trim(GetVehicleNumberPlateText(carstrie[i]))
            ESX.TriggerServerCallback('julius_xmenu:isVehicleOwner', function(owner)
                if owner and hasAlreadyLocked ~= true then
                    local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(carstrie[i]))
                    vehicleLabel = GetLabelText(vehicleLabel)
                    local lock = GetVehicleDoorLockStatus(carstrie[i])
                    if lock == 1 or lock == 0 then
                        SetVehicleDoorShut(carstrie[i], 0, false)
                        SetVehicleDoorShut(carstrie[i], 1, false)
                        SetVehicleDoorShut(carstrie[i], 2, false)
                        SetVehicleDoorShut(carstrie[i], 3, false)
                        SetVehicleDoorsLocked(carstrie[i], 2)
                        PlayVehicleDoorCloseSound(carstrie[i], 1)
                        TriggerEvent("juliusnotify", "#FF0000", "BENACHRICHTIGUNG", "Du hast dein Auto abgeschlossen.")
                        if not IsPedInAnyVehicle(PlayerPedId(), true) then
                            TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                        end
                        SetVehicleLights(carstrie[i], 2)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 0)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 2)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 0)
                        hasAlreadyLocked = true
                    elseif lock == 2 then
                        SetVehicleDoorsLocked(carstrie[i], 1)
                        PlayVehicleDoorOpenSound(carstrie[i], 0)
                        TriggerEvent("juliusnotify", "#FF0000", "BENACHRICHTIGUNG", "Du hast dein Fahrzeug aufgeschlossen.")
                        if not IsPedInAnyVehicle(PlayerPedId(), true) then
                            TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                        end
                        SetVehicleLights(carstrie[i], 2)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 0)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 2)
                        Citizen.Wait(150)
                        SetVehicleLights(carstrie[i], 0)
                        hasAlreadyLocked = true
                    end
                else
                    notowned = notowned + 1
                end
                if notowned == #carstrie then
                      TriggerEvent("juliusnotify", "#FF0000", "BENACHRICHTIGUNG", "Keins deiner Fahrzeuge in der Nähe!")
                end	
            end, plate)
        end			
    end
end)

RegisterNUICallback('suchen', function(data, cb)
    toggleField(false)

    PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET")

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 1.0 then
        TriggerEvent("juliusnotify", "#FF0000", "BENACHRICHTIGUNG", "Keine Spieler in der Nähe!")
    else
        TriggerServerEvent('julius_fesseln:search', GetPlayerServerId(closestPlayer))
    end
end)


RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    
    ClearPedTasks(PlayerPedId())
end)

RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)
    
    ClearPedTasks(PlayerPedId())
end)


AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() ~= name then
        return
    end
 
    toggleField(false)
end)

CreateThread(function()
    while true do
		Citizen.Wait(0)
 
 
        if IsControlPressed(0, 73) then
            if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                toggleField(true)
                SendNUIMessage({action = 'open', inVehicle = "no"})
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        
    end
end)

-- CreateThread(function()
--     while true do
-- 		Citizen.Wait(0)
 
 
--         if IsControlJustPressed(0, 322) then
--             if not IsPedInAnyVehicle(GetPlayerPed(-1), true) then 

--             toggleField(false)

--             end
--         end
--     end
-- end)