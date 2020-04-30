Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local vaultdoor = GetClosestObjectOfType(1175.894653320, 2711.5983886719, 38.088005065918, 30.0, GetHashKey('v_ilev_gb_vauldr'), false, false, false)
        local tellerdoor = GetClosestObjectOfType(1175.894653320, 2711.5983886719, 38.088005065918, 30.0, GetHashKey('v_ilev_gb_teldr'), false, false, false)
        if vaultdoor ~= nil then
            SetEntityAsMissionEntity(vaultdoor, true, false)
            DeleteObject(vaultdoor)
        end
        if tellerdoor ~= nil then
            SetEntityAsMissionEntity(tellerdoor, true, false)
            DeleteObject(tellerdoor)
        end
        
        local vaultdoor = GetClosestObjectOfType(1649.22, 4854.71, 42.01, 30.0, GetHashKey('v_ilev_gb_vauldr'), false, false, false)
        local tellerdoor = GetClosestObjectOfType(1649.22, 4854.71, 42.01, 30.0, GetHashKey('v_ilev_gb_teldr'), false, false, false)
        if vaultdoor ~= nil then
            SetEntityAsMissionEntity(vaultdoor, true, false)
            DeleteObject(vaultdoor)
        end
        if tellerdoor ~= nil then
            SetEntityAsMissionEntity(tellerdoor, true, false)
            DeleteObject(tellerdoor)
        end
    end
end)