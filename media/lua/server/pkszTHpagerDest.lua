function DismantleTHpagerDest(items, result, player, selectedItem)
    local success = 10 + (player:getPerkLevel(Perks.Electricity)*5);
    player:getInventory():AddItem("Base.ElectronicsScrap");
    if ZombRand(0,100)<success then
        player:getInventory():AddItem("Radio.RadioReceiver");
    end

end