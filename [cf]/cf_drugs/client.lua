local CF = nil

local Drugs = {}

local cached_item_cfg = {}

local sell_entered = false

local sell_amount = 0
sold  = false 

Citizen.CreateThread(function()
	while CF == nil do 
      Citizen.Wait(0)
      TriggerEvent('cf:getSharedObject', function(obj) CF = obj end)
    end
end)

local function ShowHelpMessage(msg)
  AddTextEntry('cfHelpNotification', msg)
  BeginTextCommandDisplayHelp('cfHelpNotification')
  EndTextCommandDisplayHelp(0, false, true, -1)
end

Drugs.Level = 0

Drugs.IsHigh = false

Drugs.GetLevel = function() 
  if (Drugs.Level > 100) then
    Drugs.Level = 100
  elseif (Drugs.Level < 0) then
    Drugs.Level = 0
  end
  return Drugs.Level
end

Drugs.IncreaseLevel = function(val) 
  if (val ~= nil and val > 0) then 
    Drugs.Level = Drugs.Level + val
    IsHigh = true
    if (Drugs.Level >= 100) then
      Drugs.Level = 100
      Drugs.Overdose()
    end
  end 
end

Drugs.DecreaseLevel = function() 
  if (Drugs.Level > 0) then
    Drugs.Level = Drugs.Level - 1
    IsHigh = true
  end
end

Drugs.StopEffects = function()
  Citizen.CreateThread(function()
    local playerPed = GetPlayerPed(-1)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
    SetPedIsDrunk(playerPed, false)
    SetPedMotionBlur(playerPed, false)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetSwimMultiplierForPlayer(PlayerId(), 1.0)
  end)
end

Drugs.Overdose = function()
  Citizen.CreateThread(function()
    IsHigh = false
    Drugs.StopEffects()
    local playerPed = GetPlayerPed(-1)  
    SetEntityHealth(playerPed, 0)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(playerPed, 0)
    SetPedIsDrunk(playerPed, false)
    SetPedMotionBlur(playerPed, false)
    -- Do whatever is needed for K.O.
  end)
end

Drugs.StartEffect = function(_drug)
  local drug = Config.Drugs[_drug]
  if (drug ~= nil) then 
    drug.action()
    Drugs.IncreaseLevel(drug.potency / 5)
  end
end

Drugs.GetItemConfig = function(_item)
  cached_item_cfg[_item] = cached_item_cfg[_item] ~= nil and cached_item_cfg[_item] or CF.GetItemConfig(_item)
  return cached_item_cfg[_item]
end

Drugs.CancelAction = function(_drug)
  local item = Drugs.GetItemConfig(_drug)
  processing = false
  ClearPedTasks(PlayerPedId())
  Citizen.Wait(5000)
  --CF.ShowNotification("~r~Stopped Collection/Sale of " .. item.label .. ".~w~")
end

Drugs.HarvestDrugs = function(_drug, continue)
  Citizen.CreateThread(function()
    if (not processing) then
      processing = true
      local item = CF.GetInventory()[_drug]
      local drug = Config.Drugs[_drug]
      local fail = false
      local reason = ""
      
      if (item ~= nil and item.count < item.max) then
        CF.ShowNotification("~g~Harvesting " .. item.label .. "...~w~")
        if item.label == "Forged Money" then
          if (continue == nil or not continue) then 
            ClearPedTasksImmediately(PlayerPedId())   
            TaskStartScenarioInPlace(PlayerPedId(), 'world_human_stand_mobile', 0, false)
          end
        else
          if (continue == nil or not continue) then 
            ClearPedTasksImmediately(PlayerPedId())
            TaskStartScenarioInPlace(PlayerPedId(), 'world_human_gardener_plant', 0, false)
          end
        end
        for i=0, drug.harvest_time do
          local x, y, z = table.unpack(drug.harvest_point)
          local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), vector3(x, y, z), true) 
          Citizen.Wait(1000)
          if (distance > 1.25) then
            fail = true
            reason = " Reason: Too far from collection area."
            break
          elseif (processing == false) then
            fail = true
            reason = " Reason: Processing stopped."
            break
          end
        end
      else
        fail = true
        reason = " Reason: No more space for this item."
      end
      if (reason ~= "") then 
        ClearPedTasks(PlayerPedId())
        Citizen.Wait(5000)
      end
      if (fail) then 
        CF.ShowNotification("~r~Stopped collecting " .. item.label .. ".".. reason .."~w~")
        processing = false
        return false  
      elseif (CF.GetInventory()[_drug] ~= nil and CF.GetInventory()[_drug].count < item.max) then -- If space is available for the weed, give it to em; and recur the function if +1 is available.
        TriggerServerEvent("cf_drugs:HarvestDrugs", _drug)
        if (CF.GetInventory()[_drug].count + 1 < item.max and processing) then 
          processing = false
          Drugs.HarvestDrugs(_drug, true)
        else
          CF.ShowNotification("~r~Stopped collecting " .. item.label .. ". Reason: No more space for this drug.~w~")
          processing = false
          return false
        end
      end
    end
  end)
end

Drugs.SellDrugs = function(_drug)
  TriggerServerEvent("cf_drugs:SellDrugs", _drug,Amount,Price)
end



local function DisplayPercentage(x,y,width,height,scale,text,r,g,b,a)
  if true then
      SetTextCentre(true)
  end
  SetTextFont(4)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(2, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x - width/2, y - height/2 + 0.005)
end

-- Harvesting Marker Thread

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if (CF ~= nil) then
      for k,v in pairs(Config.Drugs) do 
        local x, y, z = table.unpack(v.harvest_point)
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), vector3(x, y, z), true)
        if (distance < 25.00) then
          DrawMarker(1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 255, 0, 100, false, true, 2, true, false, false, false)
          if distance < 1.25 then
            if (processing) then 
              ShowHelpMessage("Press ~INPUT_CONTEXT~ to cancel harvesting.")
              if (IsControlJustReleased(1, 51)) then 
                Drugs.CancelAction(k)
              end
            else
              local item = Drugs.GetItemConfig(k)
              ShowHelpMessage("Press ~INPUT_CONTEXT~ to harvest ~g~" .. item.label .. "~w~.")
              if (IsControlJustReleased(1, 51)) then 
                Drugs.HarvestDrugs(k)
              end
            end
          end
        end
      end
    end
  end
end)

-- Selling Marker Thread

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if (CF ~= nil) then
      for k,v in pairs(Config.Drugs) do 
        local x, y, z = table.unpack(v.sell_point)
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), vector3(x, y, z), true)
        if (distance < 25.00) then
          DrawMarker(1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 255, 0, 100, false, true, 2, true, false, false, false)
          if distance < 1.25 then
            if (not sell_entered) then
              sell_entered = true
              sell_amount = CF.GetInventory()[k].count
            end
            if sold == false then
              local item = Drugs.GetItemConfig(k)
              ShowHelpMessage(sell_amount > 0 and "Press ~INPUT_CONTEXT~ to sell " .. item.label .. " (x".. sell_amount ..")~w~ for ~g~$".. sell_amount * v.sell_price .."~w~ to the dealer." or "You have no ".. item.label .." to sell.")
              if (IsControlJustReleased(1, 51)) then 
                Price = v.sell_price
                Amount = sell_amount
                Drugs.SellDrugs(k,Amount,Price) 
                sold = true
              end
            end
          elseif (sell_entered) then
            sell_entered = false
            sell_amount = 0
            sold = false
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function() 
  while true do 
    Citizen.Wait(0)
    local text = Drugs.Level > 0 and "Drug Level: " .. math.floor(Drugs.Level) .. "%" or ""
    DisplayPercentage(1.000, 1.430,1.0,1.0,0.45,text,255,0,0,255)
  end
end)

Citizen.CreateThread(function() 
  while true do 
    Citizen.Wait(Config.PotencyTimeRatio * 1000)
    if (Drugs.Level > 0) then 
      Drugs.DecreaseLevel()
    elseif (IsHigh) then 
      IsHigh = false
      Drugs.StopEffects()
    end
  end
end)

RegisterNetEvent("cf_drugs:StartEffect")
AddEventHandler("cf_drugs:StartEffect", function(drug) 
  Drugs.StartEffect(drug)
end)

RegisterNetEvent("cf_drugs:StopEffects")
AddEventHandler("cf_drugs:StopEffects", function() 
  Drugs.StopEffects()
end)

