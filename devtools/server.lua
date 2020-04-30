exports("chatMessage", function(player, message)
	TriggerClientEvent('chatMessage', player, '', {255, 255, 255}, '^8[California State Roleplay]^0 ' .. message)
end)