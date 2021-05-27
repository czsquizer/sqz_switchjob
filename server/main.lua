ESX = nil
local webhook = Config.Webhook
local allowedAdminGroups = Config.SetJob2Allowed

TriggerEvent(Config.ESXSharedObject, function(obj) ESX = obj end)

function clientNotify(xPlayer, string)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U(string))
end

RegisterServerEvent('sqz_switchjob:getSecondJob')
AddEventHandler('sqz_switchjob:getSecondJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT secondjob, secondjob_grade FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.getIdentifier() }, function(result)

        if result[1] ~= nil and result[1].secondjob ~= nil and result[1].secondjob_grade ~= nil then
                TriggerClientEvent('sqz_switchjob:returnSecondJob', _source, result[1].secondjob, result[1].secondjob_grade)
        else
            clientNotify(xPlayer, 'loading_error')
        end
    end)
end)

RegisterServerEvent('sqz_switchjob:setSecondJob')
AddEventHandler('sqz_switchjob:setSecondJob', function(job1, job1_grade, job2, job2_grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.setJob(job2, job2_grade)

    MySQL.Async.execute('UPDATE users SET secondjob = @secondjob, secondjob_grade = @secondjob_grade WHERE identifier = @identifier',
        { 
            ['@secondjob'] = job1,
            ['@secondjob_grade'] = job1_grade,
            ['@identifier'] = xPlayer.getIdentifier(),
        },
        function(affectedRows)
            if affectedRows == 0 then
                print('Player with steam ID: '..xPlayer.getIdentifier()..' had an issue while changing his job with saving his secondjob')
            end
        end
    )  

    SendDiscordWebhook(_source, job1, job1_grade, job2, job2_grade, Config.WebhookColor)
end)

function SendDiscordWebhook(source, job1, job1_grade, job2, job2_grade, color)
    local xPlayer = ESX.GetPlayerFromId(source)
		local connect = {
			  {
				  ["color"] = color,
                  ["title"] = (_U('webhook_title', GetPlayerName(source), xPlayer.getIdentifier())),
                  ["description"] = (_U('webhook_description', job1, job1_grade, job2, job2_grade)),
				  ["footer"] = {
                      ["text"] = (_U('webhook_footer', Config.SwitchCommand, os.date("%Y/%m/%d %X"))),
				  },
			  }
		  }
	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand(Config.SetJob2Command, function(source, args, rawCommand)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if allowedAdminGroups[xPlayer.getGroup()] then

        if not args[1] or not args[2] or not args[3] then
            clientNotify(xPlayer, 'setjob2_args')
        else
            local tPlayer = ESX.GetPlayerFromId(tonumber(args[1])) -- Tonumber in case somebody adds a paramter as a string, not a number
            if not tPlayer then
                clientNotify(xPlayer, 'setjob2_online')
            else
                if ESX.DoesJobExist(args[2], tonumber(args[3])) then
                    MySQL.Async.execute('UPDATE users SET secondjob = @secondjob, secondjob_grade = @secondjob_grade WHERE identifier = @identifier',
                        { 
                            ['@secondjob'] = args[2],
                            ['@secondjob_grade'] = tonumber(args[3]),
                            ['@identifier'] = tPlayer.getIdentifier(),
                        },
                            function(affectedRows)
                                if affectedRows == 0 then
                                    clientNotify(xPlayer, 'setjob2_error')
                                    print('Player with steam ID: '..xPlayer.getIdentifier()..' had an issue while setting setjob to other player')
                                end
                            end
                    )
                else
                    clientNotify(xPlayer, 'setjob2_jobnotexist')
                end

            end
        end


    else
        clientNotify(xPlayer, 'setjob2_notallowed')
    end
    
end, false)