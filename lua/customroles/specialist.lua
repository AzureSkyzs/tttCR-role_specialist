local ROLE = {}

ROLE.nameraw = "specialist"
ROLE.name = "Specialist"
ROLE.nameplural = "Specialists"
ROLE.nameext = "a Specialist"
ROLE.nameshort = "spec"

ROLE.desc = [[At any point you can put on your vest and reflect damage for 5 second
while you have your vest on you and you are the last innocent alive you do x2 damage]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.shop = nil
ROLE.loadout = {"weapon_spec_vest"}

ROLE.startingcredits = nil

ROLE.startinghealth = nil
ROLE.maxhealth = nil

ROLE.isactive = function(ply)
    return ply:GetNWBool("SpecialistActive", false)
end

ROLE.selectionpredicate = nil
ROLE.shouldactlikejester = nil

ROLE.translations = {}

if SERVER then
    CreateConVar("ttt_specialist_extradmg_slider", "2", FCVAR_NONE, "This is a slider that changes the damage the specialist does when last inno is alive", 0, 10)
    CreateConVar("ttt_specialist_vest_time_slider", "5", FCVAR_NONE, "This is a slider that changes the time the specialists vest lasts", 0, 10)

end
ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_specialist_extradmg_slider",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})
table.insert(ROLE.convars, {
    cvar = "ttt_specialist_vest_time_slider",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end

if CLIENT then
    hook.Add("TTTTutorialRoleText", "SpecialistTutorialRoleText", function(role, titleLabel, roleIcon)
        if role == ROLE_SPECIALIST then
            local roleColor = ROLE_COLORS[ROLE_INNOCENT]
            return "The " .. ROLE_STRINGS[ROLE_SPECIALIST] .. " is a member of the innocent team who can At any point you can put on your vest and reflect damage for 5 second while you have your vest on you and you are the last innocent alive you do x2 damage."
        end
    end)
end