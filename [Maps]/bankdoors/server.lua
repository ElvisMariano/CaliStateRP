AddEventHandler('chatMessage', function(player, playerName, message)
    TriggerClientEvent("deleteBankDoors", -1)
end)