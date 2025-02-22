-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local financetimer = {}
local paymentDue = false

-- Handlers

-- Store game time for player when they load
RegisterNetEvent('qb-vehicleshop:server:addPlayer', function(citizenid, gameTime)
    financetimer[citizenid] = gameTime
end)

-- Deduct stored game time from player on logout
RegisterNetEvent('qb-vehicleshop:server:removePlayer', function(citizenid)
    if financetimer[citizenid] then
        local playTime = financetimer[citizenid]
        local financetime = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid})
        for k,v in pairs(financetime) do
            if v.balance >= 1 then
                local newTime = math.floor(v.financetime - (((GetGameTimer() - playTime) / 1000) / 60))
                if newTime < 0 then newTime = 0 end
                MySQL.Async.execute('UPDATE player_vehicles SET financetime = ? WHERE plate = ?', {newTime, v.plate})
            end
        end
    end
    financetimer[citizenid] = nil
end)

-- Deduct stored game time from player on quit because we can't get citizenid
AddEventHandler('playerDropped', function()
    local src = source
    for k,v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        end
    end
    if license then
        local vehicles = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE license = ?', {license})
        if vehicles then
            for k,v in pairs(vehicles) do
                local playTime = financetimer[v.citizenid]
                if v.balance >= 1 and playTime then
                    local newTime = math.floor(v.financetime - (((GetGameTimer() - playTime) / 1000) / 60))
                    if newTime < 0 then newTime = 0 end
                    MySQL.Async.execute('UPDATE player_vehicles SET financetime = ? WHERE plate = ?', {newTime, v.plate})
                end
            end
            if vehicles[1] and financetimer[vehicles[1].citizenid] then financetimer[vehicles[1].citizenid] = nil end
        end
    end
end)

-- Functions

local function round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function calculateFinance(vehiclePrice, downPayment, paymentamount)
    local balance = vehiclePrice - downPayment
    local vehPaymentAmount = balance / paymentamount
    return round(balance), round(vehPaymentAmount)
end

local function calculateNewFinance(paymentAmount, vehData)
    local newBalance = tonumber(vehData.balance - paymentAmount)
    local minusPayment = vehData.paymentsLeft - 1
    local newPaymentsLeft = newBalance / minusPayment
    local newPayment = newBalance / newPaymentsLeft
    return round(newBalance), round(newPayment), newPaymentsLeft
end

local function GeneratePlate()
    -- local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)\
    local plate = QBCore.Shared.RandomStr(3):upper() .. ' ' .. QBCore.Shared.RandomInt(3)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

local function comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-vehicleshop:server:getVehicles', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player then
        local vehicles = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {player.PlayerData.citizenid})
        if vehicles[1] then
            cb(vehicles)
        end
    end
end)

-- Events

-- Sync vehicle for other players
RegisterNetEvent('qb-vehicleshop:server:swapVehicle', function(data)
    local src = source
    TriggerClientEvent('qb-vehicleshop:client:swapVehicle', -1, data)
    Wait(1500) -- let new car spawn
    TriggerClientEvent('qb-vehicleshop:client:homeMenu', src) -- reopen main menu
end)

-- Send customer for test drive
RegisterNetEvent('qb-vehicleshop:server:customTestDrive', function(vehicle, playerid)
    local src = source
    local target = tonumber(playerid)
    if not QBCore.Functions.GetPlayer(target) then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid Player Id Supplied', 'error')
        return
    end
    if #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target)))<3 then
        TriggerClientEvent('qb-vehicleshop:client:customTestDrive', target, vehicle)
    else
        TriggerClientEvent('QBCore:Notify', src, 'This player is not close enough', 'error')
    end
end)

-- Make a finance payment
RegisterNetEvent('qb-vehicleshop:server:financePayment', function(paymentAmount, vehData)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cash = player.PlayerData.money['cash']
    local bank = player.PlayerData.money['bank']
    local plate = vehData.vehiclePlate
    local paymentAmount = tonumber(paymentAmount)
    local minPayment = tonumber(vehData.paymentAmount)
    local timer = (Config.PaymentInterval * 60)
    local newBalance, newPaymentsLeft, newPayment = calculateNewFinance(paymentAmount, vehData)
    if newBalance > 0 then
        if player and paymentAmount >= minPayment then
            if cash >= paymentAmount then
                player.Functions.RemoveMoney('cash', paymentAmount)
                exports['qb-management']:AddMoney("cardealer", paymentAmount)
                MySQL.Async.execute('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {newBalance, newPayment, newPaymentsLeft, timer, plate})
            elseif bank >= paymentAmount then
                player.Functions.RemoveMoney('bank', paymentAmount)
                exports['qb-management']:AddMoney("cardealer", paymentAmount)
                MySQL.Async.execute('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {newBalance, newPayment, newPaymentsLeft, timer, plate})
            else
                TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Minimum payment allowed is $' ..comma_value(minPayment), 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You overpaid', 'error')
    end
end)


-- Pay off vehice in full
RegisterNetEvent('qb-vehicleshop:server:financePaymentFull', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cash = player.PlayerData.money['cash']
    local bank = player.PlayerData.money['bank']
    local vehBalance = data.vehBalance
    local vehPlate = data.vehPlate
    if player and vehBalance ~= 0 then
        if cash >= vehBalance then
            player.Functions.RemoveMoney('cash', vehBalance)
            exports['qb-management']:AddMoney("cardealer", vehBalance)
            MySQL.Async.execute('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {0, 0, 0, 0, vehPlate})
        elseif bank >= vehBalance then
            player.Functions.RemoveMoney('bank', vehBalance)
            exports['qb-management']:AddMoney("cardealer", vehBalance)
            MySQL.Async.execute('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {0, 0, 0, 0, vehPlate})
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle is already paid off', 'error')
    end
end)

-- Buy public vehicle outright
RegisterNetEvent('qb-vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source
    local vehicle = vehicle.buyVehicle
    local pData = QBCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local cash = pData.PlayerData.money['cash']
    local bank = pData.PlayerData.money['bank']
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
    local plate = GeneratePlate()
    if cash > vehiclePrice then
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            0
        })
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('cash', vehiclePrice, 'vehicle-bought-in-showroom')
        exports['qb-management']:AddMoney("cardealer", vehiclePrice)
        TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Purchased", "red","**" .. GetPlayerName(src) .. "** bought a " .. vehicle .. ' for ' .. vehiclePrice)

    elseif bank > vehiclePrice then
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            0
        })
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', vehiclePrice, 'vehicle-bought-in-showroom')
        exports['qb-management']:AddMoney("cardealer", vehiclePrice)
        TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Purchased", "red","**" .. GetPlayerName(src) .. "** bought a " .. vehicle .. ' for ' .. vehiclePrice)

    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end)

-- Finance public vehicle
RegisterNetEvent('qb-vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source
    local downPayment = tonumber(downPayment)
    local paymentAmount = tonumber(paymentAmount)
    local pData = QBCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local cash = pData.PlayerData.money['cash']
    local bank = pData.PlayerData.money['bank']
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
    local timer = (Config.PaymentInterval * 60)
    local minDown = tonumber(round((Config.MinimumDown/100) * vehiclePrice))
    if downPayment > vehiclePrice then return TriggerClientEvent('QBCore:Notify', src, 'Vehicle is not worth that much', 'error') end
    if downPayment < minDown then return TriggerClientEvent('QBCore:Notify', src, 'Down payment too small', 'error') end
    if paymentAmount > Config.MaximumPayments then return TriggerClientEvent('QBCore:Notify', src, 'Exceeded maximum payment amount', 'error') end
    local plate = GeneratePlate()
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
    if cash >= downPayment then
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            0,
            balance,
            vehPaymentAmount,
            paymentAmount,
            timer
        })
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('cash', downPayment, 'vehicle-bought-in-showroom')
        exports['qb-management']:AddMoney("cardealer", downPayment)
        TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Financed", "red","**" .. GetPlayerName(src) .. "** financed a " .. vehicle .. ' for downpayment of ' .. downPayment)

    elseif bank >= downPayment then
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            0,
            balance,
            vehPaymentAmount,
            paymentAmount,
            timer
        })
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', downPayment, 'vehicle-bought-in-showroom')
        exports['qb-management']:AddMoney("cardealer", downPayment)
        TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Financed", "red","**" .. GetPlayerName(src) .. "** financed a " .. vehicle .. ' for downpayment of ' .. downPayment)

    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end)

-- Sell vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellShowroomVehicle', function(data, playerid)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(tonumber(playerid))

    if not target then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid Player Id Supplied', 'error')
        return
    end

    if #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target.PlayerData.source)))<3 then
        local cid = target.PlayerData.citizenid
        local cash = target.PlayerData.money['cash']
        local bank = target.PlayerData.money['bank']
        local vehicle = data
        local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
        local commission = round(vehiclePrice * Config.Commission)
        local plate = GeneratePlate()
        if cash >= vehiclePrice then
            exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                target.PlayerData.license,
                cid,
                vehicle,
                GetHashKey(vehicle),
                '{}',
                plate,
                0
            })
            TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
            target.Functions.RemoveMoney('cash', vehiclePrice, 'vehicle-bought-in-showroom')
            player.Functions.AddMoney('bank', commission)
            TriggerClientEvent('QBCore:Notify', src, 'You earned $'..comma_value(commission)..' in commission', 'success')
            exports['qb-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Congratulations on your purchase!', 'success')
            TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Purchased", "red","**" .. GetPlayerName(src) .. "** sold a lux " .. vehicle .. ' for ' .. vehiclePrice .. 'to ' .. cid)

        elseif bank >= vehiclePrice then
            exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                target.PlayerData.license,
                cid,
                vehicle,
                GetHashKey(vehicle),
                '{}',
                plate,
                0
            })
            TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
            target.Functions.RemoveMoney('bank', vehiclePrice, 'vehicle-bought-in-showroom')
            player.Functions.AddMoney('bank', commission)
            exports['qb-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
            TriggerClientEvent('QBCore:Notify', src, 'You earned $'..comma_value(commission)..' in commission', 'success')
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Congratulations on your purchase!', 'success')
            TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Purchased", "red","**" .. GetPlayerName(src) .. "** sold a lux " .. vehicle .. ' for ' .. vehiclePrice .. 'to ' .. cid)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'This player is not close enough', 'error')
    end
end)

-- Finance vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellfinanceVehicle', function(downPayment, paymentAmount, vehicle, playerid)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(tonumber(playerid))

    if not target then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid Player Id Supplied', 'error')
        return
    end

    if #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target.PlayerData.source)))<3 then
        local downPayment = tonumber(downPayment)
        local paymentAmount = tonumber(paymentAmount)
        local cid = target.PlayerData.citizenid
        local cash = target.PlayerData.money['cash']
        local bank = target.PlayerData.money['bank']
        local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
        local timer = (Config.PaymentInterval * 60)
        local minDown = tonumber(round((Config.MinimumDown/100) * vehiclePrice))
        if downPayment > vehiclePrice then return TriggerClientEvent('QBCore:Notify', src, 'Vehicle is not worth that much', 'error') end
        if downPayment < minDown then return TriggerClientEvent('QBCore:Notify', src, 'Down payment too small', 'error') end
        if paymentAmount > Config.MaximumPayments then return TriggerClientEvent('QBCore:Notify', src, 'Exceeded maximum payment amount', 'error') end
        local commission = round(vehiclePrice * Config.Commission)
        local plate = GeneratePlate()
        local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
        if cash >= downPayment then
            exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                target.PlayerData.license,
                cid,
                vehicle,
                GetHashKey(vehicle),
                '{}',
                plate,
                0,
                balance,
                vehPaymentAmount,
                paymentAmount,
                timer
            })
            TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
            target.Functions.RemoveMoney('cash', downPayment, 'vehicle-bought-in-showroom')
            player.Functions.AddMoney('bank', commission)
            TriggerClientEvent('QBCore:Notify', src, 'You earned $'..comma_value(commission)..' in commission', 'success')
            exports['qb-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Congratulations on your purchase!', 'success')
            TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Financed", "red","**" .. GetPlayerName(src) .. "** financed a lux " .. vehicle .. ' for ' .. vehiclePrice .. 'to ' .. cid)

        elseif bank >= downPayment then
            exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                target.PlayerData.license,
                cid,
                vehicle,
                GetHashKey(vehicle),
                '{}',
                plate,
                0,
                balance,
                vehPaymentAmount,
                paymentAmount,
                timer
            })
            TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
            target.Functions.RemoveMoney('bank', downPayment, 'vehicle-bought-in-showroom')
            player.Functions.AddMoney('bank', commission)
            TriggerClientEvent('QBCore:Notify', src, 'You earned $'..comma_value(commission)..' in commission', 'success')
            exports['qb-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Congratulations on your purchase!', 'success')
            TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle Financed", "red","**" .. GetPlayerName(src) .. "** financed a lux " .. vehicle .. ' for ' .. vehiclePrice .. 'to ' .. cid)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'This player is not close enough', 'error')
    end
end)

-- Check if payment is due
RegisterNetEvent('qb-vehicleshop:server:checkFinance', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {player.PlayerData.citizenid})
    for k,v in pairs(result) do
        if v.balance >= 1 and v.financetime < 1 then
            paymentDue = true
            -- print("INSIDE FIRST")
            -- print(v.plate)
        end
    end
    if paymentDue then
        TriggerClientEvent('QBCore:Notify', src, 'Your vehicle payment is due within '..Config.PaymentWarning..' minutes')
        Wait(Config.PaymentWarning * 60000)
        -- Wait(10000)
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = ?', {player.PlayerData.citizenid})
        for k,v in pairs(result) do

            if v.balance >= 1 and v.financetime < 1 then
                local plate = v.plate    
                TriggerClientEvent('QBCore:Notify', src, 'Your vehicle with plate '..plate..' has been repossessed', 'error')
                exports.oxmysql:execute('INSERT INTO repo_vehicles (license, citizenid, vehicle, hash, mods, plate, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                    player.PlayerData.license, player.PlayerData.citizenid, v.vehicle, GetHashKey(v.vehicle), v.mods, v.plate,
                    0, v.balance, v.paymentamount, v.paymentsleft, v.financetime
                })
                -- local newrep = player.PlayerData.metadata["creditscore"]
                -- newrep.creditscore = tonumber(args[2])
                -- Player.Functions.SetMetaData("jobrep", newrep)
                local rep = player.PlayerData.metadata["creditscore"]
                local num = 0
                if rep then
                    num = rep.vehiclesRepod
                end
                player.Functions.SetMetaData("creditscore", {
                    ["vehiclesRepod"] = num + 1,
                })
                MySQL.Async.execute('DELETE FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate})
                -- exports.oxmysql:execute('INSERT INTO repo_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                --     {player.PlayerData.license, player.PlayerData.citizenid, v["model"], GetHashKey(v["model"]), v["mods"], v["plate"], 0})
            end
        end
    end
end)

QBCore.Commands.Add('carh', 'Spawn Vehicle (Admin Only)', { { name = 'model', help = 'Model name of the vehicle' } }, true, function(source, args)
    print("carh triggered")
    local src = source
    TriggerClientEvent('QBCore:Command:SpawnVehicleNoHash', src, args[1])
end, 'admin')

-- Transfer vehicle to player in passenger seat
RegisterNetEvent('qb-vehicleshop:server:transferVehicle', function(plate, buyerId, amount)
    local src = source
    local plate = plate
    local buyerId = tonumber(buyerId)
    local sellAmount = tonumber(amount)
    local ped = GetPlayerPed(src)
    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(buyerId)
    local citizenid = player.PlayerData.citizenid
    local sellAmount = tonumber(amount)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then return TriggerClientEvent('QBCore:Notify', src, 'Must be in a vehicle', 'error') end
    local driver = GetPedInVehicleSeat(vehicle, -1)
    local passenger = GetPedInVehicleSeat(vehicle, 0)
    -- local plate = QBCore.Functions.GetPlate(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    -- print("fetching plate")
    -- print(plate)
    -- print("test")
    local isOwned = MySQL.Sync.fetchScalar('SELECT citizenid FROM player_vehicles WHERE plate = ?', {plate})
    -- print("is owned")
    -- print(isOwned)
    if isOwned ~= citizenid then return TriggerClientEvent('QBCore:Notify', src, 'You dont own this vehicle', 'error') end
    if ped ~= driver then return TriggerClientEvent('QBCore:Notify', src, 'Must be driver', 'error') end
    if passenger == 0 then return TriggerClientEvent('QBCore:Notify', src, 'No passenger', 'error') end
    local targetid = NetworkGetEntityOwner(passenger)
    local target = QBCore.Functions.GetPlayer(targetid)
    if not target then return TriggerClientEvent('QBCore:Notify', src, 'Couldnt get passenger info', 'error') end
    if sellAmount then
        if target.Functions.GetMoney('cash') > sellAmount then
            local targetcid = target.PlayerData.citizenid
            local targetlicense = target.PlayerData.license
            MySQL.Async.execute('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {targetcid, plate})
            MySQL.Async.execute('UPDATE player_vehicles SET license = ? WHERE plate = ?', {targetlicense, plate})
            player.Functions.AddMoney('cash', sellAmount)
            TriggerClientEvent('QBCore:Notify', src, 'You sold your vehicle for $'..comma_value(sellAmount), 'success')
            target.Functions.RemoveMoney('cash', sellAmount)
            TriggerClientEvent('vehiclekeys:client:SetOwner', target.PlayerData.source, plate)
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'You were gifted a vehicle', 'success')
            
        end
    else
        local targetcid = target.PlayerData.citizenid
        local targetlicense = target.PlayerData.license
        MySQL.Async.execute('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {targetcid, plate})
        MySQL.Async.execute('UPDATE player_vehicles SET license = ? WHERE plate = ?', {targetlicense, plate})
        TriggerClientEvent('QBCore:Notify', src, 'You gifted your vehicle', 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', target.PlayerData.source, plate)
        TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'You were gifted a vehicle', 'success')
    end
end)

-- Transfer vehicle to player in passenger seat
QBCore.Commands.Add('transferVehicle', 'Gift or sell your vehicle', {{name = 'ID', help = 'ID of buyer'}, {name = 'amount', help = 'Sell amount'}}, false, function(source, args)
    if args[1] ~= nil and args[2] ~= nil then
        TriggerClientEvent('qb-vehicleshop:client:transferVehicle', source, args[1], args[2])
    else
        TriggerClientEvent('QBCore:Notify', source, 'Check who you\'re selling to or the amount to sell for.', 'error')
    end
end)
