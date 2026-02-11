
local stage = 0
local movingForward = false
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
            wait = 0
            if not IsEntityInAir(PlayerPedId()) then
                if IsControlJustReleased(0, 36) then
                    local ped = PlayerPedId()
                    if not IsPedInAnyVehicle(ped, false) and IsPedOnFoot(ped) and not IsEntityInAir(ped) and not IsPedRagdoll(ped) then            
                        stage = stage + 1
                        if stage == 2 then
                            -- Crouch stuff
                            ClearPedTasks(PlayerPedId())
                            RequestAnimSet("move_ped_crouched")
                            while not HasAnimSetLoaded("move_ped_crouched") do
                                Citizen.Wait(0)
                            end

                            SetPedMovementClipset(PlayerPedId(), "move_ped_crouched",1.0)    
                            SetPedWeaponMovementClipset(PlayerPedId(), "move_ped_crouched",1.0)
                            SetPedStrafeClipset(PlayerPedId(), "move_ped_crouched_strafing",1.0)
                        elseif stage == 3 then
                            ClearPedTasks(PlayerPedId())
                            RequestAnimSet("move_crawl")
                            while not HasAnimSetLoaded("move_crawl") do
                                Citizen.Wait(0)
                            end
                        elseif stage > 3 then
                            stage = 0
                            ClearPedTasksImmediately(PlayerPedId())
                            ResetAnimSet()
                            SetPedStealthMovement(PlayerPedId(),0,0)
                        end
                    end
                end

                if stage == 2 then
                    if GetEntitySpeed(PlayerPedId()) > 1.0 then
                        SetPedWeaponMovementClipset(PlayerPedId(), "move_ped_crouched",1.0)
                        SetPedStrafeClipset(PlayerPedId(), "move_ped_crouched_strafing",1.0)
                    elseif GetEntitySpeed(PlayerPedId()) < 1.0 and (GetFollowPedCamViewMode() == 4 or GetFollowVehicleCamViewMode() == 4) then
                        ResetPedWeaponMovementClipset(PlayerPedId())
                        ResetPedStrafeClipset(PlayerPedId())
                    end
                end
            end
        else
            stage = 0
        end
        Citizen.Wait(wait)
    end
end)

local walkSet = "default"
RegisterNetEvent("crouchprone:client:SetWalkSet")
AddEventHandler("crouchprone:client:SetWalkSet", function(clipset)
    walkSet = clipset
end)

-- Stamina

Citizen.CreateThread( function()
    while true do
      Citizen.Wait(0)
      RestorePlayerStamina(PlayerId(), 10.10)
    end
  end)

function ResetAnimSet()
    if walkSet == "default" then
        ResetPedMovementClipset(PlayerPedId())
        ResetPedWeaponMovementClipset(PlayerPedId())
        ResetPedStrafeClipset(PlayerPedId())
    else
        ResetPedMovementClipset(PlayerPedId())
        ResetPedWeaponMovementClipset(PlayerPedId())
        ResetPedStrafeClipset(PlayerPedId())
        Citizen.Wait(100)
        RequestWalking(walkSet)
        SetPedMovementClipset(PlayerPedId(), walkSet, 1)
        RemoveAnimSet(walkSet)
    end
end

function RequestWalking(set)
    RequestAnimSet(set)
    while not HasAnimSetLoaded(set) do
        Citizen.Wait(1)
    end 
end

function SetStage()
    stage = 0
    ClearPedTasksImmediately(PlayerPedId())
    ResetAnimSet()
    SetPedStealthMovement(PlayerPedId(),0,0)
end

exports('SetStage', SetStage)

