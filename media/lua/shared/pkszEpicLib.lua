pkszEpicLib = {}


pkszEpicLib.getItemType = function(item)

	local getName = item:getName()
	local getType = item:getType()
	local getFullType = item:getFullType()
	local getCategory = item:getCategory()

	local flgGen = false

	if getCategory == "Container" then
		flgGen = true
		thisType = "bag"
	end
	if item:IsWeapon() then
		flgGen = true
		thisType = "weapon"
	end
	if item:IsClothing() then
		-- print("IsClothing ",item:getCategory())
		if item:getCategory() == "AlarmClock" then
			flgGen = true
			thisType = "watch"
		else
			flgGen = true
			thisType = "cloth"
		end
	end
	if flgGen == false then
		return nil
	end

	return thisType

end

pkszEpicLib.toServer = function(player,module,command,args)

	print("pkszEpicLib.toServer ----------- ")
	-- print("toServer player ",player)
	-- print("toServer module ",module)
	-- print("toServer command ",command)
	-- print("toServer args ",args)

	--return SandboxVars
    if command == "requestSandboxVars" then
		if pkszEpicGetSandboxVars() then
			pkszEpicDataConnect("sendSandboxVars",pkszEpic.settings)
		end
	end

	--return admin create epic
    if command == "adminEpic" then
		local item = args[1]
		local tryEpic = pkszEpicCreateItemName(item)
		if tryEpic then
			pkszEpicDataConnect("sendnameByAdmin",{tryEpic})
		else
			pkszEpic.logger("ERROR admin create name error "..item:getName(),true)
		end
	end

    if command == "logger" then
		pkszEpic.logger(args[1],true)
	end
    if command == "history" then
		pkszEpic.history(args[1],true)
	end

    if command == "restart" then
		pkszEpic.restart()
	end


end

pkszEpicLib.toClient = function(module,command,args)

	print("pkszEpicLib.toClient ----------- ")
	-- print("toClient player ",player)
	-- print("toClient module ",module)
	-- print("toClient command ",command)
	-- print("toClient args ",args)

	-- update SandboxVars
    if command == "sendSandboxVars" then
		pkszEpicCli.settings = args
		-- admin mode
		if pkszEpicCli.settings.Disabled == false then
			if pkszEpicCli.settings.AdminEpicConvert == true then
				local adminFlg = false
				if isDebugEnabled() then
					adminFlg = true
				end
				if isAdmin() then
					adminFlg = true
				end
				if adminFlg == true then
					if pkszEpicCli.ConEventLock == false then
						pkszEpicCli.ConEventLock = true
						Events.OnFillInventoryObjectContextMenu.Add(pkszEpicAdminMenu)
					end
				end
			end
		end
		-- return form conversionToEpic
		if instanceof(pkszEpicCli.CreateCur, "InventoryItem") then
			local test = pkszEpicGen.doGenerate(pkszEpicCli.CreateCur)
			if test == nil then
				pkszEpicCli.clientLogger("ERROR Convert error:".. pkszEpicCli.CreateCur:getFullType() ,"log")
			end
		end

	end

    if command == "sendnameByAdmin" then
		local newName = args[1]
		pkszEpicCli.CurName = newName
		pkszEpicGen.conversionToEpic(pkszEpicCli.AdminEpicCur)
	end


end
