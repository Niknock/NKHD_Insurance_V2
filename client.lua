ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        if Config.ESX == 'old' then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        elseif Config.ESX == 'new' then
            ESX = exports["es_extended"]:getSharedObject()
        else
            print('Wrong ESX Type!')
        end
    end
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Marker.x, Config.Marker.y, Config.Marker.z)

    SetBlipSprite(blip, 380)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 17)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('blip'))
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    local marker = vector3(Config.Marker.x, Config.Marker.y, Config.Marker.z)
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - marker)

        if distance < 20.0 then
            DrawMarker(1, marker.x, marker.y, marker.z - 1, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.0, 255, 255, 255, 200, 0, 0, 0, 0)
        end

        if distance < 5.0 then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('showInsuranceMenu')
AddEventHandler('showInsuranceMenu', function()
    ESX.UI.Menu.CloseAll()

    local elements = {}
    ESX.TriggerServerCallback('getOwnedVehicles', function(ownedVehicles)
        for _, vehicle in ipairs(ownedVehicles) do

            local vehicleName = GetDisplayNameFromVehicleModel(vehicle.model)
            vehicleName = GetLabelText(vehicleName) 
            
            local insuranceLabel = {}
            if vehicle.insured == 1 then insuranceLabel = _U('insured_menu') else insuranceLabel = _U('notinsured_menu') end

            table.insert(elements, {
                label = string.format("%s - %s (%s)", vehicleName, vehicle.plate, insuranceLabel),
                value = vehicle
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_menu',
            {
                title    = _U('blip'),
                align    = 'top-left',
                elements = elements
            },
            function(data, menu)
                menu.close()

                local vehicle = data.current.value

                if vehicle.insured == 1 then
                    TriggerEvent('nkhd:notifinssuc2')
                    TriggerServerEvent('nkhd:insureVehicle', source, vehicle.plate)
                    TriggerEvent('nkhd:removemoneyclient', source)
                else
                    TriggerEvent('nkhd:notifinssuc')
                    TriggerServerEvent('nkhd:insureVehicle', source, vehicle.plate)
                    TriggerEvent('nkhd:removemoneyclient', source)
                end
            end,
            function(data, menu)
                menu.close()
            end
        )
    end)
end)

RegisterNetEvent('nkhd:removemoneyclient')
AddEventHandler('nkhd:removemoneyclient', function()
    TriggerServerEvent('nkhd:removemoney', source)
end)

RegisterNetEvent('nkhd:notifinssuc')
AddEventHandler('nkhd:notifinssuc', function(isInsured)
    ShowNotification(_U('insured'))
end)

RegisterNetEvent('nkhd:notifinssuc2')
AddEventHandler('nkhd:notifinssuc2', function(isInsured)
    ShowNotification(_U('desured'))
end)

Citizen.CreateThread(function()
    local inRange = false
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local targetCoords = vector3(Config.Marker.x, Config.Marker.y, Config.Marker.z)
        local distance = #(playerCoords - targetCoords)

        if distance < 2.0 then
            inRange = true
            ESX.ShowHelpNotification(_U('inrange'))
            
            if IsControlJustPressed(0, 38) then
                inRange = false
                TriggerEvent('showInsuranceMenu')
            end
        else
            inRange = false
        end

        if inRange then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
