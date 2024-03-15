--
-- 
-- pkszEpicGen.conversionToEpic(inventryItem)
--
--


pkszEpicGen = {}

pkszEpicGen.singleRelay = function(a,b,c,d)

	if b == "pkszEpic" then
		if c == "doChange" then
			local itemName = pkszEpicGen.doGenerate(d,"nameonly")
			local item = pkszEpicGen.conversionToEpic(d)
			item:setName(itemName)
		end
		if c == "restart" then
			pkszEpic.restart()
		end
	end

end

local function onServerCommand(a,b,c,d)

	if a == "pkszEpic" then
		if b == "logging" then
			if isServer() then
				local msg = d[1]
				pkszEpic.logger(msg,d[2])
			end
		end
	end

end
Events.OnClientCommand.Add(onServerCommand)

--
pkszEpicGen.conversionToEpic = function(item)

	local result = nil
	result = pkszEpicGen.doGenerate(item,"")
	return result

end

pkszEpicGen.doGenerate = function(item,mode)

	-- Some things are lost on reboot
	-- Closed until a solution is found
	local notSavedClose = true


	if SandboxVars.pkszEpic.Disabled == true then
		if mode == "nameonly" then
			return item:getName()
		else
			pkszEpic.logger("- pkszEpic Disabled - "..item:getName(),true)
			return item
		end
	end

	-- print("doGenerate ",item)

	-- IsWeapon
	-- IsClothing
	-- getCategory() = Container

	local org = item

	local getName = item:getName()
	local getType = item:getType()
	local getFullType = item:getFullType()
	local getCategory = item:getCategory()
	local getModID = item:getModID()

	local thisType = ""

	local effectText = "[ "..getName.." ]<br>"..getText("Tooltip_pkszEpic_Item")
	local logText = ""

	local flgGen = false
	if getCategory == "Container" then
		flgGen = true
		thisType = "bag"
		logText = pkszEpicBuildLogText(logText,"Container",getName)
	end
	if item:IsWeapon() then
		flgGen = true
		thisType = "weapon"
		logText = pkszEpicBuildLogText(logText,"IsWeapon",getName)
	end
	if item:IsClothing() then
		-- print("IsClothing ",item:getCategory())
		if item:getCategory() == "AlarmClock" then
			flgGen = true
			thisType = "watch"
			logText = pkszEpicBuildLogText(logText,"AlarmClock",getName)
		else
			flgGen = true
			thisType = "cloth"
			logText = pkszEpicBuildLogText(logText,"IsClothing",getName)
		end
	end
	if flgGen == false then
		if mode == "nameonly" then
			return getName
		else
			pkszEpic.logger("ERROR [ "..getName.." ] This item cannot be made into an Epic.",true)
			return org
		end
	end

	pkszEpicSetupMultiplier()

	local minMultiplier = pkszEpic.settings.SpecImproveMultiplierMin
	local maxMultiplier = pkszEpic.settings.SpecImproveMultiplierMax
	local weightReduction = pkszEpic.settings.weightReduction

	local flgApplyToBags = SandboxVars.pkszEpic.ApplyToBags
	local flgWeaponsGlow = SandboxVars.pkszEpic.weaponsGlow

	local modifi = {}

-- setName
	local newName = pkszEpicGetNewName(thisType,getFullType,getName)
	if newName == false then return false end
	-- logText = pkszEpicBuildLogText(logText,"newName",newName)
	if mode == "nameonly" then
		pkszEpic.logger("Generate name : "..getFullType.." = "..newName,true)
		return newName
	end
	-- item:setName(newName)

-- xx setCondition 
	if notSavedClose == false then
		local dMulti = 2
		if thisType == "watch" then
			dMulti = 5
		end
		local modifi = pkszEpicGetValue(item:getConditionMax(),minMultiplier,maxMultiplier*dMulti,1,"i","p")
		item:setConditionMax(modifi.value)
		item:setCondition(modifi.value)
		effectText = effectText.."<br>Durability + "..modifi.mod
		logText = pkszEpicBuildLogText(logText,"setConditionMax",modifi.mod)
	end

-- weapon
--------------
	if thisType == "weapon" then

	-- setMaxDamage
		local modifi = pkszEpicGetValue(item:getMaxDamage(),minMultiplier,maxMultiplier,1,"f","p")
		item:setMaxDamage(modifi.value)
		effectText = effectText.."<br>MaxDamage + "..modifi.mod
		logText = pkszEpicBuildLogText(logText,"MaxDamage",modifi.mod)

		if item:isRanged() == true then

		-- getAimingTime Higher is better
			local modifi = pkszEpicGetValue(item:getAimingTime(),minMultiplier,maxMultiplier,1,"i","p")
			item:setAimingTime(modifi.value)
			effectText = effectText.."<br>AimingTime + "..modifi.mod
			logText = pkszEpicBuildLogText(logText,"AimingTime",modifi.mod)

		-- getRecoilDelay Lower is better
			local modifi = pkszEpicGetValue(item:getRecoilDelay(),minMultiplier,maxMultiplier,1,"i","m")
			item:setRecoilDelay(modifi.value)
			effectText = effectText.."<br>RecoilDelay - "..modifi.mod
			logText = pkszEpicBuildLogText(logText,"RecoilDelay",modifi.mod)


		else

			-- getMaxRange
			if item:getMaxRange() ~= 0 then
				local modifi = pkszEpicGetValue(item:getMaxRange(),minMultiplier,maxMultiplier,2,"i","p")
				item:setMaxRange(modifi.value)
				effectText = effectText.."<br>MaxRange + "..modifi.mod
				logText = pkszEpicBuildLogText(logText,"MaxRange",modifi.mod)
			end

			if notSavedClose == false then
			-- setLightDistance
				if flgWeaponsGlow == true then
					item:setLightDistance(1)
					item:setLightStrength(0.3)
					effectText = effectText.."<br>Glow faintly"
					logText = pkszEpicBuildLogText(logText,"Glow faintly",1)
				end
			end

		end

	end

-- cloth
--------------
	if thisType == "cloth" then
		if notSavedClose == false then
			-- setInsulation
			if item:getInsulation() ~= 0 then
				local modifi = pkszEpicGetValue(item:getInsulation(),minMultiplier,maxMultiplier*2,1,"f","p")
				item:setInsulation(modifi.value)
				effectText = effectText.."<br>Insulation + "..modifi.mod
				logText = pkszEpicBuildLogText(logText,"Insulation",modifi.mod)
			end

			-- setWindresistance
			if item:getWindresistance() ~= 0 then
				local modifi = pkszEpicGetValue(item:getWindresistance(),minMultiplier,maxMultiplier*2,1,"f","p")
				item:setWindresistance(modifi.value)
				effectText = effectText.."<br>WindResistance + "..modifi.mod
				logText = pkszEpicBuildLogText(logText,"WindResistance",modifi.mod)
			end

			-- setWaterResistance
			if item:getWaterResistance() ~= 0 then
				local modifi = pkszEpicGetValue(item:getWaterResistance(),minMultiplier,maxMultiplier*2,1,"f","p")
				item:setWaterResistance(modifi.value)
				effectText = effectText.."<br>WaterResistance + "..modifi.mod
				logText = pkszEpicBuildLogText(logText,"WaterResistance",modifi.mod)
			end

			-- setStompPower
			if item:getStompPower() >= 1.5 then
				local modifi = pkszEpicGetValue(item:getStompPower(),minMultiplier,maxMultiplier*2,1,"f","p")
				item:setStompPower(modifi.value)
				effectText = effectText.."<br>StompPower + "..modifi.mod
				logText = pkszEpicBuildLogText(logText,"StompPower",modifi.mod)
			end
		end
	end

-- bag
--------------
	if thisType == "bag" then
		-- print("setMaxCapacity() ",item:getMaxCapacity())
		-- print("setItemCapacity() ",item:getItemCapacity())
		-- print("setWeightReduction() ",item:getWeightReduction())
		-- print("setCapacity() ",item:getCapacity())
		local bagMax = 5
		local bagMin = 10
		if pkszEpic.settings.ApplyToBags == true then
			bagMax = maxMultiplier
			bagMin = minMultiplier
		end

		local modifi = pkszEpicGetValue(item:getCapacity(),bagMin,bagMax,1,"i","p")
		if modifi.value == item:getCapacity() then
			modifi.value = modifi.value + 1
			modifi.mod = 1
		end
		-- setCapacity
		item:setCapacity(modifi.value)
		effectText = effectText.."<br>Capacity + "..modifi.mod
		logText = pkszEpicBuildLogText(logText,"Capacity",modifi.mod)

		-- setWeightReduction
		if weightReduction > 0 then
			print(" pkszEpicGetValue "..pkszEpic.settings.weightReduction.."/"..item:getWeightReduction().."/"..weightReduction)
			local modifi = pkszEpicGetValue(item:getWeightReduction(),0,weightReduction,1,"i","r")
			if modifi.value == item:getWeightReduction() then
				modifi.value = modifi.value + 1
				modifi.mod = 1
			end
			item:setWeightReduction(modifi.value)
			effectText = effectText.."<br>WeightReduction + "..modifi.mod
			logText = pkszEpicBuildLogText(logText,"WeightReduction",modifi.mod)
		end

	end

-- setTooltip
--------------

    local player = getPlayer();
	if player then
	    local username = player:getUsername();
		logText = pkszEpicBuildLogText(logText," | username ",username)
	end

	effectText = effectText.."<br>"..getText("Tooltip_pkszEpic_Item_info")
	item:setTooltip(effectText)

	pkszEpic.logger(logText,true)

	return item
end

function pkszEpicGetValue(val,min,max,t,m,s)

	-- print(" pkszEpicGetValue "..val.."/"..min.."/"..max)

	if val == 0 then
		if m == "f" then
			modvalue = 0.05
		end
		if m == "i" then
			modvalue = 1
		end
	else
		if s=="r" then
			s = "p"
			modvalue = ZombRand(min,max)
		else
			modvalue = val * ( ZombRand(min,max) / 100)
		end
	end

	modvalue = modvalue * t

	if m == "f" then
		modvalue = string.format("%3.3f",modvalue)
	end
	if m == "i" then
		modvalue = math.floor(modvalue)
	end

	if s == "p" then
		val = val + modvalue
	else
		val = val - modvalue
		if val < 0 then
			val = 0
		end
	end

	return {mod=modvalue,value=val}

end

function pkszEpicSetupMultiplier()

	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 1 then
		pkszEpic.settings.SpecImproveMultiplierMin = 0
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 2 then
		pkszEpic.settings.SpecImproveMultiplierMin = 5
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 3 then
		pkszEpic.settings.SpecImproveMultiplierMin = 10
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 4 then
		pkszEpic.settings.SpecImproveMultiplierMin = 15
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 5 then
		pkszEpic.settings.SpecImproveMultiplierMin = 25
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMin == 6 then
		pkszEpic.settings.SpecImproveMultiplierMin = 25
	end

	--------------------------------

	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 1 then
		pkszEpic.settings.SpecImproveMultiplierMax = 5
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 2 then
		pkszEpic.settings.SpecImproveMultiplierMax = 10
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 3 then
		pkszEpic.settings.SpecImproveMultiplierMax = 15
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 4 then
		pkszEpic.settings.SpecImproveMultiplierMax = 25
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 5 then
		pkszEpic.settings.SpecImproveMultiplierMax = 30
	end
	if SandboxVars.pkszEpic.SpecImproveMultiplierMax == 6 then
		pkszEpic.settings.SpecImproveMultiplierMax = 50
	end

	--------------------------------

	if SandboxVars.pkszEpic.weightReduction == 1 then
		pkszEpic.settings.weightReduction = 0
	end
	if SandboxVars.pkszEpic.weightReduction == 2 then
		pkszEpic.settings.weightReduction = 1
	end
	if SandboxVars.pkszEpic.weightReduction == 3 then
		pkszEpic.settings.weightReduction = 2
	end
	if SandboxVars.pkszEpic.weightReduction == 4 then
		pkszEpic.settings.weightReduction = 3
	end
	if SandboxVars.pkszEpic.weightReduction == 5 then
		pkszEpic.settings.weightReduction = 4
	end
	if SandboxVars.pkszEpic.weightReduction == 6 then
		pkszEpic.settings.weightReduction = 5
	end

end

function pkszEpicGetNewName(thisType,fullName,getName)

	--  print(" pkszEpicGetNewName "..thisType.."/"..fullName.."/"..getName)

	local newName = ""
	local header = ""
	local footer = ""

	local words = nil

	local lot = nil
	local chois = 0

	local blockFormat = nil

	local pattarn = {}
	pattarn.weapon = {1,2,2,2,2,3,3}
	pattarn.cloth = {1,1,1,2}
	pattarn.bag = {1,1,1,2}
	pattarn.watch = {1,1}
	pattarn.specifi = {1,1}

	-- item specifi
	if pkszEpic.nameList[fullName] then
		lot = pkszEpic.nameList[fullName]
		chois = ZombRand(#lot) +1
		newName = lot[chois]
		-- print("specifi "..chois.."/"..#lot.." = "..newName)
	else
		if not pattarn[thisType] then return end

		-- get word num
		lot = pattarn[thisType]
		chois = ZombRand(#lot) +1
		-- print("#lot ",#lot)
		-- print("choist ",chois)
		local words = lot[chois]

		if thisType == "weapon" then
			if words == 1 then
				chois = ZombRand(1,100)
				if chois < 50 then
					header = "The "
				end
				chois = ZombRand(1,100)
				if chois < 40 then
					header = header..getName.." of "
				end

				lot = pkszEpic.nameList["weapon"]
				chois = ZombRand(#lot) +1
				newName = lot[chois]

			end
			if words == 2 then
				chois = ZombRand(1,100)
				if chois < 20 then
					header = "The "
				end
				chois = ZombRand(1,100)
				if chois < 30 then
					header = header..getName.." of "
				end

				newName = pkszEpicPickUpWord({"weapon","weapon,any"})

			end
			if words == 3 then
				chois = ZombRand(1,100)
				if chois < 10 then
					header = "The "
				end
				newName = pkszEpicPickUpWord({"weapon","any","any"})
			end

			-- print(" weapon!!"..words)
		end
		if thisType == "cloth" then
			if words == 1 then
				header = getName.." of "
				newName = pkszEpicPickUpWord({"cloth"})
			else
				newName = pkszEpicPickUpWord({"any","any"})
			end
		end
		if thisType == "bag" then
			if words == 1 then
				header = getName.." of "
				newName = pkszEpicPickUpWord({"bag"})
			else
				newName = pkszEpicPickUpWord({"any","any"})
			end
		end
		if thisType == "watch" then
			header = "Watch of "
			newName = pkszEpicPickUpWord({"watch"})
		end

	end

	if header ~="" then
		header = header.." "
	end
	if footer ~="" then
		footer = " "..footer
	end

	newName = header..newName..footer
	newName = newName:gsub("%s%s", " ")
	newName = string.gsub(newName, "^ +(.+) +$", "%1", 1)

	-- print("pkszEpicGetNewName "..thisType.." / "..fullName.." [ "..newName.." ]")

	return newName
end

function pkszEpicPickUpWord(tags)

	local myWords = {}
	local result = ""
	local lot = nil
	local chois = 0
	local temp = ""

	tags = pkszEpicShuffle(tags)

	for key,list in pairs(tags) do
		local parts = pkszEpicGen.StrSplit(list,",")
		if #parts == 2 then
			myWords = pkszEpicMerge_tables(pkszEpic.nameList[parts[1]], pkszEpic.nameList[parts[2]])
			myWords = pkszEpicMerge_tables(myWords, pkszEpic.nameList["head"])
		else
			myWords = pkszEpic.nameList[parts[1]]
		end
		lot = myWords
		chois = ZombRand(#lot) +1
		temp = myWords[chois]
		result = result..temp.." "
	end

	return result
end


function pkszEpicShuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = ZombRand(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function pkszEpicMerge_tables(t1, t2)
    local merged = {}
    for _, v in ipairs(t1) do
        table.insert(merged, v)
    end
    for _, v in ipairs(t2) do
        table.insert(merged, v)
    end
    return merged
end

pkszEpicGen.StrSplit = function(str, ts)
	if ts == nil then return {} end
	local t = {}
	local i = 1
	for s in string.gmatch(str, "([^"..ts.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end


function pkszEpicBuildLogText(logText,title,param)
	return logText..title.." / "..param.." | "
end
