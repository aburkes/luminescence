-- this is an example file that demonstrates everything that an item can be or do. You shouldn't actually use it in the game...
return {
    name = "everything",
    description = "A test item you should never see in a released game.",
    icon = "path/to/icon",
    consumable = false, -- if true, using it will cause it to go away.
    --equipment will make it equipable
    equipment = {
        classes = {
            "any",
            -- add any classes that can equip this item. the presence of "any" will allow any class to use it.
        },
        type = "armor", -- can also be "weapon", potentially "accessory". Only one of each type can be equipped.
        bonus = {
            hp = 1,
            mp = 1,
            attack = 1,
            defense = 1,
            agility = 1,
            movement = 1
        },
    },
    effect = {
        --we'll figure this out soon enough.
    },
    range = 0 --some things can be used far, some close. Normal items should be 1; if it's 0 it can only be used on the person holding it.

}