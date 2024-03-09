require "TimedActions/ISBaseTimedAction"

pkszThCliCtrl = {}
pkszThCli.signal = "noSignal"
pkszThCli.isPager = false

-- After reading the coordinates, request object spawn
-- client watch
pkszThCliCtrl.clientWatch = function()

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end
	if pkszThCli.forceSuspend == true then
		return
	end

	if pkszThCli.signal == "noSignal" then
		-- print("signal ctrl")
		pkszThCli.phase = "init"
		pkszThCliCtrl.initConnect()
	end

	if pkszThCli.phase == "open" or pkszThCli.phase == "notis" then
		local square = getSquare(
			pkszThCli.curEvent.spawnVector.x,
			pkszThCli.curEvent.spawnVector.y,
			pkszThCli.curEvent.spawnVector.z
		)
		if square then
			local pPos = pkszThCli.getPlayerPos()
			local distance = (pPos.x - pkszThCli.curEvent.spawnVector.x) ^ 2 + (pPos.y - pkszThCli.curEvent.spawnVector.y) ^ 2
			if distance < 480 then
				local player = getSpecificPlayer(0)
				pkszThCli.phase = "enter"
				pkszThCliCtrl.removeObject(square)
				pkszThCliCtrl.dataConnect("doSpawnObject")
				ISTimedActionQueue.add(pkszTHeventEnter:new(player))
			end
		end
	end

	if pkszThCli.phase == "enter" then
		local square = getSquare(
			pkszThCli.curEvent.spawnVector.x,
			pkszThCli.curEvent.spawnVector.y,
			pkszThCli.curEvent.spawnVector.z
		)
		if square then
			local pPos = pkszThCli.getPlayerPos()
			if pkszThCli.curEvent.spawnVector.z == pPos.z then
				local distance = (pPos.x - pkszThCli.curEvent.spawnVector.x) ^ 2 + (pPos.y - pkszThCli.curEvent.spawnVector.y) ^ 2
				if distance < 3 then
					local player = getSpecificPlayer(0)
					print("--------- pkszTH catch item ----------")
					pkszThPagerCli.sayMessage("---- Clear this Mission ----")
					pkszThCli.phase = "close"
					pkszThCliCtrl.dataConnect("doClose")
					pkszThCliCtrl.syncSpawnBag()
					ISTimedActionQueue.add(pkszTHeventDrop:new(player))
				end
			end
		end
	end

	if pkszThCli.phase == "close" then
		pkszThCli.phase = "wait"
	end

end
Events.OnPlayerUpdate.Add(pkszThCliCtrl.clientWatch)

function playRandomSound(tag,char)

	local soundNam = ""
	local setNo = 1

	if tag == "enter" then
		soundNam = "enter"
		setNo = ZombRand(9) + 1
	end
	if tag == "drop" then
		soundNam = "pkszTHdropItem"
		setNo = ZombRand(3) + 1
	end

	soundNam = soundNam .. tostring(setNo)
	print("pkszTH play sound .. " ..soundNam)
	char:getEmitter():playSound(soundNam)

end

-- conn server
pkszThCliCtrl.dataConnect = function(act)

	if isServer() then return end
	local player = getPlayer();
	print("dataConnect " ..act)
	if isClient() then
		sendClientCommand(player, "pkszTHctrl", act, pkszThCli.curEvent);
	else
		pkszTHsingle.toServer(player, "pkszTHctrl", act, pkszThCli.curEvent);
	end

end

pkszThCliCtrl.initConnect = function(act)

	if isServer() then return end
	local player = getPlayer();
	print("initConnect")
	pkszThCli.signal = "onSignal"
	if isClient() then
		sendClientCommand(player, "pkszTHctrl", "initRequest", pkszThCli.curEvent);
	else
		pkszTHsingle.toServer(player, "pkszTHctrl", "initRequest", pkszThCli.curEvent);
	end

end


-- send new message
local function onServerCommand(module, command, args)
	if module ~= "pkszTHpager" then return end

	-- print("onServerCommand module ",module)
	-- print("onServerCommand command ",command)
	-- print("onServerCommand args ",args)

	local player = getPlayer();
    local playerInv = player:getInventory()

	pkszThCli.massege[1] = "no message"
	pkszThCli.massege[2] = ""
	pkszThCli.massege[3] = ""

	-- all member
	if command == "EventInfoShare" then
		pkszThCli.signal = "onSignal"
		-- Get event information
		pkszThCli.curEvent = {}
		pkszThCli.curEvent = args
		pkszThCli.phase = pkszThCli.curEvent.phase
		pkszThCli.masseg = {}
		if not pkszThCli.curEvent.massege then
			pkszThCli.curEvent.massege = {}
			pkszThCli.curEvent.massege[1] = "no message"
			pkszThCli.curEvent.massege[2] = ""
			pkszThCli.curEvent.massege[3] = ""
		end
		pkszThCli.massege[1] = pkszThCli.curEvent.massege[1]
		pkszThCli.massege[2] = pkszThCli.curEvent.massege[2]
		pkszThCli.massege[3] = pkszThCli.curEvent.massege[3]

	end

	-- has pager member
	if command == "IncomingPager" then
		if pkszThCli.isContainsPager() == false then return end
		if pkszThCli.allowRing == true then
			pkszThCli.curEvent = {}
			pkszThCli.curEvent = args
			pkszThCli.phase = pkszThCli.curEvent.phase
			pkszThCli.massege[1] = pkszThCli.curEvent.massege[1]
			pkszThCli.massege[2] = pkszThCli.curEvent.massege[2]
			pkszThCli.massege[3] = pkszThCli.curEvent.massege[3]
			-- Play Incoming call
			if pkszThPagerCli.mute == "OFF" then
				ISTimedActionQueue.add(pkszTHpagerAction:new(player))
			end
		end
	end


	-- forceSuspend
	if command == "forceSuspend" then
		print("pkszTH - Client ERROR : Processing will be force suspend because a fatal error has been detected.")
		pkszThCli.forceSuspend = true
	end


end
Events.OnServerCommand.Add(onServerCommand)

pkszThCliCtrl.syncSpawnBag = function()

	if pkszThCli.forceSuspend == true then
		return
	end

	print("pkszTH - sync spawn bag")

	local bag = pkszThCli.curEvent.objBag
	local square = getSquare(
		pkszThCli.curEvent.spawnVector.x,
		pkszThCli.curEvent.spawnVector.y,
		pkszThCli.curEvent.spawnVector.z
	)

	square:AddWorldInventoryItem(bag, 0,0,0)

	pkszThCli.curEvent.objBag = {}
end

-- removeObject
pkszThCliCtrl.removeObject = function(square)

	print("removeObject")
	if not square then return end

	local removeList = {}
	local cnt = 1
	for k=0, square:getObjects():size()-1 do
		local ttt = square:getObjects():get(k)
		if instanceof(ttt, "IsoWorldInventoryObject") then
			if ttt:getItem() then
				removeList[cnt] = ttt
				cnt = cnt + 1
			end
		end
	end

	for key in pairs(removeList) do
		square:removeWorldObject(removeList[key])
	end

	local cx = pkszThCli.curEvent.spawnVector.x
	local cy = pkszThCli.curEvent.spawnVector.y
	local cz = pkszThCli.curEvent.spawnVector.z

	local radius = 4
	local rmCnt = 0
	for x=0,radius do
		local tx = cx + x;
		for y=0,radius do
			local ty = cy + y;
			local rmSq = getSquare(
				tx-2,
				ty-2,
				cz
			)
			if rmSq then
				local deadBodys = rmSq:getDeadBodys()
				for i=0, deadBodys:size()-1 do
					local deadBody = deadBodys:get(i)
					if instanceof(deadBody, "IsoDeadBody") then
						rmSq:removeCorpse(rmSq:getDeadBody(), false)
						rmCnt = rmCnt + 1
					end
				end
			end
		end
	end
	print("pkszTH - remove dead body "..rmCnt)

end

-- debug KEY_TOOL
pkszThCliCtrl.onKeyPressed = function(keyCode)

	if pkszThCli.debug == false then return end

	-- delete
	if keyCode == 211 then
		print("pkszTH debug monitor by Client ------------")
		print("SandboxVars.pkszTHopt.eventDisabled : " ,SandboxVars.pkszTHopt.eventDisabled)
		print("Event phase : " .. pkszThCli.phase)

		pkszThCli.isContainsPager()
		-- pkszThCliCtrl.dataConnect("debugPrint")
		print("pkszTH debug monitor by Client ------------")
	end

	-- insert
--	if keyCode == 210 then
--		print("debug spawn ------------")
--	 	local square = getSquare(
--	 		pkszThCli.curEvent.spawnVector.x,
--	 		pkszThCli.curEvent.spawnVector.y,
--	 		pkszThCli.curEvent.spawnVector.z
--		)
--	 	if square then
--	 		print("clientWatch x= " ..pkszThCli.curEvent.spawnVector.x)
--	 		print("clientWatch y= " ..pkszThCli.curEvent.spawnVector.y)
--			pkszThCli.phase = "open"
--	 	end
-- 	end

end
Events.OnKeyPressed.Add(pkszThCliCtrl.onKeyPressed)
