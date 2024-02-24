require "TimedActions/ISBaseTimedAction"
pkszTHpagerAction = ISBaseTimedAction:derive("pkszTHpagerAction")

function pkszTHpagerAction:isValid() -- Check if the action can be done
    return true;
end

function pkszTHpagerAction:update() -- Trigger every game update when the action is perform
	print("Action update");
end

function pkszTHpagerAction:waitToStart() -- Wait until return false
    return false;
end

function pkszTHpagerAction:start() -- Trigger when the action start
	self.character:getEmitter():playSound("pkszTHbell1")
end

function pkszTHpagerAction:stop() -- Trigger if the action is cancel
    ISBaseTimedAction.stop(self);
end

function pkszTHpagerAction:perform() -- Trigger when the action is complete
    ISBaseTimedAction.perform(self);
end

function pkszTHpagerAction:new(character) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
	o.item = item;
    o.maxTime = 5; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end

--
--
--

pkszTHeventEnter = ISBaseTimedAction:derive("pkszTHeventEnter")

function pkszTHeventEnter:isValid() -- Check if the action can be done
    return true;
end

function pkszTHeventEnter:update() -- Trigger every game update when the action is perform
	print("Action update");
end

function pkszTHeventEnter:waitToStart() -- Wait until return false
    return false;
end

function pkszTHeventEnter:start() -- Trigger when the action start
	local soundNam = "enter"
	local setNo = ZombRand(4) + 1
	soundNam = soundNam .. tostring(setNo)
	-- print("play enter sound .. " ..soundNam)
	self.character:getEmitter():playSound(soundNam)

end

function pkszTHeventEnter:stop() -- Trigger if the action is cancel
    ISBaseTimedAction.stop(self);
end

function pkszTHeventEnter:perform() -- Trigger when the action is complete
    ISBaseTimedAction.perform(self);
end

function pkszTHeventEnter:new(character) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
	o.item = item;
    o.maxTime = 5; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end

--
--
--

pkszTHeventDrop = ISBaseTimedAction:derive("pkszTHeventEnter")

function pkszTHeventDrop:isValid() -- Check if the action can be done
    return true;
end

function pkszTHeventDrop:update() -- Trigger every game update when the action is perform
	print("Action update");
end

function pkszTHeventDrop:waitToStart() -- Wait until return false
    return false;
end

function pkszTHeventDrop:start() -- Trigger when the action start
	local soundNam = "pkszTHdropItem"
	local setNo = ZombRand(3) + 1
	soundNam = soundNam .. tostring(setNo)
	self.character:getEmitter():playSound(soundNam)

end

function pkszTHeventDrop:stop() -- Trigger if the action is cancel
    ISBaseTimedAction.stop(self);
end

function pkszTHeventDrop:perform() -- Trigger when the action is complete
    ISBaseTimedAction.perform(self);
end

function pkszTHeventDrop:new(character) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
	o.item = item;
    o.maxTime = 5; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end
