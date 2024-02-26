pkszTHsetup = {}

pkszTHsetup.eventModsList = {}

pkszTHsetup.fn = {}
pkszTHsetup.fn.eventMods = "_eventMods.txt"
pkszTHsetup.fn.history = "_log.txt"
pkszTHsetup.fn.log = "_history.txt"

pkszTHsetup.fnm = {}
pkszTHsetup.fnm.cordinates = "cordinates.txt"
pkszTHsetup.fnm.event = "event.txt"
pkszTHsetup.fnm.loadOut = "loadOut.txt"
pkszTHsetup.fnm.loadOutRandom = "loadOutRandom.txt"
pkszTHsetup.fnm.loadOutRandomGP = "loadOutRandomGP.txt"
pkszTHsetup.fnm.zedOutfitGrp = "zedOutfitGrp.txt"

pkszTHsetup.fileCheck = {}
pkszTHsetup.dataCheck = {}

-- file load
pkszTHsetup.eventFileLoader = function()

	pkszTHsetup.baseDir = "/" .. pkszTHsv.EventFileVer
	pkszTHsv.logger("-- start event File loading --",true)

	pkszTHsetup.dataCheck = {}
	pkszTHsetup.dataCheck["cordinates"] = 0
	pkszTHsetup.dataCheck["event"] = 0
	pkszTHsetup.dataCheck["loadOut"] = 0
	pkszTHsetup.dataCheck["loadOutRandom"] = 0
	pkszTHsetup.dataCheck["loadOutRandomGP"] = 0
	pkszTHsetup.dataCheck["zedOutfitGrp"] = 0


	local filename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.eventMods
	local eventMods = pkszTHsetup.fileExist(filename)
	if eventMods then
		pkszTHsetup.operateEventMods(eventMods)
		eventMods:close()
		if pkszTHsetup.eventModsList then
			pkszTHsetup.setupEvents()
		end
	end

end

pkszTHsetup.setupEvents = function()

	pkszTHsetup.fileCheck = {}

	local eventModsList = pkszTHsetup.eventModsList
	local eventDataFiles = pkszTHsetup.fnm

	for ModId, fHeader in pairs(eventModsList) do
		pkszTHsv.logger("pkszTH - Event Mod Active ["..ModId.."] / fileHeader = "..fHeader ,true)
        for key, fn in pairs(eventDataFiles) do
			local thisFn = pkszTHsetup.baseDir.."/"..fHeader.."_"..fn
			local thisDataFile = pkszTHsetup.fileExist(thisFn)
			if thisDataFile then
				-- print("filename : "..thisFn)
				if key == "cordinates" then pkszTHsetup.getCordinates(thisDataFile) end
				if key == "event" then pkszTHsetup.getEvents(thisDataFile) end
				if key == "loadOut" then pkszTHsetup.getLoadOut(thisDataFile) end
				if key == "loadOutRandom" then pkszTHsetup.getLoadOutRandom(thisDataFile) end
				if key == "loadOutRandomGP" then pkszTHsetup.getLoadOutRandomGP(thisDataFile) end
				if key == "zedOutfitGrp" then pkszTHsetup.getZedOutfitGrp(thisDataFile) end
				thisDataFile:close()
			end
		end
	end

	--debug
	for key in pairs(pkszTHsv.Events) do
		pkszTHsv.logger("setup Event ID = "..key,true)
	end
	--detacheck
	for key in pairs(pkszTHsetup.dataCheck) do
		pkszTHsv.logger("Data count "..key.." : "..pkszTHsetup.dataCheck[key],true)
		if pkszTHsetup.dataCheck[key] == 0 then
			pkszTHsv.logger("pkszTH - server : Event data "..key.." is zero. " ,true)
			pkszTHsv.errorhandling("pkszTH - server : Date File Error " ,true)
		end
	end

end

-- file check and install
pkszTHsetup.eventFileCheck = function()

	-- Processing to install when the event file is not installed, mainly when starting for the first time

	pkszTHsetup.ve = {}

	pkszTHsetup.baseDir = "/" .. pkszTHsv.EventFileVer

	local filename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.eventMods
	local eventMods = pkszTHsetup.fileExist(filename)
	if not eventMods then
		print("copy event file start ",filename)
		pkszTHsetup.eventFileDeploy()
	else
		eventMods:close()
	end
end

pkszTHsetup.eventFileDeploy = function()

	pkszTHsetup.getVanillaEvent()
	local baseFiles = {}

	-- base file
	baseFiles = pkszTHsetup.fn
	for k,v in pairs(baseFiles) do
		local thisFileName = pkszTHsetup.baseDir.."/"..v
		local thisText = pkszTHsetup.ve[k]
		pkszTHsetup.fileWriter(thisFileName,thisText)
	end

	-- event file
	baseFiles = pkszTHsetup.fnm
	for k,v in pairs(baseFiles) do
		local thisFileName = pkszTHsetup.baseDir.."/vanilla_"..v
		local thisText = pkszTHsetup.ve[k]
		pkszTHsetup.fileWriter(thisFileName,thisText)
	end

	pkszTHsv.logger("deploy event files "..pkszTHsetup.baseDir,true)

end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

pkszTHsetup.getCordinates = function(file)
	pkszTHsetup.fileCheck["cordinates"] = 1
	local cordCD = ""
	local cnt = 1
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
			pkszTHsetup.dataCheck["cordinates"] = pkszTHsetup.dataCheck["cordinates"] + 1
		end
    until true end
end

pkszTHsetup.getEvents = function(file)
	pkszTHsetup.fileCheck["event"] = 1
	local temp = {}
	local eventID = ""
	local cnt = 1
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
				pkszTHsetup.dataCheck["event"] = pkszTHsetup.dataCheck["event"] + 1
			else
				pkszTHsv.Events[eventID][key] = value
			end
		end
    until true end

end

pkszTHsetup.getLoadOut = function(file)
	pkszTHsetup.fileCheck["loadOut"] = 1
	local temp = {}
	local loadoutID = ""
	local cnt = 1
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
				pkszTHsetup.dataCheck["loadOut"] = pkszTHsetup.dataCheck["loadOut"] + 1
			else
				pkszTHsv.loadOut[loadoutID][cnt] = {item=key,num=value}
				cnt = cnt + 1
			end
		end
    until true end
end

pkszTHsetup.getLoadOutRandom = function(file)
	pkszTHsetup.fileCheck["loadOutRandom"] = 1
	local temp = {}
	local loadoutID = ""
	local cnt = 1
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
				pkszTHsetup.dataCheck["loadOutRandom"] = pkszTHsetup.dataCheck["loadOutRandom"] + 1
			else
				pkszTHsv.loadOutRandom[loadoutID][cnt] = {item=key,num=value}
				pkszTHsv.loadOutRandomIndex[pkszTHsv.loadOutRandomIndexCnt] = {item=key,num=value}
				pkszTHsv.loadOutRandomIndexCnt = pkszTHsv.loadOutRandomIndexCnt + 1
				cnt = cnt + 1
			end
		end
    until true end
end

pkszTHsetup.getLoadOutRandomGP = function(file)
	pkszTHsetup.fileCheck["loadOutRandomGP"] = 1
	local myKey = ""
	local iCnt = 1
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
			pkszTHsetup.dataCheck["loadOutRandomGP"] = pkszTHsetup.dataCheck["loadOutRandomGP"] + 1
		else
			-- pkszTHsv.getRandomGPLineSplit(line)
			pkszTHsv.loadOutRandomGP[myKey][iCnt] = line
			iCnt = iCnt + 1
		end
    until true end
end

pkszTHsetup.getZedOutfitGrp = function(file)
	pkszTHsetup.fileCheck["zedOutfitGrp"] = 1
	local temp = {}
	local loadoutID = ""
	local cnt = 1
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
				pkszTHsetup.dataCheck["zedOutfitGrp"] = pkszTHsetup.dataCheck["zedOutfitGrp"] + 1
			else
				pkszTHsv.zedOutfitGrp[GrpCD][cnt] = {item=key,num=value}
				cnt = cnt + 1
			end
		end
    until true end
end

pkszTHsetup.operateEventMods = function(file)

	local loadFlg = false

    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
		loadFlg = false
        for ModId, fHeader in string.gmatch(line, "([%w%.%_ %(%)%[%]%+%-]+) */ *(.+)") do
			if ModId == "vanilla" then
				pkszTHsetup.eventModsList[ModId] = fHeader
			elseif ActiveMods.getById("currentGame"):isModActive(ModId) then
				pkszTHsetup.eventModsList[ModId] = fHeader
			end
		end
    until true end

end


pkszTHsetup.fileWriter = function(fn,text)
	local dataFile = getFileWriter(fn, true, false);
	if dataFile then
		dataFile:write(text);
		dataFile:close();
	else
		print("pkszTH - server : File Writer Error "..filename)
		pkszTHsv.errorhandling("pkszTH - server : File Writer Error "..filename ,true)
	end
end


pkszTHsetup.fileExist = function(filename)
	local file = getFileReader(filename, false);
	if not file then
		return nil
	else
		return file
	end
end



------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

pkszTHsetup.getVanillaEvent = function()

pkszTHsetup.ve = {}

pkszTHsetup.ve.eventMods = [[-- "--" is can be used as a comment out
-- Loads event files in order from top to bottom.
-- If specify an external MOD, it will not be loaded unless the MOD is active.
-- It is recommended that original events be created with pkszTH
-- modID/folder name
--
vanilla/vanilla
pkszTH/pkszTH
]]

pkszTHsetup.ve.log = ""
pkszTHsetup.ve.history = ""

pkszTHsetup.ve.cordinates = [[-- "--" is can be used as a comment out
-- x,y,z,spawnRadius,zombioOutfit,description
---
cordListCD = error
9000,9000,0,3,None,Cordinate Error
---
cordListCD = food
13891,6689,0,2,Camper,Be careful zombies
7663,11872,0,2,Naked,Be careful zombies
13913,5765,0,4,teenager,Be careful zombies
12073,6796,1,5,None,Be careful zombies
12073,6796,0,3,None,Be careful zombies
12067,6796,1,5,None,Be careful zombies
12062,6797,0,4,None,Be careful zombies
11977,6815,0,2,teenager,Be careful zombies
11666,8296,0,2,None,Be careful zombies
11665,8798,0,3,Trader,Be careful zombies
10851,9761,0,3,Trader,Be careful zombies
10846,10029,0,3,Trader,Be careful zombies
10612,10251,0,2,Trader,Be careful zombies
8073,11344,0,3,None,Be careful zombies
6120,5303,0,3,teenager,Be careful zombies
12985,2026,0,3,medic,Be careful zombies
12964,2028,0,3,medic,Be careful zombies
12950,2028,0,3,medic,Be careful zombies
12946,2081,0,3,medic,Be careful zombies
13849,6767,0,2,None,Be careful zombies
3852,6197,2,2,rogue,Be careful zombies
---
cordListCD = civilWeapon
13849,6767,0,2,None,Be careful zombies
3836,6207,1,1,rogue,Be careful zombies
13593,3023,0,1,Officeworker,Be careful zombies
3852,6197,2,2,rogue,Be careful zombies
14012,3238,0,5,None,Be careful zombies
4975,8712,0,4,Survivor,Be careful zombies
4753,7536,0,4,Survivor,Be careful zombies
4397,7247,0,4,Survivor,Be careful zombies
4240,8431,0,5,Survivor,Be careful zombies
4112,7854,0,5,Survivor,Be careful zombies
13404,5341,0,4,Camper,Be careful zombies
13402,5339,0,6,Camper,Be careful zombies
13115,5300,0,2,Mix,Be careful zombies
13109,5299,0,3,Camper,Be careful zombies
13100,5304,0,4,Camper,Be careful zombies
13091,5120,0,4,Camper,Be careful zombies
13090,5122,0,4,Camper,Be careful zombies
13090,5122,0,3,None,Be careful zombies
4644,8109,0,3,Survivor,Be careful zombies
4278,7288,0,1,Survivor,Be careful zombies
3830,6215,0,4,rogue,Be careful zombies
12327,1262,0,3,Dress,Be careful zombies
12308,1272,0,3,Dress,Be careful zombies
---
cordListCD = militaryWeapon
10642,10401,0,2,Police,Be careful zombies
13780,2561,0,2,Police,Be careful zombies
7601,11971,0,1,PrivateMilitia,Be careful zombies
7593,11969,0,3,Police,Be careful zombies
5544,12499,0,2,Mix,Be careful zombies
5537,12468,0,2,rogue,Be careful zombies
13593,3023,0,1,Officeworker,Be careful zombies
14012,3238,0,5,None,Be careful zombies
4975,8712,0,4,Survivor,Be careful zombies
4753,7536,0,4,Survivor,Be careful zombies
4397,7247,0,4,Survivor,Be careful zombies
4240,8431,0,5,Survivor,Be careful zombies
4112,7854,0,5,Survivor,Be careful zombies
---
cordListCD = supply
12414,9007,0,2,Survivor,Be careful zombies
11249,8947,0,3,Survivor,Be careful zombies
10642,10401,0,2,Police,Be careful zombies
13891,6689,0,2,Camper,Be careful zombies
7663,11872,0,2,Naked,Be careful zombies
3836,6207,1,1,rogue,Be careful zombies
13404,5341,0,4,Camper,Be careful zombies
12985,2026,0,3,medic,Be careful zombies
12964,2028,0,3,medic,Be careful zombies
12950,2028,0,3,medic,Be careful zombies
12946,2081,0,3,medic,Be careful zombies
13593,3023,0,1,Officeworker,Be careful zombies
---
cordListCD = medic
12985,2026,0,3,medic,Be careful zombies
12964,2028,0,3,medic,Be careful zombies
12950,2028,0,3,medic,Be careful zombies
12946,2081,0,3,medic,Be careful zombies
10642,10401,0,2,Police,Be careful zombies
13891,6689,0,2,Camper,Be careful zombies
3836,6207,1,1,rogue,Be careful zombies
13849,6767,0,2,None,Be careful zombies
---
cordListCD = clothing
12327,1262,0,3,Dress,Be careful zombies
12308,1272,0,3,Dress,Be careful zombies
11860,6886,0,2,teenager,Be careful zombies
11600,8249,0,3,None,Be careful zombies
10631,9906,0,2,teenager,Be careful zombies
10616,10155,0,3,teenager,Be careful zombies
10613,9436,0,2,Young,Be careful zombies
10612,10372,0,3,teenager,Be careful zombies
10068,12816,0,2,teenager,Be careful zombies
---
cordListCD = largeplace
11521,11235,0,10,None,Horde is comming
11608,7919,0,10,None,Horde is comming
10857,6908,0,10,None,Horde is comming
8622,8106,0,10,None,Horde is comming
9642,12272,0,10,None,Horde is comming
12570,6569,0,10,None,Horde is comming
10597,6677,0,10,None,Horde is comming
11631,8312,0,10,None,Horde is comming
11864,7203,0,10,None,Horde is comming
12677,6304,0,10,None,Horde is comming
8234,11180,0,10,None,Horde is comming
13733,6042,0,10,None,Horde is comming
12256,7057,0,10,None,Horde is comming
10619,8783,0,10,None,Horde is comming
---
cordListCD = common
14598,3449,0,4,PrivateMilitia,Be careful zombies
14526,4012,0,2,PrivateMilitia,Be careful zombies
14511,3440,0,6,None,Be careful zombies
14508,3932,0,4,Mix,Be careful zombies
14484,4269,0,8,Farmer,Be careful zombies
14433,2145,0,1,Mix,Be careful zombies
14140,4291,0,8,Farmer,Be careful zombies
14139,2623,0,5,worker,Be careful zombies
14124,2758,0,2,None,Be careful zombies
14061,5215,0,2,None,Near the pond
13959,3555,0,2,None,Be careful zombies
13947,7395,0,2,None,Be careful zombies
13891,6685,0,2,None,Be careful zombies
13891,5810,2,2,None,Be careful zombies
13880,5792,2,2,Bandit,Be careful zombies
13867,1196,0,2,None,Be careful zombies
13850,3264,0,2,Mix,Be careful zombies
13838,2147,0,2,Survivor,Be careful zombies
13758,1614,0,4,Constructionworker,Be careful zombies
13720,2918,0,2,None,Be careful zombies
13715,3688,0,5,Mix,Be careful zombies
13712,3577,0,4,None,Be careful zombies
13705,2799,0,3,None,Be careful zombies
13703,4560,0,8,Farmer,Be careful zombies
13702,1985,0,8,Dress,Be careful zombies
13698,6702,0,3,None,Be careful zombies
13678,2547,0,2,None,Be careful zombies
13660,1769,2,2,Fireman,Be careful zombies
13636,4014,1,5,Naked,Be careful zombies
13631,7224,0,2,Survivor,Be careful zombies
13624,5871,2,2,None,Be careful zombies
13598,3018,0,3,None,Be careful zombies
13595,1898,0,3,None,Be careful zombies
13577,2908,0,3,None,Be careful zombies
13572,1576,1,2,Officeworker,Be careful zombies
13566,2762,0,2,teenager,Be careful zombies
13558,5130,0,8,Farmer,Be careful zombies
13536,3270,0,3,None,Be careful zombies
13356,5108,0,8,Farmer,Be careful zombies
13354,3073,1,2,Officeworker,Be careful zombies
13249,2414,0,3,None,Be careful zombies
13235,2289,0,4,None,Be careful zombies
13228,2587,0,1,None,Be careful zombies
13211,3524,0,1,rogue,Be careful zombies
13165,6406,0,2,Survivor,Be careful zombies
13090,3091,0,3,None,Be careful zombies
13008,2226,0,5,worker,Be careful zombies
13003,5266,0,2,worker,Be careful zombies
12988,1542,0,4,Naked,Be careful zombies
12984,5312,0,2,Survivor,Be careful zombies
12983,1130,0,2,None,Be careful zombies
12968,5459,0,1,Survivor,Be careful zombies
12967,1538,2,2,Mix,Be careful zombies
12951,5134,0,2,None,Be careful zombies
12867,1689,0,3,Mix,Indoor court
12874,1698,0,3,Mix,Warehouse
12864,4865,0,2,None,Be careful zombies
12861,6761,0,3,None,Be careful zombies
12858,2839,1,2,rogue,Be careful zombies
12855,2048,0,2,None,Be careful zombies
12794,2419,4,1,Mix,Be careful zombies
12786,2500,2,4,None,Be careful zombies
12785,5805,0,1,Survivor,Be careful zombies
12765,1595,0,4,None,Be careful zombies
12764,4402,0,4,None,There is a risk of death
12739,4183,0,1,None,Be careful zombies
12730,8759,0,1,Survivor,Be careful zombies
12730,1443,0,2,None,Be careful zombies
12729,8760,0,1,Survivor,Be careful zombies
12715,1614,0,4,None,Be careful zombies
12662,3714,0,2,Mix,Be careful zombies
12646,4345,1,2,None,Be careful zombies
12642,3303,0,3,Mix,Be careful zombies
12639,1827,0,3,Mix,Be careful zombies
12638,1536,0,5,worker,Be careful zombies
12634,3940,0,5,None,Be careful zombies
12617,5860,0,2,None,Be careful zombies
12617,1363,0,2,worker,Be careful zombies
12616,3198,0,3,Mix,Be careful zombies
12592,1004,0,2,PrivateMilitia,Be careful zombies
12579,4112,0,3,Mix,Be careful zombies
12575,3270,0,3,Mix,Be careful zombies
12566,1682,0,1,None,Be careful zombies
12555,4157,0,3,Mix,Be careful zombies
12479,5297,0,1,Naked,Be careful zombies
12458,1316,0,3,None,Be careful zombies
12453,4979,0,2,None,Be careful zombies
12425,1479,0,2,None,Be careful zombies
12404,1489,0,4,None,Be careful zombies
12363,1739,0,1,Fireman,Fire staiton side allay
12325,2200,1,2,teenager,Be careful zombies
12312,6587,0,2,None,Be careful zombies
12264,6700,0,2,None,Be careful zombies
12225,2755,0,5,None,Be careful zombies
12225,1348,0,2,rogue,Be careful zombies
12198,6872,0,2,None,Be careful zombies
12146,2694,3,3,Mix,Be careful zombies
12127,3465,0,2,None,Be careful zombies
12102,9013,0,3,None,Be careful zombies
12079,1452,3,4,Constructionworker,Be careful zombies
12051,7373,0,2,None,Be careful zombies
12036,9463,0,3,None,Be careful zombies
12016,7368,0,6,None,Be careful zombies
11992,1435,0,1,Mix,Be careful zombies
11988,6940,2,1,OfficeworkerSkirt,Be careful zombies
11981,6917,0,2,Trader,Be careful zombies
11897,10635,0,3,None,Be careful zombies
11895,10633,0,5,None,Be careful zombies
11894,6914,0,2,Officeworker,Be careful zombies
11828,6575,0,1,None,Be careful zombies
11813,10418,0,3,None,Be careful zombies
11735,10089,0,3,None,Be careful zombies
11735,10068,0,3,None,Be careful zombies
11673,8779,0,7,None,Be careful zombies
11629,9913,0,3,None,Be careful zombies
11620,9289,0,3,Mix,Be careful zombies
11586,10118,0,3,None,Be careful zombies
11264,6575,0,1,None,Be careful zombies
11241,8954,0,2,Mix,Be careful zombies
11071,9035,0,6,None,Be careful zombies
11066,6702,0,3,Mix,Be careful zombies
11065,6708,0,4,Naked,Be careful zombies
11064,10640,0,3,None,Be careful zombies
11056,6708,0,3,Mix,Be careful zombies
11022,10262,0,2,None,Be careful zombies
11020,10057,0,3,None,Be careful zombies
10943,6833,0,10,None,Be careful zombies
10932,9270,0,3,None,Be careful zombies
10915,9841,0,2,worker,Be careful zombies
10829,8937,0,4,Farmer,Be careful zombies
10785,10171,0,4,None,Be careful zombies
10765,10546,0,2,Bikar,Be careful zombies
10697,10005,0,2,None,Be careful zombies
10667,10615,0,3,OfficeworkerSkirt,Be careful zombies
10604,10108,0,2,Trader,Be careful zombies
10550,9697,0,3,None,Be careful zombies
10538,11172,0,5,None,Be careful zombies
10504,12891,0,6,Nurse,Be careful zombies
10479,7770,0,8,Farmer,Be careful zombies
10465,7753,0,5,None,Be careful zombies
10448,12602,0,1,None,Be careful zombies
10374,10103,0,2,Constructionworker,Be careful zombies
10322,12787,0,3,None,Be careful zombies
10318,12787,0,2,Dress,Be careful zombies
10290,9390,1,3,Constructionworker,Be careful zombies
10278,9589,0,1,rogue,Be careful zombies
10221,9888,0,3,rogue,Be careful zombies
10197,7114,0,4,Survivor,Be careful zombies
10184,6765,0,2,Mix,Be careful zombies
10180,12781,0,2,worker,Be careful zombies
10176,12656,0,2,None,Be careful zombies
10140,8883,0,1,None,Be careful zombies
10150,12716,1,2,worker,Be careful zombies
10079,12618,3,2,Mix,Top floor residence
10033,12717,1,2,None,Be careful zombies
10016,12626,0,3,None,Be careful zombies
10007,12669,1,2,Naked,Be careful zombies
9995,10987,1,3,Constructionworker,Be careful zombies
9884,13021,0,4,None,Be careful zombies
9832,13128,0,3,None,Be careful zombies
9768,12573,0,4,None,Be careful zombies
9761,13039,0,2,None,Be careful zombies
9662,8779,0,3,Camper,Be careful zombies
9612,10149,0,4,None,Be careful zombies
9597,6783,0,3,Survivor,Be careful zombies
9343,10295,0,4,Survivor,Be careful zombies
9335,6613,0,2,None,Be careful zombies
9324,9038,0,8,Farmer,Be careful zombies
9297,11622,0,8,Farmer,Be careful zombies
9283,7749,0,3,Farmer,Be careful zombies
9153,9260,0,8,Farmer,Be careful zombies
8924,7899,0,8,Farmer,Be careful zombies
8861,11938,0,6,Farmer,Be careful zombies
8757,11395,0,4,Survivor,Be careful zombies
8621,11505,0,4,Survivor,Be careful zombies
8616,12456,0,6,Farmer,Be careful zombies
8526,8834,0,6,Farmer,Be careful zombies
8462,12237,1,1,Mix,Be careful zombies
8385,12223,0,3,None,Be careful zombies
8380,11603,0,3,Student,Be careful zombies
8334,11651,0,3,Student,Be careful zombies
8333,11646,0,3,Student,Be careful zombies
8282,12216,0,4,None,Be careful zombies
8221,11864,0,6,None,Be careful zombies
8210,11880,0,3,Constructionworker,Be careful zombies
8194,8248,0,5,Farmer,Be careful zombies
8122,11543,0,3,None,Be careful zombies
8045,7115,0,2,None,Be careful zombies
8035,12307,0,8,Farmer,Be careful zombies
8026,7499,0,3,None,Be careful zombies
7989,12235,0,8,Farmer,Be careful zombies
7969,12098,0,3,Farmer,Be careful zombies
7961,10037,0,2,Farmer,Be careful zombies
7946,10986,0,8,Farmer,Be careful zombies
7884,12464,0,3,Farmer,Be careful zombies
7881,12476,0,3,Farmer,Be careful zombies
7680,11486,0,4,Mix,Be careful zombies
7666,9348,0,2,Mix,Be careful zombies
7638,11436,0,5,None,Be careful zombies
7501,6209,0,2,None,Be careful zombies
7498,5330,0,2,None,Be careful zombies
7382,8354,0,4,None,Be careful zombies
7338,5502,0,8,Farmer,Be careful zombies
7177,8985,0,6,None,Be careful zombies
7108,5595,0,6,Farmer,Be careful zombies
6779,9934,0,3,PrivateMilitia,Be careful zombies
6694,5243,0,4,rogue,Be careful zombies
6666,6156,0,2,Mix,Be careful zombies
6613,5860,0,1,Mix,Be careful zombies
6577,5374,0,4,None,Be careful zombies
6557,5239,0,5,worker,Be careful zombies
6474,12000,0,4,Mix,Be careful zombies
6446,5205,0,3,None,Be careful zombies
6440,5217,0,5,worker,Be careful zombies
6422,5216,0,5,worker,Be careful zombies
6380,5219,0,3,Dress,Be careful zombies
6376,5494,0,3,None,Be careful zombies
6204,5252,0,4,None,Be careful zombies
6185,6380,0,5,None,Be careful zombies
6172,6377,1,1,None,Be careful zombies
5862,9789,0,6,Mix,Be careful zombies
5782,6423,0,5,worker,Be careful zombies
5727,6396,0,4,None,Be careful zombies
5681,5336,0,3,Mix,Be careful zombies
5678,5315,0,3,Mix,Be careful zombies
5665,5228,0,2,None,Be careful zombies
4918,6423,0,3,None,Be careful zombies
4907,5549,0,5,None,Be careful zombies
4833,6279,0,5,PrivateMilitia,Be careful zombies
4700,5820,0,8,Farmer,Be careful zombies
4650,5618,0,2,None,Be careful zombies
4593,7845,0,3,teenager,Be careful zombies
4185,5884,0,8,Farmer,Be careful zombies
4145,5887,0,8,Farmer,Be careful zombies
4061,8132,0,5,Mix,Be careful zombies
4048,5866,0,8,Farmer,Be careful zombies
3971,6260,0,4,Mix,Be careful zombies
3801,5699,0,2,None,Be careful zombies
]]

pkszTHsetup.ve.event = [[-- "--" is can be used as a comment out
-- eventTimeout = 6 is 1 hour in-game
--
eventID = food1
eventDescription = Food supply
eventTimeout = 60
HordeDensity = 12
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = food1
cordListSelectCD = food,common
leaderOutfit = Camper
--
eventID = food2
eventDescription = Meat supply
eventTimeout = 60
HordeDensity = 12
InventoryItem = Base.Cooler
loadOutSelectCD = food2
cordListSelectCD = food,common
leaderOutfit = Survivalist
--
eventID = food3
eventDescription = Junk food
eventTimeout = 60
HordeDensity = 12
InventoryItem = Base.Bag_Satchel
loadOutSelectCD = food3
cordListSelectCD = food,common
leaderOutfit = Police
--
eventID = Weapon1
eventDescription = Survivor's Armament
eventTimeout = 72
HordeDensity = 18
InventoryItem = Base.RifleCase1
loadOutSelectCD = Weapon1
cordListSelectCD = civilWeapon,common
leaderOutfit = Survivalist
--
eventID = Weapon2
eventDescription = supply of Guns and Ammos
eventTimeout = 30
HordeDensity = 24
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = Weapon2
cordListSelectCD = militaryWeapon,common
leaderOutfit = Militia
--
eventID = Weapon3
eventDescription = Military supply
eventTimeout = 30
HordeDensity = 20
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = Weapon3
cordListSelectCD = militaryWeapon,common
leaderOutfit = Militia
--
eventID = misc1
eventDescription = Support supply
eventTimeout = 72
HordeDensity = 16
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = misc1
cordListSelectCD = supply,common
leaderOutfit = teenager
--
eventID = misc2
eventDescription = Supply of need to survive
eventTimeout = 72
HordeDensity = 14
InventoryItem = Base.Bag_MedicalBag
loadOutSelectCD = misc2
cordListSelectCD = supply,common
leaderOutfit = Survivalist
--
eventID = medic
eventDescription = Medical supply
eventTimeout = 60
HordeDensity = 12
InventoryItem = Base.Bag_MedicalBag
loadOutSelectCD = medic
cordListSelectCD = medic,common
leaderOutfit = medic
--
eventID = clothing
eventDescription = Apocalypse fashion
eventTimeout = 18
HordeDensity = 12
InventoryItem = Base.Suitcase
loadOutSelectCD = clothing
cordListSelectCD = clothing,common
leaderOutfit = Dress
--
eventID = misc3
eventDescription = Really? need this? okay...
eventTimeout = 30
HordeDensity = 24
InventoryItem = Base.Suitcase
loadOutSelectCD = misc3
cordListSelectCD = common
leaderOutfit = Spiffo
--
eventID = funbox
eventDescription = Huh? What did I put in that bag?
eventTimeout = 24
HordeDensity = 18
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = funBox
cordListSelectCD = common
leaderOutfit = Santa
--
-- eventID = horde
-- eventDescription = What a Hell... help... I need help....
-- eventTimeout = 120
-- HordeDensity = 300
-- InventoryItem = Base.Bag_BigHikingBag
-- loadOutSelectCD = horde
-- cordListSelectCD = largeplace
-- leaderOutfit = Spiffo
]]

pkszTHsetup.ve.loadOut = [[-- "--" is can be used as a comment out
-- Base.Axe = 1 / One fireaxe will always spawn.
-- random = food1 / Spawns one from a random of "food1"
-- randomGP = CivilRifle / One set will be selected and spawned from a RandomGP group of Civil Rifles.
-- random = random / Spawns one of all random items
---
loadOutCD = food1
Base.BreadKnife = 1
random = grain
random = sackProduce
random = food
random = breakfast
random = breakfast
random = breakfast
random = fruits
random = fruits
random = fruits
random = seasoning
random = cookingMag
---
loadOutCD = food2
random = TheMeat
random = TheMeat
random = TheMeat
random = TheMeat
random = TheMeat
random = Liquor
random = Liquor
random = junkfood
random = breakfast
random = breakfast
random = seasoning
random = seasoning
---
loadOutCD = food3
Base.Pop = 1
random = junkfood
random = junkfood
random = junkfood
random = junkfood
random = junkfood
random = fruits
random = hottie
random = civilmix
---
loadOutCD = Weapon1
Base.Pop = 2
random = civilVest
random = melee
random = melee
random = melee
random = spear
random = civilmix
random = civilmix
---
loadOutCD = Weapon2
Base.Pop = 2
random = armyVest
random = ammo
random = ammo
random = militalyMisc
random = militalyMisc
random = weaponPart
randomGP = CivilRifle
randomGP = MilitaryRifle
randomGP = MilitaryMix
---
loadOutCD = Weapon3
Base.Pop = 2
random = armyVest
random = armyVest
random = weaponPart
random = weaponPart
random = weaponPart
random = weaponPart
random = militalyMisc
random = militalyMisc
random = ammo
randomGP = Pistol
---
loadOutCD = misc1
Base.Pop = 2
Base.BlowTorch = 1
Base.WeldingMask = 1
Base.WeldingRods = 1
Base.DuctTape = 2
Base.Glue = 2
Base.Woodglue = 2
random = melee
random = civilmix
random = boots
random = gloves
random = Medic
random = Medic
random = misc
random = misc
---
loadOutCD = misc2
Base.Pop = 2
random = melee
random = civilmix
random = boots
random = gloves
random = Medic
random = misc
random = food
random = seasoning
random = fruits
random = fruits
---
loadOutCD = medic
Base.Lollipop = 1
Base.AlcoholBandage = 1
Base.AlcoholWipes = 1
Base.Disinfectant = 1
Base.AlcoholedCottonBalls = 1
Base.Pills = 1
Base.PillsAntiDep = 1
Base.PillsBeta = 1
Base.PillsSleepingTablets = 1
Base.PillsVitamins = 1
Base.Coldpack = 1
Base.Needle = 1
random = Medic
random = Medic
random = breakfast
random = fruits
---
loadOutCD = clothing
Base.Crisps = 1
random = clothes
random = clothes
random = clothes
random = boots
random = boots
random = gloves
random = gloves
random = civilVest
random = civilmix
---
loadOutCD = misc3
Base.PopBottle = 1
Base.HottieZ = 1
random = hottie
random = hottie
random = hottie
random = hottie
random = hottie
random = junkfood
random = melee
random = civilmix
random = random
---
loadOutCD = funBox
random = random
random = random
random = random
random = random
random = random
random = random
random = random
random = random
random = random
random = random
---
loadOutCD = horde
randomGP = CivilRifle
randomGP = MilitaryRifle
random = melee
random = melee
random = melee
random = ammo
random = ammo
random = ammo
random = ammo
random = breakfast
random = junkfood
random = Medic
]]

pkszTHsetup.ve.loadOutRandom = [[-- "--" is can be used as a comment out
-- One will be selected from the group
-- will spawn as many times as the " = number"
-- randomGP = CivilRifle / One set will be selected and spawned from a RandomGP group of Civil Rifles.
-----
loadOutRandomCD = melee
Base.Nightstick = 2
Base.MeatCleaver = 2
Base.HandAxe = 2
Base.HandScythe = 2
Base.Machete = 1
Base.ClubHammer = 1
Base.Hammer = 1
Base.Chainsaw = 1
Base.Katana = 1
Base.PickAxe = 1
Base.BaseballBat = 2
Base.BaseballBatNails = 1
Base.Axe = 1
Base.WoodAxe = 1
Base.Sledgehammer = 1
Base.Sledgehammer2 = 1
---
loadOutRandomCD = civilmix
Base.HuntingKnife = 1
Base.MeatCleaver = 1
Base.HandAxe = 2
Base.PickAxe = 1
randomGP = Revolver
randomGP = Pistol
randomGP = CivilRifle
---
loadOutRandomCD = spear
Base.SpearScrewdriver = 2
Base.SpearHuntingKnife = 2
Base.SpearMachete = 2
Base.SpearIcePick = 2
Base.SpearKnife = 2
---
loadOutRandomCD = weaponPart
Base.x2Scope = 1
Base.x4Scope = 1
Base.x8Scope = 1
Base.AmmoStraps = 1
Base.Sling = 1
Base.FiberglassStock = 1
Base.IronSight = 1
Base.RecoilPad = 1
Base.Laser = 1
Base.RedDot = 1
Base.GunLight = 1
Base.Bayonnet = 1
Base.ChokeTubeFull = 1
---
loadOutRandomCD = militalyMisc
Base.WristWatch_Right_ClassicMilitary = 1
Base.HolsterDouble = 1
Base.AmmoStrap_Bullets = 1
Base.Necklace_DogTag = 1
---
loadOutRandomCD = ammo
Base.Bullets9mmBox = 1
Base.Bullets45Box = 1
Base.Bullets44Box = 1
Base.Bullets38Box = 1
Base.556Box = 1
Base.308Box = 1
---
loadOutRandomCD = clothes
Base.Hat_Raccoon = 1
Base.Hat_Ranger = 1
Base.Scarf_White = 1
Base.Scarf_StripeBlackWhite = 1
Base.Scarf_StripeBlueWhite = 1
Base.Hat_BunnyEarsBlack = 1
Base.Hat_BunnyEarsWhite = 1
Base.BunnyTail = 1
Base.BunnySuitBlack = 1
Base.BunnySuitPink = 1
Base.PonchoGreen = 1
Base.PonchoYellow = 1
Base.Bracelet_RightFriendshipTINT = 1
Base.Jacket_LeatherWildRacoons = 1
Base.Jacket_LeatherIronRodent = 1
Base.Jacket_LeatherBarrelDogs = 1
---
loadOutRandomCD = boots
Base.Shoes_ArmyBoots = 1
Base.Shoes_ArmyBootsDesert = 1
Base.Shoes_BlackBoots = 1
Base.Shoes_Wellies = 1
---
loadOutRandomCD = gloves
Base.Gloves_LeatherGloves = 1
Base.Gloves_LeatherGlovesBlack = 1
Base.Gloves_FingerlessGloves = 1
Base.Bag_FannyPackFront = 1
Base.Bag_FannyPackBack = 1
---
loadOutRandomCD = Medic
Base.AlcoholBandage = 1
Base.AlcoholWipes = 1
Base.Disinfectant = 1
Base.AlcoholedCottonBalls = 1
Base.Pills = 1
Base.PillsAntiDep = 1
Base.PillsBeta = 1
Base.PillsSleepingTablets = 1
Base.PillsVitamins = 1
Base.Coldpack = 1
Base.Needle = 1
---
loadOutRandomCD = grain
Base.Cornmeal = 2
Base.PancakeMix = 2
Base.BakingSoda = 2
Base.Flour = 2
Base.Yeast = 2
Base.Vinegar = 2
Base.Rice = 2
---
loadOutRandomCD = sackProduce
Base.SackProduce_Apple = 1
Base.SackProduce_BellPepper = 1
Base.SackProduce_Broccoli = 1
Base.SackProduce_Corn = 1
Base.SackProduce_Eggplant = 1
Base.SackProduce_Grapes = 1
Base.SackProduce_Leek = 1
Base.SackProduce_Lettuce = 1
Base.SackProduce_Onion = 1
Base.SackProduce_Peach = 1
Base.SackProduce_Pear = 1
Base.SackProduce_Strawberry = 1
Base.SackProduce_Tomato = 1
---
loadOutRandomCD = food
Base.Pumpkin = 1
Base.Croissant = 1
Base.Peas = 1
Base.Cilantro = 1
Base.Zucchini = 1
Base.Sausage = 1
Base.Chicken = 1
Base.Cheese = 1
Base.Pear = 1
Base.Ham = 1
Base.MixedVegetables = 1
Base.EggCarton = 1
---
loadOutRandomCD = breakfast
Base.Icecream = 1
Base.Avocado = 1
Base.Baguette = 1
Base.Bread = 1
Base.Yoghurt = 1
Base.Processedcheese = 1
Base.Milk = 1
---
loadOutRandomCD = fruits
Base.Orange = 1
Base.Lime = 1
Base.Apple = 1
Base.Lemon = 1
Base.Watermelon = 1
Base.Grapes = 1
Base.Mango = 1
Base.Peach = 1
---
loadOutRandomCD = TheMeat
Base.Squid = 1
Base.Shrimp = 1
Base.Minced = 1
Base.MincedMeat = 1
Base.Oysters = 1
Base.Steak = 1
Base.MeatPatty = 1
Base.PorkChop = 1
Base.MuttonChop = 1
Base.Lobster = 1
Base.EggCarton = 1
---
loadOutRandomCD = Liquor
Base.BeerCan = 1
Base.BeerCan = 1
Base.BeerBottle = 1
Base.BeerBottle = 1
Base.BeerBottle = 1
Base.Wine = 1
Base.Wine2 = 1
Base.WhiskeyFull = 1
---
loadOutRandomCD = seasoning
Base.Coffee2 = 1
Base.RiceVinegar = 1
Base.Pepper = 1
Base.Salt = 1
Base.Vinegar = 1
Base.Wasabi = 1
Base.Seaweed = 2
---
loadOutRandomCD = junkfood
Base.Corndog = 1
Base.GrilledCheese = 1
Base.DoughnutChocolate = 1
Base.DoughnutFrosted = 1
Base.DoughnutJelly = 1
Base.DoughnutPlain = 1
Base.Burger = 1
Base.MeatSteamBun = 1
Base.MeatDumpling = 1
Base.Onigiri = 2
---
loadOutRandomCD = misc
Base.FishingRod = 1
Base.FishingLine = 2
Base.FishingNet = 1
Base.FishingTackle = 2
Base.EmptySandbag = 2
Base.SeedBag = 1
Base.Candle = 3
Base.Extinguisher = 1
Base.Matches = 3
Base.Lighter = 2
Base.BoxOfJars = 1
---
loadOutRandomCD = hottie
Base.ComicBook = 1
Base.HottieZ = 1
Base.HottieZ = 1
Base.TVMagazine = 1
Base.Spiffo = 1
Base.Spiffo = 1
Base.SpiffoBig = 1
Base.Money = 10
Base.Money = 6
Base.Money = 3
randomGP = Revolver
---
loadOutRandomCD = cookingMag
Base.CookingMag1 = 1
Base.CookingMag2 = 1
---
loadOutRandomCD = civilVest
Base.Vest_BulletCivilian = 1
Base.Vest_Hunting_Camo = 1
Base.Vest_Hunting_Orange = 1
Base.Vest_BulletPolice = 1
---
loadOutRandomCD = armyVest
Base.Vest_BulletArmy = 1
Base.Vest_BulletPolice = 1
]]

pkszTHsetup.ve.loadOutRandomGP = [[-- "--" is can be used as a comment out
-- One set is selected from the group and spawned.
-- 
loadOutRandomGPCD = CivilRifle
Base.VarmintRifle = 1;Base.223Box = 2
Base.HuntingRifle = 1;Base.308Box = 2;Base.308Clip = 2
Base.ShotgunSawnoff = 1;Base.ShotgunShellsBox = 2
Base.DoubleBarrelShotgunSawnoff = 1;Base.ShotgunShellsBox = 2
---
loadOutRandomGPCD = Pistol
Base.Pistol = 1;Base.Bullets9mmBox = 2;Base.Base.9mmClip = 2
Base.Pistol2 = 1;Base.Bullets45Box = 2;Base.45Clip = 2
Base.Pistol3 = 1;Base.Bullets44Box = 2;Base.44Clip = 2
---
loadOutRandomGPCD = Revolver
Base.Revolver = 1;Base.Bullets45Box = 2
Base.Revolver_Long = 1;Base.Bullets44Box = 2
Base.Revolver_Short = 1;Base.Bullets38Box = 2
---
loadOutRandomGPCD = MilitaryRifle
Base.AssaultRifle = 1;Base.556Box = 2;Base.556Clip = 2
Base.AssaultRifle2 = 1;Base.308Box = 2;Base.M14Clip = 2
Base.Shotgun = 1;Base.ShotgunShellsBox = 2
Base.DoubleBarrelShotgun = 1;Base.ShotgunShellsBox = 2
---
loadOutRandomGPCD = MilitaryMix
Base.AssaultRifle = 1;Base.556Box = 2;Base.556Clip = 2
Base.AssaultRifle2 = 1;Base.308Box = 2;Base.M14Clip = 2
Base.Pistol = 1;Base.Bullets9mmBox = 2;Base.Base.9mmClip = 2
Base.Pistol2 = 1;Base.Bullets45Box = 2;Base.45Clip = 2
]]

pkszTHsetup.ve.zedOutfitGrp = [[
-- "--" is can be used as a comment out
-- Zombies included in "outfitGrp" will spawn with a probability
-- The number specifies the rate at which female zombies appear
-- 0 = male / 50 = mix / 100 = female (This is by specification. Please check the official website for details)
--
outfitGrpCD = None
None = 50
---
outfitGrpCD = Farmer
Farmer = 50
None = 50
---
outfitGrpCD = PrivateMilitia
PrivateMilitia = 50
---
outfitGrpCD = Constructionworker
Constructionworker = 50
---
outfitGrpCD = Young
Young = 50
None = 50
---
outfitGrpCD = Student
Student = 50
None = 50
---
outfitGrpCD = Camper
Camper = 50
---
outfitGrpCD = Officeworker
Officeworker = 50
---
outfitGrpCD = OfficeworkerSkirt
OfficeworkerSkirt = 50
---
outfitGrpCD = Trader
Trader = 50
---
outfitGrpCD = Bikar
Bikar = 50
---
outfitGrpCD = Bandit
Bandit = 50
---
outfitGrpCD = Fireman
Fireman = 50
---
outfitGrpCD = Police
Police = 50
---
outfitGrpCD = Mix
Student = 50
Young = 50
DressLong = 100
DressNormal = 100
DressShort = 100
Bandit = 50
Bikar = 50
AmbulanceDriver = 50
OfficeWorker = 50
OfficeWorkerSkirt = 50
ConstructionWorker = 50
Trader = 50
Fireman = 50
Priest = 0
Police = 50
PrivateMilitia = 80
Ranger = 50
Camper = 50
Survivalist = 50
Survivalist02 = 50
Survivalist03 = 50
---
outfitGrpCD = teenager
Student = 50
Young = 50
---
outfitGrpCD = Dress
DressLong = 100
DressNormal = 100
DressShort = 100
---
outfitGrpCD = rogue
Bikar = 50
Bandit = 50
---
outfitGrpCD = medic
AmbulanceDriver = 50
Doctor = 50
Nurse = 100
---
outfitGrpCD = worker
OfficeWorker = 50
OfficeWorkerSkirt = 50
ConstructionWorker = 50
---
outfitGrpCD = Survivor
Camper = 50
Bandit = 50
Bikar = 50
None = 50
Survivalist = 50
Survivalist02 = 50
Survivalist03 = 50
Naked = 50
Trader = 50
Police = 50
Ranger = 50
---
outfitGrpCD = Survivalist
Survivalist = 50
Survivalist02 = 50
Survivalist03 = 50
---
outfitGrpCD = Militia
PrivateMilitia = 50
ArmyCamoDesert = 50
ArmyInstructor = 0
ArmyServiceUniform = 50
---
outfitGrpCD = Spiffo
Spiffo = 50
---
outfitGrpCD = Santa
Santa = 50
---
outfitGrpCD = costume
Spiffo = 50
Santa = 50
---
outfitGrpCD = Naked
Naked = 50
]]

end