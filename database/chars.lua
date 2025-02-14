return {
    name = "Alan",
    class = "swordsman",
    stats = {
        level = 1,
        hpmax = 10,
        mpmax = 10,
        defense = 4,
        agility = 4,
        movement = 6,
        exp = 0,
        toNext = 500
        -- other stats?
    },
    gain = {
        {}, -- already level 1.
        {
            hpmax = 1.4,
            mpmax = 0,
            attack = 1,
            defense = 1,
            agility = 1,

        }
    },
    promotion = {
        class = "hero",
        {}, -- starts at level 1
        {
            hpmax = 1.4,
            mpmax = 0,
            attack = 1,
            defense = 1,
            agility = 1,
        }
    }
}
