local upgrades = {
    UpgradeTea =           require "scripts.upgrade.upgrade_tea",
    UpgradeEspresso =      require "scripts.upgrade.upgrade_espresso",
    UpgradeMilk =          require "scripts.upgrade.upgrade_milk",
    UpgradeBoba =          require "scripts.upgrade.upgrade_boba",
    UpgradeEnergyDrink =   require "scripts.upgrade.upgrade_energy_drink",
    UpgradeSoda =          require "scripts.upgrade.upgrade_soda",
    UpgradeFizzyLemonade = require "scripts.upgrade.upgrade_fizzy_lemonade",

    UpgradeWater =       require "scripts.upgrade.upgrade_water",
}

return upgrades