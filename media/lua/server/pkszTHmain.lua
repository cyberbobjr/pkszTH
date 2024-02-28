pkszTHmain = {}

pkszTHmain.tick = function()


	if isClient() then return end

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end
	if pkszTHsv.forceSuspend == true then
		return
	end

	if pkszTHsv.initialize == 0 then
		pkszTHsv.initialize = 1;
		pkszTHsv.restart()
		pkszTHsv.Phase = "wait"
	end

	pkszTHsv.mainTick = pkszTHsv.mainTick + 1

	if pkszTHsv.Progress == 1 then

		-- send to pager (become unnecessary
		if pkszTHsv.Phase == "notice" then
			pkszTHsv.Phase = "open"
			pkszTHmain.dataConnect('EventInfoShare')
		end

		-- oparate close
		if pkszTHsv.Phase == "close" then
			pkszTHsv.Progress = 0
			pkszTHsv.mainTick = 0
			pkszTHsv.Phase = "wait"
		end

		-- time over
		if pkszTHsv.mainTick > pkszTHsv.curEvent.endTick then
			pkszTHsv.Phase = "close"
			pkszTHsv.Progress = 0
			pkszTHsv.logger("Event time over " ..pkszTHsv.curEvent.EventId,true)
			pkszTHmain.dataConnect('EventInfoShare')
		end
	end

	-- new Event Setup
	if pkszTHsv.Progress == 0 then
		local startEvent = pkszTHmain.newEventSetup()
		if startEvent == "1" then
			pkszTHsv.Phase = "open"
			local sendStr = pkszTHmain.buildSendMessageFormat(pkszTHsv.curEvent)
			pkszTHsv.curEvent.massege = sendStr
			pkszTHmain.dataConnect('IncomingPager','send message')
		end
	end

end
Events.EveryTenMinutes.Add(pkszTHmain.tick)
-- Events.EveryOneMinute.Add(pkszTHmain.tick)

pkszTHmain.buildSendMessageFormat = function(cur)


	local gameTime = pkszTHsv.getGameTime()
	local sendString = {}
	local cords = pkszTHsv.strSplit(cur.Coordinate,",")

	sendString[1] = gameTime
	sendString[2] = cur.eventDescription
	sendString[3] = cords[6]

	return sendString
end


pkszTHmain.newEventSetup = function()

	local eventgetFlg = "0"

	if pkszTHsv.mainTick > pkszTHsv.Settings.eventStartWaitTick then
		-- lottery start
		local lot = ZombRand(10)
		if lot <= pkszTHsv.Settings.eventStartChance then
			eventgetFlg = "1"
			pkszTHmain.getNewEvent()
			pkszTHsv.logger("new eventID = "..pkszTHsv.curEvent.EventId,true)
			pkszTHsv.logger("new event start tick = "..pkszTHsv.curEvent.startTick,true)
			pkszTHsv.logger("new event end tick = "..pkszTHsv.curEvent.endTick,true)
			pkszTHsv.logger("base timeout = "..pkszTHsv.curEvent.eventTimeout,true)
			pkszTHsv.logger("Coordinate = "..pkszTHsv.curEvent.Coordinate,true)
			-- event mst / pkszTHsv.curEvent = pkszTHsv.Events[myEventId]
			-- Coordinate / pkszTHsv.curEvent.Coordinate = myCordList[setCordNo]
			-- LoadOut / pkszTHsv.curEvent.LoadOut
			pkszTHsv.Progress = 1
			pkszTHsv.Phase = "notice"
			pkszTHmain.saveEventHistory()
		end
	end

	return eventgetFlg
end

pkszTHmain.getNewEvent = function()

	local changeThis = {}

	pkszTHsv.logger("-- setup new event --",true)

	-- get event id
	local setEventNo = ZombRand(pkszTHsv.EventNum)
	setEventNo = setEventNo + 1
	local myEventId = pkszTHsv.EventIDs[setEventNo]
	local timeAvg = SandboxVars.pkszTHopt.eventTickAverage / 10

	-- set Event ---------------------------------------
	pkszTHsv.curEvent = {}
	pkszTHsv.curEvent.massege = {}
	pkszTHsv.curEvent.massege[1] = "empty"
	pkszTHsv.curEvent.massege[2] = ""
	pkszTHsv.curEvent.massege[3] = ""
	pkszTHsv.curEvent.objBag = nil
	pkszTHsv.curEvent.zedSquare = nil

	pkszTHsv.curEvent = pkszTHsv.Events[myEventId]
	pkszTHsv.curEvent.EventId = myEventId
	pkszTHsv.curEvent.startDateTime = pkszTHsv.getGameTime()
	pkszTHsv.curEvent.startTick = pkszTHsv.mainTick
	pkszTHsv.curEvent.endTick = pkszTHsv.mainTick + (pkszTHsv.curEvent.eventTimeout * timeAvg)
	-- pkszTHsv.curEvent.checkPlayer = "<Unacquired>"
	pkszTHsv.curEvent.phase = pkszTHsv.Phase

	-- get Coordinate
	local myCordList = pkszTHmain.getCordList(pkszTHsv.curEvent.cordListSelectCD)
	local setCordNo = ZombRand(#myCordList) + 1

	pkszTHsv.curEvent.Coordinate = myCordList[setCordNo]

	pkszTHsv.logger("eventID " ..myEventId,true)
	pkszTHsv.logger("getCordList " ..pkszTHsv.curEvent.cordListSelectCD.. " setCordNo = " ..setCordNo.. " / " ..#myCordList,true)
	pkszTHsv.logger("getCoordinate " ..pkszTHsv.curEvent.Coordinate,true)

	-- set coordinate vector3
	pkszTHsv.curEvent.spawnVector = {}
	local cords = pkszTHsv.strSplit(pkszTHsv.curEvent.Coordinate,",")
	pkszTHsv.curEvent.spawnVector.x = tonumber(cords[1])
	pkszTHsv.curEvent.spawnVector.y = tonumber(cords[2])
	pkszTHsv.curEvent.spawnVector.z = tonumber(cords[3])
	pkszTHsv.curEvent.spawnRadius = tonumber(cords[4])
	pkszTHsv.curEvent.outfitGrpCD = cords[5]
	pkszTHsv.curEvent.spawnDesc = cords[6]

	-- get load out
	local tempLoadOut = pkszTHsv.loadOut[pkszTHsv.curEvent.loadOutSelectCD]
	pkszTHsv.curEvent.LoadOut = {}

	-- get randome load out
	local cnt = 1
	local rGPitems = {}
	for key in pairs(tempLoadOut) do
		changeThis = {}
		-- print("tempLoadOut ".. tempLoadOut[key]["item"] .. " / " .. tempLoadOut[key]["num"])
		for keyB,valueB in pairs(tempLoadOut[key]) do
			if keyB == "item" then
				rGPitems = {}
				if valueB == "random" then
					if tempLoadOut[key]["num"] == "random" then
						local getRandomItem = pkszTHmain.getAllLoadOutRandomItem()
						if getRandomItem then
							if getRandomItem.item == "randomGP" then
								rGPitems = pkszTHmain.getLoadOutRandomGP(getRandomItem["num"])
								if rGPitems then
									for rKey in pairs(rGPitems) do
										pkszTHsv.curEvent.LoadOut[cnt] = rGPitems[rKey]
										pkszTHsv.logger("loadout=randomAllandGP/"..getRandomItem["num"]..":name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
										cnt = cnt + 1
									end
								end
							else
								pkszTHsv.curEvent.LoadOut[cnt] = getRandomItem
								pkszTHsv.logger("loadout=randomAll/"..getRandomItem["item"]..":name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
								cnt = cnt + 1
							end
						else
								pkszTHsv.logger("getRandomGP Error by "..getRandomItem["num"],true)
						end
					else
						changeThis = pkszTHmain.lotRandomItem(tempLoadOut[key]["num"])
						-- print("changeThis item " ..changeThis["item"])
						-- print("changeThis num " ..changeThis["num"])
						if changeThis then
							if changeThis.item == "randomGP" then
								rGPitems = pkszTHmain.getLoadOutRandomGP(changeThis["num"])
								if rGPitems then
									for rKey in pairs(rGPitems) do
										pkszTHsv.curEvent.LoadOut[cnt] = rGPitems[rKey]
										pkszTHsv.logger("loadout=randomOneGP/"..changeThis["num"]..":name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
										cnt = cnt + 1
									end
								end
							else
								pkszTHsv.curEvent.LoadOut[cnt] = changeThis
								pkszTHsv.logger("loadout=randomOne/"..tempLoadOut[key]["num"]..":name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
								cnt = cnt + 1
							end
						end
					end
				elseif valueB == "randomGP" then
					rGPitems = pkszTHmain.getLoadOutRandomGP(tempLoadOut[key]["num"])
					for rKey in pairs(rGPitems) do
						pkszTHsv.curEvent.LoadOut[cnt] = rGPitems[rKey]
						pkszTHsv.logger("loadout=randomGP/"..tempLoadOut[key]["num"]..":name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
						cnt = cnt + 1
					end
				else
					pkszTHsv.curEvent.LoadOut[cnt] = tempLoadOut[key]
					pkszTHsv.logger("loadout=nomal :name="..pkszTHsv.curEvent.LoadOut[cnt]["item"]..":amount="..pkszTHsv.curEvent.LoadOut[cnt]["num"],true)
					cnt = cnt + 1
				end

			end
		end
	end

	-- get zedOutfit
	-- print("outfitGrpCD ---- " ..pkszTHsv.curEvent.outfitGrpCD)
	-- print("spawnDesc ---- " ..pkszTHsv.curEvent.spawnDesc)

	-- leader
	if not pkszTHsv.zedOutfitGrp[pkszTHsv.curEvent.leaderOutfit] then
		pkszTHsv.logger("ERROR : leaderOutfitGrp CD not found " ..pkszTHsv.curEvent.leaderOutfit,true)
		pkszTHsv.curEvent.leaderOutfitGrp = "None"
		return
	end
	pkszTHsv.curEvent.leaderOutfitGrp = pkszTHsv.zedOutfitGrp[pkszTHsv.curEvent.leaderOutfit]
	pkszTHsv.logger("leaderOutfitGrp = "..pkszTHsv.curEvent.leaderOutfit,true)
	-- print("pkszTHsv.curEvent.leaderOutfitGrp" ,pkszTHsv.curEvent.leaderOutfitGrp[1]["item"])

	-- guards
	if not pkszTHsv.zedOutfitGrp[pkszTHsv.curEvent.outfitGrpCD] then
		pkszTHsv.logger("ERROR : zedOutfitGrp CD not found " ..pkszTHsv.curEvent.outfitGrpCD,true)
		pkszTHsv.curEvent.outfitGrpCD = "None"
		return
	end

	pkszTHsv.curEvent.zedOutfitGrp = pkszTHsv.zedOutfitGrp[pkszTHsv.curEvent.outfitGrpCD]
	pkszTHsv.logger("zedOutfitGrp = "..pkszTHsv.curEvent.outfitGrpCD,true)

end

pkszTHmain.getCordList = function(cordText)

	-- print("cordText "..cordText)
	local newcordList = {}
	if string.find(cordText,",") then
		-- print("multi cordlist")
		local ml = pkszTHsv.strSplit(cordText,",")
		for key,val in pairs(ml) do
			if not pkszTHsv.CordinateList[val] then
				pkszTHsv.logger("ERROR : CordinateList cd not found "..val,true)
				pkszTHsv.curEvent.cordListSelectCD = "error"
			end
			newcordList = pkszTHsv.merge_tables(newcordList,pkszTHsv.CordinateList[val])
		end
		return newcordList
	else
		-- print("single cordlist")
		if not pkszTHsv.CordinateList[cordText] then
			pkszTHsv.logger("ERROR : CordinateList cd not found "..cordText,true)
			pkszTHsv.curEvent.cordListSelectCD = "error"
		end
		return pkszTHsv.CordinateList[cordText]
	end

end

pkszTHmain.getAllLoadOutRandomItem = function()

	local loadOutRandomNo = ZombRand(pkszTHsv.loadOutRandomIndexCnt) + 1
	local takeThis = pkszTHsv.loadOutRandomIndex[loadOutRandomNo]
	return takeThis

end

pkszTHmain.getLoadOutRandomGP = function(rGPCD)

	if not pkszTHsv.loadOutRandomGP[rGPCD] then
		pkszTHsv.logger("ERROR : loadOutRandomGP id not found " ..rGPCD,true)
		return
	end

	local myArray = pkszTHsv.loadOutRandomGP[rGPCD]
	local chois = ZombRand(#myArray) + 1
	local getMyItem = pkszTHsv.loadOutRandomGP[rGPCD][chois]
	local myItems = pkszTHsv.getRandomGPLineSplit(getMyItem)

	return myItems

end

pkszTHmain.lotRandomItem = function(grpID)

	if not pkszTHsv.loadOutRandom[grpID] then
		pkszTHsv.logger("ERROR : loadOutRandom id not found " ..grpID,true)
		return
	end

	local myLots = pkszTHsv.loadOutRandom[grpID]
	local chois = ZombRand(#myLots) + 1

	local myItem = pkszTHsv.loadOutRandom[grpID][chois]

	-- print("------ /// lotRandomItem grpID " ..grpID)
	-- print("------ /// chois random no "..chois)

	return myItem
end


-- Why does the order change?
-- sendClientCommand(player, "pkszTHctrl", act, pkszThCli.curEvent);
local function onServerCommand(module,command,player,args)

	if module ~= "pkszTHctrl" then return end

    if command == "doSpawnObject" then
		if pkszTHsv.Phase == "open" then
			pkszTHsv.Phase = "enter"
			pkszTHmain.spawnZombie()
			pkszTHmain.syncLoadout()
			pkszTHmain.dataConnect('EventInfoShare')
		end
    end

    if command == "doClose" then
		pkszTHsv.Phase = "wait"
		pkszTHsv.Progress = 0
		pkszTHsv.logger("Event Clear " ..pkszTHsv.curEvent.EventId,true)
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "doSpawnObjectSurely" then
		print("doSpawnObjectSurely -- debug only ----------")
		-- test
		pkszTHsv.Phase = "enter"
		pkszTHmain.syncLoadout()
		pkszTHmain.spawnZombie()
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "requestCurEvent" then
		-- print("pkszTH catch requestCurEvent")
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "initRequest" then
		-- print("pkszTH catch initRequest")
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "debugPrint" then
		print("pkszTH debug monitor by Server ------------")
		print("pkszTH progress = " .. pkszTHsv.Progress)
		print("pkszTH mainTick = " .. pkszTHsv.mainTick)
		print("pkszTH startTick "..pkszTHsv.curEvent.startTick)
		print("pkszTH eventTimeout "..pkszTHsv.curEvent.eventTimeout)
		print("pkszTH endTick "..pkszTHsv.curEvent.endTick)
		print("pkszTH Phase sv "..pkszTHsv.Phase)
		print("pkszTH Phase cl "..args.phase)
		pkszTHmain.getSafehouseList()
    end

end
Events.OnClientCommand.Add(onServerCommand)


-- spawnZed
pkszTHmain.spawnZombie = function()

	local density = tonumber(pkszTHsv.curEvent.HordeDensity)
	local radius = tonumber(pkszTHsv.curEvent.spawnRadius)
	local squareX = pkszTHsv.curEvent.spawnVector.x
	local squareY = pkszTHsv.curEvent.spawnVector.y
	local squareZ = pkszTHsv.curEvent.spawnVector.z

	-- 1 Zed down in the center (Leader)
	local LDoutfits = pkszTHsv.curEvent.leaderOutfitGrp
	local LDoutfitNo = ZombRand(#LDoutfits) + 1
	local LDOutfit = LDoutfits[LDoutfitNo]
	addZombiesInOutfit(squareX, squareY, squareZ, 1,LDOutfit["item"], tonumber(LDOutfit["num"]), true, true, true, true, 1)

	local square = getSquare(
		pkszTHsv.curEvent.spawnVector.x,
		pkszTHsv.curEvent.spawnVector.y,
		pkszTHsv.curEvent.spawnVector.z
	)

	local zed = square:getZombie()
	local zedId = zed:getOnlineID()
	pkszTHsv.curEvent.lootZedId = zedId

	-- Spawn Horde
	local outfits = pkszTHsv.curEvent.zedOutfitGrp
	for i=1,density do
		local outfitNo = ZombRand(#outfits) + 1
		local thisOutfit = outfits[outfitNo]
		local x = ZombRand(squareX - radius, squareX + radius + 1)
		local y = ZombRand(squareY - radius, squareY + radius + 1)
		-- print("x= "..x.." y= "..y.." sqZ "..squareZ.." zed "..thisOutfit["item"].." femaleChance "..thisOutfit["num"])
		addZombiesInOutfit(x, y, squareZ, 1, tostring(thisOutfit["item"]), tonumber(thisOutfit["num"]), false, false, false, false, 1)
	end

	pkszTHsv.logger("spawnLeader "..LDOutfit["item"].. " id = "..zedId,true)
	pkszTHsv.logger("spawnZed "..squareX.."-"..squareY.."-"..squareZ.." Density "..density.." Radius "..radius,true)

end

-- loadout sync
pkszTHmain.syncLoadout = function()

	local item = InventoryItemFactory.CreateItem(pkszTHsv.curEvent.InventoryItem)
	for key in pairs(pkszTHsv.curEvent.LoadOut) do
		for keyB,valueB in pairs(pkszTHsv.curEvent.LoadOut[key]) do
			if keyB == "item" then
				-- print("on Inventory:" ..valueB.. " num = " ..pkszTHsv.curEvent.LoadOut[key]["num"])
				item:getItemContainer():AddItems( valueB ,tonumber(pkszTHsv.curEvent.LoadOut[key]["num"]) );
			end
		end
	end

	-- This "transmitCompleteItemToServer" fucking broken 
	-- local inv = square:AddWorldInventoryItem(pkszTHsv.curEvent.InventoryItem, 0,0,0)
	-- inv:getWorldItem():transmitCompleteItemToServer()
	-- --------------------------xxxxxx

	--- Solved by send isoObject to client
	pkszTHsv.curEvent.objBag = item
	-- 同行者に見えないなら、squareを読み込んでいるプレイヤーもクライアント側でアイテムスポーン処理をすれば解決する

end

pkszTHmain.dataConnect = function(act)

	if isClient() then return end
	-- print("isServer ",isServer())
	pkszTHsv.logger(pkszTHsv.Phase .. " / to client send message " .. act ,true)
	pkszTHsv.curEvent.phase = pkszTHsv.Phase
	if isServer() then
		sendServerCommand('pkszTHpager', act, pkszTHsv.curEvent)
	else
		pkszTHsingle.toClient(player, "pkszTHctrl", act, pkszTHsv.curEvent);
	end

end


-- safehouseList
-- under develop now
pkszTHmain.getSafehouseList = function()
	-- print(" getSafehouseList ")
	local safeVector = {}
	for i=0,SafeHouse.getSafehouseList():size()-1 do
		local safe = SafeHouse.getSafehouseList():get(i);
		if safe:isRespawnInSafehouse(username) and (safe:getPlayers():contains(username) or (safe:getOwner() == username)) then
			safeVector.x = safe:getX() + (safe:getH() / 2);
			safeVector.y = safe:getX() + (safe:getH() / 2);
			-- print("safe x=" ..safeVector.x.. " y=" ..safeVector.y)
		end
	end
end


pkszTHmain.saveEventHistory = function()

	local timestamp = getTimestamp();
    local gameDate = pkszTHsv.getGameTime()

	local str = ""

	str = str .. timestamp .. ","
	str = str .. gameDate .. ","
	str = str .. pkszTHsv.curEvent.EventId .. ","
	str = str .. pkszTHsv.curEvent.startDateTime .. ","
	str = str .. pkszTHsv.curEvent.Coordinate .. ","
	str = str .. pkszTHsv.curEvent.HordeDensity .. ","
	str = str .. pkszTHsv.curEvent.loadOutSelectCD .. ","
	str = str .. pkszTHsv.curEvent.cordListSelectCD .. ","
	-- str = str .. pkszTHsv.mainTick .. ","
	-- str = str .. pkszTHsv.Phase .. ","
	-- str = str .. pkszTHsv.curEvent.checkPlayer .. ","

	-- pkszTHsv.logger("EventHistory //" ..str,true)
	local dataFile = getFileWriter(pkszTHsv.Settings.historyFilename, true, true);
	dataFile:write(str .. "\n");
	dataFile:close();

end
