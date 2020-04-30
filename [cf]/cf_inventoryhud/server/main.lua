CF = nil

TriggerEvent('cf:getSharedObject', function(obj) CF = obj end)

CF.RegisterServerCallback(
	"cf_inventoryhud:getPlayerInventory",
	function(source, cb, target)
		local targetXPlayer = CF.GetPlayerFromId(target)

		if targetXPlayer ~= nil then
			cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout})
		else
			cb(nil)
		end
	end
)

RegisterServerEvent("cf_inventoryhud:tradePlayerItem")
AddEventHandler("cf_inventoryhud:tradePlayerItem",
	function(from, target, type, itemName, itemCount)
		local _source = from
		CF.AddItem(target, itemName, itemCount)
		CF.RemoveItem(_source, itemName, itemCount)
	end
)

RegisterCommand(
	"openinventory",
	function(source, args, rawCommand)
		if IsPlayerAceAllowed(source, "inventory.openinventory") then
			local target = tonumber(args[1])
			local targetXPlayer = CF.GetPlayerFromId(target)

			if targetXPlayer ~= nil then
				TriggerClientEvent("cf_inventoryhud:openPlayerInventory", source, target, targetXPlayer.name)
			else
				TriggerClientEvent("chatMessage", source, "^1" .. _U("no_player"))
			end
		else
			TriggerClientEvent("chatMessage", source, "^1" .. _U("no_permissions"))
		end
	end
)
