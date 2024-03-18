pkszEpicCli = {}

pkszEpicCli.disabled = true
pkszEpicCli.ConEventLock = false

pkszEpicCli.AdminEpicCur = nil
pkszEpicCli.CreateCur = nil
pkszEpicCli.CurName = nil

pkszEpicCli.settings = {}
pkszEpicCli.settings.Disabled = false
pkszEpicCli.settings.AdminEpicConvert = false
pkszEpicCli.settings.SpecImproveMultiplierMin = 0
pkszEpicCli.settings.SpecImproveMultiplierMax = 0
pkszEpicCli.settings.ApplyToBags = 0
pkszEpicCli.settings.weightReduction = 0


pkszEpicCli.ready = function()

	-- get servre sandbox-vars
	pkszEpicCli.dataConnect("requestSandboxVars",{})

end
Events.OnGameStart.Add(pkszEpicCli.ready)


function pkszEpicAdminMenu(player, table, items)

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

				local item = nil
				for i,v in ipairs(items) do
					table:addOption("** Try EPIC" , v ,pkszEpicTryChange)
					table:addOption("** Display info on client console" , v ,pkszEpicItemInfo)
					table:addOption("** SandboxVars Reload" , v ,pkszEpicCli.ready)
				end
			end
		end
	end

end


function pkszEpicTryChange(param)

	if not param then return end
	local item = nil

	if not instanceof(param, "InventoryItem") then
		item = param.items[1]
	end
	if instanceof(param, "InventoryItem") then
		item = param
	end

	if item then
		pkszEpicCli.AdminEpicCur = item
		pkszEpicCli.dataConnect("adminEpic",{item})
	end

end

pkszEpicCli.dataConnect = function(act,param)
	if isServer() then return end

	local player = getPlayer();

	if isClient() then
		sendClientCommand(player, "pkszEpic", act, param);
	else
		pkszEpicLib.toServer(player, "pkszEpic", act, param);
	end
end

pkszEpicCli.clientLogger = function(param,mode)

	if mode == "log" then
		pkszEpicCli.dataConnect("logger",{param})
	end
	if mode == "history" then
		pkszEpicCli.dataConnect("history",{param})
	end

end

local function onServerCommand(module, command, args)

	if module ~= "pkszEpic" then return end

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
						print("admin context on")
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
Events.OnServerCommand.Add(onServerCommand)

function pkszEpicItemInfo(param)

	local item = nil
	if not instanceof(param, "InventoryItem") then
		item = param.items[1]
	end
	if instanceof(param, "InventoryItem") then
		item = param
	end

	if item then
		print(" --------------------------")
		print(" item:getName()",item:getName())
		print(" item:getTooltip()",item:getTooltip())
		print(" item:getDescription()",item:getDescription())
		print(" item:getID()",item:getID())
		print(" item:getDisplayName()",item:getDisplayName())
		print(" item:getType()",item:getType())
		print(" item:getCategory()",item:getCategory())
		print(" item:getDisplayName()",item:getDisplayName())
		print(" item:getCategory()",item:getCategory())
		print(" item:getModID()",item:getModID())
		print(" item:getModule()",item:getModule())
		print(" item:getConditionMax()",item:getConditionMax())
		print(" item:IsClothing()",item:IsClothing())
		print(" item:IsWeapon()",item:IsWeapon())
		print(" --------------------------")
		if item:IsWeapon() == true then
			print(" item:getMaxDamage()",item:getMaxDamage())
			if item:isRanged() == true then
				print(" item:getMaxRange()",item:getMaxRange())
				print(" item:getAimingTime()",item:getAimingTime())
				print(" item:getRecoilDelay()",item:getRecoilDelay())
			else
				print(" item:getSwingSound()",item:getSwingSound())
			end
		elseif item:IsClothing() == true then
			print(" item:getInsulation()",item:getInsulation())
			print(" item:getWindresistance()",item:getWindresistance())
			print(" item:getWaterResistance()",item:getWaterResistance())
			print(" item:getStompPower()",item:getStompPower())
			print(" item:getStringItemType()",item:getStringItemType())
		end
		print(" item:getAttachmentType()",item:getAttachmentType())
	end
end

function pkszEpicDebugKey(keyCode)

	-- insert
	if keyCode == 210 then

		local adminFlg = false
		if isDebugEnabled() then
			adminFlg = true
		end
		if isAdmin() then
			adminFlg = true
		end
		if adminFlg == true then
			print("recive pkszEpic debug")
			pkszEpicCli.dataConnect("restart",{})
			pkszEpicCli.ready()
		end

	end

end
Events.OnKeyPressed.Add(pkszEpicDebugKey)
