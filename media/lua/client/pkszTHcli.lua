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

pkszThCli.isContainsPager = function(playerInv)

	if playerInv:containsTypeRecurse("THpagerBlue") then
		return true
	end
	if playerInv:containsTypeRecurse("THpagerRed") then
		return true
	end

	return false
end
