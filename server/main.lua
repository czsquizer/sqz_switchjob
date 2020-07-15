ESX = nil
local webhook = '' -- Change it to your likings :)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('sqz_switchjob:getSecondJob')
AddEventHandler('sqz_switchjob:getSecondJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT secondjob, secondjob_grade FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.getIdentifier() }, function(result)

        if result[1] ~= nil and result[1].secondjob ~= nil and result[1].secondjob_grade ~= nil then
                TriggerClientEvent('sqz_switchjob:returnSecondJob', _source, result[1].secondjob, result[1].secondjob_grade)
        else
            xPlayer.showNotification('There was an error while loading your second job from database')
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

    SendDiscordWebhook(_source, job1, job1_grade, job2, job2_grade, 255)
end)

function SendDiscordWebhook(source, job1, job1_grade, job2, job2_grade, color)
    local xPlayer = ESX.GetPlayerFromId(source)
		local connect = {
			  {
				  ["color"] = color,
				  ["title"] = GetPlayerName(source)..', SteamID: '..xPlayer.getIdentifier(), -- Maybye it us better to replace by xPlayer.getIdentifier() ,  I don't know :D Change by yourself, if you want
				  ["description"] = 'This player has changed his job **FROM**: '..job1..' with grade: '..job1_grade..' **TO**: '..job2.. ' with grade '..job2_grade,
				  ["footer"] = {
					  ["text"] = 'sqz_switchjob, job change using command /changejob '..os.date("%Y/%m/%d %X"),
				  },
			  }
		  }
	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end