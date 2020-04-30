CF = nil




TriggerEvent('cf:getSharedObject', function(obj) CF = obj end)

RegisterNetEvent("cf_drugs:HarvestDrugs")
AddEventHandler("cf_drugs:HarvestDrugs", function(_drug)
    local _source = source
    local item = CF.GetItemConfig(_drug)
    if (item ~= nil) then 
        CF.AddItem(_source, _drug, 1)
    end
end)

RegisterNetEvent("cf_drugs:SellDrugs")
AddEventHandler("cf_drugs:SellDrugs", function(_drug,Amount,Price)
    local _source = source
    local item = CF.GetItemConfig(_drug)
    if(Amount>0 and Amount * Price > 0) then
        if (item ~= nil) then 
            local user = exports.essentialmode:getPlayerFromId(source)
            user.addMoney(Price * Amount)
            CF.ShowNotification(_source, "You have earned ~g~$" .. Amount * Price .. "~w~ from selling ~g~" .. item.label .. "~w~.")
            CF.RemoveItem(_source, _drug, Amount) 
        end 
    end
end)
