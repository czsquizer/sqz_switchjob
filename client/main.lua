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

exports('GetJobs', function()
    return { job = job1, grade = job1_grade }, { job = job2, grade = job2_grade }
end)
