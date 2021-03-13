ESX = nil
local limit = 18000

local cachedData = {}

TriggerEvent("esx:getSharedObject", function(library) 
	ESX = library 
end)

ESX.RegisterUsableItem(Config.FishingItems["rod"]["name"], function(source)
	TriggerClientEvent("james_fishing:tryToFish", source)
end)

ESX.RegisterServerCallback("james_fishing:receiveFish", function(source, callback)
	local player = ESX.GetPlayerFromId(source)
	local sayi = math.random(1, 10)

	if not player then return callback(false) end

	if player.canCarryItem(Config.FishingItems["fish"]["name"], sayi) then
		player.removeInventoryItem(Config.FishingItems["bait"]["name"], 1)
		player.addInventoryItem(Config.FishingItems["fish"]["name"], sayi)
	end
	
	callback(true)
end)

ESX.RegisterServerCallback("james_fishing:sellFish", function(source, callback)
	
	local player = ESX.GetPlayerFromId(source)

	if not player then return callback(false) end

	local fishItem = Config.FishingItems["fish"]

	local fishCount = player.getInventoryItem(fishItem["name"])["count"]
	local fishPrice = fishItem["price"]

	-- if fishCount > 0 then
	-- 	player.addMoney(fishCount * fishPrice)
	-- 	player.removeInventoryItem(fishItem["name"], fishCount)

	-- 	callback(fishCount * fishPrice, fishCount)
	-- else
	-- 	callback(false)
	-- end

end)

RegisterServerEvent("james_fishing:sellFish")
AddEventHandler("james_fishing:sellFish", function()
	local source = source
	local player = ESX.GetPlayerFromId(source)

	local fishItem = Config.FishingItems["fish"]

	local fishCount = player.getInventoryItem(fishItem["name"])["count"]
	local fishPrice = fishItem["price"]
	local sold = fishCount * fishPrice

	if CheckFishLimit(source, fishPrice) == true then
		if fishCount > 0 then
			TriggerClientEvent('hir:sellfish', player.source)
			player.addMoney(sold)
			player.removeInventoryItem(fishItem["name"], fishCount)

			TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'success', text = sold.."$ karşılığında "..fishCount.." adet balık sattın"})
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "Hiç balığın yok !"})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', player.source, { type = 'error', text = "Günlük limitine ulaştın"})
	end
end)

function SellItem()
	local player = ESX.GetPlayerFromId(source)

	if not player then return callback(false) end

	local fishItem = Config.FishingItems["fish"]

	local fishCount = player.getInventoryItem(fishItem["name"])["count"]
	local fishPrice = fishItem["price"]

	if CheckFishLimit(source, fishPrice) == true then
		if fishCount > 0 then
			player.addMoney(fishCount * fishPrice)
			player.removeInventoryItem(fishItem["name"], fishCount)

		end
	-- else
	-- 	TriggerClientEvent('esx:showNotification', source, "Günlük limitine ulaştın!")
	end
end

function ResetFishLimits()
    local sqlresult = MySQL.Sync.fetchAll("SELECT * FROM characters")

    for i = 1, #sqlresult, 1 do
        MySQL.Async.execute("UPDATE characters SET fishlimit = @fishlimit WHERE identifier = @identifier", {
            ["@fishlimit"] = 0,
            ["@identifier"] = sqlresult[i].identifier
        })
    end
    print("^1Meslek limitleri sıfırlandı.^0")
end

function CheckFishLimit(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local result = MySQL.Sync.fetchAll("SELECT fishlimit FROM characters WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
	})
	local fishItem = Config.FishingItems["fish"]
	local fishCount = xPlayer.getInventoryItem(fishItem["name"])["count"]
	local fishPrice = fishItem["price"]
	local sold = fishCount * fishPrice

    if result[1].fishlimit >= limit then -- limit sayısı
		return false
    else
        MySQL.Async.execute("UPDATE characters SET fishlimit = @fishlimit WHERE identifier = @identifier", {
            ["@fishlimit"] = result[1].fishlimit + sold, -- günlük limiti aşmayıp satış yaptığı için sql de o kişinin satışını arttırma
            ["@identifier"] = xPlayer.identifier
		})
		return true
    end
end

TriggerEvent('cron:runAt', 24, 0, ResetFishLimits)
