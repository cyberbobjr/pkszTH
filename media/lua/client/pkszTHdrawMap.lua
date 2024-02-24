local pkszThISWorldMap_render = ISWorldMap.render;
function ISWorldMap:render()
	pkszThISWorldMap_render(self);

	if SandboxVars.pkszTHopt.eventDisabled == true then
		return
	end

	if ISWorldMap.IsAllowed() then end
	if isServer() then return end
	if pkszThCli.signal == "noSignal" then return end

	local player = getPlayer();
    local playerInv = player:getInventory()
	pkszThCli.isPager = pkszThCli.isContainsPager(playerInv)
	if pkszThCli.isPager == false then return end
	if not pkszThCli.curEvent.massege then return end
	if not pkszThCli.curEvent.spawnVector then return end

	-- if pkszThCli.phase == "close" then return end
	-- if pkszThCli.phase == "wait" then return end

    local x = math.floor(self.mapAPI:worldToUIX(pkszThCli.curEvent.spawnVector.x,pkszThCli.curEvent.spawnVector.y));
    local y = math.floor(self.mapAPI:worldToUIY(pkszThCli.curEvent.spawnVector.x,pkszThCli.curEvent.spawnVector.y));

	local myText = pkszThCli.curEvent.startDateTime .. " " .. pkszThCli.curEvent.spawnDesc

	self:drawRect(x,y,12,12, 0.7, 0.2, 0.2, 0.9);
    self:drawRectBorder(x,y,13,13, 1, 0, 0, 0);
	self:drawText(myText, x+20, y, 0, 0, 0, 1, UIFont.Small);
end
