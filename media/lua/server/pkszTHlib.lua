pkszTHlib = {}


pkszTHlib.DetermEventTypeFlags = function(eventType)

	-- zombiewalk(spd1,spd2,spd3)
	-- afterhorde(Density)

	pkszTHsv.curEvent.eventTags = {}

	local types = pkszTHsv.strSplit(eventType,"/")
	for no,val in pairs(types) do
		local tags = pkszTHsv.strSplit(val,":")
		pkszTHsv.curEvent.eventTags[tags[1]] = tags[2]
		-- table.insert(pkszTHsv.curEvent.eventTags,val)
	end

end

pkszTHlib.buildSendMessageFormat = function(cur)


	local gameTime = pkszTHsv.getGameTime()
	local sendString = {}
	local cords = pkszTHsv.strSplit(cur.Coordinate,",")

	sendString[1] = gameTime
	sendString[2] = cur.eventDescription
	sendString[3] = pkszTHsv.curEvent.eventNote

	return sendString
end

pkszTHlib.saveEventHistory = function(mode)

	local timestamp = getTimestamp();
    local gameDate = pkszTHsv.getGameTime()

	local str = ""

	str = str .. timestamp .. ","
	str = str .. gameDate .. ","
	str = str .. pkszTHsv.curEvent.EventId .. ","
	if mode == "start" then
		str = str .. pkszTHsv.curEvent.startDateTime .. ","
		str = str .. pkszTHsv.curEvent.Coordinate .. ","
		str = str .. pkszTHsv.curEvent.HordeDensity .. ","
		str = str .. pkszTHsv.curEvent.loadOutSelectCD .. ","
		str = str .. pkszTHsv.curEvent.cordListSelectCD .. ","
	else
		str = str .. mode .. ","
	end

	-- str = str .. pkszTHsv.mainTick .. ","
	-- str = str .. pkszTHsv.Phase .. ","
	-- str = str .. pkszTHsv.curEvent.checkPlayer .. ","

	-- pkszTHsv.logger("EventHistory //" ..str,true)
	local dataFile = getFileWriter(pkszTHsv.Settings.historyFilename, true, true);
	dataFile:write(str .. "\n");
	dataFile:close();

end

