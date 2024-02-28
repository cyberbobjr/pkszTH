pkszTHsv = {}
if isClient() then return end

pkszTHsv.EventFileVer = "pkszTHv20240227"

pkszTHsv.Events = {}
pkszTHsv.EventIDs = {}
pkszTHsv.EventNum = 0

pkszTHsv.CordinateList = {}
pkszTHsv.loadOut = {}
pkszTHsv.loadOutRandom = {}
pkszTHsv.loadOutRandomIndex = {}
pkszTHsv.loadOutRandomIndexCnt = 1
pkszTHsv.loadOutDebug = {}

pkszTHsv.forceSuspend = false

pkszTHsv.Progress = 0

-- init (initial)
-- wait (wait next event)
-- notice (send message to pager)
-- open (event progress)
-- enter (player enter)
-- close (cleaning)
pkszTHsv.Phase = "init"


pkszTHsv.mainTick = 0

pkszTHsv.initialize = 0
pkszTHsv.Settings = {}

pkszTHsv.curEvent = {}
pkszTHsv.curEvent.massege = {}
pkszTHsv.curEvent.massege[1] = "empty"
pkszTHsv.curEvent.massege[2] = ""
pkszTHsv.curEvent.massege[3] = ""
pkszTHsv.curEvent.phase = "init"
pkszTHsv.curEvent.lootZedId = 0
pkszTHsv.curEvent.objBag = nil
pkszTHsv.curEvent.zedSquare = nil


pkszTHsv.restart = function()

	pkszTHsv.initialize = 1

	pkszTHsv.Events = {}
	pkszTHsv.EventIDs = {}

	pkszTHsv.CordinateList = {}
	pkszTHsv.loadOut = {}
	pkszTHsv.loadOutRandom = {}
	pkszTHsv.loadOutRandomGP = {}
	pkszTHsv.zedOutfitGrp = {}

	pkszTHsv.Client = {}
	pkszTHsv.Progress = 0
	pkszTHsv.Phase = 0
	pkszTHsv.mainTick = 0

	pkszTHsv.Settings.eventStartChance = SandboxVars.pkszTHopt.eventStartChance;
	pkszTHsv.Settings.eventStartWaitTick = SandboxVars.pkszTHopt.eventStartWaitTick;



	-- event file check
	pkszTHsetup.eventFileCheck()

	pkszTHsv.Settings.logFilename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.history;
	pkszTHsv.Settings.historyFilename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.log;

	if pkszTHsv.forceSuspend == true then
		return
	end

	pkszTHsv.logger("-- Log files are now available --",false)

	-- event File Loader
	pkszTHsetup.eventFileLoader()


	pkszTHsv.logger("-- restart --",true)

	-- end

end
Events.OnGameBoot.Add(pkszTHsv.restart)


pkszTHsv.getRandomGPLineSplit = function(rec)

	local ary = pkszTHsv.strSplit(rec,";")
	local cnt = 1
	local result = {}
	for no,val in pairs(ary) do
		for key, value in string.gmatch(val, "([%w%.%_]+) *= *(.+)") do
			result[cnt] = {item=key,num=value}
		end
		cnt = cnt + 1
	end
	return result

end

pkszTHsv.getGameTime = function()
    local y = getGameTime():getYear();
    local m = getGameTime():getMonth() + 1;
    local d = getGameTime():getDay() + 1;
    local h = getGameTime():getHour();
    local n = getGameTime():getMinutes();
    local gameTimeNow = string.format("%04d-%02d-%02d %02d:%02d", y, m, d, h, n);
	return gameTimeNow
end

pkszTHsv.logger = function(msg,mode)

    local gameTimeNow = pkszTHsv.getGameTime()

	local thisStr = "pkszTH - server : " .. pkszTHsv.mainTick .. " / " .. gameTimeNow .. " / " .. msg ;
	print(thisStr);

	local dataFile = getFileWriter(pkszTHsv.Settings.logFilename, true, mode);
	dataFile:write(thisStr .. "\n");
	dataFile:close();
end

pkszTHsv.errorhandling = function(msg,force)

	pkszTHsv.forceSuspend = force
	print("pkszTH - server ERROR : " ..msg)
	if force then
		print("pkszTH - server ERROR : This error is fatal, mod process to be force suspend.")
	end
	pkszTHmain.dataConnect('forceSuspend')

end

pkszTHsv.tableMonitor = function(tbl)

	print("--- tableMonitor ---------");

	local cnt = 1
	for key, value in pairs(tbl) do
		print(cnt.. " : key = " .. key .. " val = " .. value);
		cnt = cnt + 1
	end

end

pkszTHsv.strSplit = function(str, ts)
	if ts == nil then return {} end
	local t = {}
	local i = 1
	for s in string.gmatch(str, "([^"..ts.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end

pkszTHsv.merge_tables = function(t1, t2)
    local merged = {}
    for _, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for _, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end
