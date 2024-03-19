pkszTHsv = {}
if isClient() then return end

pkszTHsv.nextEventDebug = false
pkszTHsv.nextEventID = "foodaid"
pkszTHsv.nextEventCoordinate = "13069,1207,0,1,None,2F Reading room"
-- "13069,1207,0,1,None,2F Reading room"


pkszTHsv.EventFileVer = "pkszTHv202403"
pkszTHsv.EventFileVerOpt = 1

pkszTHsv.Events = {}
pkszTHsv.EventIDs = {}
pkszTHsv.EventNum = 0

pkszTHsv.CordinateList = {}
pkszTHsv.loadOut = {}
pkszTHsv.loadOutRandom = {}
pkszTHsv.loadOutRandomIndex = {}
pkszTHsv.loadOutRandomIndexCnt = 1
pkszTHsv.loadOutDebug = {}
pkszTHsv.autoCategorys = {}

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
pkszTHsv.curEvent.objBag = nil
pkszTHsv.curEvent.zedSquare = nil
pkszTHsv.curEvent.eventNote = ""
pkszTHsv.curEvent.epics = nil

pkszTHsv.restart = function()

	pkszTHsv.initialize = 1

	pkszTHsv.Events = {}
	pkszTHsv.EventIDs = {}

	pkszTHsv.CordinateList = {}
	pkszTHsv.loadOut = {}
	pkszTHsv.loadOutRandom = {}
	pkszTHsv.loadOutRandomGP = {}
	pkszTHsv.zedOutfitGrp = {}
	pkszTHsv.autoCategorys = {}

	pkszTHsv.Client = {}
	pkszTHsv.Progress = 0
	pkszTHsv.Phase = 0
	pkszTHsv.mainTick = 0


	pkszTHsv.eventFileVersions = {"pkszTHv202403","pkszTHvE202403"}

	pkszTHsv.Settings.eventStartChance = SandboxVars.pkszTHopt.eventStartChance;
	pkszTHsv.Settings.eventStartWaitTick = SandboxVars.pkszTHopt.eventStartWaitTick;

	pkszTHsetup.ready()

	pkszTHsv.Settings.logFilename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.history;
	pkszTHsv.Settings.historyFilename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.log;

	-- event file check
	pkszTHsetup.eventFileCheck()

	if pkszTHsv.forceSuspend == true then
		return
	end

	pkszTHsv.logger("-- Log files are now available --",false)
	if SandboxVars.pkszTHopt.eventLogDivision == true then
		pkszTHsv.logger("Log output mode = pkszTH and console",false)
	else
		pkszTHsv.logger("Log output mode = Only pkszTH",false)
	end



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
		local rec = pkszTHsv.strSplit(val,"=")
		if #rec == 2 then
			local key = string.gsub(rec[1], "^%s*(.-)%s*$", "%1")
			local value = string.gsub(rec[2], "^%s*(.-)%s*$", "%1")
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
	if SandboxVars.pkszTHopt.eventLogDivision == true then
		print(thisStr);
	end

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
