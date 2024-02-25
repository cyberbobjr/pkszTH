pkszTHsingle = {}

pkszTHsingle.toServer = function(player,module,command,args)

	print("pkszTHsingle.toServer ----------- ",pkszTHsv.Phase)
	-- print("toServer player ",player)
	-- print("toServer module ",module)
	-- print("toServer command ",command)
	-- print("toServer args ",args)


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
		print("catch requestCurEvent")
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "initRequest" then
		print("catch initRequest")
		pkszTHmain.dataConnect('EventInfoShare')
    end

    if command == "debugPrint" then
		print("progress = " .. pkszTHsv.Progress)
		print("mainTick = " .. pkszTHsv.mainTick)
		print("startTick "..pkszTHsv.curEvent.startTick)
		print("eventTimeout "..pkszTHsv.curEvent.eventTimeout)
		print("endTick "..pkszTHsv.curEvent.endTick)
		print("Phase sv "..pkszTHsv.Phase)
		print("Phase cl "..args.phase)
		pkszTHmain.getSafehouseList()
    end

end

pkszTHsingle.toClient = function(player,module,command,args)

	print("pkszTHsingle.toClient ----------- ",pkszThCli.phase)
	-- print("toClient player ",player)
	-- print("toClient module ",module)
	-- print("toClient command ",command)
	-- print("toClient args ",args)

	local player = getPlayer();
    local playerInv = player:getInventory()
	pkszThCli.isPager = pkszThCli.isContainsPager(playerInv)

	pkszThCli.massege[1] = "empty"
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
			pkszThCli.curEvent.massege[1] = "no signal"
			pkszThCli.curEvent.massege[2] = ""
			pkszThCli.curEvent.massege[3] = ""
		end
		pkszThCli.massege[1] = pkszThCli.curEvent.massege[1]
		pkszThCli.massege[2] = pkszThCli.curEvent.massege[2]
		pkszThCli.massege[3] = pkszThCli.curEvent.massege[3]

	end

	-- has pager member
	if command == "IncomingPager" then
		-- print("pkszTHsingle.toClient IncomingPager ",args.massege[1])
		if pkszThCli.isPager == true then
			pkszThCli.curEvent = {}
			pkszThCli.curEvent = args
			pkszThCli.phase = pkszThCli.curEvent.phase
			pkszThCli.massege[1] = pkszThCli.curEvent.massege[1]
			pkszThCli.massege[2] = pkszThCli.curEvent.massege[2]
			pkszThCli.massege[3] = pkszThCli.curEvent.massege[3]
			-- Play Incoming call
			ISTimedActionQueue.add(pkszTHpagerAction:new(player))
		end
	end

end
