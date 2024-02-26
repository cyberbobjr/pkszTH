pkszThPagerCli = {}

pkszThPagerCli.pagerContextMenu = function(player, table, items)

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end

	for i,v in ipairs(items) do
		if not instanceof(v, "InventoryItem") then
			if pkszThPagerCli.isPager(v.items[1]) then
				table:addOption("Check monitor" , v ,pkszThPagerCli.checkMonitor)
				-- table:addOption("Event debug" , v ,pkszThPagerCli.restart)
			end
		end
	end
end
Events.OnFillInventoryObjectContextMenu.Add(pkszThPagerCli.pagerContextMenu)


pkszThPagerCli.checkMonitor = function()

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end

	if pkszThCli.phase == "init" then
		pkszThPagerCli.sayMessage("Initializing...");
		pkszThPagerCli.sayMessage("Please wait a moment and check again.");
		pkszThCliCtrl.initConnect()
	else
		pkszThCliCtrl.dataConnect("requestCurEvent")
	end

	-- print current message
	pkszThPagerCli.sayMessage(pkszThCli.massege[1]);
	pkszThPagerCli.sayMessage(pkszThCli.massege[2]);
	pkszThPagerCli.sayMessage(pkszThCli.massege[3]);
	if pkszThCli.phase == "open" then
		pkszThPagerCli.sayMessage("----- Check! your map!! -----");
	end

end

pkszThPagerCli.sayMessage = function(msg)
	getPlayer():Say(msg)
end

pkszThPagerCli.isPager = function(item)
	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end
	if item and string.find(item:getType(), "THpager") then
		return true
	else
		return false
	end
end
