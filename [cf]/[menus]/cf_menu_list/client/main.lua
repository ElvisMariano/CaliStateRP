CF = nil

Citizen.CreateThread(function()
	while CF == nil do 
		Citizen.Wait(0)
		CF = exports['cf'].GetFramework ~= nil and exports['cf'].GetFramework() or nil
	end

	local MenuType    = 'list'
	local OpenedMenus = {}

	local openMenu = function(namespace, name, data)

		OpenedMenus[namespace .. '_' .. name] = true

		SendNUIMessage({
			action    = 'openMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		CF.SetTimeout(200, function()
			SetNuiFocus(true, true)
		end)

	end

	local closeMenu = function(namespace, name)

		OpenedMenus[namespace .. '_' .. name] = nil
		local OpenedMenuCount = 0

		SendNUIMessage({
			action    = 'closeMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		for k,v in pairs(OpenedMenus) do
			if v == true then
				OpenedMenuCount = OpenedMenuCount + 1
			end
		end

		if OpenedMenuCount == 0 then
			SetNuiFocus(false)
		end

	end

	CF.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = CF.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.submit ~= nil then
			menu.submit(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_cancel', function(data, cb)
		local menu = CF.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
	end)

end)