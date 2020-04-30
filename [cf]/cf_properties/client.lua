CF = nil

Properties = Config.Properties

local property_robbery = nil

local inside_marker = false

local queue = {}

local menu_open = false

local identifier = nil

Citizen.CreateThread(function()
	while CF == nil do 
        Citizen.Wait(0)
        TriggerEvent('cf:getSharedObject', function(obj) CF = obj end)
    end
    TriggerServerEvent("cf_properties:UpdateClientProperties")
    GetIdentifier()
end)

function GetIdentifier() 
    if (identifier == nil) then
        CF.TriggerServerCallback("cf_properties:GetPlayerIdentifier", function(result)
            identifier = result 
        end, nil)
    end
end

function DisplayHelpMessage(msg)
    AddTextEntry("cfPropertiesHelp", msg) 
    DisplayHelpTextThisFrame("cfPropertiesHelp", false)
end

function DisplayMarkerHelp(_marker)
    if (_marker == "enter") then
        DisplayHelpMessage("Press ~INPUT_CONTEXT~ to interact with this property.")
    elseif (_marker == "exit") then
        DisplayHelpMessage("Press ~INPUT_CONTEXT~ to exit this property.")
    end
end

function InitiateRobbery(_property) 

end

function InteractionHandler(_property, action, menu, _door) 
    local property = Properties[_property]
    if (action == "ring_doorbell" or action == "visit_property") then 
        TriggerServerEvent("cf_properties:DingDong", _property)
    elseif (action == "enter_property") then
        EnterProperty(_property, _door)
    elseif (action == "pay_bill") then
        TriggerServerEvent("cf_properties:ManageProperty", _property, "pay_bill")
    elseif (action == "rent_property" or action == "buy_property") then 
        CF.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm-purchase', {
            title    = "Are you sure you want to " .. (action == "rent_property" and "rent" or "buy") .. " this property for $" .. (action == "rent_property" and property.rent or property.price) .. "?",
            align    = 'center',
            elements = {{label = "Yes", value = true}, {label = "No", value = false},}
        }, function(data, _menu)
            if (data.current.value) then 
                if (action == "rent_property") then
                    TriggerServerEvent("cf_properties:ManageProperty", _property, "rent")
                elseif (action == "buy_property") then 
                    TriggerServerEvent("cf_properties:ManageProperty", _property, "buy")
                end
                _menu.close()
            end
        end, function(data, _menu)
            _menu.close()
        end)
        --TriggerServerEvent("cf_properties:RentProperty", _property)
    elseif (action == "break_in") then 
        menu.close()
        menu_open = false
        CF.TriggerServerCallback("cf_properties:AttemptBreakIn", function(result)
            if (result) then 
                RequestAnimDict('anim@amb@clubhouse@tutorial@bkr_tut_ig3@')
                while not HasAnimDictLoaded('anim@amb@clubhouse@tutorial@bkr_tut_ig3@') do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(GetPlayerPed(-1), 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@' , 'machinic_loop_mechandplayer' ,8.0, -8.0, -1, 1, 0, false, false, false )
                for i=1, Config.LockpickTimer do 
                    Citizen.Wait(1000)
                    if (not inside_marker) then
                        CF.ShowNotification("~r~Robbery Cancelled.")
                        return
                    end
                end
                ClearPedTasks(GetPlayerPed(-1))
                EnterProperty(_property, _door)
                InitiateRobbery(_property)
            end
        end, _property)
    elseif (action == "breach") then
        CF.TriggerServerCallback("cf_properties:BreachProperty", function(result)
            if (result) then 
                Citizen.Wait(500)
                ClearPedTasks(GetPlayerPed(-1))
                EnterProperty(_property, _door)
                InitiateRobbery(_property)
            end
        end, _property, _door)
    end 
    if (menu) then 
        menu.close()
        menu_open = false
    end
end

function InteractWithMarker(_property, _door, _marker) 
    local property = Properties[_property]
    local marker = (_marker ~= "enter" and _marker ~= "exit") and property[_door] or property.doors[marker]
    local _elements = {}
    if (_marker == "enter") then
        if (property.data.owner == nil and property.rent > 0) then
            table.insert(_elements, {label = "Rent this property for $" .. property.rent .. ".", value = "rent_property"})
        elseif (property.data.owner == nil and property.price > 0) then
            table.insert(_elements, {label = "Purchase this property for $" .. property.price .. ".", value = "buy_property"})
        end
        if (property.data.owner == nil and (property.price > 0 or property.rent > 0)) then
            table.insert(_elements, {label = "Tour this property.", value = "visit_property"})
        end
        if (property.data.owner == identifier) then
            table.insert(_elements, {label = "Enter this property.", value = "enter_property"})
            if (property.data.rent_paid ~= nil and property.data.rent_paid == false) then
                table.insert(_elements, {label = "Pay this month's bills. ($" .. property.rent .. ")", value = "pay_bill"})
            end
        end
        if (property.data.owner ~= nil and property.data.owner ~= identifier) then
            table.insert(_elements, {label = "Ring the doorbell.", value = "ring_doorbell"})
        end
        table.insert(_elements, {label = "<span style='color: red'><b>Break into the property.</b></span>", value = "break_in"})
        table.insert(_elements, {label = "<span style='color: aqua'><b>Breach into the property.</b></span>", value = "breach"})
        CF.UI.Menu.Open('default', GetCurrentResourceName(), 'main-menu', {
            title    = property.label,
            align    = 'center',
            elements = _elements
        }, function(data, menu)
            InteractionHandler(_property, data.current.value, menu, _door)
        end, function(data, menu)
            menu.close()
            menu_open = false
        end)
    elseif (_marker == "exit") then
        ExitProperty(_property, _door)
    end
end

function EnterProperty(_property, _door)
    local property = Properties[_property]
    if (property ~= nil) then 
        Citizen.CreateThread(function()
            local door = _door ~= nil and Properties[_property].doors[_door].exit or Properties[_property].doors["main"].exit
            DoScreenFadeOut(800)
            while not IsScreenFadedOut() do
                Citizen.Wait(0)
            end
            SetEntityCoords(GetPlayerPed(-1), door.point, false)
            DoScreenFadeIn(800)
            CF.ShowNotification("You have entered ~y~" .. property.label .. "~w~.")
        end)
    else
        CF.ShowNotification("This property does not exist.")
    end
end

function ExitProperty(_property, _door)
    local property = Properties[_property]
    if (property ~= nil) then 
        Citizen.CreateThread(function()
            local door = _door ~= nil and Properties[_property].doors[_door].enter or Properties[_property].doors["main"].enter
            DoScreenFadeOut(800)
            while not IsScreenFadedOut() do
                Citizen.Wait(0)
            end     
            SetEntityCoords(GetPlayerPed(-1), door.point, false)
            DoScreenFadeIn(800)
            CF.ShowNotification("You have exited ~y~" .. property.label .. "~w~.")
        end)
    else
        CF.ShowNotification("This property does not exist.")
    end
end

Citizen.CreateThread(function() -- Process Markers/Interact Handling
    while true do 
        Citizen.Wait(0)
        local _inside_marker = false
        for k,v in pairs(Properties) do 
            local ply_coords = GetEntityCoords(GetPlayerPed(-1), true)
            for a,b in pairs(v.doors) do 
                local markers = {"enter", "exit"}
                for i=1, #markers do 
                    local marker_name = markers[i]
                    local marker = Properties[k].doors[a][marker_name]
                    if (GetDistanceBetweenCoords(ply_coords, marker.point, true) < 15.0) then -- If true, render marker.
                        DrawMarker(marker.type, marker.point, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, marker.color[1], marker.color[2], marker.color[3], 100, false, true, 2, true, false, false, false)
                        if (GetDistanceBetweenCoords(ply_coords, marker.point, true) < 1.25) then -- If true, show marker's action prompt.
                            _inside_marker = true
                            if (not menu_open) then
                                DisplayMarkerHelp(marker_name)
                                if (IsControlJustReleased(0, 51)) then -- Interaction
                                    InteractWithMarker(k, a, marker_name)
                                    menu_open = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if (menu_open and not _inside_marker) then 
            CF.UI.Menu.CloseAll()
            menu_open = false
        end
        inside_marker = _inside_marker
    end
end)

local current_invite = nil

function PromptInvite(_property, _id)
    local _source = _id
    local name = GetPlayerName(GetPlayerFromServerId(_source))
    local status = nil
    local time_left = 10
    current_invite = _id
    Citizen.CreateThread(function() 
        while status == nil do 
            Citizen.Wait(0)
            DisplayHelpMessage("Press ~INPUT_CONTEXT~ to allow ".. name .. " to enter, Press ~INPUT_ENTER~ to reject them.")
            if (IsControlJustReleased(0,51)) then -- On E Press
                status = true
            end
            if (IsControlJustReleased(0,23)) then -- On F Press
                status = false
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do    
            Citizen.Wait(100)
            if (status == nil) then 
                time_left = time_left - 0.1
            end
            if (time_left <= 0) then -- expired
                status = false
                break
            end
            if (status ~= nil) then
                if (status) then 
                    TriggerServerEvent("cf_properties:GrantEntry", _property, _source)
                end
                break
            end
        end
        current_invite = nil
    end)
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        if (current_invite == nil) then
            for k,v in pairs(queue) do
                PromptInvite(v, k)
                queue[k] = nil
                break
            end
        end
    end
end)

RegisterNetEvent("cf_properties:UpdateProperties")
AddEventHandler("cf_properties:UpdateProperties", function(data) 
    Properties = data
end)

RegisterNetEvent("cf_properties:EnterProperty")
AddEventHandler("cf_properties:EnterProperty", function(_property)
    EnterProperty(_property)
end)

RegisterNetEvent("cf_properties:RequestEntry")
AddEventHandler("cf_properties:RequestEntry", function(_property, _source)
    queue[_source] = _property
end)