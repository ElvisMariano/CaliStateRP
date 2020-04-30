--CALLIFE = exports["callife"].GetFramework()
---
    local Webhook911 = "http://34.67.146.216:3000/game/call"
---

CF = {}

CF.Players = {}

CF.ServerCallbacks = {}

CF.RegisterServerCallback = function(name, cb)
	CF.ServerCallbacks[name] = cb
end

CF.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if CF.ServerCallbacks[name] ~= nil then
		CF.ServerCallbacks[name](source, cb, ...)
	else
		print('cf: TriggerServerCallback => [' .. name .. '] does not exist')
	end
end

CF.GetPlayerFromId = function(id)
	return CF.Players[id]
end

CF.GetIdentifier = function(id) 
    local identifiers = GetPlayerIdentifiers(id)
    for i in ipairs(identifiers) do
        if (string.match(identifiers[i], "license")) then
            return identifiers[i]
        end
    end
end

CF.GetPlayerFromIdentifier = function(identifier) 
    for k,v in pairs(CF.Players) do 
        if (CF.GetIdentifier(k) == identifier) then
            return v
        end
    end
end

CF.InitializeDefaultInventory = function(src) 
    local items = {}
    for k,v in pairs (Config.Items) do
        items[k] = 0
    end
    return items
end

CF.GetInventory = function(src) 
    local source = src
    local xPlayer = CF.GetPlayerFromId(source)
    local items = xPlayer.Items ~= nil and {} or nil
    if (items == nil) then
        items = CF.InitializeDefaultInventory(source)
    else
        for k,v in pairs (xPlayer.Items) do
            items[k] = Config.Items[k]
            items[k].count = xPlayer.Items[k]
        end
    end
    return items
end

CF.GetWeaponConfig = function(name)
    for i=1, #Config.Weapons do 
        local weapon = Config.Weapons[i]
        if (string.upper(weapon.name) == string.upper(name)) then 
            return weapon
        end
    end
    return nil
end

CF.IsWeapon = function(name)
    return CF.GetWeaponConfig(name) 
end

CF.GetItemConfig = function(name)
    return Config.Items[name]
end

CF.GetConfig = function()
	return Config
end

CF.ShowNotification = function(src, msg)
    local source = src
    TriggerClientEvent("cf:ShowNotification", source, msg)
end

CF.Create911Call = function(name, description, location, postal) 
    local parameters = {"from", "description", "address", "postal", "steam"}
    local translation = {
        [" "] = "%%20",
    }
    local Webhook = Webhook911
    if (name ~= nil and description ~= nil and location ~= nil) then
        for i=1, #parameters do 
            local param = i ~= 1 and "&" .. parameters[i] .. "=" or "?" .. parameters[i] .. "="
            local converted = ""
            if (param == "?from=") then 
                converted = string.gsub(name, " ", translation[" "])
            elseif (param == "&description=") then
                converted = string.gsub(description, " ", translation[" "])
            elseif (param == "&address=") then
                converted = string.gsub(location, " ", translation[" "])
            elseif (param == "&postal=" and postal ~= nil) then
                converted = string.gsub(postal, " ", translation[" "])
            elseif (param == "&postal=" and postal == nil) then
                converted = "1"
            elseif (param == "&steam=" and steam ~= nil) then
                converted = string.gsub(steam, " ", translation[" "])
            elseif (param == "&steam=" and steam == nil) then
                converted = "1"
            end
            param = param .. converted
            Webhook = Webhook .. param
        end
        PerformHttpRequest(Webhook, function(Error, Content, Head) 
            --print(json.encode(Content)) 
        end, 'GET')
    end
end

CF.AddItem = function(src, name, count)
    local source = src
    local xPlayer = CF.GetPlayerFromId(source)
    local item = CF.GetItemConfig(name)
    local isWeapon = CF.IsWeapon(name)
    if (item ~= nil and not isWeapon) then 
        if (xPlayer.Items[name] == nil) then 
            xPlayer.Items[name] = 0
        end
        if (count >= 0 and xPlayer.Items[name] + count <= item.max) then 
            xPlayer.Items[name] = xPlayer.Items[name] + count
            SyncPlayerData(source, true)
            CF.ShowNotification(source, "~g~" .. item.label .. " (x" .. count .. ")~w~ has been added to your inventory! Press ~g~F2~w~ to view your inventory.")
            return true
        else 
            CF.ShowNotification(source, "~r~" .. item.label .. " (x" .. count .. ")~w~ couldn't be added to your inventory. Press ~g~F2~w~ to view your inventory.")
            return false
        end
    elseif (isWeapon) then 
        local weapon = CF.GetWeaponConfig(name)
        if (weapon ~= nil) then 
            if (xPlayer.Loadout[name] == nil) then 
                xPlayer.Loadout[name] = {
                    name = name,
                    ammo = count,
                    label = weapon.label,
                    components = weapon.components,
                }
            end
            if (count >= 0 and xPlayer.Loadout[name].ammo + count <= 9999) then 
                xPlayer.Loadout[name].ammo = xPlayer.Loadout[name].ammo + count
                TriggerClientEvent("cf:SetWeapon", source, {remove = false, name = name, ammo = count})
                SyncPlayerData(source, true)
                CF.ShowNotification(source, "~g~" .. weapon.label .. " (Ammo: " .. count .. ")~w~ has been added to your inventory! Press ~g~F2~w~ to view your inventory.")
                return true
            else 
                CF.ShowNotification(source, "~r~" .. weapon.label .. " (Ammo: " .. count .. ")~w~ couldn't be added to your inventory. Press ~g~F2~w~ to view your inventory.")
                return false
            end
        else
            CF.ShowNotification(source, "~r~DEVELOPER ERROR: Notify the developers that ".. name .." is not a configured weapon.~w~")
            return false
        end
    else
        CF.ShowNotification(source, "~r~DEVELOPER ERROR: Notify the developers that ".. name .." is not a configured item.~w~")
        return false
    end
end

CF.RemoveItem = function(src, name, count)
    local source = src
    local xPlayer = CF.GetPlayerFromId(source)
    local item = CF.GetItemConfig(name)
    local isWeapon = CF.IsWeapon(name)
    if (item ~= nil and not isWeapon) then 
        if (xPlayer.Items[name] == nil) then 
            xPlayer.Items[name] = 0
            SyncPlayerData(source, true)
            return false
        end
        if (item.removeable and count > 0 and xPlayer.Items[name] - count >= 0) then
            xPlayer.Items[name] = xPlayer.Items[name] - count
            CF.ShowNotification(source, "~r~" .. item.label .. " (x" .. count .. ")~w~ has been ~r~removed~w~ from your inventory. Press ~g~F2~w~ to view your inventory.")
            SyncPlayerData(source, true)
            return true
        else 
            CF.ShowNotification(source, "~y~" .. item.label .. " (x" .. count .. ")~w~ couldn't be removed from your inventory. Press ~g~F2~w~ to view your inventory.")
            return false
        end
    elseif (isWeapon) then 
        local weapon = CF.GetWeaponConfig(name)
        if (weapon ~= nil) then 
            TriggerClientEvent("cf:SetWeapon", source, {remove = true, name = name})
            CF.ShowNotification(source, "~r~" .. weapon.label .. " (x" .. count .. ")~w~ has been ~r~removed~w~ from your inventory. Press ~g~F2~w~ to view your inventory.")
            SyncPlayerData(source, true)
            return true
        else
            CF.ShowNotification(source, "~y~" .. weapon.label .. " (x" .. count .. ")~w~ couldn't be removed from your inventory. Press ~g~F2~w~ to view your inventory.")
            return false
        end
    else
        CF.ShowNotification(source, "~r~DEVELOPER ERROR: Notify the developers that ".. name .." is not a configured item.~w~")
        return false
    end
end

CF.UseItem = function(src, name)
    local source = src
    local item = CF.GetItemConfig(name)
    if (item ~= nil) then 
        if (not item.reusable) then
            if (CF.RemoveItem(source, name, 1) == true) then 
                item.sv_action()
                TriggerClientEvent("cf:UseItemCL", source, name)
                CF.ShowNotification(source, "You have used ~g~" .. item.label .. "~w~.")
                return true
            else
                CF.ShowNotification(source, "~r~You don't have enough of this item, If you do however; contact a developer~w~.")
                return false
            end
        else
            SyncPlayerData(source, true)
            item.sv_action()
            TriggerClientEvent("cf:UseItemCL", source, name)
            CF.ShowNotification(source, "You have used ~g~" .. item.label .. "~w~.")
            return true
        end
    else
        CF.ShowNotification(source, "~r~DEVELOPER ERROR: Notify the developers that ".. name .." is not a configured item.~w~")
        return false
    end
end

CF.SetLoadout = function(src, loadout) 
    local source = src
    CF.Players[source].Loadout = loadout
    SyncPlayerData(source)
end

CF.GetLoadout = function(src) 
    local source = src
    return CF.Players[source].Loadout
end

CF.GiveItem = function(src, target, _item, count) 
    local xPlayer = CF.GetPlayerFromId(src)
    local xTarget = CF.GetPlayerFromId(target)
    local item = CF.GetItemConfig(_item)
    local fail = false 
    local reason = ""
    if (item ~= nil and xPlayer ~= nil and xTarget ~= nil) then 
        local pInventory = CF.GetInventory(src)
        local tInventory = CF.GetInventory(target)
        if (pInventory[item] == nil or pInventory[item].count - count >= 0) then 
            if (tInventory[item] == nil or tInventory[item].count + count < item.max) then 
                fail = CF.RemoveItem(src, _item, count)
                if (not fail) then 
                    fail = CF.AddItem(target, _item, count)
                end
                if (fail) then 
                    reason = " Reason: DEVELOPER ERROR."
                end
            else
                fail = true
                reason = " Reason: Receiving Player can't hold that much more of this item."
            end
        else
            fail = true
            reason = " Reason: Gifting Player can't give that much more of this item."
        end
    else
        fail = true
    end
    if (fail) then 
        CF.ShowNotification(src, "~r~Failed Transaction.".. reason .."~w~")
        CF.ShowNotification(target, "~r~Failed Transaction.".. reason .."~w~")
    else
        CF.ShowNotification(src, "~w~You gave ~y~"+ GetPlayerName(target) + " ~g~".. item.label .."(x ".. count ..")~w~!")
        CF.ShowNotification(src, "~w~You received ~g~".. item.label .."(x ".. count ..") from ~y~"+ GetPlayerName(target) + "~w~!")
    end
end

function GetFramework()
    return CF
end

RegisterNetEvent("cf:getSharedObject")
AddEventHandler("cf:getSharedObject", function(cb) 
	cb(CF)
end)

function SyncPlayerData(src, updateDB) 
    local source = src
    TriggerClientEvent("cf:UpdatePlayerData", source, CF.Players[source])
    if (updateDB ~= nil and updateDB == true) then
        MySQL.Async.execute('UPDATE cf_users SET data=@data WHERE identifier=@identifier', {["@data"] = json.encode(CF.Players[source]), ["@identifier"] = CF.GetIdentifier(src)})
    end
end

function InitializePlayer(src) 
    local source = src
    CF.Players[source] = {}
    local identifier = CF.GetIdentifier(src)
    MySQL.Async.fetchAll('SELECT * FROM cf_users WHERE identifier=@identifier', {["@identifier"] = identifier}, function(results)
        if (#results == 0) then
            MySQL.Async.execute('INSERT INTO cf_users (`identifier`) VALUES (@identifier);', {
                ["@identifier"] = identifier,
            })
            CF.Players[source] = {Items = {}, Identifier = identifier}
            CF.Players[source].source = source
            SyncPlayerData(source, true)
        else
            CF.Players[source] = json.decode(results[1].data ~= nil and results[1].data or "{}")
            CF.Players[source].source = source
            SyncPlayerData(source)
        end
    end)
end

CF.RegisterServerCallback("cf:GetPlayerData", function(source, cb, id)
    local rt = nil
    if (id == -1) then
        rt = CF.Players
    elseif (CF.Players[id]) then
        rt = CF.Players[id]
    end
    cb(rt)
end)

RegisterNetEvent("cf:UseItemSV")
AddEventHandler("cf:UseItemSV", function(name)
    local _source = source
    CF.UseItem(_source, name)
end)

RegisterNetEvent("cf:RemoveItem")
AddEventHandler("cf:RemoveItem", function(name, count)
    local _source = source
    CF.RemoveItem(_source, name, count)
end)

RegisterNetEvent("cf:UpdateLoadout")
AddEventHandler("cf:UpdateLoadout", function(loadout)
    local _source = source
    CF.SetLoadout(_source, loadout)
end)

RegisterServerEvent("cf:PlayerConnected")
AddEventHandler("cf:PlayerConnected", function()
    local _source = source
    InitializePlayer(_source)
end)

RegisterServerEvent('cf:triggerServerCallback')
AddEventHandler('cf:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	CF.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('cf:serverCallback', _source, requestId, ...)
	end, ...)
end)

RegisterNetEvent("cf:SearchPlayer")
AddEventHandler("cf:SearchPlayer", function(target, distance)
    local _source = source
    if (distance <= Config.SearchDistance and target ~= -1) then
        -- good
        print(target)
        TriggerClientEvent("cf_inventoryhud:openPlayerInventory", _source, target, GetPlayerName(target))
    else 
        -- bad
        TriggerClientEvent("chatMessage", "[^1ERROR^0]", {255,255,255}, "You are not close enough to any players to do this.")
    end 
end)

RegisterCommand("additem", function(src, args, raw) 
    CF.AddItem(src, args[1], tonumber(args[2]))
end, false)

RegisterCommand("testt", function(s, a, r)
    CF.GiveItem(1, 1, "weed", 10)
end, false)