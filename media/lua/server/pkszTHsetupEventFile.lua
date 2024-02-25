pkszTHsetup = {}

-- under develop now
pkszTHsetup.loadEventMods = function()

	local file = getFileReader(pkszTHsv.Settings.eventModsFilename, true)
	if not file then
		pkszTHsv.logger("Events file not found "..pkszTHsv.Settings.eventModsFilename,false)
		pkszTHsv.forceSuspend = true
		return
	end

--	if ActiveMods.getById("currentGame"):isModActive("KuromiBackpack") then
--	else

end

-- under develop now
pkszTHsetup.proc = function()

	print("pkszTHsetup.proc")


end