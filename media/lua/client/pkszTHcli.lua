pkszThCli = {}
pkszThCli.debug = true

-- [ phase ]
-- init (initial)
-- wait (wait next event)
-- notice (send message to pager)
-- open (event progress)
-- enter (player enter)
-- close (cleaning)
pkszThCli.phase = "init"
pkszThCli.signal = "noSignal"

pkszThCli.allowRing = false
pkszThCli.allowUse = false

pkszThCli.forceSuspend = false

pkszThCli.curEvent = {}
pkszThCli.massege = {}
pkszThCli.massege[1] = "no signal"
pkszThCli.massege[2] = ""
pkszThCli.massege[3] = ""

pkszThCli.getPlayerPos = function()
	local player = getSpecificPlayer(0)
	local pos = {}
	if not player then
		pos = {x=0,y=0,z=0}
	else
		pos = {
			x=round(player:getX()),
			y=round(player:getY()),
			z=round(player:getZ())
		}
	end

	return pos
end

pkszThCli.isContainsPager = function()

	local flg = false

	pkszThCli.allowRing = false
	pkszThCli.allowUse = false
	pkszThCli.pagerPower = false
	local player = getPlayer();
    local playerInv = player:getInventory()

	for j = playerInv:getItems():size(), 1,-1  do
		local item = playerInv:getItems():get(j-1)
		if item:getTags():contains("pkszTHpager") then
			if item:isActivated() then
				if item:getDrainableUsesInt() > 5 then
					if item:getAttachedSlot() > 0 then
						pkszThCli.allowUse = true
					end

					if item:isEquipped() then
						pkszThCli.allowUse = true
					end

					pkszThCli.allowRing = true
					flg = true
				end
			end
			-- print(" item:getTags()",item:getTags())
			-- print(" item:isActivated()",item:isActivated())
			-- print(" item:IsDrainable()",item:IsDrainable())
			-- print(" item:IsClothing()",item:IsClothing())
			-- print(" item:getAttachmentType()",item:getAttachmentType())
			-- print(" item:getAttachedSlot()",item:getAttachedSlot())
			-- print(" item:getAttachedSlotType()",item:getAttachedSlotType())
			-- print(" item:getAttachmentsProvided()",item:getAttachmentsProvided())
			-- print(" item:isEquipped()",item:isEquipped())
			-- print(" item:getDrainableUsesInt()",item:getDrainableUsesInt())
			-- print(" allowRing ",pkszThCli.allowRing)
			-- print(" allowUse ",pkszThCli.allowUse)
		end
	end
	return flg
end


pkszThCli.isEquippedPager = function(item)

	if item:getTags():contains("pkszTHpager") then
		if item:isActivated() then
			if item:getDrainableUsesInt() > 5 then
				if item:isEquipped() then
					return true
				end
				if item:getAttachedSlot() > 0 then
					return true
				end
			end
		end
	end
	return false

end
