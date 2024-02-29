pkszThPagerCli = {}
pkszThPagerCli.mute = "OFF"


pkszThPagerCli.pagerContextMenu = function(player, table, items)

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end
	if pkszThCli.forceSuspend == true then
		return
	end

	for i,v in ipairs(items) do
		if not instanceof(v, "InventoryItem") then
			if pkszThPagerCli.isPager(v.items[1]) then
				local muteText = getText("ContextMenu_pkszTH_pagerMute")
				table:addOption(muteText..pkszThPagerCli.mute , v ,pkszThPagerCli.toggleMute)
				table:addOption(getText("ContextMenu_pkszTH_checkMonitor") , v ,pkszThPagerCli.checkMonitor)
				-- table:addOption("Event debug" , v ,pkszThPagerCli.restart)
			end
		end
	end
end
Events.OnFillInventoryObjectContextMenu.Add(pkszThPagerCli.pagerContextMenu)

pkszThPagerCli.toggleMute = function()

	if pkszThPagerCli.mute == "OFF" then
		pkszThPagerCli.mute = "ON"
		pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_toggleMuteON"));
	else
		pkszThPagerCli.mute = "OFF"
		pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_toggleMuteOFF"));
		local player = getPlayer();
		ISTimedActionQueue.add(pkszTHpagerAction:new(player))
	end

end

pkszThPagerCli.checkMonitor = function()

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end

	if pkszThCli.phase == "init" then
		if isClient() then
			pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_Initializ"));
			pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_PleaseWait"));
		end
		pkszThCli.phase = "wait"
		pkszThCliCtrl.dataConnect("requestCurEvent")
	else
		pkszThCliCtrl.dataConnect("requestCurEvent")
		-- print current message
		pkszThPagerCli.sayMessage(pkszThCli.massege[1]);
		pkszThPagerCli.sayMessage(pkszThCli.massege[2]);
		pkszThPagerCli.sayMessage(pkszThCli.massege[3]);
		if pkszThCli.phase == "open" then
			pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_CheckYourMap"));
		end
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
