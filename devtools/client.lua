-- Raycast and Return Result
exports("raycast", function(distance)
    local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, distance, player, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end)

-- Closest Vehicle (Returns Vehicle and Distance)
function GetVehiclesFixed()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

  return vehicles
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

exports("closestVehicle", function(coords)
    local vehicles        = GetVehiclesFixed()
    local closestDistance = -1
    local closestVehicle  = -1
    local coords          = coords
  
    if coords == nil then
      local playerPed = PlayerPedId()
      coords          = GetEntityCoords(playerPed)
    end
  
    for i=1, #vehicles, 1 do
      local vehicleCoords = GetEntityCoords(vehicles[i])
      local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)
  
      if closestDistance == -1 or closestDistance > distance then
        closestVehicle  = vehicles[i]
        closestDistance = distance
      end
    end
  
    local data = {
        vehicle = closestVehicle,
        distance = closestDistance
    }

    return data
end)

-- Create Object
exports("createObject", function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)

		if cb ~= nil then
			cb(obj)
		end
	end)
end)

exports("chatMessage", function(message)
	TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[California State Roleplay]^0 ' .. message)
end)

exports("dump",	function(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end)