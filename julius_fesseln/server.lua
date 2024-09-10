ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterServerEvent('julius_fesseln:rope')
AddEventHandler('julius_fesseln:rope', function(target)
    local ids = ExtractIdentifiers(source)
    local id = ExtractIdentifiers(target)
    local _source = source
    TriggerClientEvent("julius_fesseln:rope:askRoped", target, _source)
end)

RegisterServerEvent('julius_fesseln:rope:isRoped')
AddEventHandler('julius_fesseln:rope:isRoped', function(roped, roper)
    if not roped then
        local xPlayer = ESX.GetPlayerFromId(roper)
        if xPlayer.getInventoryItem("seile").count >= 1 then
            TriggerClientEvent('julius_fesseln:rope', source)
            xPlayer.removeInventoryItem("seile", 1)
            
        else
            TriggerClientEvent('juliusnotify', roper, '#FF0000', "info", 'Du hast kein Seil')
        end
    else
        TriggerClientEvent('julius_fesseln:rope', source)
        sendToDiscordKonfeszierFesseln("814776", "BloodyCity Logs", "FESSELN","`"..GetPlayerName(source).."` FESSELT den Spieler `"..GetPlayerName(target).."`\n\n**[FESSLER INFO]**\n\n**"..GetPlayerName(source).. " | ID: "..source.."**\n`DISCORD ID :`  <@"..ids.discord..">\n`STEAM-ID :` "..ids.steam.."\n\n**[GEFESSELTER INFO]**\n\n**"..GetPlayerName(target).. " | ID: "..target.."**\n`DISCORD ID:`  <@"..id.discord..">\n`STEAM-ID :`"..id.steam, "BloodyCity Logs")
    end
end)

RegisterServerEvent('julius_fesseln:search:isRoped')
AddEventHandler('julius_fesseln:search:isRoped', function(roped, roper)
    if roped then
        TriggerClientEvent('julius_fesseln:search', roper)

    else
        TriggerClientEvent('juliusnotify', roper, '#FF0000', "info", 'Dieser Spieler ist nicht gefesselt')
    end
end)

RegisterServerEvent('julius_fesseln:search')
AddEventHandler('julius_fesseln:search', function(target)
    local _source = source
    TriggerClientEvent('julius_fesseln:search:askRoped', target, _source)
end)

ESX.RegisterServerCallback('julius_fesseln:getOtherPlayerData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    local data = {
        name = GetPlayerName(target),
        job = xPlayer.job,
        inventory = xPlayer.inventory,
        accounts = xPlayer.accounts,
        weapons = xPlayer.loadout
    }

    cb(data)
    sendToDiscordFesseln("814776", "BloodyCity Logs", "KONFESZIEREN","`"..GetPlayerName(source).."` HAT DEN SPIELER `"..GetPlayerName(target).."` GEFESSELT `".."`\n\n**[FESSEL INFO]**\n\n**"..GetPlayerName(source).. " | ID: "..source.."**\n`DISCORD ID :`  <@"..ids.discord..">\n`STEAM-ID :` "..ids.steam.."\n\n**[FESSEL INFO]**\n\n**"..GetPlayerName(target).. " | ID: "..target.."**\n`DISCORD ID:`  <@"..id.discord..">\n`STEAM-ID :`"..id.steam, "BloodyCity Logs")

end)

RegisterNetEvent('julius_fesseln:confiscatePlayerItem')
AddEventHandler('julius_fesseln:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)
    local ids = ExtractIdentifiers(source)
    local id = ExtractIdentifiers(target)


    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
        local sourceItem = sourceXPlayer.getInventoryItem(itemName)

        -- does the target player have enough in their inventory?
        if targetItem.count > 0 and targetItem.count <= amount then

            -- can the player carry the said amount of x item?
            targetXPlayer.removeInventoryItem(itemName, amount)
            sourceXPlayer.addInventoryItem(itemName, amount)
            sendToDiscordKonfeszierItems("814776", "BloodyCity Logs", "KONFESZIEREN","`"..GetPlayerName(source).."` KONFESZIERT DEM SPIELER `"..GetPlayerName(target).."` das Item `"..itemName.." x"..amount.."`\n\n**[KONFESZIERER INFO]**\n\n**"..GetPlayerName(source).. " | ID: "..source.."**\n`DISCORD ID :`  <@"..ids.discord..">\n`STEAM-ID :` "..ids.steam.."\n\n**[KONFESZIERTER INFO]**\n\n**"..GetPlayerName(target).. " | ID: "..target.."**\n`DISCORD ID:`  <@"..id.discord..">\n`STEAM-ID :`"..id.steam, "BloodyCity Logs")
            TriggerClientEvent('juliusnotify', source, '#FF0000', 'info', 'Du nimmst weg')
            TriggerClientEvent('juliusnotify', target, '#FF0000', 'info', 'Dir wurde abgenommen')
        else
            TriggerClientEvent('juliusnotify', source, '#FF0000', "info", 'Ungültige Menge')
        end

    elseif itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)

        TriggerClientEvent('juliusnotify', source, '#FF0000', 'info', 'Du nimmst weg')
        TriggerClientEvent('juliusnotify', target, '#FF0000', 'info', 'Dir wurde abgenommen')

    elseif itemType == 'item_weapon' then
        if amount == nil then
            amount = 0
        end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon(itemName, amount)
            sendToDiscordKonfeszierWeapon("814776", "BloodyCity Logs", "KONFESZIEREN","`"..GetPlayerName(source).."` KONFESZIERT DEM SPIELER `"..GetPlayerName(target).."` die Waffe `"..itemName.."`\n\n**[KONFESZIERER INFO]**\n\n**"..GetPlayerName(source).. " | ID: "..source.."**\n`DISCORD ID :`  <@"..ids.discord..">\n`STEAM-ID :` "..ids.steam.."\n\n**[KONFESZIERTER INFO]**\n\n**"..GetPlayerName(target).. " | ID: "..target.."**\n`DISCORD ID:`  <@"..id.discord..">\n`STEAM-ID :`"..id.steam, "BloodyCity Logs")
        TriggerClientEvent('juliusnotify', target, '#FF0000', 'info', 'Dir wurde abgenommen')
        TriggerClientEvent('bd_notify', target, '#FF0000', 'info', 'Dir wurde abgenommen')
    end
end)

function sendToDiscordKonfeszierWeapon(color, name, title, message, footer)
	local embed = {
		  {
			  ["red"] = color,
			  ["Waffen-Konfestieren"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest("https://discord.com/api/webhooks/910644061776515073/ULiuQlzx18YIUtMo-04yn2ono-xjAMlwQgOiLoskTD65N_JYBHXR3UNVa70yPrynx_uD", function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function sendToDiscordKonfeszierItems(color, name, title, message, footer)
	local embed = {
		  {
			  ["red"] = color,
			  ["Item-Konfestieren"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest("https://discord.com/api/webhooks/910644400135241828/bRkBnihpPxqcTtXdpwN_2w2pyYOTc-KlMhcrQ_4aOvodw87EpTQsxxhKiOxYunnFeFSo", function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


function sendToDiscordFesseln(color, name, title, message, footer)
	local embed = {
		  {
			  ["red"] = color,
			  ["Item-Konfestieren"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest("https://discord.com/api/webhooks/910644400135241828/bRkBnihpPxqcTtXdpwN_2w2pyYOTc-KlMhcrQ_4aOvodw87EpTQsxxhKiOxYunnFeFSo", function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


function sendToDiscordKonfeszierFesseln(color, name, title, message, footer)
	local embed = {
		  {
			  ["red"] = color,
			  ["Fesseln-Logs"] = "**".. title .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }  
	PerformHttpRequest("https://discord.com/api/webhooks/910644942416797696/dzw09bQmPZCwpXlNdjVa1e7PNyTcHdTUbWv3s7q6xdGT4LJ-tGIXPu-wt9NHmw699M_K", function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end                     
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
		live = "",
		fivem = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
			local test = string.gsub(id,"discord:","")
            identifiers.discord = test
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        elseif string.find(id, "fivem") then
            identifiers.fivem = id
        end
    end

    return identifiers
end