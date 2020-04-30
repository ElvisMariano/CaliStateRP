CF = nil

CAL = nil

TriggerEvent('cf:getSharedObject', function(obj) CF = obj end)
TriggerEvent('callife:getSharedObject', function(obj) CAL = obj end)

CFP = {}

CFP.DoorbellCooldown = {}

CFP.Properties = Config.Properties

CFP.GetProperty = function(_property)
    return CFP.Properties[_property]
end

CFP.UpdateProperty = function(_property, _data, updateDB) 
    _data.data = _data.data ~= nil and _data.data or {}
    CFP.Properties[_property] = _data
    if (updateDB) then 
        MySQL.Async.execute("UPDATE cf_properties SET property_owner=@property_owner, property_data=@property_data WHERE property_name=@property_name;", {
            ["@property_name"] = _property,
            ["@property_data"] = json.encode(_data.data),
            ["@property_owner"] = _data.data.owner

        }, function() 
            print("^3\nUpdated Property \"".. _property .."\" on the database.^0")
        end)
    end
    TriggerClientEvent("cf_properties:UpdateProperties", -1, CFP.Properties)
end

CFP.AddProperty = function(_property, _data) 
    MySQL.Async.execute('INSERT INTO cf_properties (property_name, property_owner, property_data) VALUES (@property_name, @property_owner, @property_data);', {
        ["@property_name"] = _property,
        ["@property_owner"] = _data.data ~= nil and _data.data.owner or nil,
        ["@property_data"] = json.encode(_data.data ~= nil and _data.data or {}),
    }, function(rowsChanged)
        print("^3\nAdded Property \"".. _property .."\" to the database.^0")
    end)
    CFP.UpdateProperty(_property, _data) 
end

CFP.FormatProperty = function(_property, _owner, _data) 

end

CFP.RingDoorbell = function(_property, source)
    local _source = source
    local property = CFP.GetProperty(_property)
    if (property ~= nil) then
        if (property.data.owner ~= nil and CF.GetPlayerFromIdentifier(property.data.owner) ~= nil ) then 
            local player = CF.GetPlayerFromIdentifier(property.data.owner)
            CF.ShowNotification(_source, "~y~You have ringed the doorbell, wait ~g~10 second(s) ~y~before ringing it again.~w~")
            CFP.DoorbellCooldown[_source] = 10
            TriggerClientEvent("cf_properties:RequestEntry", player.source, _property, _source)
        else
            CF.ShowNotification(_source, "~y~Nobody is responding..~w~")
        end
    end 
end

CFP.TriggerEvictionNotice = function(_property) 
    local property = CFP.GetProperty(_property)
    if (property.evicting == nil or not property.evicting) then
        property.evicting = true 
        CFP.UpdateProperty(_property, property, false)
    else                            
        return
    end
    if (os.time() >= property.data.rent_date + (86400 * Config.RentCycle)) then
        if (not property.data.rent_paid) then -- paid check
            Citizen.CreateThread(function()
                local player = CF.GetPlayerFromIdentifier(property.data.owner)
                if (player ~= nil) then -- IF online
                    CF.ShowNotification(player.source, "~r~EVICTION NOTICE, You have 60 seconds to pay the bill, or face eviction. ~y~Property Bill: $".. property.rent ..".~w~")
                    for i=1, 60 do 
                        Citizen.Wait(1000)
                    end
                end
                local timeleft = ((property.data.rent_date + (86400 * Config.RentCycle)) - os.time())
                if (CFP.GetProperty(_property).data.rent_paid == false and timeleft <= 0) then 
                    property.data = nil
                    property.evicting = nil
                    CFP.UpdateProperty(_property, property, true)
                    if (player ~= nil) then 
                        CF.ShowNotification(player.source, "~r~EVICTION NOTICE, You have been evicted from ~w~" .. property.label .. "~r~.")
                    end
                end
            end)
            -- No rent payment, Remove property.
        end
    end
end

CF.RegisterServerCallback("cf_properties:GetPlayerIdentifier", function(source, cb) 
    cb(CF.GetIdentifier(source))
end)

CF.RegisterServerCallback("cf_properties:AttemptBreakIn", function(source, cb, _property) 
    local _source = source
    local property = CFP.GetProperty(_property)
    local result = false
    if (property.bicooldown ~= nil) then 
        CF.ShowNotification(_source, "~r~This property cannot be robbed for another ".. property.bicooldown .. " second(s).~w~")
    else
        result = true
        property.bicooldown = Config.RobberyCooldown * 60 -- to Minutes
        property.robbery = true
        CF.ShowNotification(_source, "~r~Breaking into property, the police might be on their way.~w~")
        CF.Create911Call("Anonymous", "HELP!!! SOMEONE'S BREAKING INTO MY NEIGHBOR'S PROPERTY!", property.label)
    end
    cb(result)
end)

CF.RegisterServerCallback("cf_properties:BreachProperty", function(source, cb, _property, _door) 
    local _source = source
    local result = true
    if (CAL.GetPlayerData(_source).job == "police") then
        local property = CFP.GetProperty(_property)
        local quotes = {
            "\"Don't die, because that means people will be sad.\" - Lance Good",
            "\"Check your corners, we aren't losing this game of hide and speak.\" - Lance Good",
            "\"Whatever you do, spawn your bearcat at the RIGHT location.\" - Lance Good",
        }
        local index = math.random (1, #quotes)
        property.robbery = true
        CF.ShowNotification(_source, "~r~Breaching into property.~w~")
        CF.ShowNotification(_source, "~b~".. quotes[index] .."~w~")
        local coords = property.doors[_door].exit.point
        coords = {x=coords.x, y=coords.y, z=coords.z}
        TriggerClientEvent("mp3player:PlayAudio", -1, "raid", 2, coords)
    else
        result = false
    end
    cb(result)
end)

local function TestOwnership(src, property)
    property.data.owner = CF.GetIdentifier(src)
    property.data.rent_date = nil
    property.data.rent_paid = true
    CF.ShowNotification(src, "~g~Purchased property!~w~")
    return property
end

RegisterServerEvent("cf_properties:UpdateClientProperties")
AddEventHandler("cf_properties:UpdateClientProperties", function()
    local _source = source
    TriggerClientEvent("cf_properties:UpdateProperties", -1, CFP.Properties)
end)

RegisterServerEvent("cf_properties:DingDong")
AddEventHandler("cf_properties:DingDong", function(_property)
    local _source = source
    local property = CFP.GetProperty(_property)
    if (property ~= nil) then 
        if (property.data.owner == nil) then -- Tourable
            TriggerClientEvent("cf_properties:EnterProperty", _source, _property)
        elseif (property.data.owner == CF.GetIdentifier(_source)) then
            TriggerClientEvent("cf_properties:EnterProperty", _source, _property)
        elseif (CFP.DoorbellCooldown[k] == nil) then -- DingDongable
            CFP.RingDoorbell(_property, _source)
        end
    end
end)


RegisterServerEvent("cf_properties:GrantEntry")
AddEventHandler("cf_properties:GrantEntry", function(_property, _target)
    local _source = source 
    local property = CFP.GetProperty(_property)
    if (property ~= nil) then 
        if (property.data.owner ~= nil and CF.GetPlayerFromIdentifier(property.data.owner) ~= nil ) then 
            local player = CF.GetPlayerFromIdentifier(property.data.owner)
            if (player.source == _source) then 
                TriggerClientEvent("cf_properties:EnterProperty", _target, _property)
            end
        end
    end
end)

RegisterServerEvent("cf_properties:ManageProperty")
AddEventHandler("cf_properties:ManageProperty", function(_property, option)
    local _source = source
    local property = CFP.GetProperty(_property)
    local success = false
    if (property ~= nil) then 
        property.data = property.data ~= nil and property.data or {} -- create/get table
        if (option == "buy" or option == "rent" or "pay_bill") then 
            --property = TestOwnership(_source, property) -- LEAVE COMMENTED OR DIE.
            if (property.data.owner == nil) then -- Rentable/Buyable
                if (option == "buy") then
                    TriggerEvent('es:getPlayerFromId', _source, function(user)
                        local money = tonumber(user.getMoney())
                        if (user.money - property.price >= 0) then 
                            user.removeMoney(property.price)
                            property.data.owner = CF.GetIdentifier(_source)
                            property.data.rent_date = nil
                            property.data.rent_paid = true
                            CF.ShowNotification(_source, "~g~Purchased property!~w~")
                        else
                            CF.ShowNotification(_source, "~r~Failed to purchase property, Not enough money.~w~")
                        end
                    end)
                elseif (option == "rent") then 
                    TriggerEvent('es:getPlayerFromId', _source, function(user)
                        local money = tonumber(user.getMoney())
                        if (money - property.rent >= 0) then 
                            user.removeMoney(property.rent)
                            property.data.owner = CF.GetIdentifier(_source)
                            property.data.rent_date = os.time()
                            property.data.rent_paid = true
                            CF.ShowNotification(_source, "~g~Purchased property!.~w~")
                        else
                            CF.ShowNotification(_source, "~r~Failed to purchase property, Not enough money.~w~")
                        end
                    end)
                end
            elseif (property.data.owner == CF.GetIdentifier(_source)) then
                if (option == "pay_bill") then
                    TriggerEvent('es:getPlayerFromId', _source, function(user)
                        local money = tonumber(user.getMoney())
                        if (money - property.rent >= 0) then
                            user.removeMoney(property.rent)
                            property.data.rent_paid = true
                            CF.ShowNotification(_source, "~g~Paid the bill for this property!~w~")
                        else
                            CF.ShowNotification(_source, "~r~Failed to pay the bill for this property, Not enough money.~w~")
                        end
                    end)
                end
            end
        end
        CFP.UpdateProperty(_property, property, true)
    end
end)


function InitializeProperties() 
    local properties = CFP.Properties
    local f_properties = {}
    MySQL.Async.fetchAll('SELECT * FROM cf_properties', {}, function(result)
        for i=1, #result do 
            local _property = result[i].property_name
            if (properties[_property] ~= nil) then 
                f_properties[_property] = properties[_property]
                f_properties[_property].data = result[i].property_data ~= nil and json.decode(result[i].property_data) or {}
                f_properties[_property].data.owner = result[i].property_owner
            end
        end
        for k,v in pairs(properties) do 
            if (f_properties[k] == nil) then 
                f_properties[k] = properties[k]
                f_properties[k].data = {}
                CFP.AddProperty(k, f_properties[k])
            end
        end
    end)
    CFP.Properties = f_properties
end

MySQL.ready(function ()
    InitializeProperties()
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        -- Doorbell Request Countdown. --
        for k,v in pairs(CFP.DoorbellCooldown) do
            CFP.DoorbellCooldown[k] = CFP.DoorbellCooldown[k] ~= nil and (CFP.DoorbellCooldown[k] - 1) or nil
            if (CFP.DoorbellCooldown[k] ~= nil and CFP.DoorbellCooldown[k] <= 0) then 
                CFP.DoorbellCooldown[k] = nil
            end
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
        for k,v in pairs(CFP.Properties) do 
            if (v.data ~= nil) then
                if (v.data.rent_date ~= nil) then 
                    local time_left = (v.data.rent_date + (86400 * Config.RentCycle)) - os.time()
                    if (not v.data.rent_paid) then
                        if (time_left < 70 and time_left > 65) then
                            local src = CF.GetPlayerFromIdentifier(v.data.owner)
                            if (src) then 
                                CF.ShowNotification(src.source, "~r~Your rent is due within 60 seconds.~w~ ~y~Property Bill: $".. v.rent ..".~w~")
                            end
                        elseif (time_left < 10 and time_left > 5) then -- Ensure Notification is sent. -- 10 Second Warning. --(86400 * Config.RentCycle)) then
                            local src = CF.GetPlayerFromIdentifier(v.data.owner)
                            if (src) then 
                                CF.ShowNotification(src.source, "~r~Your rent is due within 10 seconds. Please make sure you have cash on-hand to pay the tenant with.~w~")
                            end
                        elseif (time_left <= 0) then --(86400 * Config.RentCycle)) then
                            CFP.TriggerEvictionNotice(k)
                            
                        end
                    elseif (time_left <= 0) then --(86400 * Config.RentCycle)) then
                        local player = CF.GetPlayerFromIdentifier(v.data.owner)
                        if (player ~= nil) then
                            v.data.rent_paid = false
                            v.data.rent_date = os.time()
                            CFP.UpdateProperty(k, v, true)
                            CF.ShowNotification(player.source, "~g~You have now began a new month into your lease.~w~")
                        end
                    end
                end
            end
            if (v.bicooldown ~= nil) then 
                v.bicooldown = v.bicooldown > 0 and v.bicooldown - 1 or nil
                CFP.UpdateProperty(k, v, false)
            end
        end
        Citizen.Wait(1000) -- Every second check
    end
end)