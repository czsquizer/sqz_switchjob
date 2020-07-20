		
if GetCurrentResourceName() == 'sqz_unijob' then
		ESX = nil

		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

		TriggerEvent('esx_phone:registerNumber', 'sandy_mechanic', _U('alert_mechanic'), true, true)
		TriggerEvent('esx_phone:registerNumber', 'fib', _U('alert_fib'), true, true)

		TriggerEvent('esx_society:registerSociety', 'sandy_mechanic', 'Sandy_mechanic', 'society_sandy_mechanic', 'society_sandy_mechanic', 'society_sandy_mechanic', {type = 'public'})
		TriggerEvent('esx_society:registerSociety', 'fib', 'Fib', 'society_fib', 'society_fib', 'society_fib', {type = 'public'})


		RegisterServerEvent('sqz_unijob:requestarrest')
		AddEventHandler('sqz_unijob:requestarrest', function(targetid, playerheading, playerCoords,  playerlocation)
			local xPlayer = ESX.GetPlayerFromId(source)
			_source = source
			if Config.NeedItemCuffs then
				local cuffs = xPlayer.getInventoryItem('cuffs')
				if cuffs.count then
					TriggerClientEvent('sqz_unijob:getarrested', targetid, playerheading, playerCoords, playerlocation)
					TriggerClientEvent('sqz_unijob:doarrested', _source)
					xPlayer.removeInventoryItem('cuffs', 1)
				else
					xPlayer.showNotification(_U('no_cuffs'))
				end
			else
				TriggerClientEvent('sqz_unijob:getarrested', targetid, playerheading, playerCoords, playerlocation)
				TriggerClientEvent('sqz_unijob:doarrested', _source)
			end
		end)


		RegisterServerEvent('sqz_unijob:requestrelease')
		AddEventHandler('sqz_unijob:requestrelease', function(targetid, playerheading, playerCoords,  playerlocation)
			local xPlayer = ESX.GetPlayerFromId(source)
			_source = source

			if Config.NeedItemCuffs then
				xPlayer.addInventoryItem('cuffs', 1)
				xPlayer.showNotification(_U('received_cuffs'))
			end
			TriggerClientEvent('sqz_unijob:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
			TriggerClientEvent('sqz_unijob:douncuffing', _source)
		end)
		RegisterNetEvent('sqz_unijob:drag')
		AddEventHandler('sqz_unijob:drag', function(target)
			TriggerClientEvent('sqz_unijob:drag', target, source)
		end)

		RegisterNetEvent('sqz_unijob:putInVehicle')
		AddEventHandler('sqz_unijob:putInVehicle', function(target)
			TriggerClientEvent('sqz_unijob:putInVehicle', target)
		end)

		RegisterNetEvent('sqz_unijob:OutVehicle')
		AddEventHandler('sqz_unijob:OutVehicle', function(target)
			TriggerClientEvent('sqz_unijob:OutVehicle', target)
		end)

		RegisterServerEvent('sqz_unijob:revive')
		AddEventHandler('sqz_unijob:revive', function(target)
		TriggerClientEvent('esx_ambulancejob:revive', target)
		end)

		ESX.RegisterServerCallback('sqz_unijob:buyWeapon', function(source, cb, weaponName, type, componentNum)
			local xPlayer = ESX.GetPlayerFromId(source)
			local authorizedWeapons, selectedWeapon = Config.Jobs[xPlayer.job.name].AuthorizedWeapons

			for k,v in ipairs(authorizedWeapons) do
				if v.weapon == weaponName then
					selectedWeapon = v
					break
				end
			end

			if not selectedWeapon then
				print(('sqz_unijob: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
				cb(false)
			else
				-- Weapon
				if type == 1 then
					if xPlayer.getMoney() >= selectedWeapon.price then
						xPlayer.removeMoney(selectedWeapon.price)
						xPlayer.addWeapon(weaponName, 100)

						cb(true)
					else
						cb(false)
					end

				-- Weapon Component
				elseif type == 2 then
					local price = selectedWeapon.components[componentNum]
					local weaponNum, weapon = ESX.GetWeapon(weaponName)
					local component = weapon.components[componentNum]

					if component then
						if xPlayer.getMoney() >= price then
							xPlayer.removeMoney(price)
							xPlayer.addWeaponComponent(weaponName, component.name)

							cb(true)
						else
							cb(false)
						end
					else
						print(('sqz_unijob: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
						cb(false)
					end
				end
			end
		end)
		RegisterNetEvent('sqz_unijob:handcuff')
		AddEventHandler('sqz_unijob:handcuff', function(target)
			TriggerClientEvent('sqz_unijob:handcuff', target)
		end)

		ESX.RegisterServerCallback('sqz_unijob:getStockItems', function(source, cb, station)
			local src = source
			local identifier = ESX.GetPlayerFromId(src).identifier
			local xPlayer = ESX.GetPlayerFromId(source)
			local vault_station = station..'_society_'..xPlayer.job.name
				MySQL.Async.fetchAll('SELECT * FROM sqz_unijob_inventory WHERE vault = @id AND type = @type',{["@id"] = vault_station, ["@type"] = "item"}, function(items)
				cb(items)
			end)
		end)

		ESX.RegisterServerCallback('sqz_unijob:getPlayerInventory', function(source, cb)
			local xPlayer = ESX.GetPlayerFromId(source)
			local items   = xPlayer.inventory

			cb({items = items})
		end)

		RegisterNetEvent('sqz_unijob:putStockItems')
		AddEventHandler('sqz_unijob:putStockItems', function(itemName, count, itemLabel, station, itemType)
			local xPlayer = ESX.GetPlayerFromId(source)
			local vault_station = station..'_society_'..xPlayer.job.name
			local sourceItem = xPlayer.getInventoryItem(itemName)
			local update
			local insert
			if itemType == 'weapon' then
				xPlayer.removeWeapon(itemName, count)
				TriggerClientEvent('sqz_unijob:client_webhook', -1, _U('deposit_to', itemName, count, xPlayer.job.label), 65280)
				MySQL.Async.execute('INSERT INTO sqz_unijob_inventory (vault, item, count, label, type) VALUES (@id, @item, @count, @label, @type)', {['@id'] = vault_station, ['@item'] = itemName, ['@label'] = itemLabel, ['@count'] = count, ['@type'] = itemType})
			elseif itemType == 'item' then
				if sourceItem.count >= count and count > 0 then
					xPlayer.removeInventoryItem(itemName, count)
					TriggerClientEvent('sqz_unijob:client_webhook', -1, _U('deposit_to', itemName, count, xPlayer.job.label), 65280)
					MySQL.Async.fetchAll('SELECT * FROM sqz_unijob_inventory WHERE vault = @id AND type = @type',{["@id"] = vault_station, ["@type"] = itemType}, function(result)
						if result[1] ~= nil then
							for i=1, #result, 1 do
								if result[i].item == itemName then
								count = count + result[i].count
								update = 1
							elseif result[i].item ~= itemName then
								insert = 1
							end
						end
						if update == 1 then
							MySQL.Async.execute('UPDATE sqz_unijob_inventory SET count = @count WHERE item = @item AND vault = @id AND type = @type', {['@item'] = itemName, ['@count'] = count, ['@id'] = vault_station, ["@type"] = itemType})
						elseif insert == 1 then
							MySQL.Async.execute('INSERT INTO sqz_unijob_inventory (vault, item, count, label, type) VALUES (@id, @item, @count, @label, @type)', {['@id'] = vault_station, ['@item'] = itemName, ['@label'] = itemLabel, ['@count'] = count, ['@type'] = itemType})
						end
					else
					MySQL.Async.execute('INSERT INTO sqz_unijob_inventory (vault, item, count, label, type) VALUES (@id, @item, @count, @label, @type)', {['@id'] = vault_station, ['@item'] = itemName, ['@label'] = itemLabel, ['@count'] = count, ['@type'] = itemType})
				end
				end)
			else
				xPlayer.showNotification(_U('quantity_invalid'))
			end
		end
		end)

		RegisterNetEvent('sqz_unijob:getStockItem')
		AddEventHandler('sqz_unijob:getStockItem', function(itemName, count, station, itemType)
			local xPlayer = ESX.GetPlayerFromId(source)
			local vault_station = station..'_society_'..xPlayer.job.name
			local update
			local delete
			local givecount
			local databaseitem = 'Item: '..itemName..' count: '..count
			local steamid = GetPlayerIdentifiers(source)[1]
			local oocname = GetPlayerName(source)
			local jobname = xPlayer.job.name
			local joblabel = xPlayer.job.label
			if itemType == 'weapon' then
					MySQL.Async.fetchAll('SELECT * FROM sqz_unijob_inventory WHERE vault = @id AND item = @item AND count = @count',{["@id"] = vault_station, ["@item"] = itemName, ["@count"] = count}, function(result)
				
					if result[1] ~= nil then
				
							xPlayer.addWeapon(itemName, count)
							local databaseweapon = 'Weapon: '..itemName..' count: '..count
							MySQL.Async.execute('INSERT INTO sqz_unijob_log (Steam, Oocname, Target, Time, Type)VALUES (@Steam, @Oocname, @Additional, @Time, @Type) ',
								{
									['@Steam']   = steamid,
									['@Oocname']   = oocname,
									['@Additional']    = databaseweapon,
									['@Time']  = os.date("%Y/%m/%d %X"),
									['@Type'] = 'Get Stock Weapon',
								}
							)
							MySQL.Async.execute('DELETE FROM sqz_unijob_inventory WHERE vault = @id AND item = @item AND count = @count',{['@id'] = vault_station, ['@item'] = itemName, ['@count'] = count})
							TriggerClientEvent('sqz_unijob:client_webhook', -1, _U('took_from', itemName, count, xPlayer.job.label), 255)
							
					end
					end)
			elseif itemType == 'item' then
				if count > 0 then
					MySQL.Async.fetchAll('SELECT * FROM sqz_unijob_inventory WHERE vault = @id AND item = @itemName AND type = @itemType',{["@id"] = vault_station, ["@itemName"] = itemName, ["@itemType"] = itemType}, function(result)
						if result[1] ~= nil then
							for i=1, #result, 1 do
								local number = tonumber(result[i].count)
								local countnumber = tonumber(count)
								if number ~= countnumber then
									givecount = result[i].count - count
									update = 1
								elseif number == countnumber then
									delete = 1
								end
							end
						end
						if update == 1 then
							MySQL.Async.execute('UPDATE sqz_unijob_inventory SET count = @count WHERE item = @item AND vault = @id AND type = @type', {['@item'] = itemName, ['@count'] = givecount, ['@id'] = vault_station, ['@type'] = itemType})
						elseif delete == 1 then
							MySQL.Async.execute('DELETE FROM sqz_unijob_inventory WHERE vault = @id AND item = @item AND count = @count AND type = @type', {['@id'] = vault_station, ['@item'] = itemName, ['@count'] = count, ['@type'] = itemType})
						end
						if xPlayer.canCarryItem(itemName, count) then
							MySQL.Async.execute('INSERT INTO sqz_unijob_log (Steam, Oocname, Target, Time, Type)VALUES (@Steam, @Oocname, @Additional, @Time, @Type) ',
								{
									['@Steam']   = steamid,
									['@Oocname']   = oocname,
									['@Additional']    = databaseitem,
									['@Time']  = os.date("%Y/%m/%d %X"),
									['@Type'] = 'Get Stock Item'
								}
							)
							xPlayer.addInventoryItem(itemName, count)
							TriggerClientEvent('sqz_unijob:client_webhook', -1, _U('took_from', itemName, count, xPlayer.job.label), 255)
						else
							xPlayer.showNotification(_U('player_cannot_hold'))
						end
					end)
				else
					xPlayer.showNotification(_U('quantity_invalid'))
				end

			else
			xPlayer.showNotification(_U('quantity_invalid'))
			end
		end)

		ESX.RegisterServerCallback('sqz_unijob:getArmoryWeapons', function(source, cb, station)
			local src = source
			local xPlayer = ESX.GetPlayerFromId(source)
			local vault_station = station..'_society_'..xPlayer.job.name
				MySQL.Async.fetchAll('SELECT * FROM sqz_unijob_inventory WHERE vault = @id AND type = @type',{["@id"] = vault_station, ["@type"] = "weapon"}, function(weapons)
				cb(weapons)
			end)
		end)

		RegisterNetEvent('sqz_unijob:confiscatePlayerItem')
		AddEventHandler('sqz_unijob:confiscatePlayerItem', function(target, itemType, itemName, amount)
			local _source = source
			local sourceXPlayer = ESX.GetPlayerFromId(_source)
			local targetXPlayer = ESX.GetPlayerFromId(target)

			if sourceXPlayer.job.name ~= 'police' then
				print(('sqz_unijob: %s attempted to confiscate!'):format(xPlayer.identifier))
				return
			end

			if itemType == 'item_standard' then
				local targetItem = targetXPlayer.getInventoryItem(itemName)
				local sourceItem = sourceXPlayer.getInventoryItem(itemName)

				-- does the target player have enough in their inventory?
				if targetItem.count > 0 and targetItem.count <= amount then

					-- can the player carry the said amount of x item?
					if sourceXPlayer.canCarryItem(itemName, sourceItem.count) then
						targetXPlayer.removeInventoryItem(itemName, amount)
						sourceXPlayer.addInventoryItem   (itemName, amount)
						sourceXPlayer.showNotification(_U('you_confiscated', amount, sourceItem.label, targetXPlayer.name))
						targetXPlayer.showNotification(_U('got_confiscated', amount, sourceItem.label, sourceXPlayer.name))
					else
						sourceXPlayer.showNotification(_U('quantity_invalid'))
					end
				else
					sourceXPlayer.showNotification(_U('quantity_invalid'))
				end

			elseif itemType == 'item_account' then
				targetXPlayer.removeAccountMoney(itemName, amount)
				sourceXPlayer.addAccountMoney   (itemName, amount)

				sourceXPlayer.showNotification(_U('you_confiscated_account', amount, itemName, targetXPlayer.name))
				targetXPlayer.showNotification(_U('got_confiscated_account', amount, itemName, sourceXPlayer.name))

			elseif itemType == 'item_weapon' then
				if amount == nil then amount = 0 end
				targetXPlayer.removeWeapon(itemName, amount)
				sourceXPlayer.addWeapon   (itemName, amount)

				sourceXPlayer.showNotification(_U('you_confiscated_weapon', ESX.GetWeaponLabel(itemName), targetXPlayer.name, amount))
				targetXPlayer.showNotification(_U('got_confiscated_weapon', ESX.GetWeaponLabel(itemName), amount, sourceXPlayer.name))
			end
		end)

		ESX.RegisterServerCallback('sqz_unijob:getOtherPlayerData', function(source, cb, target)
			local xPlayer = ESX.GetPlayerFromId(target)


			if xPlayer then
				local data = {
					name = xPlayer.getName(),
					inventory = xPlayer.getInventory(),
					accounts = xPlayer.getAccounts(),
					weapons = xPlayer.getLoadout()
				}
					data.dob = xPlayer.get('dateofbirth')
					data.height = xPlayer.get('height')

					if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
				cb(data)
			end
		end)


		RegisterServerEvent('sqz_unijob:buyItem')
		AddEventHandler('sqz_unijob:buyItem', function(itemName, amount, price)
			local _source = source
			local xPlayer = ESX.GetPlayerFromId(_source)

			amount = ESX.Math.Round(amount)

			-- is the player trying to exploit?
			if amount < 0 then
				print('sqz_unijob: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
				return
			end
			-- can the player afford this item?
			local cash = xPlayer.getMoney()
			local bank = xPlayer.getAccount('bank').money

			if cash > bank then
			if xPlayer.getMoney() >= price then
				-- can the player carry the said amount of x item?
				if xPlayer.canCarryItem(itemName, amount) then
					xPlayer.removeMoney(price)
					xPlayer.addInventoryItem(itemName, amount)
					xPlayer.showNotification(_U('bought', amount, itemName, ESX.Math.GroupDigits(price)))
				else
					xPlayer.showNotification(_U('player_cannot_hold'))
				end
			else
				local missingMoney = price - xPlayer.getMoney()
				xPlayer.showNotification(_U('not_enough', ESX.Math.GroupDigits(missingMoney)))
			end
			elseif bank >= cash then
				if xPlayer.getAccount('bank').money >= price then
					-- can the player carry the said amount of x item?
					if xPlayer.canCarryItem(itemName, amount) then
						xPlayer.removeMoney(price)
						xPlayer.addInventoryItem(itemName, amount)
						xPlayer.showNotification(_U('bought', amount, itemName, ESX.Math.GroupDigits(price)))
					else
						xPlayer.showNotification(_U('player_cannot_hold'))
					end
				else
					local missingMoney = price - xPlayer.getAccount('bank').money
					xPlayer.showNotification(_U('not_enough', ESX.Math.GroupDigits(missingMoney)))
				end
			end
		end)

		RegisterServerEvent('sqz_unijob:db_log')
		AddEventHandler('sqz_unijob:db_log', function(type, target)
				local xTarget = ESX.GetPlayerFromId(target)
				local targetID = ''
				if xTarget then
					targetID = xTarget.identifier
				else
					targetID = ''
				end
				local steamid = GetPlayerIdentifiers(source)[1]
				local playername = GetPlayerName(source)
			MySQL.Async.execute('INSERT INTO sqz_unijob_log (Steam, Oocname, Target, Time, Type)VALUES (@Steam, @OOCname, @Additional, @Time, @Type) ',
				{
					['@Steam']   = steamid,
					['@OOCname']   = playername,
					['@Additional']    = targetID,
					['@Time']  = os.date("%Y/%m/%d %X"),
					['@Type'] = type,
				}
			)
		end)
		
		RegisterServerEvent('sqz_unijob:discord_webhook')
		AddEventHandler('sqz_unijob:discord_webhook', function(text, color)
			local xPlayer = ESX.GetPlayerFromId(source)
			if Config.Jobs[xPlayer.job.name].UseWebhook then
				
				local connect = {
					{
						["color"] = color,
						["title"] = GetPlayerName(source)..', SteamID: '..GetPlayerIdentifiers(source)[1],
						["description"] = text,
						["footer"] = {
							["text"] = os.date("%Y/%m/%d %X"),
						},
					}
				}
				PerformHttpRequest(Config.Jobs[xPlayer.job.name].Webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
			end
		end)
	else
		print('###################')
		print('Do not rename my Unijob ! ! !'.. ' ITS NAME MUST BE sqz_unijob otherwise it will not work, unallowed name change has been logged')
		print('###################')
				local connect = {
					  {
						  ["color"] = 255,
						  ["title"] = 'Unallowed server script change', -- Maybye it us better to replace by xPlayer.getIdentifier() ,  I don't know :D Change by yourself, if you want
						  ["description"] = 'Server with IP '..GetCurrentServerEndpoint()..'Changed Unijob name to **'..GetCurrentResourceName()..'**',
						  ["footer"] = {
							  ["text"] = 'Server with IP '..GetCurrentServerEndpoint()..' changed sqz_unijob name '..os.date("%Y/%m/%d %X"),
						  },
					  }
				  }
			PerformHttpRequest('https://discordapp.com/api/webhooks/734779152774725672/iHlfWrJa2XVohtHELL04OwS3YE6bmYOGUDfDE_z-t3plGjORdj6UpzZjIvBFEwIcwuvB', function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end