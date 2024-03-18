pkszThPagerCli = {}
pkszThPagerCli.mute = "OFF"


pkszThPagerCli.pagerContextMenu = function(player, table, items)


	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end
	if pkszThCli.forceSuspend == true then
		for i,v in ipairs(items) do
			if not instanceof(v, "InventoryItem") then
				table:addOption(getText("ContextMenu_pkszTH_pagerBroken") , v ,pkszThPagerCli.checkMonitor)
			end
		end
		return
	end

	local contextOn = false
	local item = nil
	for i,v in ipairs(items) do
		if not instanceof(v, "InventoryItem") then
			item = v.items[1]
			contextOn = true
		end
		if instanceof(v, "InventoryItem") then
			item = v
			contextOn = true
		end
		if contextOn then
			pkszThCli.isContainsPager()
			if pkszThCli.isEquippedPager(item) then
				local muteText = getText("ContextMenu_pkszTH_pagerMute")
				table:addOption(muteText..pkszThPagerCli.mute , v ,pkszThPagerCli.toggleMute)
				table:addOption(getText("ContextMenu_pkszTH_checkMonitor") , v ,pkszThPagerCli.checkMonitor)
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
		pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_Initializ"));
		pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_PleaseWait"));
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
		if pkszThCli.phase == "wait" then
			pkszTHsv.curEvent.massege[1] = ""
			pkszTHsv.curEvent.massege[2] = ""
			pkszTHsv.curEvent.massege[3] = ""
			pkszThPagerCli.sayMessage(getText("IGUI_pkszTH_closeInfo"));
		end
	end

end

pkszThPagerCli.sayMessage = function(msg)
	if msg then
		getPlayer():Say(msg)
	else
		getPlayer():Say("...")
	end
end
