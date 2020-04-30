local listOn = false

Citizen.CreateThread(function()
    listOn = false
    while true do
        Wait(0)

        if IsControlPressed(0, 27) and GetLastInputMethod(2) then
            if not listOn then
                local players = {}
                ptable = GetPlayers()  
                for _, i in ipairs(ptable) do
                    r, g, b = GetPlayerRgbColour(i)
                    table.insert(players, 
                    '<tr style=\"color: white\"><p class="workIconQuestionMarkKappa"></p><td id="playerID">ID</td><td id="playeridreal">' .. GetPlayerServerId(i) .. '</td><td id="playerbox">NAME</td><td id="playerreal">' .. cleanName(sanitize(GetPlayerName(i))) .. '</td>'
                    )
                end
                
                SendNUIMessage({ text = table.concat(players) })

                listOn = true
                while listOn do
                    Wait(0)
                    if(IsControlPressed(0, 27) == false) then
                        listOn = false
                        SendNUIMessage({
                            meta = 'close'
                        })
                        break
                    end
                end
            end
        end
    end
end)

function compare(a,b)
    return a[1] < b[1]
end

function GetPlayers()
    local players = {}

    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function sanitize(txt)
    local replacements = {
        ['&' ] = '&amp;', 
        ['<' ] = '&lt;', 
        ['>' ] = '&gt;',  
        ['\n'] = '<br/>'
    }
    return txt
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s) return ' '..('&nbsp;'):rep(#s-1) end)
end

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
end