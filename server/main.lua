ESX = nil
local webhook = '' -- Change it to your likings :)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('sqz_switchjob:getSecondJob')
AddEventHandler('sqz_switchjob:getSecondJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT secondjob, secondjob_grade FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.getIdentifier() }, function(result)

        Wait(100)
        TriggerClientEvent('sqz_switchjob:returnSecondJob', _source, result[1].secondjob, result[1].secondjob_grade)
    end)
end)

RegisterServerEvent('sqz_switchjob:setSecondJob')
AddEventHandler('sqz_switchjob:setSecondJob', function(job1, job1_grade, job2, job2_grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.setJob(job2, job2_grade)
    Wait(100) 
    MySQL.Async.execute('UPDATE users SET secondjob = @secondjob WHERE identifier = @identifier',
        { 
            ['@secondjob'] = job1,
            ['@identifier'] = xPlayer.getIdentifier(),
        },
        function(affectedRows)
            if affectedRows == 0 then
                print('Player with steam ID: '..xPlayer.getIdentifier()..' tried to exploit switchjob system (job_name)')
            end
        end
    )  
    Wait(100) 
    MySQL.Async.execute('UPDATE users SET secondjob_grade = @secondjob_grade WHERE identifier = @identifier',
    { 
        ['@secondjob_grade'] = job1_grade,
        ['@identifier'] = xPlayer.getIdentifier(),
    },
    function(affectedRows)
        if affectedRows == 0 then
            print('Player with steam ID: '..xPlayer.getIdentifier()..' tried to exploit switchjob system (job_grade)')
        end
    end
    )
    Wait(100)

    TriggerClientEvent('sqz_switchjob:client_webhook', _source, job1, job1_grade, job2, job2_grade, 255)

    ESX.SavePlayer(xPlayer) 
end)

RegisterServerEvent('sqz_switchjob:discord_webhook')
AddEventHandler('sqz_switchjob:discord_webhook', function(job1, job1_grade, job2, job2_grade, color)
		local connect = {
			  {
				  ["color"] = color,
				  ["title"] = GetPlayerName(source)..', SteamID: '..GetPlayerIdentifiers(source)[1], -- Maybye it us better to replace by xPlayer.getIdentifier() ,  I don't know :D Change by yourself, if you want
				  ["description"] = 'This player has changed his job **FROM**: '..job1..' with grade: '..job1_grade..' **TO**: '..job2.. ' with grade '..job2_grade,
				  ["footer"] = {
					  ["text"] = 'sqz_switchjob, job change using command /changejob '..os.date("%Y/%m/%d %X"),
				  },
			  }
		  }
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end)