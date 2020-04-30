CF = {}

CF.Game = {}

CF.CurrentRequestId = 0

CF.ServerCallbacks = {}

CF.PlayerData = nil

CF.TimeoutCallbacks = {}

CF.TriggerServerCallback = function(name, cb, ...)
	CF.ServerCallbacks[CF.CurrentRequestId] = cb

	TriggerServerEvent('cf:triggerServerCallback', name, CF.CurrentRequestId, ...)

	if CF.CurrentRequestId < 65535 then
		CF.CurrentRequestId = CF.CurrentRequestId + 1
	else
		CF.CurrentRequestId = 0
	end
end

CF.GetPlayerData = function(src) 
	if (src == nil) then
        return CF.PlayerData
    else
        local rt = "NULL"
        CF.TriggerServerCallback("cf:GetPlayerData", function(result)
            rt = result
        end, src)
        while rt == "NULL" do 
            Citizen.Wait(10)
        end
        return rt
    end
end

CF.UseItem = function(item)
    local table = CF.GetInventory()[item]
    if (table ~= nil) then 
        table.cl_action()
    end
end

CF.GetLoadout = function() 
    return CF.PlayerData.Loadout
end

CF.SetWeapon = function(data)
	if (data.remove) then
		if (string.match(string.upper(data.name), "WEAPON_")) then	
			RemoveWeaponFromPed(PlayerPedId(), GetHashKey(data.name))
		end
	else
		if (string.match(string.upper(data.name), "WEAPON_")) then
			GiveWeaponToPed(PlayerPedId(), GetHashKey(data.name), data.ammo, false, false);
			for i=1, data.components do 
				local comp = data.components[i]
				GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(data.name), comp.name)
			end
		end
	end
	CheckLoadout()
end

CF.GetInventory = function(source)
	local xPlayer = source ~= nil and CF.GetPlayerData(source) or CF.PlayerData 
	local items = {}
	for k,v in pairs (Config.Items) do
		items[k] = v
		items[k].count = xPlayer.Items[k] ~= nil and xPlayer.Items[k] or 0
	end
    return items
end

CF.GetItemConfig = function(name)
    return Config.Items[name]
end

CF.GetConfig = function()
	return Config
end

CF.ShowNotification = function(msg)
	AddTextEntry('cfNotification', msg)
	SetNotificationTextEntry('cfNotification')
	DrawNotification(false, true)
end

-- GAME FUNCTIONS, PORTED FROM ESX.


CF.Math = {}

CF.Math.Round = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

-- credit http://richard.warburton.it
CF.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

CF.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

CF.SetTimeout = function(msec, cb)
	table.insert(CF.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
	return #CF.TimeoutCallbacks
end

CF.ClearTimeout = function(i)
	CF.TimeoutCallbacks[i] = nil
end

CF.Game.GetPlayers = function()
	local players = {}

	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end

	return players
end

CF.Game.GetPlayersInArea = function(area)
    local players       = CF.Game.GetPlayers()
	local playersInArea = {}
	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords, GetEntityCoords(PlayerPedId(), true), true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

CF.Game.GetClosestPlayer = function(coords) 
	local players, closestDistance, closestPlayer = CF.Game.GetPlayers(), -1, -1
	local coords, usePlayerPed = coords, false
	local playerPed, playerId = PlayerPedId(), PlayerId()

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance = #(coords - targetCoords)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

RegisterNetEvent("cf:getSharedObject")
AddEventHandler("cf:getSharedObject", function(cb) 
	cb(CF)
end)

function GetFramework()
    return CF
end

-- THREADS

local lastLoadout = {}

function CheckLoadout()

	local playerPed      = PlayerPedId()
	local Loadout        = {}
	local LoadoutChanged = false
	for k,v in ipairs(Config.Weapons) do
		local weaponName = v.name
		local weaponHash = GetHashKey(weaponName)
		local weaponComponents = {}
		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponName ~= 'WEAPON_UNARMED' and not string.match(weaponName, "GADGET_")then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

			for k2,v2 in ipairs(v.components) do
				if HasPedGotWeaponComponent(playerPed, weaponHash, v2.hash) then
					table.insert(weaponComponents, v2.name)
				end
			end

			if not lastLoadout[weaponName] or lastLoadout[weaponName] ~= ammo then
				LoadoutChanged = true
			end
			
			lastLoadout[weaponName] = ammo

			table.insert(Loadout, {
				name = weaponName,
				ammo = ammo,
				label = v.label,
				components = weaponComponents
			})
		else
			if lastLoadout[weaponName] then
				LoadoutChanged = true
			end

			lastLoadout[weaponName] = nil
		end
	end
	if (LoadoutChanged) then 
		CF.PlayerData.Loadout = Loadout
		TriggerServerEvent('cf:UpdateLoadout', Loadout)
	end
end

Citizen.CreateThread(function()
	TriggerServerEvent("cf:PlayerConnected")
	while true do
		Citizen.Wait(5000)
		CheckLoadout()
	end
end)

-- SetTimeout
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local currTime = GetGameTimer()

		for i=1, #CF.TimeoutCallbacks, 1 do
			if CF.TimeoutCallbacks[i] then
				if currTime >= CF.TimeoutCallbacks[i].time then
					CF.TimeoutCallbacks[i].cb()
					CF.TimeoutCallbacks[i] = nil
				end
			end
		end
	end
end)

-- Events.

RegisterNetEvent('cf:serverCallback')
AddEventHandler('cf:serverCallback', function(requestId, ...)
	CF.ServerCallbacks[requestId](...)
	CF.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent("cf:UpdatePlayerData")
AddEventHandler("cf:UpdatePlayerData", function(data)
    CF.PlayerData = data
end)

RegisterNetEvent("cf:SetWeapon")
AddEventHandler("cf:SetWeapon", function(data)
	CF.SetWeapon(data)
end)

RegisterNetEvent("cf:UseItemCL")
AddEventHandler("cf:UseItemCL", function(name)
    CF.UseItem(name)
end)

RegisterNetEvent("cf:ShowNotification")
AddEventHandler("cf:ShowNotification", function(msg)
    CF.ShowNotification(msg)
end)

-- Commands needing local information.

RegisterCommand("search", function(source, args, raw)
	local target, distance = CF.Game.GetClosestPlayer()
	if (target ~= -1) then 
		local id = GetPlayerServerId(target)
		TriggerServerEvent("cf:SearchPlayer", id, distance)
	else 
		TriggerEvent("chatMessage", "[^1ERROR^0]", {255,255,255}, "You are not close enough to any players to do this.")
	end
end)