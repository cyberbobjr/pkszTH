pkszTHsetup = {}

pkszTHsetup.eventModsList = {}

pkszTHsetup.fn = {}
pkszTHsetup.fn.eventMods = "_eventMods.txt"
pkszTHsetup.fn.autoCategory = "_autoCategory.txt"
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
pkszTHsetup.activateModsByfID = {}

pkszTHsetup.ready = function()

	pkszTHsetup.EventFileVersionCheck()

end

pkszTHsetup.EventFileVersionCheck = function()

	local current = "pkszTHv202403"

	if SandboxVars.pkszTHopt.eventSelectFileVer == 1 then
		pkszTHsv.EventFileVerOpt = 1
		current = "pkszTHv202403"
	elseif SandboxVars.pkszTHopt.eventSelectFileVer == 2 then
		pkszTHsv.EventFileVerOpt = 2
		current = "pkszTHvE202403"
	end

	pkszTHsv.EventFileVer = current
	pkszTHsetup.baseDir = "/" .. pkszTHsv.EventFileVer
	if not isServer() then
		pkszTHsetup.baseDir = pkszTHsetup.baseDir .. "single"
	end

end

-- file load
pkszTHsetup.eventFileLoader = function()

	pkszTHsv.logger("-- start event File loading --",true)

	pkszTHsetup.dataCheck = {}
	pkszTHsetup.dataCheck["cordinates"] = 0
	pkszTHsetup.dataCheck["event"] = 0
	pkszTHsetup.dataCheck["loadOut"] = 0
	pkszTHsetup.dataCheck["loadOutRandom"] = 0
	pkszTHsetup.dataCheck["loadOutRandomGP"] = 0
	pkszTHsetup.dataCheck["zedOutfitGrp"] = 0


	local eventMods = pkszTHsetup.fileExist(pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.eventMods)
	if eventMods then
		pkszTHsetup.operateEventMods(eventMods)
		eventMods:close()
		if pkszTHsetup.eventModsList then
			pkszTHsetup.setupEvents()
		end
	end

	-- autoCategory
	-- local autoCategory = pkszTHsetup.fileExist(pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.autoCategory)
	-- if autoCategory then
	-- 	pkszTHsetup.operateAutoCategory(autoCategory)
	-- 	autoCategory:close()
	-- end

end

pkszTHsetup.setupEvents = function()

	pkszTHsetup.fileCheck = {}

	local eventModsList = pkszTHsetup.eventModsList
	local eventDataFiles = pkszTHsetup.fnm

	pkszTHsv.Events = {}

	for ModId, fHeader in pairs(eventModsList) do
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
				pkszTHsv.logger("Eventdatafile loading :"..thisFn,true)
			end
		end
	end

	-- eventIDs
	pkszTHsv.EventIDs = {}
	pkszTHsv.EventNum = 0
	for key in pairs(pkszTHsv.Events) do
		pkszTHsv.EventNum = pkszTHsv.EventNum + 1
		pkszTHsv.EventIDs[pkszTHsv.EventNum] = key
		pkszTHsv.logger(pkszTHsv.EventNum .." : Event ID Ready = "..key,true)
	end


	--debug
	--for key in pairs(pkszTHsv.Events) do
	--	pkszTHsv.logger("Ready Event ID = "..key,true)
	--end
	--detacheck
	for key in pairs(pkszTHsetup.dataCheck) do
		pkszTHsv.logger("Data count "..key.." : "..pkszTHsetup.dataCheck[key],true)
		if pkszTHsetup.dataCheck[key] == 0 then
			pkszTHsv.logger("ERROR Event data "..key.." is zero. " ,true)
			pkszTHsv.errorhandling("pkszTH - server : Date File Error " ,true)
		end
	end

end

-- file check and install
pkszTHsetup.eventFileCheck = function()

	-- Processing to install when the event file is not installed, mainly when starting for the first time

	pkszTHsetup.ve = {}

	local filename = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.eventMods
	local eventMods = pkszTHsetup.fileExist(filename)
	if not eventMods then
		print("event file deploy start ",filename)
		pkszTHsetup.eventFileDeploy()
	else
		eventMods:close()
	end

	-- deploy AutoCategory
	-- local autoCategory = pkszTHsetup.fileExist(pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.autoCategory)
	-- if not autoCategory then
	-- 	pkszTHsetup.autoCategoryDeploy()
	-- else
	-- 	autoCategory:close()
	-- end

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
				eventID = value
				pkszTHsv.Events[eventID] = {}
				pkszTHsetup.dataCheck["event"] = pkszTHsetup.dataCheck["event"] + 1
			else
				-- print("Events key = "..key)
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
		local rec = pkszTHsv.strSplit(line,"=")
		if #rec == 2 then
			local key = string.gsub(rec[1], "^%s*(.-)%s*$", "%1")
			local value = string.gsub(rec[2], "^%s*(.-)%s*$", "%1")
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
		local rec = pkszTHsv.strSplit(line,"=")
		if #rec == 2 then
			local key = string.gsub(rec[1], "^%s*(.-)%s*$", "%1")
			local value = string.gsub(rec[2], "^%s*(.-)%s*$", "%1")
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

    local ga_mods = getActivatedMods()
	local mods = {}
    for i=ga_mods:size()-1, 0, -1 do
        local modn = ga_mods:get(i)
		mods[modn] = modn
    end

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
			-- pkszTHsv.logger("Mod Check..."..ModId ,true)
			if ModId == "vanilla" then
				pkszTHsv.logger("Event Mod Active ["..ModId.."] / fileHeader = "..fHeader ,true)
				pkszTHsetup.eventModsList[ModId] = fHeader
				pkszTHsetup.activateModsByfID[fHeader] = ModId
			else
				if mods[ModId] then
					pkszTHsv.logger("Event Mod Active ["..ModId.."] / fileHeader = "..fHeader ,true)
					pkszTHsetup.eventModsList[ModId] = fHeader
					pkszTHsetup.activateModsByfID[fHeader] = ModId
				else
					pkszTHsv.logger("Notis MOD not activated = "..ModId ,true)
				end
			end
		end
    until true end

end

pkszTHsetup.operateAutoCategory = function(file)



	local modID = ""

    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end
		local rec = pkszTHsv.strSplit(line,"=")
		if #rec == 2 then
			local key = string.gsub(rec[1], "^%s*(.-)%s*$", "%1")
			local value = string.gsub(rec[2], "^%s*(.-)%s*$", "%1")
			if key == "ModFileHeaderName" then
				if pkszTHsetup.activateModsByfID[value] then
					modID = pkszTHsetup.activateModsByfID[value]
					-- print("get modID "..modID)
				end
			else
				local rec2 = pkszTHsv.strSplit(value,"/")
				local loadOutCd = rec2[2]
				pkszTHsv.autoCategorys[loadOutCd] = {modId=modID,subject=key,param=rec2[1]}
				pkszTHsv.logger("add Auto Category :"..modID.." [ "..key.." = "..rec2[1].." ] -> "..loadOutCd,true)
			end
		end
    until true end

end

pkszTHsetup.fileWriter = function(fn,text)

	if not text then return end
	if not fn then return end

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
-- This is the default setting
-- When customizing an event, please edit the files in the USER folder
-- When customizing an event, please edit the files in the USER folder
-- When customizing an event, please edit the files in the USER folder
-- thank you
------------------------------------------------------------
------------------------------------------------------------

pkszTHsetup.autoCategoryDeploy = function()

local text = [[-- "--" is can be used as a comment out
-- Automatically adds all items in the specified category of the specified Mod
-- To use it, write the following in the "loadOut" or "randomLoadOut" file
-- auto = [auto category name]
-- 
-- !! This feature can be memory intensive and abuse is not recommended.
-- !! Depending on the MOD, there are some items that may cause problems when acquired.
-- but, this feature is attractive.
-- It can also looting as an Epic item using autoEpic
-- 
-- ModFileHeaderName = [ModFileHeder]
-- [subject] = [value]/[loadOutCD]
-- subject : DisplayCategory or type can be specified 
-- value : Keyword specified for the subject
-- loadOutCD : This is the calling code written in the loadOut file.
--
-- ex ) 
-- ModFileHeaderName = vanilla
-- DisplayCategory = Clothing/pzClothings
--     -> All vanilla clothes are available at pzClothings
-- ex ) 
-- ModFileHeaderName = AuthenticZ
-- DisplayCategory = Clothing/aZClothing
-- DisplayCategory = Accessory/aZAccessory
--     -> All AuthenticZ Clothing and accessories will appear
--        (AuthenticZ must be loaded and AuthenticZ must be specified as the header name)
--
--
--
ModFileHeaderName = vanilla
DisplayCategory = Bag/pzBags
DisplayCategory = SkillBook/pzSkillBooks
Type = Weapon/pzWeapons
Type = Clothing/pzClothings
Type = AlarmClockClothing/pzWatchs
]]

	local thisFileName = pkszTHsetup.baseDir.."/"..pkszTHsetup.fn.autoCategory
	local thisText = text
	pkszTHsetup.fileWriter(thisFileName,thisText)

end

pkszTHsetup.getVanillaEvent = function()

pkszTHsetup.ve = {}

pkszTHsetup.ve.eventMods = [[-- "--" is can be used as a comment out
-- Loads event files in order from top to bottom.
-- If specify an external MOD, it will not be loaded unless the MOD is active.
-- "pkszTH" is an already loaded mod, so you can use it at any time
-- modID/folder name
--
vanilla/vanilla
pkszTH/pkszTH
]]

pkszTHsetup.ve.log = ""
pkszTHsetup.ve.history = ""

---------------------------------------
---------------------------------------
-- event
---------------------------------------
pkszTHsetup.ve.event = [[-- "--" is can be used as a comment out
-- eventTimeout = 6 is 1 hour in-game / 30 = 5 hour in-game
-- eventType is currently defunct
-- 
eventID = foodaid
eventDescription = Food aid
eventNote = Week's worth of food
eventType = nomal
eventTimeout = 180
HordeDensity = 10
InventoryItem = Base.Bag_MedicalBag
loadOutSelectCD = foodaid
cordListSelectCD = food,common
leaderOutfit = Trader
-- = 
eventID = fleshfood
eventDescription = Fresh food supply
eventNote = It's raw. Hurry up collect it
eventType = nomal
eventTimeout = 180
HordeDensity = 12
InventoryItem = Base.Cooler
loadOutSelectCD = fleshfood
cordListSelectCD = food,common
leaderOutfit = worker
-- = 
eventID = preservedfood
eventDescription = Preservative food supply
eventNote = Grandmother's handiwork.
eventType = nomal
eventTimeout = 180
HordeDensity = 12
InventoryItem = Base.Bag_DuffelBagTINT
loadOutSelectCD = preservedfood
cordListSelectCD = food,common
leaderOutfit = Farmer
-- = 
eventID = junkfood
eventDescription = Junk food
eventNote = It smells delicious. Zombies probably think so too.
eventType = nomal
eventTimeout = 180
HordeDensity = 18
InventoryItem = Base.Lunchbox
loadOutSelectCD = junkfood
cordListSelectCD = food,common
leaderOutfit = Police
-- = 
eventID = civilarm
eventDescription = Civil armament
eventNote = Be careful, okay?
eventType = nomal
eventTimeout = 180
HordeDensity = 20
InventoryItem = Base.PistolCase1
loadOutSelectCD = civilarm
cordListSelectCD = civilWeapon,ComeToLouisville,common
leaderOutfit = Survivor
-- = 
eventID = milarm
eventDescription = Military armament
eventNote = Be very careful you
eventType = nomal
eventTimeout = 180
HordeDensity = 24
InventoryItem = Base.RifleCase1
loadOutSelectCD = milarm
cordListSelectCD = militaryWeapon,ComeToLouisville,common
leaderOutfit = Militia
-- = 
eventID = gunmisc
eventDescription = Military supply
eventNote = That's Dangerous place
eventType = nomal
eventTimeout = 180
HordeDensity = 16
InventoryItem = Base.Toolbox
loadOutSelectCD = gunmisc
cordListSelectCD = civilWeapon,militaryWeapon,common
leaderOutfit = Survivor
-- = 
eventID = ammos
eventDescription = Ammunition supply
eventNote = This time the supply is only ammunition.
eventType = nomal
eventTimeout = 180
HordeDensity = 20
InventoryItem = Base.Bag_ShotgunBag
loadOutSelectCD = ammos
cordListSelectCD = civilWeapon,militaryWeapon,common
leaderOutfit = Survivor
-- = 
eventID = melee
eventDescription = Survivor's armament
eventNote = Don't neglect maintenance
eventType = nomal
eventTimeout = 180
HordeDensity = 12
InventoryItem = Base.Bag_GolfBag
loadOutSelectCD = melee
cordListSelectCD = supply,common
leaderOutfit = rogue
-- = 
eventID = support
eventDescription = Rescue supply
eventNote = We send relief supplies
eventType = nomal
eventTimeout = 180
HordeDensity = 12
InventoryItem = Base.Bag_NormalHikingBag
loadOutSelectCD = support
cordListSelectCD = supply,common
leaderOutfit = worker
-- = 
eventID = beginner
eventDescription = Welcome to Knox!
eventNote = To survive the beginning...
eventType = nomal
eventTimeout = 180
HordeDensity = 6
InventoryItem = Base.Bag_SurvivorBag
loadOutSelectCD = beginner
cordListSelectCD = mforest,beginner,clothing
leaderOutfit = Mix
-- = 
eventID = survival
eventDescription = Survival goods supply
eventNote = Get ready to self-sufficient life
eventType = nomal
eventTimeout = 180
HordeDensity = 8
InventoryItem = Base.Bag_SurvivorBag
loadOutSelectCD = survival
cordListSelectCD = mforest,beginner,supply
leaderOutfit = Mix
-- = 
eventID = fashion
eventDescription = Apocalypse fashion
eventNote = We also included branded trend.
eventType = nomal
eventTimeout = 180
HordeDensity = 8
InventoryItem = Base.Suitcase
loadOutSelectCD = fashion
cordListSelectCD = supply,clothing,common
leaderOutfit = Young
-- = 
eventID = party
eventDescription = Party support
eventNote = Who are you celebrating?
eventType = nomal
eventTimeout = 180
HordeDensity = 8
InventoryItem = Base.Bag_DoctorBag
loadOutSelectCD = party
cordListSelectCD = food,common
leaderOutfit = Young
-- = 
eventID = funbox
eventDescription = Lucky Seven Box
eventNote = It depends on your luck!
eventType = nomal
eventTimeout = 180
HordeDensity = 10
InventoryItem = Base.Bag_Schoolbag
loadOutSelectCD = funbox
cordListSelectCD = common
leaderOutfit = costume
-- = 
eventID = candy
eventDescription = Happy Candy Supply :)
eventNote = From sweetie
eventType = nomal
eventTimeout = 180
HordeDensity = 8
InventoryItem = Base.Bag_Satchel
loadOutSelectCD = candy
cordListSelectCD = food,common
leaderOutfit = costume
-- = 
eventID = horde
eventDescription = What a Hell... help... I need help....
eventNote = Risk : Very difficult
eventType = nomal
eventTimeout = 180
HordeDensity = 80
InventoryItem = Base.Bag_ALICEpack
loadOutSelectCD = horde
cordListSelectCD = largeplace,mforest
leaderOutfit = Mix
-- = 
eventID = roomhorde
eventDescription = Kill them all!
eventNote = Risk : Very difficult
eventType = nomal
eventTimeout = 180
HordeDensity = 50
InventoryItem = Base.Bag_ALICEpack
loadOutSelectCD = horde
cordListSelectCD = largeRoom
leaderOutfit = Mix
-- = 
eventID = cqc
eventDescription = Are you good at CQC?
eventNote = Risk : Be ready to DIE
eventType = nomal
eventTimeout = 180
HordeDensity = 46
InventoryItem = Base.Bag_ALICEpack
loadOutSelectCD = horde
cordListSelectCD = largeRoom,CQC
leaderOutfit = Mix
-- = 
eventID = smallhorde
eventDescription = Reports ...of small hords
eventNote = Reported about 30 zombies
eventType = nomal
eventTimeout = 180
HordeDensity = 32
InventoryItem = Base.Bag_DuffelBag
loadOutSelectCD = smallhorde
cordListSelectCD = largeRoom,CQC,largeplace
leaderOutfit = Mix
-- = 
eventID = worsttrip
eventDescription = Really worst trip
eventNote = I hope there's still a road connected
eventType = nomal
eventTimeout = 180
HordeDensity = 16
InventoryItem = Base.Bag_BigHikingBag
loadOutSelectCD = worsttrip
cordListSelectCD = nowhere
leaderOutfit = Camper
-- = 
]]


---------------------------------------
---------------------------------------
-- cordinates
---------------------------------------
pkszTHsetup.ve.cordinates = [[-- "--" is can be used as a comment out
--
-- x,y,z,spawnRadius,zombioOutfit,description
--
-- Please note that "," cannot be used in the description.
-- 
cordListCD = error
9000,9000,0,3,None,get coordinate failed
--
--
cordListCD = food
13946,2245,0,1,None,Kept in the stockroom
13248,1698,1,1,None,Find the president's office
13012,5263,0,2,None,Find poker table
12985,2026,0,3,medic,Emergency way
12975,2022,0,3,medic,Nurses station
12956,2001,0,3,medic,autopsy room
12946,2081,0,3,medic,Front reception
12538,5292,0,1,None,Here is the to pay
12528,1545,1,2,Officeworker,2F Staircase
13913,5765,0,4,teenager,Food court
13891,6689,0,2,Camper,Pond campsite
13849,6767,0,2,None,Cafeteria
13804,6751,0,3,Student,Be careful zombies
13603,5753,0,2,None,Crepe kitchen
12073,6796,1,5,None,2nd floor of the bar
12073,6796,0,3,None,Restroom
12067,6796,0,5,None,bartender counter
12062,6797,0,4,None,back room
11977,6815,0,2,teenager,Inside Spiffo
11666,8296,0,2,None,Inside Spiffo
11665,8798,0,3,Trader,Food market
11664,7085,0,1,Young,Let's go buy pizza
11656,7083,0,1,Young,Let's go buy pizza
10851,9761,0,3,Trader,Food market
10846,10029,0,3,Trader,store
10652,9922,0,1,None,Here is the to pay
10632,9768,0,1,None,Here is the to pay
10620,9608,0,1,None,Here is the to pay
10615,9562,0,1,None,Here is the to pay
10612,10251,0,2,Trader,Food market
10609,10457,0,1,None,Here is the to pay
10607,10114,0,1,Young,Let's go buy pizza
10606,10108,0,1,Young,Let's go buy pizza
10147,12750,0,1,None,Here is the to pay
10123,12794,0,1,None,Here is the to pay
8133,11485,0,1,None,Here is the to pay
8133,11482,0,1,None,Here is the to pay
8078,11311,0,1,Young,Let's go buy pizza
8074,11311,0,1,Young,Let's go buy pizza
8073,11344,0,3,None,Inside Spiffo
8071,11315,0,1,Young,Let's go buy pizza
7663,11872,0,2,Naked,Courtyard
7644,11887,0,2,None,cafeteria
7401,8333,0,3,Camper,Be careful zombies
6514,5358,0,1,None,Here is the to pay
6514,5350,0,1,None,Here is the to pay
6492,5265,0,1,None,Here is the to pay
6477,5309,0,1,None,Here is the to pay
6120,5303,0,3,teenager,Inside Spiffo
3852,6197,2,2,rogue,3rd floor dining
7134,8976,0,1,None,Here is the to pay
5463,9575,0,1,None,Here is the to pay
10618,10561,0,1,exercise,Be careful zombies
10165,12658,0,1,None,Be careful zombies
10657,9981,0,2,exercise,Be careful zombies
--
--
cordListCD = civilWeapon
13946,3234,0,5,None,Gun shop backyard
13593,3023,0,1,Officeworker,SDB Room
13573,1297,0,3,None,Ground floor. Stand by me?
13406,5336,0,4,Camper,In the forest Hunting stand
13403,5344,0,6,Camper,In the forest Hunting stand
13328,5450,0,4,None,Behind the shooting target
13115,5300,0,2,Mix,Hunting Logde
13109,5299,0,3,Camper,Hunting Logde
13100,5304,0,4,Camper,Hunting Logde
13092,5125,0,3,None,Hunter hut
13091,5120,0,4,Camper,Hunter hut
13090,5122,0,4,Camper,Hunter hut
12550,1551,0,2,OfficeworkerSkirt,Completed speech draft?
12331,1264,0,3,Dress,Staff Room
12309,1277,0,3,Dress,bar counter
13995,5864,2,1,Bandit,Up floor stockroom
11934,6863,0,1,OfficeworkerSkirt,Completed speech draft?
10966,9162,0,3,Bandit,Be careful zombies
10061,9571,0,3,worker,Be careful zombies
8060,11678,0,1,OfficeworkerSkirt,Completed speech draft?
4644,8109,0,3,Survivor,public lavatory
4277,7289,0,1,Survivor,under the tree
3857,6173,2,2,rogue,Garage
3836,6207,1,1,rogue,Control room
3830,6215,0,4,rogue,workshop
5439,9678,0,3,PrivateMilitia,want to join the military?
5440,9685,0,3,PrivateMilitia,want to join the military?
10658,10014,0,3,exercise,walk-in participant
--
--
cordListCD = militaryWeapon
12596,4201,0,1,PrivateMilitia,Approach from the west
12446,4350,0,1,PrivateMilitia,Be careful zombies
13957,3227,0,5,None,Gun shop
13780,2561,0,2,Police,Police Station
13601,3030,0,1,Officeworker,VIP room
10642,10401,0,2,Police,Police Station
7801,11818,0,1,Police,escapee's lost article
7700,11857,0,3,Police,Patrol passage
7662,11890,0,2,Police,Courtyard
5439,9678,0,3,PrivateMilitia,want to join the military?
5440,9685,0,3,PrivateMilitia,want to join the military?
--
cordListCD = supply
13593,3029,1,1,Officeworker,2nd floor break room
13401,5343,0,4,Camper,Near hunting stand
12985,2026,0,3,medic,Emergency way
12964,2028,0,3,medic,main hall
12946,2081,0,3,medic,Front reception
12930,2030,1,3,medic,2nd floor ward
13891,6689,0,2,Camper,campground
12414,9007,0,2,Survivor,abandoned forest hut
11249,8947,0,3,Survivor,One tree near forest hut
10642,10401,0,2,Police,Police Station
7663,11872,0,2,Naked,Courtyard
3836,6207,1,1,rogue,Control room
5439,9678,0,3,PrivateMilitia,want to join the military?
5440,9685,0,3,PrivateMilitia,want to join the military?
7134,8976,0,1,None,Here is the to pay
5463,9575,0,1,None,Here is the to pay
--
cordListCD = medic
12948,2008,1,3,medic,linen room
12944,2053,0,3,medic,Dispensing pharmacy
12924,2068,0,3,medic,Head doctor office
13891,6689,0,2,Camper,camp site
13849,6767,0,2,None,Cafeteria
10642,10401,0,2,Police,Police Station
7660,11896,0,1,Police,library
3836,6207,1,1,rogue,Control room
--
cordListCD = clothing
12311,1248,0,3,None,empty tenant
12310,1261,0,3,Dress,VIP pole
11860,6886,0,2,teenager,Be careful zombies
11740,8865,0,3,Biker,Be careful zombies
11600,8249,0,3,None,apparel shop
10631,9906,0,2,teenager,apparel shop
10616,10155,0,3,teenager,apparel shop
10613,9436,0,2,Young,apparel shop
10612,10372,0,3,teenager,apparel shop
10068,12816,0,2,teenager,apparel shop
6506,5261,0,1,None,Here is the to pay
--
cordListCD = largeplace
13733,6042,0,10,None,Horde is comming
12677,6304,0,10,None,Horde is comming
12570,6569,0,10,None,Horde is comming
12256,7057,0,10,None,Horde is comming
11864,7203,0,10,None,Horde is comming
11631,8312,0,10,None,Horde is comming
11608,7919,0,10,None,Horde is comming
11521,11235,0,10,None,Horde is comming
10857,6908,0,10,None,Horde is comming
10619,8783,0,10,None,Horde is comming
10597,6677,0,10,None,Horde is comming
9642,12272,0,10,None,Horde is comming
8622,8106,0,10,None,Horde is comming
8234,11180,0,10,None,Horde is comming
13839,5655,0,7,None,Horde is comming
14255,5794,0,7,None,Horde is comming
--
cordListCD = beginner
12073,6914,0,3,worker,Be careful zombies
11987,7105,0,3,None,In the usual place
11960,6675,0,3,None,In the usual place
11890,6628,0,3,None,In the usual place
11739,6646,0,3,None,In the usual place
11656,6990,0,3,None,In the usual place
11549,6665,0,3,None,In the usual place
11451,8830,0,1,Police,Be careful zombies
11365,6614,0,3,None,In the usual place
11297,6617,0,3,None,In the usual place
11207,6678,0,3,None,In the usual place
11153,6917,0,3,None,In the usual place
10929,9646,0,3,None,In the usual place
10897,9343,0,3,None,In the usual place
10889,6725,0,3,None,In the usual place
10886,9781,0,3,None,In the usual place
10833,10476,0,3,None,In the usual place
10789,9565,0,3,None,In the usual place
10764,10480,0,3,None,In the usual place
10693,9232,0,3,None,In the usual place
10677,9979,0,3,None,In the usual place
10565,9377,0,3,None,In the usual place
10539,9163,0,3,None,In the usual place
10513,10419,0,3,None,In the usual place
10509,10275,0,3,None,In the usual place
10483,9494,0,4,Survivor,Be careful zombies
10246,11009,1,2,Bandit,On the catwalk
8570,11558,0,3,None,In the usual place
8520,11740,0,3,None,In the usual place
8515,11875,0,3,None,In the usual place
8514,11645,0,3,None,In the usual place
8496,11886,0,3,None,In the usual place
8458,11880,0,3,None,In the usual place
8389,11883,0,3,None,In the usual place
8072,12275,0,3,Farmer,In the usual place
8071,12039,0,3,Farmer,In the usual place
8049,11843,0,3,Farmer,In the usual place
7952,12117,0,3,Farmer,In the usual place
7383,6410,0,3,None,In the usual place
7342,6641,0,3,None,In the usual place
7214,5501,0,3,Farmer,In the usual place
6994,5449,0,3,None,In the usual place
6859,5490,0,3,None,In the usual place
6801,5223,0,3,None,In the usual place
6657,5193,0,3,None,In the usual place
6413,5631,0,3,None,In the usual place
6281,5188,0,3,None,In the usual place
6278,5561,0,3,None,In the usual place
6128,5189,0,3,None,In the usual place
6032,5192,0,2,None,In the usual place
5907,5207,0,3,None,In the usual place
5863,5337,0,3,None,In the usual place
5859,5525,0,2,None,In the usual place
--
cordListCD = nowhere
14434,2177,0,1,Mix,Be ready for everything.
14432,2143,0,1,Mix,Be ready for everything.
14405,2125,0,3,Mix,Be ready for everything.
14009,6987,0,3,Mix,Be ready for everything.
13913,6732,0,3,Mix,Be ready for everything.
13632,7224,0,2,Mix,Be ready for everything.
7606,11967,0,2,Mix,Be ready for everything.
7593,11969,0,3,Mix,Be ready for everything.
6730,6182,0,4,Mix,Be ready for everything.
5544,12499,0,2,Mix,Be ready for everything.
5538,12471,0,2,Mix,Be ready for everything.
5011,8038,0,3,Mix,Be ready for everything.
4884,7863,0,3,Mix,Be ready for everything.
4645,8181,0,3,Mix,Be ready for everything.
4596,8311,0,2,Naked,Be ready for everything.
4534,7998,0,3,Mix,Be ready for everything.
4319,8226,0,3,Mix,Be ready for everything.
4234,7236,0,1,Mix,Be ready for everything.
4072,8154,0,1,Mix,Be ready for everything.
4061,8132,0,5,Mix,Be ready for everything.
4975,8712,0,5,Survivor,Be ready for everything.
4753,7536,0,5,Survivor,Be ready for everything.
4397,7247,0,5,Survivor,Be ready for everything.
4240,8431,0,5,Survivor,Be ready for everything.
4112,7854,0,5,Survivor,Be ready for everything.
--
cordListCD = largeRoom
12312,3256,0,3,None,Let's Roll
12864,4955,0,2,None,Let's Roll
12422,3065,0,4,None,Let's Roll
11977,6981,0,2,None,Let's Roll
11933,6871,0,3,None,Let's Roll
11826,9769,0,3,None,Let's Roll
11668,10030,0,3,None,Let's Roll
11602,8256,0,3,None,Let's Roll
11377,6781,0,3,None,Let's Roll
10335,12808,0,3,None,Let's Roll
10335,9257,0,3,None,Let's Roll
10312,9258,0,3,None,Let's Roll
10300,9257,0,2,None,Let's Roll
10050,12719,0,3,None,Let's Roll
8064,11678,0,3,None,Let's Roll
7421,8383,0,3,None,Let's Roll
7413,8382,0,3,None,Let's Roll
6584,5214,0,3,None,Let's Roll
6565,5308,0,4,None,Let's Roll
6459,5465,0,4,None,Let's Roll
5768,6442,0,4,None,Let's Roll
5583,5908,0,3,None,Let's Roll
--
cordListCD = ComeToLouisville
12662,3714,0,2,Mix,Come to Louisville!
12634,3940,0,5,None,Come to Louisville!
12127,3465,0,2,None,Come to Louisville!
13211,3524,0,1,rogue,Come to Louisville!
12642,3303,0,3,None,Come to Louisville!
12575,3270,0,3,Mix,Come to Louisville!
12341,3250,0,2,None,Come to Louisville!
12326,3255,0,1,None,Come to Louisville!
12664,3450,0,6,Biker,Come to Louisville!
12801,2620,0,6,Biker,Come to Louisville!
12741,2614,0,6,Biker,Come to Louisville!
12645,2984,0,6,Biker,Come to Louisville!
13713,3630,0,3,Young,Come to Louisville!
13619,3824,0,3,Farmer,Come to Louisville!
12119,2254,0,3,Survivor,Come to Louisville!
--
cordListCD = CQC
10700,10361,0,4,None,The target is 1F
10700,10365,0,4,None,The target is 1F
10678,10361,0,4,None,The target is 1F
10680,10313,0,3,None,The target is 1F
10031,12738,1,4,None,The target is 2F
10033,12733,1,4,None,The target is 2F
10001,12653,1,4,None,The target is 2F
8346,11611,0,4,None,The target is 1F
8341,11612,0,4,None,The target is 1F
8067,11660,0,4,None,The target is 1F
7674,11884,0,4,None,Target is courtyard
5736,6447,1,4,None,The target is 2F
6582,5226,1,5,None,The target is 2F
11524,9652,0,4,None,The target is 1F
12143,7094,0,4,None,The target is 1F
12628,3751,1,4,None,The target is 2F
12564,3698,1,4,None,The target is 2F
11315,6784,1,4,None,The target is 2F
11313,6774,1,4,None,The target is 2F
10311,9337,0,4,None,The target is 1F
3864,6203,2,6,None,The target is 3F
10095,12619,1,4,None,The target is 2F
10070,12625,2,5,None,The target is 3F
10082,12632,3,6,None,The target is 4F
--
cordListCD = mforest
12150,7238,0,6,Mix,Walking dead in forest
12104,7296,0,6,Mix,Walking dead in forest
10516,7066,0,6,Mix,Walking dead in forest
10049,6905,0,6,Mix,Walking dead in forest
9557,7322,0,6,Mix,Walking dead in forest
8687,11283,0,6,Mix,Walking dead in forest
7240,6102,0,6,Mix,Walking dead in forest
8084,7567,0,6,Mix,Walking dead in forest
12987,5140,0,6,Mix,Walking dead in forest
13263,6820,0,6,Mix,Walking dead in forest
11546,9076,0,6,Mix,Walking dead in forest
10697,9151,0,6,Mix,Walking dead in forest
10457,10211,0,6,Mix,Walking dead in forest
8542,8413,0,6,Mix,Walking dead in forest
8586,8202,0,6,Mix,Walking dead in forest
11150,9530,0,6,Mix,Walking dead in forest
11197,9456,0,6,Mix,Walking dead in forest
--
cordListCD = common
8241,12233,0,7,Survivor,bye-bye bus
13895,5830,0,6,None,Today is special sale!
13957,5834,0,6,None,Today is special sale!
13894,5771,0,6,None,Today is special sale!
6344,5235,0,2,beach,Be careful zombies
5765,6473,0,2,beach,Be careful zombies
5785,6485,0,2,beach,Be careful zombies
3716,5697,0,2,beach,Be careful zombies
10717,10100,0,3,None,Be careful zombies
10714,10094,0,1,None,Be careful zombies
12663,4622,0,6,Biker,Along railroad
12661,4814,0,6,Biker,Stopped ringing Crossing
12656,4354,0,6,Biker,Stopped ringing Crossing
12620,6382,0,6,Biker,Along railroad
12292,6700,0,6,Biker,Along railroad
12181,7171,0,6,Biker,Stopped ringing Crossing
12177,6855,0,6,Biker,Along railroad
12105,8317,0,6,Biker,Along railroad
12103,9308,0,6,Biker,Along railroad
11898,10361,0,6,Biker,Along railroad
11897,11196,0,6,Biker,Along railroad
11885,11483,0,6,Biker,Along railroad
11645,9624,0,6,Biker,Along railroad
12988,5159,0,3,None,Bit into the fores
12988,5313,0,2,Survivor,riverside chair
12965,5453,0,1,Survivor,riverside
12953,5134,0,2,None,rive side
12665,5359,0,3,None,Stopped ringing Crossing
12664,5347,0,3,None,Stopped ringing Crossing
12663,4035,0,6,Biker,Along railroad
12646,4345,1,2,None,2nd floor of the bar
12579,4112,0,3,Mix,Be careful zombies
12555,4157,0,3,Mix,Be careful zombies
12453,4979,0,2,None,River side
14598,3449,0,4,PrivateMilitia,Median divider
14570,4972,0,4,Mix,Really wish.Rest in peace
14526,4012,0,2,PrivateMilitia,Army Checkpoint
14512,3449,0,6,None,Median divider
14508,3932,0,4,Mix,Corn farm
14484,4269,0,8,Farmer,shade of trees along filed  
14314,5478,0,3,Farmer,Be careful zombies
14140,4291,0,8,Farmer,Outer of field
14139,2622,0,5,worker,Hedge
14124,2758,0,2,None,park
14061,5215,0,2,None,Near the pond
13964,4867,0,1,None,Be careful zombies
13959,3555,0,2,None,Pig farm
13937,4864,0,1,None,Be careful zombies
13863,1198,0,2,None,Rive side
13850,3264,0,2,Mix,woods road
13837,2146,0,2,Survivor,Pond side
13759,5029,0,3,Farmer,Be careful zombies
13758,1614,0,4,Constructionworker,Construction site
13720,2918,0,2,None,Neighborhood
13715,3688,0,5,Mix,maze central
13712,3577,0,4,None,main stage
13710,2778,0,1,Student,Pool side
13705,2799,0,3,None,men's
13703,4560,0,8,Farmer,Outer of field
13702,1985,0,8,Dress,beside the stage
13678,2547,0,2,None,eternal vow
13660,1769,0,2,Fireman,Be careful zombies
13630,4015,0,5,Naked,burnt down house
13598,3018,0,3,None,reception desk
13596,1897,0,3,None,Be careful zombies
13577,2908,0,3,None,baron on horseback
13574,2899,0,2,Dress,Couple date location. still lingers
13572,1576,1,2,Officeworker,Knox Radio 2F
13564,2756,0,2,teenager,classroom
13558,5130,0,8,Farmer,in the field
13356,5108,0,8,Farmer,in the field
13354,3073,1,2,Officeworker,2F Boardroom
13260,5445,0,1,None,Be careful zombies
13249,2414,0,3,None,Deepest of park road
13235,2289,0,4,None,golf course bunker sand
13228,2587,0,1,None,Bench on Plank Bridge
13222,2573,0,1,Naked,Along the lake
13107,2828,0,2,Dress,Couple date location. still lingers
13091,5452,0,1,None,Be careful zombies
13090,5322,0,1,None,Be careful zombies
13090,3091,0,3,None,The park
13082,2022,0,5,None,Nursing home
13066,5485,0,3,None,Along roadside
13062,2650,0,3,None,Park west
13055,2003,0,2,None,Nursing home cafeteria
13032,5069,0,3,None,Forest Behind Someone House
13008,2226,0,5,worker,Hedge
13003,5266,0,2,worker,Bar counter
12985,1541,0,4,Naked,left-handed hitter
12983,1130,0,2,None,Be careful zombies
12967,1538,2,2,Mix,broadcast room
12942,2113,0,2,Dress,Couple date location. still lingers
12926,2012,2,3,medic,Operating room
12874,1698,0,3,Mix,Warehouse
12870,4856,0,1,None,Let's go to school
12867,1689,0,3,Mix,Indoor court
12866,4867,0,2,None,teachers
12859,4855,0,1,None,Let's go to school
12858,2839,1,2,rogue,2F lounge
12852,2052,0,1,None,Be careful zombies
12848,4877,0,1,None,Let's go to school
12840,4391,0,1,None,Be careful zombies
12823,4792,0,4,Student,Be careful zombies
12794,2419,4,1,Mix,Top floor
12786,2500,2,4,None,Cat walk
12765,1595,0,4,None,Be careful at open the door
12764,4402,0,4,None,There is a risk of death
12739,4183,0,1,None,Be careful zombies
12730,1443,0,2,None,Be careful zombies
12715,1614,0,4,None,Head office of Spiffo
12705,4130,0,2,Naked,Along the lake
12701,2720,0,3,PrivateMilitia,Be careful zombies
12639,1827,0,3,Mix,1F Main hall
12638,1536,0,5,worker,Be careful zombies
12618,3200,0,3,Mix,Really wish.Rest in peace
12617,1363,0,2,worker,1F Bar counter
12592,1004,0,2,PrivateMilitia,Be careful zombies
12574,5386,0,4,Bandit,Be careful zombies
12568,1678,1,1,None,2nd floor room
12542,5214,0,1,None,Be careful zombies
12479,5297,0,1,Naked,Be careful zombies
12458,1316,0,3,None,1F Movie theater
12425,1479,0,2,None,Really wish.Rest in peace
12404,1489,0,4,None,Be careful zombies
12363,1739,0,1,Fireman,Fire staiton side allay
12325,2200,1,2,teenager,LSU 2F lounge
12225,2755,0,5,None,Horstruck
12217,1349,0,2,rogue,in the factory
12146,2694,3,3,Mix,Top Floor
12077,1437,3,4,Constructionworker,3rd floor near helipad
14345,5751,0,3,Police,Be careful zombies
13947,7395,0,2,None,River source
13891,6685,0,2,None,camp site
13891,5810,2,2,None,3rd floor empty tenant
13889,5799,2,2,Bandit,2F staff room
13859,6770,0,2,None,entrance room
13818,5654,0,3,Young,Be careful zombies
13698,6703,0,3,Young,Now. let's kick off
13698,6702,0,3,None,Center circle
13624,5871,2,2,None,rooftop
13566,5658,0,3,Bandit,Be careful zombies
13447,5680,0,3,None,Bit into the fores
13211,5705,0,3,None,Along roadside
13165,6406,0,2,Survivor,River side
12861,6761,0,3,None,rive side
12853,6345,0,4,Mix,Be careful zombies
12783,5810,0,1,Survivor,Be careful zombies
12730,8759,0,1,Survivor,Be careful zombies
12729,8760,0,1,Survivor,Be careful zombies
12665,5757,0,3,None,Stopped ringing Crossing
12664,5767,0,3,None,Stopped ringing Crossing
12619,5858,0,2,None,Be careful zombies
12307,6590,0,2,None,River side
12272,6929,0,1,None,1F Garage
12266,6927,1,1,None,2F Office
12264,6700,0,2,None,Be careful zombies
12198,6872,0,2,None,Welcome to Westpoint!
12178,7174,0,3,None,Stopped ringing Crossing
12150,7076,0,2,None,Need something torch light
12144,7098,0,1,None,Need something torch light
12135,7102,0,1,None,Be careful zombies
12102,9013,0,3,None,Be careful zombies
12066,7370,0,1,Mix,Be careful zombies
12051,7373,0,2,None,Picnic area
12050,6860,0,1,None,1F Stockroom
12048,7366,0,1,None,Be careful zombies
12041,6851,1,1,None,2F Office
12036,9463,0,3,None,Along railroad
12034,6852,1,1,None,2F Office
12016,7368,0,6,None,Picnic area
11992,1435,0,1,Mix,Be careful zombies
11990,6888,1,1,None,2F Office
11988,6940,2,1,OfficeworkerSkirt,3F roof balcony
11986,6946,1,1,None,2F Office
11977,6946,2,1,None,3F Office
11977,6885,0,1,None,1F Office
11972,6882,1,1,None,2F Staircase
11963,6876,0,1,None,baguette already sold out?
11953,6882,0,1,None,2F Mayor's room
11947,6889,1,1,None,2F Mayor's office
11946,6870,1,1,None,2F Office room
11946,6869,0,1,None,1F Hallway
11933,6983,0,2,Trader,Be careful zombies
11907,6940,0,2,Police,Summons from police
11907,6924,1,1,None,2F common room
11906,6944,0,1,Police,Summons from police
11902,6952,0,2,Police,Summons from police
11902,6916,1,1,None,2F Office
11897,10635,0,3,None,Along railroad
11896,6910,1,1,None,2F Office
11894,6914,0,2,Officeworker,secure room
11889,6949,0,2,Police,Summons from police
11826,6594,0,1,None,Be careful zombies
11821,6870,0,1,Police,Be careful zombies
11813,10418,0,3,None,Along railroad
11807,6654,0,3,None,Forest Behind Someone House
11769,8970,0,3,None,Be careful zombies
11740,8928,0,3,None,Be careful zombies
11736,6930,0,1,None,Let's go to school
11736,6924,0,1,None,Let's go to school
11735,10089,0,3,None,Be careful zombies
11735,10068,0,3,None,Be careful zombies
11727,6632,0,3,None,Forest Behind Someone House
11717,6852,0,3,None,Forest Behind Someone House
11707,8392,0,2,None,Hide out
11694,8273,0,3,None,Be careful zombies
11691,8363,0,1,None,Be careful zombies
11689,8379,0,3,None,Be careful zombies
11673,8779,0,7,None,Welcome to DIXIE
11629,9913,0,3,None,Be careful zombies
11621,9051,0,3,None,Stopped ringing Crossing
11620,9289,0,3,Mix,Be careful zombies
11610,10427,0,3,None,Stopped ringing Crossing
11599,10419,0,3,None,Stopped ringing Crossing
11598,8300,0,3,None,Be careful zombies
11588,10066,0,2,None,Be careful zombies
11586,10118,0,3,None,Be careful zombies
11566,8860,0,3,None,Be careful zombies
11552,8862,0,1,None,Be careful zombies
11551,8856,0,1,None,Be careful zombies
11545,8901,0,3,None,Be careful zombies
11544,6694,0,3,None,Forest Behind Someone House
11513,6678,0,3,None,Forest Behind Someone House
11470,8810,0,2,None,Be careful zombies
11465,8804,0,1,None,Be careful zombies
11456,8809,0,1,None,Be careful zombies
11373,6917,0,3,None,Forest Behind Someone House
11367,6663,0,3,None,Forest Behind Someone House
11347,6783,1,1,None,2F Common room
11342,6769,1,1,None,2F Daycare
11338,6917,0,3,None,Forest Behind Someone House
11332,6779,1,1,None,2F hallway
11259,6595,0,3,None,Be careful zombies
11241,8954,0,2,Mix,Be careful zombies
11102,9315,0,3,None,Stopped ringing Crossing
11099,9323,0,3,None,Stopped ringing Crossing
11091,6716,0,2,None,Be careful zombies
11091,6712,0,1,None,Be careful zombies
11087,9235,0,1,rogue,Be careful zombies
11071,9035,0,6,None,Be careful zombies
11066,6702,0,3,Mix,RIP someone
11065,6708,0,4,Naked,RIP somebody
11064,10640,0,3,None,Secret hut
11056,6708,0,3,Mix,whoever you are.
11039,9220,0,1,None,Be careful zombies
11022,10262,0,1,None,Be careful zombies
11020,10057,0,3,None,Along railroad
10981,10266,0,2,Naked,Along the lake
10976,10256,0,2,Naked,Along the lake
10943,6833,0,6,None,Be careful zombies
10940,6652,0,3,None,Be careful zombies
10932,9270,0,3,None,Be careful zombies
10922,9342,0,3,None,Forest Behind Someone House
10916,9841,0,2,worker,Be careful zombies
10909,6710,0,3,None,Forest Behind Someone House
10897,6691,0,3,None,Forest Behind Someone House
10857,9748,0,2,None,Be careful zombies
10848,9775,0,2,None,Be careful zombies
10809,8997,0,4,Farmer,Be careful zombies
10785,10171,0,4,None,Holy Grace
10765,10546,0,2,Biker,1F Strage
10697,10005,0,2,None,dressing room
10697,9833,0,3,None,Be careful zombies
10682,9827,0,3,None,Be careful zombies
10667,10615,0,3,OfficeworkerSkirt,ladies
10641,10408,0,3,Police,Summons from police
10635,10414,0,3,Police,Summons from police
10631,9703,1,1,None,2F Restroom
10630,9971,0,1,None,Let's go to school
10627,9981,0,1,None,Let's go to school
10626,9699,1,1,None,2F Office
10625,9692,1,1,None,2F Office
10623,9957,0,1,None,Let's go to school
10618,9964,0,1,None,Let's go to school
10616,9317,2,1,None,Roof top
10612,9310,1,1,None,2F Office
10604,10108,0,2,Trader,Pizza Have Hope?
10550,9697,0,3,None,Be careful zombies
10538,11172,0,5,None,Be careful zombies
10504,12891,0,6,Nurse,Be careful zombies
10479,7770,0,8,Farmer,Be careful zombies
10465,7753,0,5,None,Be careful zombies
10461,7355,0,3,None,Forest Behind Someone House
10448,12602,0,1,None,Be careful zombies
10374,10103,0,2,Constructionworker,Be careful zombies
10363,12384,0,3,None,Be careful zombies
10322,12787,0,3,None,Be happy. it's you.
10318,12787,0,2,Dress,Be happy. it's you.
10290,9390,1,3,Constructionworker,on the catwalk
10278,9589,0,1,rogue,Be careful zombies
10248,10361,0,2,Naked,Along the lake
10221,9888,0,3,rogue,Be careful zombies
10220,7291,0,3,None,Forest Behind Someone House
10197,7114,0,4,Survivor,Be careful zombies
10184,6765,0,2,Mix,Be careful zombies
10180,12782,0,2,worker,Be careful zombies
10176,12656,0,2,None,I put it in the toilet
10172,12728,0,3,None,Be careful zombies
10150,12716,0,2,worker,Be careful zombies
10140,8883,0,1,None,Be careful zombies
10117,12781,1,1,None,2F staff room
10081,12633,2,2,None,3F lounge
10079,12618,3,2,Mix,Top floor residence
10075,12782,0,1,Officeworker,Be careful zombies
10075,12618,0,2,None,1F Play room
10054,12751,1,1,None,2F Reading room
10047,7325,0,3,None,Forest Behind Someone House
10046,12743,1,1,None,2F Stockroom
10030,12716,1,1,None,2nd floor room
10016,12626,0,3,None,Open the door carefully
10009,10278,0,2,Naked,Along the lake
10007,12669,1,2,Naked,Not on the ground floor
10002,12643,0,1,Militia,Let's go to school
9995,10987,1,3,Constructionworker,Find the stairs going up
9994,12655,0,1,Student,Let's go to school
9884,13021,0,4,None,Be careful zombies
9832,13128,0,3,None,Be careful zombies
9768,12573,0,4,None,Be careful zombies
9761,13039,0,2,None,Be careful zombies
9730,12312,0,2,Dress,on the way
9664,8781,0,3,Camper,Don't pollute the well. okay?
9612,10152,0,4,None,Who will use this toilet?
9597,6783,0,3,Survivor,Be careful zombies
9449,9776,0,4,Farmer,Be careful zombies
9420,12335,0,2,Dress,on the way
9394,9289,0,2,None,Be careful zombies
9344,10295,0,4,Survivor,Be careful zombies
9337,8069,0,1,teenager,on the way
9335,6613,0,2,None,Be careful zombies
9334,8642,0,1,None,Boardinghouse
9330,8626,0,3,None,Be careful zombies
9324,9038,0,8,Farmer,Be careful zombies
9297,11622,0,8,Farmer,Be careful zombies
9283,7749,0,3,Farmer,Be careful zombies
9185,5354,0,1,None,Need something torch light
9153,9260,0,8,Farmer,Be careful zombies
8924,7899,0,8,Farmer,Be careful zombies
8861,11938,0,6,Farmer,Be careful zombies
8757,11395,0,4,Survivor,Be careful zombies
8621,11505,0,4,Survivor,Be careful zombies
8616,12456,0,6,Farmer,Be careful zombies
8553,8456,0,3,None,Forest Behind Someone House
8526,8834,0,6,Farmer,Be careful zombies
8479,11793,0,3,None,Forest Behind Someone House
8475,11702,0,3,None,Forest Behind Someone House
8462,12237,1,1,Mix,to projection room.
8419,8494,0,3,None,Forest Behind Someone House
8403,11531,0,1,Mix,Near residential area
8387,12229,0,3,None,Oh...show time has passed
8378,11604,0,3,Student,Be careful zombies
8376,11221,0,1,None,Along roadside
8375,7923,0,2,Dress,on the way
8352,11612,0,2,None,Let's go to school
8347,11604,0,1,None,Let's go to school
8334,11651,0,3,Student,Be careful zombies
8331,11641,0,3,Student,Be careful zombies
8331,11614,0,1,None,Let's go to school
8329,11621,0,1,None,Let's go to school
8329,11598,0,1,None,Let's go to school
8282,12216,0,4,None,Be careful zombies
8221,11864,0,6,None,Be careful zombies
8210,11880,0,3,Constructionworker,Be careful zombies
8194,12205,0,2,Naked,Along the lake
8194,8248,0,5,Farmer,Be careful zombies
8146,11471,1,1,None,2F Manager's room
8144,11489,1,2,None,2F cafeteria
8122,11543,0,3,None,Be happy.it's you.
8075,11660,1,1,None,2F Hallway
8075,11658,0,1,None,Enter the front and first
8074,11667,1,1,None,2F Office
8073,11647,0,1,None,guilty?
8072,11728,0,1,Police,Summons from police
8057,11747,0,1,Police,Summons from police
8057,11647,0,1,None,Judge Judy
8045,7115,0,2,None,Be careful zombies
8035,12307,0,8,Farmer,Be careful zombies
8026,7499,0,3,None,Be careful zombies
7989,12235,0,8,Farmer,Be careful zombies
7969,12098,0,3,Farmer,Be careful zombies
7961,10037,0,2,Farmer,Be careful zombies
7951,11473,0,3,None,Forest Behind Someone House
7946,10986,0,8,Farmer,Be careful zombies
7886,12474,0,3,Farmer,Be careful zombies
7886,12468,0,3,Farmer,Be careful zombies
7700,12348,0,3,None,Be careful zombies
7680,11486,0,4,Mix,Be careful zombies
7651,9353,0,2,Mix,Be careful zombies
7638,11436,0,5,None,Be careful zombies
7501,6209,0,1,None,Be careful zombies
7498,5330,0,2,None,Be careful zombies
7410,12336,0,2,None,Be careful zombies
7382,8354,0,4,None,Be happy.  it's me?
7352,8473,0,3,None,Forest Behind Someone House
7350,6460,0,3,None,Forest Behind Someone House
7338,5502,0,8,Farmer,Be careful zombies
7296,5980,0,3,None,Forest Behind Someone House
7262,8498,0,1,None,Fully enjoy countryside
7254,8382,0,1,None,Fully enjoy countryside
7254,8380,0,1,Police,Summons from police
7250,8523,0,1,None,Fully enjoy countryside
7235,8207,0,1,None,Fully enjoy countryside
7177,8985,0,6,None,Be careful zombies
7168,8497,0,3,None,Forest Behind Someone House
7112,6422,0,2,Dress,on the way
7108,5595,0,6,Farmer,Be careful zombies
7100,8111,0,2,Naked,Along the lake
7057,8328,0,3,None,Forest Behind Someone House
7051,8259,0,3,None,Forest Behind Someone House
7007,7797,0,3,Farmer,Be careful zombies
6894,5735,0,2,Dress,on the way
6882,7362,0,2,Naked,Along the lake
6774,9934,0,3,PrivateMilitia,Be careful zombies
6694,5243,0,4,rogue,behind the wall.
6664,6155,0,2,Mix,Be careful zombies
6613,5862,0,1,Mix,Be careful zombies
6597,5207,1,1,None,2F lounge
6594,5231,1,3,None,2F Room
6587,5205,0,1,None,1F lounge
6579,5239,1,1,None,2F Play room
6577,5374,0,4,None,Be happy. it's you?
6574,5216,1,2,None,2F lounge
6557,5239,0,5,worker,inside the hedge
6537,5307,0,2,Dress,Couple date location. still lingers
6516,5226,0,3,Dress,Couple date location. still lingers
6460,5465,0,2,None,Let's go to school
6454,5439,0,2,None,Let's go to school
6446,5205,0,3,None,Be careful zombies
6440,5217,0,5,worker,inside the hedge
6440,5210,0,2,Dress,Couple date location. still lingers
6422,5216,0,5,worker,inside the hedge
6421,5209,0,2,Dress,Couple date location. still lingers
6394,5204,1,1,None,2F Kitchen
6390,5210,1,1,None,2F Dining
6381,5216,0,3,Dress,1F hall
6377,5494,0,3,None,Be careful zombies
6372,5212,1,2,None,2F Terrace dining
6358,6576,0,2,Naked,Along the lake
6329,6777,0,2,Dress,on the way
6316,5266,1,2,None,2F Office
6308,5266,1,1,None,2F Office
6204,5252,0,4,None,Be careful zombies
6187,5362,0,1,None,Exam room
6186,5344,0,3,None,Kitchen
6186,5339,0,2,None,Hall
6185,6380,0,5,None,golf course cafe
6172,6377,1,1,None,golf course cafe
6087,5257,0,1,Police,Summons from police
6081,5261,0,1,Police,Summons from police
5968,6065,0,3,None,15th hole
5862,9789,0,6,Mix,Be careful zombies
5813,6684,0,3,None,Be careful zombies
5782,6423,0,5,worker,inside the hedge
5727,6396,0,4,None,Be careful zombies
5682,5336,0,3,Mix,Oh my Goddess
5679,5315,0,3,Mix,RIP somebody
5665,5228,0,1,None,Be careful zombies
5477,5550,0,3,None,Forest Behind Someone House
5465,5515,0,3,None,Forest Behind Someone House
5412,5878,0,3,None,Be careful zombies
5215,11200,0,3,None,Be careful zombies
5156,5468,0,3,None,Forest Behind Someone House
4947,5934,0,2,Dress,on the way
4918,6423,0,2,None,Be careful zombies
4907,5549,0,5,None,Be careful zombies
4833,6279,0,5,PrivateMilitia,Be careful zombies
4700,5820,0,8,Farmer,Be careful zombies
4650,5618,0,2,None,Be careful zombies
4598,6069,0,2,Dress,on the way
4593,7845,0,3,teenager,Are you good at serving?
4372,10612,0,3,None,Be careful zombies
4185,5884,0,8,Farmer,Be careful zombies
4145,5887,0,8,Farmer,Be careful zombies
4089,6198,0,3,None,Forest Behind Someone House
4085,5695,0,3,None,Forest Behind Someone House
4078,6096,0,3,None,Forest Behind Someone House
4048,5866,0,8,Farmer,Be careful zombies
3972,6097,0,3,None,Forest Behind Someone House
3971,6260,0,4,Mix,Be careful zombies
3801,5699,0,2,None,Be careful zombies
3763,6068,0,2,Dress,on the way
10290,9532,0,1,None,Be careful zombies
10356,9521,0,1,None,Be careful zombies
10376,8868,0,1,None,Be careful zombies
11722,8933,0,1,None,Be careful zombies
5371,6062,0,3,None,Be careful zombies
5516,6089,0,2,None,Be careful zombies
5732,6456,0,1,None,Golf course reception
5460,9570,0,2,None,Be careful zombies
5505,9568,0,1,None,Be careful zombies
10260,9343,0,2,Mix,Bench work
10327,9315,0,2,Mix,Be careful zombies
10674,9334,0,2,Mix,Bench work
10999,9646,0,2,Mix,Bench work
11265,6608,0,2,Mix,Bench work
11418,6765,0,2,Mix,Bench work
10344,12795,0,2,Mix,Bench work
6296,5275,0,2,Mix,Bench work
3713,5715,0,2,Mix,Bench work
3692,5716,0,2,Mix,Bench work
3692,8477,0,2,Mix,Bench work
5512,9626,0,2,Mix,Bench work
9082,12199,0,2,Mix,Bench work
12850,6337,0,2,Mix,Bench work
12516,5333,0,2,Mix,Bench work
12519,5347,0,2,Mix,Bench work
13669,5874,0,2,Mix,Bench work
13669,5900,0,2,Mix,Bench work
13801,5662,0,2,Mix,Bench work
13801,5644,0,2,Mix,Bench work
]]


---------------------------------------
---------------------------------------
-- loadOut
---------------------------------------
pkszTHsetup.ve.loadOut = [[-- "--" is can be used as a comment out
-- Base.Axe = 1 / One fireaxe will always spawn.
-- random = food1 / Spawns one from a random of "food1"
-- randomGP = CivilRifle / One set will be selected and spawned from a RandomGP group of Civil Rifles.
-- random = random / Spawns one of all random items
---
loadOutCD = foodaid
random = sackVegetables
random = sackFruit
random = sackProduce
random = grain
random = protein
random = breakfast
random = preservedfood
random = candy
random = drink
random = drink
random = seasoning
random = seasoning
random = misc
-- = 
loadOutCD = fleshfood
random = protein
random = protein
random = protein
random = protein
random = breakfast
random = breakfast
random = breakfast
random = drink
random = fruit
random = fruit
random = vegetable
random = vegetable
random = cakes
-- = 
loadOutCD = preservedfood
random = preservedfood
random = preservedfood
random = preservedfood
random = preservedfood
random = preservedfood
random = drink
random = drink
random = grain
random = seasoning
random = candy
random = candy
-- = 
loadOutCD = junkfood
random = firstfood
random = firstfood
random = firstfood
random = firstfood
random = firstfood
random = firstfood
random = fruit
random = drink
random = drink
random = drink
random = candy
random = enjoyment
random = enjoyment
random = enjoyment
epic/random = random
-- = 
loadOutCD = civilarm
random = drink
random = fruit
epic/random = civilarmmix
random = civilarmmix
random = melee
random = repair
random = weaponPart
random = vests
random = bootsGloves
random = medic
random = medic
-- = 
loadOutCD = milarm
random = drink
random = firstfood
epic/random = milamrmix
random = milamrmix
random = melee
random = ammo
random = repair
random = weaponPart
random = vests
random = bootsGloves
random = medic
-- = 
loadOutCD = gunmisc
random = drink
random = firstfood
random = civilarmmix
epic/random = poorWeaponMix
random = ammo
random = ammo
random = repair
random = weaponPart
random = weaponPart
random = weaponPart
random = medic
random = medic
-- = 
loadOutCD = ammos
random = drink
random = fruit
epic/random = poorWeaponMix
random = ammo
random = ammo
random = ammo
random = ammo
random = ammo
random = ammo
random = repair
random = repair
random = medic
-- = 
loadOutCD = melee
random = drink
random = fruit
epic/random = melee
epic/random = cloth
random = melee
random = melee
random = melee
random = repair
random = repair
random = vests
random = bootsGloves
random = medic
-- = 
loadOutCD = support
random = sackProduce
random = preservedfood
random = seasoning
random = drink
random = drink
random = BuildingSupplies
random = misc
random = misc
epic/random = poorWeaponMix
epic/random = cloth
random = medic
random = medic
random = starterGoods
random = enjoyment
random = repair
random = random
-- = 
loadOutCD = beginner
random = drink
random = fruit
random = vegetable
random = SurvivalSupplies
random = bootsGloves
random = misc
random = melee
random = starterGoods
random = starterGoods
random = starterGoods
random = medic
epic/random = bag
random = random
-- = 
loadOutCD = survival
epic/Base.HuntingKnife = 1
random = drink
random = preservedfood
random = preservedfood
random = misc
random = starterGoods
random = SurvivalSupplies
random = SurvivalSupplies
random = SurvivalSupplies
random = melee
random = medic
random = random
-- = 
loadOutCD = fashion
random = drink
random = candy
random = firstfood
random = enjoyment
random = enjoyment
epic/random = watch
epic/random = cloth
epic/random = cloth
epic/random = cloth
epic/random = cloth
epic/random = cloth
epic/random = bag
random = random
-- = 
loadOutCD = party
Base.PizzaWhole = 1
random = drink
random = drink
random = drink
random = candy
random = candy
random = candy
random = cakes
random = cakes
random = cakes
random = firstfood
random = firstfood
epic/random = accessory
epic/random = cloth
random = candybonus
-- = 
loadOutCD = candy
random = drink
random = drink
random = drink
random = candy
random = candy
random = candy
random = candy
random = candy
random = cakes
random = candybonus
random = enjoyment
epic/random = cloth
epic/random = random
-- = 
loadOutCD = horde
random = drink
random = drink
random = firstfood
random = firstfood
random = protein
random = protein
random = preservedfood
random = repair
random = medic
random = medic
random = vests
epic/random = milamrmix
epic/random = melee
epic/random = melee
epic/random = cloth
random = ammo
random = misc
random = fruit
random = random
-- = 
loadOutCD = smallhorde
random = drink
random = drink
random = firstfood
random = protein
random = medic
random = medic
random = civilarmmix
epic/random = melee
random = misc
random = fruit
random = vegetable
random = cakes
random = random
-- = 
loadOutCD = worsttrip
epic/Base.Katana = 1
epic/Base.HandAxe = 1
random = civilarmmix
random = milamrmix
random = ammo
random = ammo
epic/random = vests
epic/random = bootsGloves
epic/random = accessory
random = preservedfood
random = preservedfood
random = drink
random = medic
random = random
random = random
-- = 
loadOutCD = funbox
random = random
random = random
random = random
random = random
epic/random = random
epic/random = random
epic/random = random
]]


---------------------------------------
---------------------------------------
-- loadOutRandom
---------------------------------------
pkszTHsetup.ve.loadOutRandom = [[-- "--" is can be used as a comment out
-- One will be selected from the group
-- will spawn as many times as the " = number"
-- randomGP = CivilRifle //-> One set will be selected and spawned from a RandomGP group of Civil Rifles.
-----
loadOutRandomCD = sackVegetables
Base.SackProduce_BellPepper = 1
Base.SackProduce_Broccoli = 1
Base.SackProduce_Cabbage = 1
Base.SackProduce_Carrot = 1
Base.SackProduce_Corn = 1
Base.SackProduce_Eggplant = 1
Base.SackProduce_Tomato = 1
Base.SackProduce_Leek = 1
Base.SackProduce_Lettuce = 1
Base.SackProduce_Onion = 1
Base.SackProduce_Potato = 1
Base.SackProduce_RedRadish = 1
-- = 
loadOutRandomCD = sackFruit
Base.SackProduce_Apple = 1
Base.SackProduce_Cherry = 1
Base.SackProduce_Peach = 1
Base.SackProduce_Pear = 1
Base.SackProduce_Strawberry = 1
Base.SackProduce_Grapes = 1
-- = 
loadOutRandomCD = sackProduce
Base.SackProduce_BellPepper = 1
Base.SackProduce_Broccoli = 1
Base.SackProduce_Cabbage = 1
Base.SackProduce_Carrot = 1
Base.SackProduce_Corn = 1
Base.SackProduce_Eggplant = 1
Base.SackProduce_Tomato = 1
Base.SackProduce_Leek = 1
Base.SackProduce_Lettuce = 1
Base.SackProduce_Onion = 1
Base.SackProduce_Potato = 1
Base.SackProduce_RedRadish = 1
Base.SackProduce_Apple = 1
Base.SackProduce_Cherry = 1
Base.SackProduce_Peach = 1
Base.SackProduce_Pear = 1
Base.SackProduce_Strawberry = 1
Base.SackProduce_Grapes = 1
-- = 
loadOutRandomCD = grain
Base.Cornflour = 1
Base.Flour = 1
Base.Rice = 1
Base.BakingSoda = 2
Base.PancakeMix = 2
-- = 
loadOutRandomCD = protein
farming.Bacon = 1
Base.Baloney = 1
Base.Chicken = 1
Base.EggCarton = 1
Base.Ham = 1
Base.MeatPatty = 1
Base.MincedMeat = 1
Base.MuttonChop = 1
Base.PorkChop = 1
Base.Salami = 1
Base.Sausage = 1
Base.Steak = 1
Base.Tofu = 1
Base.Crayfish = 1
Base.Lobster = 1
Base.Salmon = 1
Base.Shrimp = 1
Base.Squid = 1
-- = 
loadOutRandomCD = preservedfood
Base.CannedBellPepper = 1
Base.CannedBroccoli = 1
Base.CannedCabbage = 1
Base.CannedCarrots = 1
Base.CannedEggplant = 1
Base.CannedLeek = 1
Base.CannedPotato = 1
Base.CannedRedRadish = 1
Base.CannedTomato = 1
Base.OatsRaw = 1
Base.Cereal = 1
Base.Popcorn = 1
Base.GrahamCrackers = 3
Base.Macandcheese = 1
Base.TVDinner = 1
-- = 
loadOutRandomCD = firstfood
Base.PizzaWhole = 1
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
Base.BaguetteSandwich = 1
Base.ChickenFried = 1
Base.Fries = 1
Base.PotatoPancakes = 1
Base.ShrimpDumpling = 1
Base.Pizza = 1
Base.Icecream = 1
Base.ConeIcecream = 1
Base.Pie = 1
Base.Hotdog = 1
Base.Springroll = 1
Base.ChickenNuggets = 1
Base.FishFried = 1
-- = 
loadOutRandomCD = breakfast
Base.Bread = 1
Base.Baguette = 1
Base.Yoghurt = 1
Base.Processedcheese = 1
Base.Milk = 1
Base.Ramen = 1
Base.Pasta = 1
Base.CornFrozen = 1
Base.Coffee2 = 1
Base.Teabag2 = 1
Base.CannedMilk = 1
Base.CannedFruitBeverage = 1
-- = 
loadOutRandomCD = fruit
Base.Apple = 3
Base.Banana = 4
Base.BerryBlack = 3
Base.BerryBlue = 3
Base.Mango = 3
Base.Orange = 3
Base.Peach = 3
Base.Pear = 3
Base.Pineapple = 1
Base.Watermelon = 1
-- = 
loadOutRandomCD = vegetable
Base.Avocado = 3
Base.Corn = 3
Base.Daikon = 3
Base.Edamame = 3
Base.PepperHabanero = 3
Base.PepperJalapeno = 3
Base.Peas = 3
Base.Pumpkin = 3
Base.Seaweed = 5
Base.Zucchini = 3
Base.Onion = 3
Base.GingerPickled = 3
-- = 
loadOutRandomCD = drink
Base.PopBottle = 1
Base.Pop = 2
Base.JuiceBox = 2
Base.Milk = 1
Base.WaterBottleFull = 1
Base.BeerBottle = 1
Base.BeerCan = 1
Base.WhiskeyFull = 1
Base.Wine2 = 1
Base.Wine = 1
-- = 
loadOutRandomCD = seasoning
Base.BouillonCube = 1
Base.SugarBrown = 1
Base.Hotsauce = 1
Base.Ketchup = 1
Base.Lard = 1
Base.MapleSyrup = 1
Base.Margarine = 1
Base.Marinara = 1
farming.MayonnaiseFull = 1
Base.Mustard = 1
Base.OilOlive = 1
Base.Pepper = 1
Base.RiceVinegar = 1
Base.Salt = 1
Base.Soysauce = 1
Base.Sugar = 1
Base.OilVegetable = 1
Base.Wasabi = 1
Base.Tomatopaste = 1
Base.SugarPacket = 1
Base.Butter = 1
Base.Cheese = 1
Base.CocoaPowder = 1
Base.JamFruit = 1
Base.GravyMix = 1
Base.Honey = 1
Base.JamMarmalade = 1
Base.PeanutButter = 1
farming.RemouladeFull = 1
Base.Vinegar = 1
Base.Yeast = 1
-- = 
loadOutRandomCD = cakes
Base.CakeBlackForest = 1
Base.CakeSlice = 1
Base.CakeCarrot = 1
Base.CakeCheesecake = 1
Base.CakeChocolate = 1
Base.CakeRedVelvet = 1
Base.CakeStrawberryShortcake = 1
-- = 
loadOutRandomCD = SurvivalSupplies
camping.CampingTentKit = 1
Base.HuntingKnife = 1
Base.HandAxe = 1
Base.HandScythe = 1
Base.TrapCage = 1
Base.TrapMouse = 1
Base.TrapSnare = 1
Base.TrapStick = 1
Base.TrapBox = 1
Base.TrapCrate = 1
Base.CannedSardines = 1
Base.CannedCornedBeef = 1
Base.Candle = 3
Base.HerbalistMag = 1
Base.HuntingMag1 = 1
Base.HuntingMag2 = 1
Base.HuntingMag3 = 1
-- = 
loadOutRandomCD = BuildingSupplies
Base.Axe = 1
Base.WoodAxe = 1
Base.Sledgehammer = 1
Base.PipeWrench = 1
Base.CarBatteryCharger = 1
Base.GardenSaw = 1
Base.Shovel = 1
-- = 
loadOutRandomCD = bootsGloves
Base.Shoes_ArmyBoots = 1
Base.Shoes_ArmyBootsDesert = 1
Base.Shoes_BlackBoots = 1
Base.Shoes_Wellies = 1
Base.Gloves_LeatherGloves = 1
Base.Gloves_LeatherGlovesBlack = 1
Base.Gloves_FingerlessGloves = 1
Base.Bag_FannyPackFront = 1
Base.Bag_FannyPackBack = 1
-- = 
loadOutRandomCD = candybonus
Base.Tshirt_BusinessSpiffo = 1
Base.Apron_Spiffos = 1
Base.Tie_Full_Spiffo = 1
Base.MugSpiffo = 1
Base.BorisBadger = 1
Base.JacquesBeaver = 1
Base.FluffyfootBunny = 1
Base.FreddyFox = 1
Base.PancakeHedgehog = 1
Base.MoleyMole = 1
Base.FurbertSquirrel = 1
-- = 
loadOutRandomCD = misc
Base.EmptySandbag = 1
Base.SeedBag = 1
Base.Candle = 2
Base.Extinguisher = 1
Base.Matches = 2
Base.Lighter = 2
Base.BoxOfJars = 1
Base.Money = 10
Base.CookingMag1 = 1
Base.CookingMag2 = 1
farming.GardeningSprayCigarettes = 2
farming.GardeningSprayMilk = 2
farming.WateredCan = 1
Base.Fertilizer = 1
Base.FarmingMag1 = 1
Base.HerbalistMag = 1
Base.ComicBook = 1
Base.MagazineCrossword1 = 1
Base.HottieZ = 1
Base.Magazine = 1
Base.TVMagazine = 1
Base.MagazineWordsearch1 = 1
-- = 
loadOutRandomCD = melee
Base.HandAxe = 1
Base.Machete = 1
Base.Katana = 1
Base.BaseballBat = 1
Base.Axe = 1
Base.SpearScrewdriver = 1
Base.SpearHuntingKnife = 1
Base.SpearMachete = 1
Base.SpearIcePick = 1
Base.SpearKnife = 1
--- = 
loadOutRandomCD = civilarmmix
randomGP = Revolver
randomGP = Pistol
randomGP = CivilRifle
Base.HandAxe = 1
Base.Machete = 1
Base.Katana = 1
Base.BaseballBat = 1
Base.Axe = 1
--- = 
loadOutRandomCD = milamrmix
randomGP = Pistol
randomGP = MilitaryRifle
randomGP = MilitaryMix
randomGP = Revolver
--- = 
loadOutRandomCD = ammo
Base.Bullets9mmBox = 1
Base.Bullets45Box = 1
Base.Bullets44Box = 1
Base.Bullets38Box = 1
Base.556Box = 1
Base.308Box = 1
--- = 
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
Base.WristWatch_Right_ClassicMilitary = 1
Base.HolsterDouble = 1
Base.AmmoStrap_Bullets = 1
Base.Necklace_DogTag = 1
Base.HolsterSimple = 1
-- = 
loadOutRandomCD = vests
Base.Vest_BulletCivilian = 1
Base.Vest_Hunting_Camo = 1
Base.Vest_Hunting_Orange = 1
Base.Vest_BulletPolice = 1
Base.Vest_BulletArmy = 1
Base.Vest_BulletPolice = 1
-- = 
loadOutRandomCD = starterGoods
Base.BucketEmpty = 1
Base.NailsBox = 1
Base.Pot = 1
Base.Kettle = 1
Base.Rope = 1
Base.Book = 1
--- = 
loadOutRandomCD = medic
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
--- = 
loadOutRandomCD = watch
Base.WristWatch_Right_ClassicBlack = 1
Base.WristWatch_Right_ClassicBrown = 1
Base.WristWatch_Right_ClassicGold = 1
Base.WristWatch_Right_ClassicMilitary = 1
Base.WristWatch_Right_DigitalBlack = 1
Base.WristWatch_Right_DigitalDress = 1
Base.WristWatch_Right_DigitalRed = 1
--- = 
loadOutRandomCD = accessory
Base.BellyButton_DangleGold = 1
Base.BellyButton_DangleGoldRuby = 1
Base.BellyButton_DangleSilver = 1
Base.BellyButton_DangleSilverDiamond = 1
Base.BellyButton_RingGold = 1
Base.BellyButton_RingGoldDiamond = 1
Base.BellyButton_RingGoldRuby = 1
Base.BellyButton_RingSilver = 1
Base.BellyButton_RingSilverAmethyst = 1
Base.BellyButton_RingSilverDiamond = 1
Base.BellyButton_RingSilverRuby = 1
Base.BellyButton_StudGold = 1
Base.BellyButton_StudGoldDiamond = 1
Base.BellyButton_StudSilver = 1
Base.BellyButton_StudSilverDiamond = 1
Base.Bracelet_BangleLeftGold = 1
Base.Bracelet_BangleLeftSilver = 1
Base.Bracelet_BangleRightGold = 1
Base.Bracelet_BangleRightSilver = 1
Base.Bracelet_ChainLeftGold = 1
Base.Bracelet_ChainLeftSilver = 1
Base.Bracelet_ChainRightGold = 1
Base.Bracelet_ChainRightSilver = 1
Base.Bracelet_LeftFriendshipTINT = 1
Base.Bracelet_RightFriendshipTINT = 1
Base.Earring_Dangly_Diamond = 1
Base.Earring_Dangly_Emerald = 1
Base.Earring_Dangly_Pearl = 1
Base.Earring_Dangly_Ruby = 1
Base.Earring_Dangly_Sapphire = 1
Base.Earring_LoopLrg_Gold = 1
Base.Earring_LoopLrg_Silver = 1
Base.Earring_LoopMed_Gold = 1
Base.Earring_LoopMed_Silver = 1
Base.Earring_LoopSmall_Gold_Both = 1
Base.Earring_LoopSmall_Gold_Top = 1
Base.Earring_LoopSmall_Silver_Both = 1
Base.Earring_LoopSmall_Silver_Top = 1
Base.Earring_Pearl = 1
Base.Earring_Stone_Emerald = 1
Base.Earring_Stone_Ruby = 1
Base.Earring_Stone_Sapphire = 1
Base.Earring_Stud_Gold = 1
Base.Earring_Stud_Silver = 1
Base.Glasses = 1
Base.Glasses_Shooting = 1
Base.Glasses_SkiGoggles = 1
Base.Glasses_Sun = 1
Base.Necklace_Choker = 1
Base.Necklace_Choker_Amber = 1
Base.Necklace_Choker_Diamond = 1
Base.Necklace_Choker_Sapphire = 1
Base.Necklace_Crucifix = 1
Base.Necklace_Gold = 1
Base.Necklace_GoldDiamond = 1
Base.Necklace_GoldRuby = 1
Base.Necklace_Pearl = 1
Base.Necklace_Silver = 1
Base.Necklace_SilverCrucifix = 1
Base.Necklace_SilverDiamond = 1
Base.Necklace_SilverSapphire = 1
Base.Necklace_YingYang = 1
Base.NecklaceLong_Amber = 1
Base.NecklaceLong_Gold = 1
Base.NecklaceLong_GoldDiamond = 1
Base.NecklaceLong_Silver = 1
Base.NecklaceLong_SilverDiamond = 1
Base.NecklaceLong_SilverEmerald = 1
Base.NecklaceLong_SilverSapphire = 1
Base.NoseRing_Gold = 1
Base.NoseRing_Silver = 1
Base.NoseStud_Gold = 1
Base.NoseStud_Silver = 1
Base.Ring_Left_MiddleFinger_Gold = 1
Base.Ring_Left_MiddleFinger_GoldDiamond = 1
Base.Ring_Left_MiddleFinger_GoldRuby = 1
Base.Ring_Left_MiddleFinger_Silver = 1
Base.Ring_Left_MiddleFinger_SilverDiamond = 1
Base.Ring_Left_RingFinger_Gold = 1
Base.Ring_Left_RingFinger_GoldDiamond = 1
Base.Ring_Left_RingFinger_GoldRuby = 1
Base.Ring_Left_RingFinger_Silver = 1
Base.Ring_Left_RingFinger_SilverDiamond = 1
Base.Ring_Right_MiddleFinger_Gold = 1
Base.Ring_Right_MiddleFinger_GoldDiamond = 1
Base.Ring_Right_MiddleFinger_GoldRuby = 1
Base.Ring_Right_MiddleFinger_Silver = 1
Base.Ring_Right_MiddleFinger_SilverDiamond = 1
Base.Ring_Right_RingFinger_Gold = 1
Base.Ring_Right_RingFinger_GoldDiamond = 1
Base.Ring_Right_RingFinger_GoldRuby = 1
Base.Ring_Right_RingFinger_Silver = 1
Base.Ring_Right_RingFinger_SilverDiamond = 1
--- = 
loadOutRandomCD = cloth
Base.Scarf_StripeBlackWhite = 1
Base.Scarf_StripeBlueWhite = 1
Base.Scarf_StripeRedWhite = 1
Base.Scarf_White = 1
Base.StockingsWhite = 1
Base.Tie_BowTieFull = 1
Base.Tie_Full = 1
Base.Apron_Black = 1
Base.Apron_White = 1
Base.Bikini_TINT = 1
Base.Boxers_White = 1
Base.Bra_Strapless_White = 1
Base.Bra_Straps_White = 1
Base.Briefs_AnimalPrints = 1
Base.Briefs_White = 1
Base.Dress_Knees = 1
Base.Dress_Long = 1
Base.Dress_long_Straps = 1
Base.Dress_Normal = 1
Base.Dress_Short = 1
Base.Dress_SmallBlackStrapless = 1
Base.Dress_SmallBlackStraps = 1
Base.Dress_SmallStrapless = 1
Base.Dress_SmallStraps = 1
Base.Dress_Straps = 1
Base.DressKnees_Straps = 1
Base.Dungarees = 1
Base.HoodieUP_WhiteTINT = 1
Base.Jacket_ArmyCamoDesert = 1
Base.Jacket_ArmyCamoGreen = 1
Base.Jacket_Black = 1
Base.Jacket_CoatArmy = 1
Base.Jacket_LeatherBarrelDogs = 1
Base.Jacket_LeatherIronRodent = 1
Base.Jacket_LeatherWildRacoons = 1
Base.Jacket_NavyBlue = 1
Base.Jacket_Padded = 1
Base.Jacket_WhiteTINT = 1
Base.JacketLong_Random = 1
Base.Jumper_DiamondPatternTINT = 1
Base.Jumper_PoloNeck = 1
Base.Jumper_RoundNeck = 1
Base.Jumper_TankTopDiamondTINT = 1
Base.Jumper_TankTopTINT = 1
Base.Jumper_VNeck = 1
Base.PonchoGreen = 1
Base.PonchoYellow = 1
Base.Shirt_Denim = 1
Base.Shirt_FormalWhite = 1
Base.Shirt_FormalWhite_ShortSleeve = 1
Base.Shirt_HawaiianTINT = 1
Base.Shirt_HawaiianRed = 1
Base.Shirt_Lumberjack = 1
Base.Shoes_BlackBoots = 1
Base.Shoes_BlueTrainers = 1
Base.Shoes_Fancy = 1
Base.Shoes_FlipFlop = 1
Base.Shoes_Strapped = 1
Base.Shorts_LongDenim = 1
Base.Shorts_ShortDenim = 1
Base.Skirt_Knees = 1
Base.Skirt_Long = 1
Base.Skirt_Mini = 1
Base.Skirt_Normal = 1
Base.Skirt_Short = 1
Base.Socks_Ankle = 1
Base.Socks_Long = 1
Base.Trousers = 1
Base.Trousers_Denim = 1
Base.Trousers_JeanBaggy = 1
Base.Trousers_LeatherBlack = 1
Base.Trousers_Padded = 1
Base.Trousers_Suit = 1
Base.Trousers_WhiteTINT = 1
Base.TrousersMesh_DenimLight = 1
Base.Tshirt_CamoUrban = 1
Base.Tshirt_IndieStoneDECAL = 1
Base.Tshirt_Rock = 1
Base.Tshirt_Sport = 1
Base.Tshirt_WhiteTINT = 1
Base.Vest_DefaultTEXTURE = 1
Base.Vest_Waistcoat = 1
Base.WeddingDress = 1
Base.WeddingJacket = 1
--- = 
loadOutRandomCD = bag
Base.Bag_BigHikingBag = 1
Base.Bag_DoctorBag = 1
Base.Bag_DuffelBag = 1
Base.Bag_DuffelBagTINT = 1
Base.Bag_FannyPackFront = 1
Base.Bag_GolfBag = 1
Base.Bag_JanitorToolbox = 1
Base.Bag_MedicalBag = 1
Base.Bag_NormalHikingBag = 1
Base.Cooler = 1
Base.Lunchbox = 1
Base.PaperBag = 1
Base.Purse = 1
Base.Suitcase = 1
Base.Tote = 1
--- = 
loadOutRandomCD = candy
Base.Allsorts = 3
Base.Biscuit = 3
Base.LicoriceBlack = 3
Base.ChocoCakes = 3
Base.CookiesChocolate = 3
Base.CinnamonRoll = 3
Base.Cupcake = 3
Base.MuffinFruit = 3
Base.HardCandies = 3
Base.Jujubes = 3
Base.Lollipop = 3
Base.Marshmallows = 3
Base.MintCandy = 3
Base.Modjeska = 3
Base.CookiesOatmeal = 3
Base.Peppermint = 3
Base.Plonkies = 3
Base.QuaggaCakes = 3
Base.LicoriceRed = 3
Base.CookiesShortbread = 3
Base.SnoGlobes = 3
Base.CookiesSugar = 3
--- = 
loadOutRandomCD = enjoyment
Base.Candle = 1
Base.Money = 10
Base.Money = 6
Base.ComicBook = 1
Base.HottieZ = 1
Base.Magazine = 1
Base.MagazineCrossword1 = 1
Base.MagazineWordsearch1 = 1
--- = 
loadOutRandomCD = repair
Base.Glue = 2
Base.Woodglue = 2
Base.DuctTape = 2
Base.Scotchtape = 2
Base.Nails = 6
--- = 
loadOutRandomCD = poorWeaponMix
Base.HuntingKnife = 1
Base.IcePick = 1
Base.KitchenKnife = 1
Base.MeatCleaver = 1
Base.Pan = 1
Base.RollingPin = 1
Base.Scalpel = 1
Base.Shovel = 1
Base.Broom = 1
Base.ChairLeg = 1
Base.Flute = 1
Base.Keytar = 1
Base.BadmintonRacket = 1
Base.CanoePadel = 1
Base.Golfclub = 1
Base.IceHockeyStick = 1
Base.Poolcue = 1
Base.PipeWrench = 1
Base.MetalPipe = 1
Base.BaseballBatNails = 1
]]


---------------------------------------
---------------------------------------
-- loadOutRandomGP
---------------------------------------
pkszTHsetup.ve.loadOutRandomGP = [[-- "--" is can be used as a comment out
-- One set is selected from the group and spawned.
-- 
loadOutRandomGPCD = CivilRifle
Base.VarmintRifle = 1;Base.223Box = 2
Base.HuntingRifle = 1;Base.308Box = 2;Base.308Clip = 2
Base.ShotgunSawnoff = 1;Base.ShotgunShellsBox = 1
Base.DoubleBarrelShotgunSawnoff = 1;Base.ShotgunShellsBox = 1
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
Base.Shotgun = 1;Base.ShotgunShellsBox = 1
Base.DoubleBarrelShotgun = 1;Base.ShotgunShellsBox = 1
---
loadOutRandomGPCD = MilitaryMix
Base.AssaultRifle = 1;Base.556Box = 2;Base.556Clip = 2
Base.AssaultRifle2 = 1;Base.308Box = 2;Base.M14Clip = 2
Base.Pistol = 1;Base.Bullets9mmBox = 2;Base.Base.9mmClip = 2
Base.Pistol2 = 1;Base.Bullets45Box = 2;Base.45Clip = 2
]]


---------------------------------------
---------------------------------------
-- zedOutfitGrp
---------------------------------------
pkszTHsetup.ve.zedOutfitGrp = [[
-- "--" is can be used as a comment out
-- Zombies included in "outfitGrp" will spawn with a probability
-- The number specifies the rate at which female zombies appear
-- 0 = male / 50 = mix / 100 = female (This is by specification. Please check the official website for details)
--
outfitGrpCD = None
None = 50
--- = 
outfitGrpCD = Farmer
Farmer = 50
None = 50
--- = 
outfitGrpCD = PrivateMilitia
PrivateMilitia = 50
--- = 
outfitGrpCD = Constructionworker
Constructionworker = 50
--- = 
outfitGrpCD = Young
Young = 50
None = 50
--- = 
outfitGrpCD = Student
Student = 50
None = 50
--- = 
outfitGrpCD = Camper
Camper = 50
Survivalist = 50
--- = 
outfitGrpCD = Officeworker
Officeworker = 50
--- = 
outfitGrpCD = OfficeworkerSkirt
OfficeworkerSkirt = 50
--- = 
outfitGrpCD = Trader
Trader = 50
--- = 
outfitGrpCD = Biker
Biker = 50
--- = 
outfitGrpCD = Bandit
Bandit = 50
--- = 
outfitGrpCD = Fireman
Fireman = 50
--- = 
outfitGrpCD = Police
Police = 50
--- = 
outfitGrpCD = Mix
Student = 50
Young = 50
DressLong = 100
DressNormal = 100
DressShort = 100
Bandit = 50
Biker = 50
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
--- = 
outfitGrpCD = teenager
Student = 50
Young = 50
--- = 
outfitGrpCD = Dress
DressLong = 100
DressNormal = 100
DressShort = 100
--- = 
outfitGrpCD = rogue
Biker = 50
Bandit = 50
--- = 
outfitGrpCD = medic
AmbulanceDriver = 50
Doctor = 50
Nurse = 100
--- = 
outfitGrpCD = worker
OfficeWorker = 50
OfficeWorkerSkirt = 50
ConstructionWorker = 50
--- = 
outfitGrpCD = Survivor
Camper = 50
Bandit = 50
Biker = 50
None = 50
Survivalist = 50
Survivalist02 = 50
Survivalist03 = 50
Naked = 50
Trader = 50
Police = 50
Ranger = 50
--- = 
outfitGrpCD = Militia
PrivateMilitia = 50
ArmyCamoDesert = 50
ArmyInstructor = 0
ArmyServiceUniform = 50
--- = 
outfitGrpCD = Priest
Priest = 0
--- = 
outfitGrpCD = Spiffo
Spiffo = 50
--- = 
outfitGrpCD = Santa
Santa = 50
--- = 
outfitGrpCD = costume
Spiffo = 50
Santa = 50
--- = 
outfitGrpCD = exercise
BaseballFan_KY = 50
BaseballFan_Rangers = 50
StreetSports = 50
Cyclist = 50
--- = 
outfitGrpCD = beach
NakedVeil = 100
Swimmer = 50
Stripper = 50
TutoriaMom = 50
--- = 
outfitGrpCD = Naked
Naked = 50
--- = 
--- sNone / Alternatives when using None in Single mode
--- Please do not delete sNone group
--- = 
outfitGrpCD = sNone
Camper = 50
Student = 50
Young = 50
DressLong = 100
DressNormal = 100
DressShort = 100
Bandit = 50
Biker = 50
AmbulanceDriver = 50
OfficeWorker = 50
OfficeWorkerSkirt = 50
ConstructionWorker = 50
Trader = 50
Classy = 50
Hobbo = 50
Punk = 50
Rocker = 50
Varsity = 50
Police = 50
TutoriaMom = 50
Cyclist = 50
BaseballFan_KY = 50
BaseballFan_Rangers = 50
StreetSports = 50
]]

end