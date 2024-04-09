if CLIENT then
    SWEP.PrintName          = "Vest"
    SWEP.Slot               = 7

    SWEP.ViewModelFOV       = 60
end

SWEP.ViewModel              = "models/weapons/v_slam.mdl"
SWEP.WorldModel             = "models/weapons/w_slam.mdl"
SWEP.Weight                 = 2

SWEP.Base                   = "weapon_tttbase"
SWEP.Category               = WEAPON_CATEGORY_ROLE

SWEP.Spawnable              = true
SWEP.AutoSpawnable          = false
SWEP.HoldType               = "slam"
SWEP.Kind                   = WEAPON_ROLE

SWEP.DeploySpeed            = 4
SWEP.AllowDrop              = false
SWEP.NoSights               = true
SWEP.UseHands               = true
SWEP.LimitedStock           = true
SWEP.AmmoEnt                = nil

SWEP.Primary.Delay          = 0.25
SWEP.Primary.Automatic      = false
SWEP.Primary.Cone           = 0
SWEP.Primary.Ammo           = nil
SWEP.Primary.ClipSize       = 100
SWEP.Primary.ClipMax        = 100
SWEP.Primary.DefaultClip    = 100
SWEP.Primary.Sound          = ""

if SERVER then
    SWEP.UseCount = 0

    CreateConVar("ttt_specialist_vest_drain", "0.32", FCVAR_NONE, "The drain delay", 0.01, 1)
    CreateConVar("ttt_specialist_vest_recharge", "0.16", FCVAR_NONE, "The recharge delay", 0.01, 1)
    CreateConVar("ttt_specialist_vest_uses", "0", FCVAR_NONE, "How many times the vest can be used. 0 = Infinite", 0, 10)
end

-- If this vest has limited uses, remove it when they've met or exceeded that amount
local function CheckUseCount(vest)
    local uses = GetConVar("ttt_specialist_vest_uses"):GetInt()
    vest.UseCount = vest.UseCount + 1

    -- 0 = Infinite
    if uses == 0 then return end

    if vest.UseCount >= uses then
        vest:Remove()
    end
end

function SWEP:Initialize()
    self.lastTickSecond = 0
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)

    if CLIENT then
        self:AddHUDHelp("spec_vest_help_pri", "spec_vest_help_sec", true)
    end
    return self.BaseClass.Initialize(self)
end

function SWEP:Equip()
end

-- If we're switching from a TFA weapon to the vest while it's running, JUST DO IT!
-- The holster animation causes a delay where the client is not allowed to switch weapons
-- This means if we tell the user to select a weapon and then block the user from switching weapons immediately after,
-- the holster animation delay will cause the player to not select the weapon we told them to
hook.Add("TFA_PreHolster", "specialistTFAPreHolster", function(wep, target)
    if not IsValid(wep) or not IsValid(target) then return end

    local owner = wep:GetOwner()
    if not IsPlayer(owner) or not owner:Isspecialist() then return end

    local weapon = WEPS.GetClass(target)
    local running = owner:GetNWBool("specialistvestunning", false)
    if running and weapon == "weapon_spec_vest" then
        return true
    end
end)

function SWEP:Holster()
    return not self:GetOwner():GetNWBool("specialistvestunning", false)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
    return true
end

function SWEP:SetvestState(active)
    if CLIENT then return end

    local owner = self:GetOwner()
    owner:SetNWBool("specialistVestActive", active)

    local message = "Your vest has been "
    if not active then
        message = message .. "de-"
    end
    message = message .. "activated."
    owner:QueueMessage(MSG_PRINTBOTH, message)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    local owner = self:GetOwner()
    if owner:GetNWBool("specialistvestunning", false) then return end

    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

    if SERVER then
        -- Toggle state
        local active = not owner:GetNWBool("specialistVestActive", false)
        self:SetvestState(active)
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then return end

    if self:GetNextPrimaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    local owner = self:GetOwner()
    if owner:GetNWBool("specialistvestunning", false) then
        owner:specialistRevive()
        CheckUseCount(self)
    end
end

function SWEP:Think()
    if CLIENT then return end

    local owner = self:GetOwner()
    local running = owner:GetNWBool("specialistvestunning", false)
    local rate = running and GetConVar("ttt_specialist_vest_drain"):GetFloat() or GetConVar("ttt_specialist_vest_recharge"):GetFloat()

    if CurTime() - self.lastTickSecond > rate then
        local clip = self:Clip1()
        -- If they run out of charge, disable the vest
        if running and clip == 0 then
            owner:specialistRevive()
            CheckUseCount(self)
        else
            if running then
                clip = clip - 1
            else
                clip = clip + 1
            end

            if clip < 0 or clip > self:GetMaxClip1() then return end

            self:SetClip1(clip)
            self.lastTickSecond = CurTime()
        end
    end
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if not IsPlayer(owner) then return end

    if CLIENT and owner == LocalPlayer() and owner:Alive() then
        RunConsoleCommand("lastinv")
    end

    if SERVER then
        if owner:GetNWBool("specialistvestunning", false) then
            owner:specialistRevive()
        end

        owner:SetNWBool("specialistVestActive", false)
    end
end

if SERVER then
    hook.Add("TTTPlayerHandcuffed", "specialist_TTTPlayerHandcuffed", function(owner, target, time)
        if not IsValid(target) then return end
        if not target:Isspecialist() then return end

        local vest = target:GetWeapon("weapon_spec_vest")
        if not IsValid(vest) then return end

        vest:SetvestState(false)
        if target:GetNWBool("specialistvestunning", false) then
            target:specialistRevive()
            CheckUseCount(vest)
        end
    end)
end