-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

CreateThread(function()
    local bones = {'wheel_lf', 'wheel_rf', 'wheel_lm1', 'wheel_rm1', 'wheel_lm2', 'wheel_rm2', 'wheel_lm3', 'wheel_rm3', 'wheel_lr', 'wheel_rr'}

    local event = 'wasabi_tireslash:slash'
    local icon = 'fas fa-info'
    local distance = 1.0

    if Config.TargetSystem == 'ox_target' then
        exports.ox_target:addGlobalVehicle({
            {
                bones = bones,
                event = event,
                icon = icon,
                label = Language['slash_tire'],
                distance = distance
            }
        })
    else
        exports[Config.TargetSystem]:AddTargetBone(bones, {
            options = {
                {
                    event = event,
                    icon = icon,
                    label = Language['slash_tire'],
                    num = 1
                },
            },
            distance = distance
        })
    end
end)

RegisterNetEvent('wasabi_tireslash:slash', function()
    local vehicle = GetClosestVehicleToPlayer()
    if vehicle ~= 0 then
        if CanUseWeapon(Config.allowedWeapons) then
            local closestTire = GetClosestVehicleTire(vehicle)
            if closestTire ~= nil then
                if IsVehicleTyreBurst(vehicle, closestTire.tireIndex, 0) == false then
                    local animDict = 'melee@knife@streamed_core_fps'
                    local animName = 'ground_attack_on_spot'
                    loadDict('melee@knife@streamed_core_fps')
                    local animDuration = GetAnimDuration(animDict, animName)
                    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, animDuration, 15, 1.0, 0, 0, 0)
                    Wait((animDuration / 2) * 1000)
                    local driverId = GetDriverOfVehicle(vehicle)
                    local driverServId = GetPlayerServerId(driverId)
                    if driverServId == 0 then
                        SetEntityAsMissionEntity(vehicle, true, true)
                        SetVehicleTyreBurst(vehicle, closestTire.tireIndex, 0, 100.0)
                        SetEntityAsNoLongerNeeded(vehicle)
                    else
                        TriggerServerEvent('wasabi_tireslash:sync', driverServId, closestTire.tireIndex)
                    end
                    Wait((animDuration / 2) * 1000)
                    ClearPedTasks(PlayerPedId())
                    RemoveAnimDict(animDict)
                else
                    TriggerEvent('wasabi_tireslash:notify', Language['already_slashed'])
                end
            end
        else
            TriggerEvent('wasabi_tireslash:notify', Language['no_weapon'])
        end
    end
end)

RegisterNetEvent('wasabi_tireslash:sync')
AddEventHandler('wasabi_tireslash:sync', function(tireIndex)
	TriggerEvent('wasabi_tireslash:notify', Language['car_slashed'])
	local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	SetVehicleTyreBurst(vehicle, tireIndex, 0, 100.0)
end)