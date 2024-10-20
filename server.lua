ESX = nil

if Config.ESX == 'old' then
     TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.ESX == 'new' then
    ESX = exports["es_extended"]:getSharedObject()
else
    print('Wrong ESX Type!')
end

ESX.RegisterServerCallback('getOwnedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ownedVehicles = {}

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
        ['@owner']  = xPlayer.identifier,
        ['@type']   = 'car',
        ['@insured']   = insured
    }, function(data)
        for _, v in pairs(data) do
            local vehicle = json.decode(v.vehicle)
            local isInsured = v.insured == 1
            table.insert(ownedVehicles, {
                plate = v.plate,
                model = vehicle.model,
                insured = v.insured
            })
        end
        cb(ownedVehicles)
    end)
    
end)

RegisterServerEvent('nkhd:insureVehicle')
AddEventHandler('nkhd:insureVehicle', function(source, plate)
    
    MySQL.Async.fetchScalar('SELECT insured FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(insured)
        if insured then
            local newInsuranceStatus = (insured == 1) and 0 or 1

            
            MySQL.Async.execute('UPDATE owned_vehicles SET insured = @insured WHERE plate = @plate', {
                ['@insured'] = newInsuranceStatus,
                ['@plate'] = plate
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    
                else
                    
                end
            end)
        else

        end
    end)
end)

RegisterServerEvent('nkhd:removemoney')
AddEventHandler('nkhd:removemoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        if xPlayer.getMoney() < 250 then
            xPlayer.removeAccountMoney(bank, 250)
        else
            xPlayer.removeMoney(250)
        end
    else

    end
end)
