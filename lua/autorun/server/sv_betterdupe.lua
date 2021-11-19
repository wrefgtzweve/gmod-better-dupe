if not AdvDupe2 then
    PrintMessage( 3, "Advanced duplicator 2 is not installed. Better dupe has been disabled." )
    return
end

hook.Add( "PostGamemodeLoaded", "BetterDupeLoad", function()

    local duper = weapons.GetStored( "gmod_tool" )["Tool"]["duplicator"]
    duper.OldLeftClick = duper.LeftClick

    function duper:LeftClick( trace )
        local ply = self:GetOwner()

        if CLIENT then return true end

        if not ply.CurrentDupe or not ply.CurrentDupe.Entities then return false end
        if ply.AdvDupe2.Pasting or ply.AdvDupe2.Downloading then
            AdvDupe2.Notify( ply, "Better Duplicator is busy.", NOTIFY_ERROR )

            return false
        end
            
        if ply:KeyDown(IN_SPEED) then
            if ply:IsAdmin() then
                return self:OldLeftClick(trace)
            else
                AdvDupe2.Notify( ply, "Refusing to bypass Better Duplicator for a non-admin.", NOTIFY_ERROR )
                return false
            end
        end

        local dupe = ply.CurrentDupe
        local pos = trace.HitPos

        for _, v in pairs( dupe.Entities ) do -- Dirt hack to fix wire stuff
            if v.LocalPos then v.LocalPos = nil end
        end

        pos.z = pos.z - dupe.Mins.z

        ply.tempBetterDupeAdvDupe2 = table.Copy( ply.AdvDupe2 )
        ply.tempBetterDupe = true

        ply.AdvDupe2.Entities = dupe.Entities
        ply.AdvDupe2.Constraints = dupe.Constraints
        ply.AdvDupe2.Position = pos
        ply.AdvDupe2.Angle = self:GetOwner():EyeAngles()
        ply.AdvDupe2.Angle.pitch = 0
        ply.AdvDupe2.Angle.roll = 0
        ply.AdvDupe2.Pasting = true
        ply.AdvDupe2.Name = "Better dupe"

        AdvDupe2.InitPastingQueue( ply, ply.AdvDupe2.Position, ply.AdvDupe2.Angle, nil, true, true, true, tobool( ply:GetInfo( "advdupe2_paste_protectoveride" ) ) )
    end
end )

local function betterDupe( tbl )
    local ply = tbl[1].Player
    if not ply or not ply.tempBetterDupe then return end

    ply.AdvDupe2 = ply.tempBetterDupeAdvDupe2 or {}
    ply.AdvDupe2.Pasting = false

    ply.tempBetterDupeAdvDupe2 = nil
    ply.tempBetterDupe = nil
end

hook.Add( "AdvDupe_FinishPasting", "Betterdupe_AdvDupe_FinishPasting", betterDupe )
