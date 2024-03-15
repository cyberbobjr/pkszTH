pkszEpicCli = {}

pkszEpicCli.isClientForce = false

-- debug only
function pkszEpicReady()

	-- local flg = false
	-- if isDebugEnabled() then
	-- 	pkszEpicCli.isClientForce = true
	-- 	flg = true
	-- end
	-- if isAdmin() then
	-- 	pkszEpicCli.isClientForce = true
	-- 	flg = true
	-- end
	-- if flg == false then return end

	pkszEpic.restart()

end
Events.OnGameStart.Add(pkszEpicReady)


local function pkszEpicAdminMenu(player, table, items)

	print(" pkszEpic_adminMenu ")

	local flg = false
	if isDebugEnabled() then
		flg = true
	end
	if isAdmin() then
		flg = true
	end
	if flg == false then return end

	local item = nil
	for i,v in ipairs(items) do
		local epicChangeText = "** Try change EPIC"
		table:addOption(epicChangeText , v ,pkszEpicTryChange)
		table:addOption("** Display info on client console" , v ,pkszEpicItemInfo)
	end

end
-- Events.OnFillInventoryObjectContextMenu.Add(pkszEpicAdminMenu)

function pkszEpicItemInfo(param)

	local item = nil
	if not instanceof(param, "InventoryItem") then
		print("not InventoryItem")
		item = param.items[1]
	end
	if instanceof(param, "InventoryItem") then
		print("is InventoryItem")
		item = param
	end

	if item then
		print(" --------------------------")
		print(" item:getName()",item:getName())
		print(" item:getTooltip()",item:getTooltip())
		print(" item:getDescription()",item:getDescription())
		print(" item:getID()",item:getID())
		print(" item:getDisplayName()",item:getDisplayName())
		print(" item:getCategory()",item:getCategory())
		print(" item:getModID()",item:getModID())
		print(" item:getModule()",item:getModule())
		print(" item:getType()",item:getType())
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

function pkszEpicTryChange(param)

	if not param then return end
	local item = nil

	print("pkszEpicTryChange ",param)

	if not instanceof(param, "InventoryItem") then
		print("not InventoryItem")
		item = param.items[1]
	end
	if instanceof(param, "InventoryItem") then
		print("is InventoryItem")
		item = param
	end

	if item then
		pkszEpicDataConnect("doChange",item)
	end

end

function pkszEpicDataConnect(act,param)

	local player = getPlayer();

	if isClient() then
		--sendClientCommand(player, "pkszEpic", act, param);
		pkszEpicGen.singleRelay(player, "pkszEpic", act, param);
	else
		pkszEpicGen.singleRelay(player, "pkszEpic", act, param);
	end

end

function pkszEpicDebugKey(keyCode)

	-- insert
	if keyCode == 210 then
		pkszEpicDataConnect("restart",{})
	end

end
-- Events.OnKeyPressed.Add(pkszEpicDebugKey)
