Config = {}

Config.Debug = false -- only in dev mode.

Config.MarkerData = {
    ["type"] = 6,
    ["size"] = vector3(2.0, 2.0, 2.0),
    ["color"] = vector3(0, 255, 150)
}

Config.FishingRestaurant = {
    ["name"] = "Balık Restorantı",
    ["blip"] = {
        ["sprite"] = 0,
        ["color"] = 3
    },
    ["ped"] = {
        ["model"] = 0xED0CE4C6,
        ["position"] = vector3(-1038.4545898438, -1397.0551757813, 5.553192615509),
        ["heading"] = 75.0
    }
}

Config.FishingItems = {
    ["rod"] = {
        ["name"] = "wiz_fishingrod",
        ["label"] = "Olta"
    },
    ["bait"] = {
        ["name"] = "wiz_fishingbait",
        ["label"] = "Balık Yemi"
    },
    ["fish"] = {
        ["name"] = "wiz_fish",
        ["label"] = "Tatlı Su Balığı",
        ["price"] = 15 -- this is the price for each fish captured.
    }
}

Config.Command = "fish" -- if set to "" or "none" command will not work. otherwise item use will be used.