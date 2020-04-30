local Price_Multiplier = 8 -- dont toutch
Config = {
    Drugs = { 
         ["coke"] = {
             harvest_point = {1101.05, -3194.93, -39.99},
             sell_point = {2432.72, 4964.38, 41.35},
             potency = 25, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
             can_overdose = true,
	         harvest_time = 15, -- in seconds.
             harvest_cost = 20,
             sell_price = 50*Price_Multiplier,
             action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                 local playerPed = GetPlayerPed(-1)
             
                 RequestAnimSet("move_m@hurry_butch@a") 
                 while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                 Citizen.Wait(0)
                 end    
            
                 TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                 Citizen.Wait(3000)
                 ClearPedTasksImmediately(playerPed)
                 SetTimecycleModifier("spectator5")
                 SetPedMotionBlur(playerPed, true)
                 SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                 SetPedIsDrunk(playerPed, true)
                
                 --Effects
                 local player = PlayerId()
                 SetRunSprintMultiplierForPlayer(player, 1.3)
                 SetSwimMultiplierForPlayer(player, 1.3)

		 --Ending

		 Wait(20000)

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
                SetPedIsDrunk(playerPed, false)
                SetPedMotionBlur(playerPed, false)
		        SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                 SetRunSprintMultiplierForPlayer(player, 1.0)
                 SetSwimMultiplierForPlayer(player, 1.0)
             end,
         },
         ["meth"] = {
            harvest_point = {1003.72,-3199.01,-39.99},
            sell_point = {1251.05,-2577.69,41.91},
            potency = 35, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = true,
            harvest_time = 10, -- in seconds.
            harvest_cost = 20,
            sell_price = 60 * Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(20000)

               ClearTimecycleModifier()
               ResetScenarioTypesEnabled()
               --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
               SetPedIsDrunk(playerPed, false)
               SetPedMotionBlur(playerPed, false)
       SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
        ["opium"] = {
            harvest_point = {899.81,-959.95,38.28},
            sell_point = {1042.64,-2533.73,1.83},
            potency = 35, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = true,
            harvest_time = 20, -- in seconds.
            harvest_cost = 20,
            sell_price = 65 * Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(20000)

               ClearTimecycleModifier()
               ResetScenarioTypesEnabled()
               --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
               SetPedIsDrunk(playerPed, false)
               SetPedMotionBlur(playerPed, false)
       SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
        
                        
        ["weed"] = {
            harvest_point = {1057.16, -3201.04, -40.11},
            sell_point = {-1165.61,-1566.9,3.45},
            harvest_time = 15, -- in seconds.
            potency = 5, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = false,
            sell_price = 75* Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)

                RequestAnimSet("move_m@hipster@a") 
                while not HasAnimSetLoaded("move_m@hipster@a") do
                Citizen.Wait(0)
                end    
                
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetPedIsDrunk(playerPed, true)
                
                --Efects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
            end,
        },
	
	    ["croquettes"] = { -- heroin
            harvest_point = {-325.69,-2439.05,6.36},
            sell_point = {-505.58,-2706.6,7.76},
            potency = 60, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = true,
            harvest_time = 30, -- in seconds.
            harvest_cost = 30,
            sell_price = 70 * Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(20000)

               ClearTimecycleModifier()
               ResetScenarioTypesEnabled()
               --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
               SetPedIsDrunk(playerPed, false)
               SetPedMotionBlur(playerPed, false)
                SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
        ["cash"] = {
            harvest_point = {1119.95,-3195.38,-41.4},
            sell_point = {-54.83,-2523.18,6.4},
            potency = 35, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = false,
            harvest_time = 0.25, -- in seconds.
            harvest_cost = 0,
            sell_price = 20,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(20000)

                ClearTimecycleModifier()
                ResetScenarioTypesEnabled()
                --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
                SetPedIsDrunk(playerPed, false)
                SetPedMotionBlur(playerPed, false)
                SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
        ["acid"] = { -- Acid
            harvest_point = {262.18, -1803.78, 25.91},
            sell_point = {-2043.02,-1031.99,10.98},
            potency = 60, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = true,
            harvest_time = 40, -- in seconds.
            harvest_cost = 30,
            sell_price = 100 * Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(5000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(50000)

               ClearTimecycleModifier()
               ResetScenarioTypesEnabled()
               --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
               SetPedIsDrunk(playerPed, false)
               SetPedMotionBlur(playerPed, false)
                SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
        ["Aderral"] = { -- Aderral
        harvest_point = {-1371.12,-310.53,38.68},
        sell_point = {-647.23,-1148.33,8.62},
        potency = 60, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
        can_overdose = true,
        harvest_time = 40, -- in seconds.
        harvest_cost = 30,
        sell_price = 70 * Price_Multiplier,
        action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
            local playerPed = GetPlayerPed(-1)
        
            RequestAnimSet("move_m@hurry_butch@a") 
            while not HasAnimSetLoaded("move_m@hurry_butch@a") do
            Citizen.Wait(0)
            end    
       
            TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRUG_DEALER", 0, 1)
            Citizen.Wait(5000)
            ClearPedTasksImmediately(playerPed)
            SetTimecycleModifier("spectator5")
            SetPedMotionBlur(playerPed, true)
            SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
            SetPedIsDrunk(playerPed, true)
           
            --Effects
            local player = PlayerId()
            SetRunSprintMultiplierForPlayer(player, 1.3)
            SetSwimMultiplierForPlayer(player, 1.3)

    --Ending

     Wait(50000)

           ClearTimecycleModifier()
           ResetScenarioTypesEnabled()
           --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
           SetPedIsDrunk(playerPed, false)
           SetPedMotionBlur(playerPed, false)
            SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
            SetRunSprintMultiplierForPlayer(player, 1.0)
            SetSwimMultiplierForPlayer(player, 1.0)
        end,
    }, 
    ["OXYCODONE"] = { -- Oxy
            harvest_point = {1943.45,5180.26,46.98},
            sell_point = {-175.62,-632.24,47.98},
            potency = 60, -- 1-100, Once used, it will increase their drug level by this much. If their level reaches 100+, they will overdose.
            can_overdose = true,
            harvest_time = 20, -- in seconds.
            harvest_cost = 30,
            sell_price = 50 * Price_Multiplier,
            action = function() -- CLIENT SIDE ONLY, What happens when the drug is used. 
                local playerPed = GetPlayerPed(-1)
            
                RequestAnimSet("move_m@hurry_butch@a") 
                while not HasAnimSetLoaded("move_m@hurry_butch@a") do
                Citizen.Wait(0)
                end    
           
                TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
                Citizen.Wait(5000)
                ClearPedTasksImmediately(playerPed)
                SetTimecycleModifier("spectator5")
                SetPedMotionBlur(playerPed, true)
                SetPedMovementClipset(playerPed, "move_m@hurry_butch@a", true)
                SetPedIsDrunk(playerPed, true)
               
                --Effects
                local player = PlayerId()
                SetRunSprintMultiplierForPlayer(player, 1.3)
                SetSwimMultiplierForPlayer(player, 1.3)

        --Ending

        Wait(50000)

               ClearTimecycleModifier()
               ResetScenarioTypesEnabled()
               --ResetPedMovementClipset(playerPed, 0) <- it might cause the push of the vehicles
               SetPedIsDrunk(playerPed, false)
               SetPedMotionBlur(playerPed, false)
                SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                SetRunSprintMultiplierForPlayer(player, 1.0)
                SetSwimMultiplierForPlayer(player, 1.0)
            end,
        }, 
--Aderral
--harvest_point = {1944.38,5179.79,46.98},
    },
    PotencyTimeRatio = 100, -- In seconds, how long does one percentage of potent drugs last before decreasing?
}