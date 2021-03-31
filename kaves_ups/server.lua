ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("kaves_ups:limanpay")
AddEventHandler("kaves_ups:limanpay", function(miktar)
    local count = miktar
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT ups FROM stocks', {
        ['@ups'] = ups
    }, function(result)
	local postcount = result[1].ups
	 MySQL.Sync.execute('UPDATE stocks SET ups = @ups', {
	 ['@ups'] = postcount + count
	 })
    end)
    xPlayer.addMoney(3500)
end)

RegisterServerEvent("kaves_ups:pay")
AddEventHandler("kaves_ups:pay", function(sayi,level)
    local miktar = sayi * 100
    local carp = 1
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT ups FROM stocks', {
        ['@ups'] = ups
    }, function(result)
	local post = result[1].ups
	 MySQL.Sync.execute('UPDATE stocks SET ups = @ups', {
	 ['@ups'] = post - miktar
	 })
    end)
    if level >= 1 and level <= 3 then
        carp = 2
    elseif level > 3 and level <= 6 then
        carp = 3
    elseif level > 6 and level <= 9 then
        carp = 4
    elseif level >= 9 then
        carp = 4
    end
    local money = ((carp*sayi) * 80)
    xPlayer.addMoney(money)

    
end)

ESX.RegisterServerCallback("kaves_ups:checkPost", function(source,cb)
    MySQL.Async.fetchAll('SELECT ups FROM stocks', {
        ['@ups'] = ups
    }, function(result)
    local post = result[1].ups
    
    if post >= Config.PostReq then
        cb(true)
    else
        cb(false)
    end
    end)    
end)