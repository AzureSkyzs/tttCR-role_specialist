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
ROLE.loadout = {}

ROLE.startingcredits = nil

ROLE.startinghealth = nil
ROLE.maxhealth = nil

ROLE.isactive = function(ply)
    return ply:GetNWBool("SpecialistActive", false)
end

ROLE.selectionpredicate = nil
ROLE.shouldactlikejester = nil

ROLE.translations = {}

--if SERVER then
--    CreateConVar("ttt_specialist_finalextra_dmg_slider", "0", FCVAR_NONE, "This is a slider to decide the extra dmg the specialist get when they are the last alive", 0, 2)
--end
ROLE.convars = {}
--table.insert(ROLE.convars, {
--    cvar = "ttt_summoner_slider",
--    type = ROLE_CONVAR_TYPE_NUM,
--    decimal = 1
--})

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