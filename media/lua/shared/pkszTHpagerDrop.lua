
local pagerDropOpt = 0
local pagerDropRate = 0
local pagerDropLottery = 0

function pkszTHpagerDrops(zed)


	if pagerDropOpt ~= SandboxVars.pkszTHopt.PagerDropRate then
		pkszTHsetPagerDropRate()
	end

	if isServer() then return end

	-- 1 to pagerDropRate
	local myLot = ZombRand(1, pagerDropRate)

	if pagerDropLottery == myLot then
		local inv = zed:getInventory();
		local n = ZombRand(2)
		if n == 1 then
			inv:AddItems("pkszTHitem.THpagerBlue", 1);
		else
			inv:AddItems("pkszTHitem.THpagerRed", 1);
		end
	end

end
Events.OnZombieDead.Add(pkszTHpagerDrops);

function pkszTHsetPagerDropRate()

	-- I feel like there are no 1s at all, so I also set the Lottery number.
	-- Is ZombRand really right?

	pagerDropOpt = SandboxVars.pkszTHopt.PagerDropRate

	-- 1/1000
	if SandboxVars.pkszTHopt.PagerDropRate == 1 then
		pagerDropRate = 1000
		pagerDropLottery = 200
	-- 1/500
	elseif SandboxVars.pkszTHopt.PagerDropRate == 2 then
		pagerDropRate = 500
		pagerDropLottery = 200
	-- 1/100
	elseif SandboxVars.pkszTHopt.PagerDropRate == 3 then
		pagerDropRate = 100
		pagerDropLottery = 50
	-- 1/50 (default)
	elseif SandboxVars.pkszTHopt.PagerDropRate == 4 then
		pagerDropRate = 50
		pagerDropLottery = 20
	-- 1/25
	elseif SandboxVars.pkszTHopt.PagerDropRate == 5 then
		pagerDropRate = 25
		pagerDropLottery = 10
	-- 1/50
	elseif SandboxVars.pkszTHopt.PagerDropRate == 6 then
		pagerDropRate = 2
		pagerDropLottery = 1
	-- 1/1 (debug)
	else
		pagerDropRate = 50
		pagerDropLottery = 20
	end

	if isServer() then
		pkszTHsv.logger("Set Pager drop rate 1/"..pagerDropRate,false)
	end

end
