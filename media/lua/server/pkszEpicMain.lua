pkszEpicMain = {}
if isClient() then return end

local function onServerCommand(module,command,player,args)

	if module ~= "pkszEpic" then return end

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
Events.OnClientCommand.Add(onServerCommand)

pkszEpicMain.CreateItemNameWrap = function(item)
	local name = pkszEpicCreateItemName(item)
	return name
end

function pkszEpicCreateItemName(item)

	local result = false

	local thisType = pkszEpicLib.getItemType(item)

	if thisType == nil then
		return result
	end

	local getFullType = item:getFullType()
	local getName = item:getName()

	local tryName = pkszEpicGetNewName(thisType,getFullType,getName)
	if tryName then
		result = tryName
	end

	return result

end


function pkszEpicGetNewName(thisType,fullName,getName)

	--  print(" pkszEpicGetNewName "..thisType.."/"..fullName.."/"..getName)

	local newName = ""
	local header = ""
	local footer = ""

	local words = nil

	local lot = nil
	local chois = 0

	local pattarn = {}
	pattarn.weapon = {1,2,2,2,2,3,3}
	pattarn.cloth = {1,1,1,2,2}
	pattarn.bag = {1,1,1,2,2}
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
		local parts = pkszEpic.StrSplit(list,",")
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

function pkszEpicDataConnect(act,param)

	if isClient() then return end

	if isServer() then
		sendServerCommand('pkszEpic', act, param)
	else
		pkszEpicLib.toClient("pkszEpic", act, param);
	end

end

function pkszEpicGetSandboxVars()

	pkszEpic.settings.Disabled = SandboxVars.pkszEpic.Disabled
	pkszEpic.settings.AdminEpicConvert = SandboxVars.pkszEpic.AdminEpicConvert
	pkszEpic.settings.ApplyToBags = SandboxVars.pkszEpic.ApplyToBags

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

	return true
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
