RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
    end

    print(author .. '^7: ' .. message .. '^7')
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = cleanName(GetPlayerName(source))

    TriggerEvent('chatMessage', source, name, '/' .. command)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end

    CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)

RegisterCommand('say', function(source, args, rawCommand)
	if source == 0 then
		TriggerClientEvent('chatMessage', -1, '', { 255, 255, 255 }, '^8[California State Roleplay]^0 ' .. rawCommand:sub(5))
	else
		TriggerClientEvent('chatMessage', -1, (source == 0) and '^8[California State Roleplay]^0' or cleanName(GetPlayerName(source)), { 255, 255, 255 }, rawCommand:sub(5))
	end
end)




function cleanName(txt)
    return txt:gsub("~r~", "")
                :gsub("~b~", "")
                :gsub("~g~", "")
                :gsub("~y~", "")
                :gsub("~p~", "")
                :gsub("~o~", "")
                :gsub("~c~", "")
                :gsub("~m~", "")
                :gsub("~u~", "")
                :gsub("~n~", "")
                :gsub("~s~", "")
                :gsub("~h~", "")
                :gsub("~w~", "")
                :gsub("^0", "")
                :gsub("^2", "")
                :gsub("^3", "")
                :gsub("^4", "")
                :gsub("^5", "")
                :gsub("^6", "")
                :gsub("^7", "")
                :gsub("^8", "")
                :gsub("^9", "")
end