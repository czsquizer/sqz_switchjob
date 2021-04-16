ESX = nil
local job1, job2
local job1_grade, job2_grade
local timer = 0
local sleepThread = 1000
local allowCommand = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterCommand("changejob", function (src, args, raw)
    if timer == 0 and allowCommand then
        TriggerServerEvent('sqz_switchjob:getSecondJob')
        timer = 30
        allowCommand = false
    else
        ESX.ShowNotification('You have to wait 30 seconds between switching jobs, now you have to wait: (time in seconds) '..timer) -- Here you can change whatewer you want
    end
end, false)

RegisterNetEvent('sqz_switchjob:returnSecondJob')
AddEventHandler('sqz_switchjob:returnSecondJob', function(secondjob, secondjob_grade)
    job2 = secondjob
    job2_grade = secondjob_grade
    job1 = ESX.PlayerData.job.name
    job1_grade = ESX.PlayerData.job.grade
    TriggerServerEvent('sqz_switchjob:setSecondJob', job1, job1_grade, job2, job2_grade)
    ESX.ShowNotification('You have changed your jobs.') -- Here you can change whatewer you want
    Wait(5000)
    ESX.ShowNotification('Your current job is: '..ESX.PlayerData.job.label..' and Your job grade is: '..ESX.PlayerData.job.grade_label) -- Here you can change whatewer you want
end)

Citizen.CreateThread(function()
    
    while true do
        if timer > 1 then
            timer = timer-1  
        elseif timer == 1 then
            allowCommand = true
            timer = 0
        end
        Citizen.Wait(sleepThread)
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-- Add sugestion for /setjob2 command

TriggerEvent('chat:addSuggestion', '/setjob2', 'Sets players second job', {
    { name="playerID", help="The server ID of player you want to change his second job" },
    { name="jobname", help="The job name of job you want to set for a player" },
    { name="jobgrade", help="The job grade of job you want to set for a player" }
})


Citizen.CreateThread(function()

	Wait(15000)
	local scripts = {
		"sqz_unijob",
		"scb_rpmenu",
		"sqz_drugs"
	}

	for k, v in pairs(scripts) do

		if GetResourceState(v) == 'started' then
			break
		end

		if GetResourceState(v) == 'missing' or GetResourceState(v) == 'unknown' or GetResourceState(v) == 'uninitialized' then

			local printData = [[                                                                                    _                         _       _
	  \ \   / /        ( )                    (_)       (_)                                                        | |               (_)     | |     | |
	   \ \_/ /__  _   _|/ _ __ ___   _ __ ___  _ ___ ___ _ _ __   __ _   ___  ___  _ __ ___   ___    ___ ___   ___ | |  ___  ___ _ __ _ _ __ | |_ ___| |
		\   / _ \| | | | | '__/ _ \ | '_ ` _ \| / __/ __| | '_ \ / _` | / __|/ _ \| '_ ` _ \ / _ \  / __/ _ \ / _ \| | / __|/ __| '__| | '_ \| __/ __| |
		 | | (_) | |_| | | | |  __/ | | | | | | \__ \__ \ | | | | (_| | \__ \ (_) | | | | | |  __/ | (_| (_) | (_) | | \__ \ (__| |  | | |_) | |_\__ \_|
		 |_|\___/ \__,_| |_|  \___| |_| |_| |_|_|___/___/_|_| |_|\__, | |___/\___/|_| |_| |_|\___|  \___\___/ \___/|_| |___/\___|_|  |_| .__/ \__|___(_)
																__/ |                                                                | |              
																|___/                                                                 |_|              

		 _____      _                                        _   _   _                                                       _______   _                 
		/ ____|    | |                                     / _| | | | |                                                     |__   __| | |                
		| |  __  ___| |_   ___  ___  _ __ ___   ___    ___ | |_  | |_| |__   ___ _ __ ___     ___  _ __     ___  _   _ _ __     | | ___| |__   _____  __  
		| | |_ |/ _ \ __| / __|/ _ \| '_ ` _ \ / _ \  / _ \|  _| | __| '_ \ / _ \ '_ ` _ \   / _ \| '_ \   / _ \| | | | '__|    | |/ _ \ '_ \ / _ \ \/ /  
		| |__| |  __/ |_  \__ \ (_) | | | | | |  __/ | (_) | |   | |_| | | |  __/ | | | | | | (_) | | | | | (_) | |_| | |       | |  __/ |_) |  __/>  < _ 
		\_____|\___|\__| |___/\___/|_| |_| |_|\___|  \___/|_|    \__|_| |_|\___|_| |_| |_|  \___/|_| |_|  \___/ \__,_|_|       |_|\___|_.__/ \___/_/\_(_)
																																																				
			███████╗ ██████╗ ███████╗        ██╗   ██╗███╗   ██╗██╗     ██╗ ██████╗ ██████╗ 
			██╔════╝██╔═══██╗╚══███╔╝        ██║   ██║████╗  ██║██║     ██║██╔═══██╗██╔══██╗
			███████╗██║   ██║  ███╔╝         ██║   ██║██╔██╗ ██║██║     ██║██║   ██║██████╔╝
			╚════██║██║▄▄ ██║ ███╔╝          ██║   ██║██║╚██╗██║██║██   ██║██║   ██║██╔══██╗
			███████║╚██████╔╝███████╗███████╗╚██████╔╝██║ ╚████║██║╚█████╔╝╚██████╔╝██████╔╝
			╚══════╝ ╚══▀▀═╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚════╝  ╚═════╝ ╚═════╝ 

			███████╗ ██████╗ ███████╗        ██████╗ ██████╗ ██╗   ██╗ ██████╗ ███████╗
			██╔════╝██╔═══██╗╚══███╔╝        ██╔══██╗██╔══██╗██║   ██║██╔════╝ ██╔════╝
			███████╗██║   ██║  ███╔╝         ██║  ██║██████╔╝██║   ██║██║  ███╗███████╗
			╚════██║██║▄▄ ██║ ███╔╝          ██║  ██║██╔══██╗██║   ██║██║   ██║╚════██║
			███████║╚██████╔╝███████╗███████╗██████╔╝██║  ██║╚██████╔╝╚██████╔╝███████║
			╚══════╝ ╚══▀▀═╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝

			███████╗ ██████╗██████╗         ██████╗ ██████╗ ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
			██╔════╝██╔════╝██╔══██╗        ██╔══██╗██╔══██╗████╗ ████║██╔════╝████╗  ██║██║   ██║
			███████╗██║     ██████╔╝        ██████╔╝██████╔╝██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
			╚════██║██║     ██╔══██╗        ██╔══██╗██╔═══╝ ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
			███████║╚██████╗██████╔╝███████╗██║  ██║██║     ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
			╚══════╝ ╚═════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
											
									sqz.tebex.io

					Scripts made by Squizer#3020 and Scoobiik#9981
			]]
			print(printData)
			break
		end

	end


end)