Config = {}
Config.Locale = 'en'
Config.SetJob2Allowed = { -- Here you can add more groups, which will be allowed to you /setjob2 command, do not forget to add comma .
    ["superadmin"] = true,
    ["admin"] = true
}
Config.Webhook = '' -- Put a discord webhook for the log here.
Config.WebhookColor = '255'
Config.ESXSharedObject = 'esx:getSharedObject' -- Some servers have an anticheat that modifies the esx:getSharedObject trigger. You can change it here.
Config.SwitchCommand = 'changejob' -- Here you can change command name.
Config.SetJob2Command = 'setjob2' -- Here you can change admin command name for changing player's second job.