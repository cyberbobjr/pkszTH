pkszEpic = {}
if isClient() then return end

----------------------------------
pkszEpic.fileVer = "pkszEpic"
----------------------------------
pkszEpic.nameListFileName = "nameList.txt"
pkszEpic.fn = {}
pkszEpic.fn.historyFileName = "_history.txt"
pkszEpic.fn.logFileName = "_log.txt"

pkszEpic.forceSuspend = false

pkszEpic.initialize = 0
pkszEpic.nameList = {}

pkszEpic.baseDir = ""

pkszEpic.settings = {}
pkszEpic.settings.Disabled = false
pkszEpic.settings.AdminEpicConvert = false
pkszEpic.settings.SpecImproveMultiplierMin = 10
pkszEpic.settings.SpecImproveMultiplierMax = 15
pkszEpic.settings.weightReduction = 2
pkszEpic.settings.ApplyToBags = false

pkszEpic.restart = function()
	pkszEpic.initialize = 1
	pkszEpic.logger("pkszEpic -- restart --",false)

	pkszEpic.baseDir = "/" .. pkszEpic.fileVer
	pkszEpic.logFileName = pkszEpic.baseDir.."/"..pkszEpic.fn.logFileName
	pkszEpic.historyFileName = pkszEpic.baseDir.."/"..pkszEpic.fn.historyFileName

	-- file setup
	pkszEpicSetup.ready()
	if pkszEpicGetSandboxVars() then
		pkszEpicDataConnect("sendSandboxVars",pkszEpic.settings)
	end

end
Events.OnGameStart.Add(pkszEpic.restart)

pkszEpic.BuildLogText= function(logText,title,param)
	return logText..title.." / "..param.." | "
end

pkszEpic.logger = function(msg,mode)

    local gameTimeNow = pkszEpic.getGameTime()
	local thisStr = "pkszEpic : " .. gameTimeNow .. " / " .. msg ;

	if thisStr then
		print(thisStr);
		local dataFile = getFileWriter(pkszEpic.logFileName, true, true);
		dataFile:write(thisStr .. "\n");
		dataFile:close();
	end

end

pkszEpic.history = function(msg,mode)

    local gameTimeNow = pkszEpic.getGameTime()
	local thisStr = "pkszEpic : " .. gameTimeNow .. " / " .. msg ;

	if thisStr then
		print(thisStr);
		local dataFile = getFileWriter(pkszEpic.historyFileName, true, mode);
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

pkszEpic.StrSplit = function(str, ts)
	if ts == nil then return {} end
	local t = {}
	local i = 1
	for s in string.gmatch(str, "([^"..ts.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end
