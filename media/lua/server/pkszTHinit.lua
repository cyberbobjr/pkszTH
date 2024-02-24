pkszTHsv = {}
if isClient() then return end

pkszTHsv.Events = {}
pkszTHsv.EventIDs = {}
pkszTHsv.EventNum = 0

pkszTHsv.CordinateList = {}
pkszTHsv.loadOut = {}
pkszTHsv.loadOutRandom = {}
pkszTHsv.loadOutRandomIndex = {}
pkszTHsv.loadOutRandomIndexCnt = 1
pkszTHsv.loadOutDebug = {}

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

local SettingsValidator = {}
SettingsValidator.eventId = "string"
SettingsValidator.eventDescription = "string"
SettingsValidator.eventTimeout = "integer"
SettingsValidator.HordeDensity = "integer"
SettingsValidator.HordeRadius = "integer"
SettingsValidator.InventoryItem = "string"
SettingsValidator.loadOutSelectCD = "string"
SettingsValidator.cordListSelectCD = "string"
SettingsValidator.leaderOutfit = "string"

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

	pkszTHsv.Settings.eventFilename = "/pkszTh/vanilla/event.txt";
	pkszTHsv.Settings.cordlistFilename = "/pkszTh/vanilla/cordinates.txt";
	pkszTHsv.Settings.loadoutFilename = "/pkszTh/vanilla/loadOut.txt";
	pkszTHsv.Settings.loadoutRandomFilename = "/pkszTh/vanilla/loadOutRandom.txt";
	pkszTHsv.Settings.loadoutRandomGPFilename = "/pkszTh/vanilla/loadOutRandomGP.txt";
	pkszTHsv.Settings.zedOutfitGrpFilename = "/pkszTh/vanilla/zedOutfitGrp.txt";

	pkszTHsv.Settings.logFilename = "/pkszTh/log.txt";
	pkszTHsv.Settings.historyFilename = "/pkszTh/history.txt";


	-- getEvents
	pkszTHsv.getEvents()
	pkszTHsv.logger("Events count "..pkszTHsv.EventNum,false)

	-- getCordList
	pkszTHsv.getCordList()

	-- getLoadOut
	pkszTHsv.getLoadOut()
	pkszTHsv.getLoadOutRandom()
	pkszTHsv.getLoadOutRandomGP()

	-- getLoadZedOutfitGrp
	pkszTHsv.getLoadZedOutfitGrp()
	-- logger restart
	pkszTHsv.logger("-- restart --",false)

	-- end

end
Events.OnGameBoot.Add(pkszTHsv.restart)


pkszTHsv.getEvents = function()

	local temp = {}
	local eventID = ""
	local cnt = 1

	local file = getFileReader(pkszTHsv.Settings.eventFilename, true)
	if not file then
		pkszTHsv.logger("Events file not found "..pkszTHsv.Settings.eventFilenam,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
        for key, value in string.gmatch(line, "(%w+) *= *(.+)") do
			if key == "eventID" then
				pkszTHsv.EventNum = cnt
				eventID = value
				pkszTHsv.Events[eventID] = {}
				pkszTHsv.EventIDs[cnt] = eventID
				cnt = cnt + 1
			else
				pkszTHsv.Events[eventID][key] = value
			end
		end
    until true end
end

pkszTHsv.getCordList = function()

	local cordCD = ""
	local cnt = 1

	local file = getFileReader(pkszTHsv.Settings.cordlistFilename, true)
	if not file then
		pkszTHsv.logger("cordlist file not found "..pkszTHsv.Settings.cordlistFilename,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
		if string.sub(line, 1, 10) == "cordListCD" then
	        for key, value in string.gmatch(line, "(%w+) *= *(.+)") do
				cordCD = value
				pkszTHsv.CordinateList[cordCD] = {}
				cnt = 1
			end
		else
			pkszTHsv.CordinateList[cordCD][cnt] = line
			cnt = cnt + 1
		end


    until true end
end

pkszTHsv.getLoadOut = function()

	local temp = {}
	local loadoutID = ""
	local cnt = 1
	local file = getFileReader(pkszTHsv.Settings.loadoutFilename, true)
	if not file then
		pkszTHsv.logger("LoadOut file not found "..pkszTHsv.Settings.loadoutFilename,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
        for key, value in string.gmatch(line, "([%w%.%_]+) *= *(.+)") do
			if key == "loadOutCD" then
				loadoutID = value
				pkszTHsv.loadOut[loadoutID] = {}
				cnt = 1
			else
				pkszTHsv.loadOut[loadoutID][cnt] = {item=key,num=value}
				cnt = cnt + 1
			end
		end
    until true end

end

pkszTHsv.getLoadOutRandom = function()

	local temp = {}
	local loadoutID = ""
	local cnt = 1
	local file = getFileReader(pkszTHsv.Settings.loadoutRandomFilename, true)
	if not file then
		pkszTHsv.logger("LoadOutRandom file not found "..pkszTHsv.Settings.loadoutRandomFilename,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
        for key, value in string.gmatch(line, "([%w%.%_]+) *= *(.+)") do
			if key == "loadOutRandomCD" then
				loadoutID = value
				pkszTHsv.loadOutRandom[loadoutID] = {}
				cnt = 1
			else
				pkszTHsv.loadOutRandom[loadoutID][cnt] = {item=key,num=value}
				pkszTHsv.loadOutRandomIndex[pkszTHsv.loadOutRandomIndexCnt] = {item=key,num=value}
				pkszTHsv.loadOutRandomIndexCnt = pkszTHsv.loadOutRandomIndexCnt + 1
				cnt = cnt + 1
			end
		end
    until true end

end

pkszTHsv.getLoadOutRandomGP = function()

	local myKey = ""
	local iCnt = 1


	local file = getFileReader(pkszTHsv.Settings.loadoutRandomGPFilename, true)
	if not file then
		pkszTHsv.logger("loadoutRandomGP file not found "..pkszTHsv.Settings.loadoutRandomGPFilename,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
		-- print(line)
		if string.sub(line, 1, 17) == "loadOutRandomGPCD" then
			for key, value in string.gmatch(line, "([%w%.%_]+) *= *(.+)") do
				myKey = value
			end
			pkszTHsv.loadOutRandomGP[myKey] = {}
			iCnt = 1
		else
			-- pkszTHsv.getRandomGPLineSplit(line)
			pkszTHsv.loadOutRandomGP[myKey][iCnt] = line
			iCnt = iCnt + 1
		end
    until true end

end

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

pkszTHsv.getLoadZedOutfitGrp = function()

	local temp = {}
	local loadoutID = ""
	local cnt = 1
	local file = getFileReader(pkszTHsv.Settings.zedOutfitGrpFilename, true)
	if not file then
		pkszTHsv.logger("LoadZedOutfitGrp file not found "..pkszTHsv.Settings.zedOutfitGrpFilename,false)
		return
	end
    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
        for key, value in string.gmatch(line, "([%w%.%_]+) *= *(.+)") do
			if key == "outfitGrpCD" then
				GrpCD = value
				pkszTHsv.zedOutfitGrp[GrpCD] = {}
				cnt = 1
			else
				pkszTHsv.zedOutfitGrp[GrpCD][cnt] = {item=key,num=value}
				cnt = cnt + 1
			end
		end
    until true end

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
