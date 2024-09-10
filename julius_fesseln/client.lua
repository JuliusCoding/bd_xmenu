Config = {}
Config.Locale = 'de'

local isRoped = false

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('bd_fesseln:rope:askRoped')
AddEventHandler('bd_fesseln:rope:askRoped', function(roper)
    TriggerServerEvent('bd_fesseln:rope:isRoped', isRoped, roper)
end)

RegisterNetEvent('bd_fesseln:search:askRoped')
AddEventHandler('bd_fesseln:search:askRoped', function(roper)
    TriggerServerEvent('bd_fesseln:search:isRoped', isRoped, roper)
end)

RegisterNetEvent('bd_fesseln:search')
AddEventHandler('bd_fesseln:search', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    OpenBodySearchMenu(closestPlayer)
end)

RegisterNetEvent('bd_fesseln:rope')
AddEventHandler('bd_fesseln:rope', function()
    local playerPed = PlayerPedId()
	local closestPed = GetPlayerPed(closestPlayer)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    Citizen.CreateThread(function()
        if isRoped then

            RequestAnimDict('mp_arresting')
            while not HasAnimDictLoaded('mp_arresting') do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
            SetPedCanPlayGestureAnims(playerPed, false)
			TriggerServerEvent('discordLogs', ''..GetPlayerName(closestPlayer)..' fesselt '..GetPlayerName(PlayerId())..'!', '1752220', 'fesseln')
            -- FreezeEntityPosition(playerPed, true)
            
            -- local name = NetworkPlayerGetName(PlayerId())
            -- TriggerServerEvent()
        else
            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
            FreezeEntityPosition(playerPed, false)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
            DisplayRadar(true)
			TriggerServerEvent('discordLogs', ''..GetPlayerName(closestPlayer)..' entfesselt '..GetPlayerName(PlayerId())..'!', '1752220', 'fesseln')
        end
    end)
    isRoped = not isRoped
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if isRoped then
            DisableControlAction(0, 74)
            DisableControlAction(0, 24)
            DisableControlAction(0, 25)
            DisableControlAction(0, 170)
            DisableControlAction(0, 73)
            DisableControlAction(0, 289)
        end
    end
end)

function OpenBodySearchMenu(player)
    ESX.TriggerServerCallback('bd_fesseln:getOtherPlayerData', function(data)
        local elements = {}
		local closestPed = GetPlayerPed(closestPlayer)
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

        for i = 1, #data.accounts, 1 do
            if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                table.insert(elements, {
                    label = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
                    value = 'black_money',
                    itemType = 'item_account',
                    amount = data.accounts[i].money
                })

                break
            end
        end

        table.insert(elements, {
            label = _U('guns_label')
        })

        for i = 1, #data.weapons, 1 do
            table.insert(elements, {
                label = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
                value = data.weapons[i].name,
                itemType = 'item_weapon',
                amount = data.weapons[i].ammo
            })
        end

        table.insert(elements, {
            label = _U('inventory_label')
        })

        for i = 1, #data.inventory, 1 do
            if data.inventory[i].count > 0 then
                table.insert(elements, {
                    label = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
                    value = data.inventory[i].name,
                    itemType = 'item_standard',
                    amount = data.inventory[i].count
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
            title = _U('search'),
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            if data.current.value then
                TriggerServerEvent('bd_fesseln:confiscatePlayerItem', GetPlayerServerId(player),
                    data.current.itemType, data.current.value, data.current.amount)
                OpenBodySearchMenu(player)
				TriggerServerEvent('discordLogs', ''..GetPlayerName(PlayerId())..' durchsucht  '..GetPlayerName(closestPlayer)..'!', '1752220', 'durchsuchen')
            end
        end, function(data, menu)
            menu.close()
        end)
    end, GetPlayerServerId(player))
end
