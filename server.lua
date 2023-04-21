local VehicleHandling = {}

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local vehicles = {}
local carPlate = nil

CreateThread(function()
    Wait(500)
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "./currentVehicles.json"))

    if not result then
        return
    end

    vehicles = result

end)

RegisterServerEvent('lab-chopshop:server:setVehicle')
AddEventHandler('lab-chopshop:server:setVehicle', function (carPlate, carOnLift, carEngineJack)
    local src = source
    vehicles[carPlate] = {}
    vehicles[carPlate]["carPlate"] = carPlate
    vehicles[carPlate]["carOnLift"] = carOnLift
    vehicles[carPlate]["carEngineJack"] = carEngineJack
    carPlate = carPlate
    SaveResourceFile(GetCurrentResourceName(), "./currentVehicles.json", json.encode(vehicles), -1)
end)


RegisterServerEvent('lab-chopshop:server:setVehicleStatement')
AddEventHandler('lab-chopshop:server:setVehicleStatement', function(plate, carOnLift, carEngineJack)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if vehicles[plate]["carPlate"] == plate then
        vehicles[plate].carOnLift = carOnLift
        
        if carEngineJack == "" then
            vehicles[plate].carEngineJack = vehicles[plate].carEngineJack
        else
            vehicles[plate].carEngineJack = carEngineJack
        end
        SaveResourceFile(GetCurrentResourceName(), "./currentVehicles.json", json.encode(vehicles), -1)

    end
end)

RegisterNetEvent('lab-chopshop:server:syncDoorBroken')
AddEventHandler('lab-chopshop:server:syncDoorBroken', function (nVehicle, doorData, objData)
    TriggerClientEvent('lab-chopshop:client:syncDoorBroken', -1, nVehicle, doorData)
end)


RegisterNetEvent('lab-chopshop:server:getVehicleHandling')
AddEventHandler('lab-chopshop:server:getVehicleHandling',function(plate)
    local src = source
    TriggerClientEvent('lab-chopshop:client:getVehicleHandling', src, plate, VehicleHandling[plate])
end)


RegisterNetEvent('lab-chopshop:server:setVehicleHandling')
AddEventHandler('lab-chopshop:server:setVehicleHandling',function(plate, handlingData)
    VehicleHandling[plate] = handlingData
end)


RegisterNetEvent('lab-chopshop:server:removeItem')
AddEventHandler('lab-chopshop:server:removeItem', function(itemName, price)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.removeInventoryItem(itemName, 1)
    xPlayer.addInventoryItem('money', tonumber(price))
end)

RegisterNetEvent('lab-chopshop:server:giveMetaItem')
AddEventHandler('lab-chopshop:server:giveMetaItem', function(handling, plate)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    info = {
        label = plate.. "'s Engine",
        description = plate,
        id = math.random(100000, 999999),
        handling = handling,
    }

    -- add info as an argument for metadata of this item

    xPlayer.addInventoryItem('car_engine', 1)
end)


RegisterNetEvent('lab-chopshop:server:giveItem')
AddEventHandler('lab-chopshop:server:giveItem', function(doorIndex)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if doorIndex == 0 or doorIndex == 1 or doorIndex == 2 or doorIndex == 3  then       
        item = "car_door"
    elseif doorIndex == 4 then
        item = "car_bonnet"
    elseif  doorIndex == 5 then
        item = "car_trunk"
    end
    xPlayer.addInventoryItem(name, 1)
end)

ESX.RegisterServerCallback('lab-chopshop:server:checkItem', function (source, cb, item) --QBCORE
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local itemCount = xPlayer.getInventoryItem(item)
    local hasItem = false

    if itemCount.count > 0 then
        hasItem = true
    end

    if hasItem then 
        cb(true) 
    else 
        cb(false) 
    end
end)

ESX.RegisterServerCallback('lab-chopshop:server:checkVehicleInfo', function (source, cb, plate, value)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if vehicles[plate] ~= nil then
        if vehicles[plate].carPlate == plate then
            if vehicles[plate][value] == false then
                cb(vehicles[plate].carOnLift, vehicles[plate].carEngineJack)
            else
                cb(vehicles[plate].carOnLift,vehicles[plate].carEngineJack)
            end
        else
            xPlayer.showNotification('Sistemde plaka uyuşmazlığı 505')
        end
    else
        vehicles[plate] = {}
        vehicles[plate]["carPlate"] = plate
        vehicles[plate]["carOnLift"] = false
        vehicles[plate]["carEngineJack"] = false
        plate = plate
        SaveResourceFile(GetCurrentResourceName(), "./currentVehicles.json", json.encode(vehicles), -1)
    
        xPlayer.showNotification('Yeni data Oluşturuldu')
        cb(vehicles[plate].carEngineJack)
    end
end)

--QBCore.Functions.CreateUseableItem('car_engine', function(source, item)
--    LoadVehicle(source, item)
--end)

ESX.RegisterUsableItem('car_engine', function(source)
    LoadVehicle(source, item)
end)

function LoadVehicle(source,item)
    print(json.encode(source), json.encode(item))
    local src = source
    local plate = item.info.plate
    local vehicleHandling = item.info.handling
    TriggerClientEvent('lab-chopshop:client:useEngine', src, vehicleHandling)
end
