local upgrades = require "data.upgrades"

local upgrade_probabilities = {
    {upgrades.UpgradeTea:new(), 1},
    {upgrades.UpgradeEspresso:new(), 1},
    {upgrades.UpgradeMilk:new(), 1},
    {upgrades.UpgradeBoba:new(), 1},
    {upgrades.UpgradeSoda:new(), 1},
    {upgrades.UpgradeFizzyLemonade:new(), 1},
    {upgrades.UpgradeAppleJuice:new(), 1},
    {upgrades.UpgradeHotSauce:new(), 1},
    {upgrades.UpgradeCoconutWater:new(), 1},
    {upgrades.UpgradeHotChocolate:new(), 1},
}

return upgrade_probabilities