pkszEpic = {}

----------------------------------
pkszEpic.fileVer = "pkszEpic"
----------------------------------

pkszEpic.nameListFileName = "nameList.txt"

pkszEpic.initialize = 0
pkszEpic.nameList = {}
pkszEpic.settings = {}

pkszEpic.baseDir = ""
pkszEpic.settings.logFilename = ""

pkszEpic.settings.SpecImproveMultiplierMin = 0.1
pkszEpic.settings.SpecImproveMultiplierMax = 0.1
pkszEpic.settings.weightReduction = 0.1
pkszEpic.settings.ApplyToBags = false
pkszEpic.settings.weaponsGlow = true

pkszEpic.restart = function()

	-- if pkszEpicCli.isClientForce == false then
	-- 	pkszEpicSetup.fileDeployOnly()
	-- 	return
	-- end

	-- if isClient() then return end

	print("pkszEpic -- restart --")
	pkszEpic.initialize = 1
	pkszEpic.settings.logFilename = "_log.txt"

	pkszEpic.baseDir = "/" .. pkszEpic.fileVer

	pkszEpic.settings.logFilename = pkszEpic.baseDir.."/"..pkszEpic.settings.logFilename

	pkszEpic.nameList = {}
	pkszEpicSetup.ready()

end
Events.OnGameBoot.Add(pkszEpic.restart)


pkszEpic.logger = function(msg,mode)

	if isClient() then
		-- server‚É”ò‚Î‚·
		sendClientCommand(player, "pkszEpic", "logging", {msg,mode});
	end


    local gameTimeNow = pkszEpic.getGameTime()
	local thisStr = "pkszEpic : " .. gameTimeNow .. " / " .. msg ;
	-- if SandboxVars.pkszTHopt.eventLogDivision == true then
	print(thisStr);
	-- end

	if str then
		local dataFile = getFileWriter(pkszEpic.settings.logFilename, true, mode);
		dataFile:write(thisStr .. "\n");
		dataFile:close();
	end
end

pkszEpic.getGameTime = function()
    local y = getGameTime():getYear();
    local m = getGameTime():getMonth() + 1;
    local d = getGameTime():getDay() + 1;
    local h = getGameTime():getHour();
    local n = getGameTime():getMinutes();
    local gameTimeNow = string.format("%04d-%02d-%02d %02d:%02d", y, m, d, h, n);
	return gameTimeNow
end
