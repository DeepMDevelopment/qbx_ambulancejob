local isEscorting = false

exports.ox_target:addGlobalPlayer({
    label = 'Escort Player',
    name = 'qbx_ambulancejob:escort',
    icon = 'fas fa-people-pulling',
    distance = 1.0,
    onSelect = function(data)
        local coords = GetEntityCoords(cache.ped)
        local players = lib.getNearbyPlayers(coords, 2.0)
        local playerId = nil

        for _, playerdata in pairs(players) do
            playerdata['playerId'] = GetPlayerServerId(playerdata.id)

            if playerdata.ped == data.entity then
                playerId = playerdata['playerId']
                break
            end
        end

        if not playerId then return end
        if QBX.PlayerData.metadata.ishandcuffed or isEscorting then return end
        TriggerServerEvent('police:server:EscortPlayer', playerId);

        CreateThread(function ()
            local tick = 100
            local limit = 5000
            local time = 0

            while not IsEntityAttachedToEntity(cache.ped, data.entity) and time < limit do
                time += tick
                Wait(tick)
            end

            if time < limit then
                isEscorting = true
            end
        end)
    end
})

-- Check for deescort
CreateThread(function ()
    while true do
        exports.ox_target:removeGlobalOption('qbx_ambulancejob:deescort')

        if isEscorting then
            exports.ox_target:addGlobalOption({
                label = 'Let Player Go',
                name = 'qbx_ambulancejob:deescort',
                icon = 'fas fa-people-arrows',
                onSelect = function(data)
                    local coords = GetEntityCoords(cache.ped)
                    local players = lib.getNearbyPlayers(coords, 2.0)
                    local playerId = nil

                    for _, playerdata in pairs(players) do
                        playerdata['playerId'] = GetPlayerServerId(playerdata.id)

                        if IsEntityAttachedToEntity(cache.ped, playerdata.ped) then
                            playerId = playerdata['playerId']
                            break
                        end
                    end

                    if not playerId then return end
                    TriggerServerEvent('police:server:EscortPlayer', playerId);
                end
            })
        end

        Wait(100)
    end
end)

-- Check attachment status
CreateThread(function ()
    while true do
        local isAttached = false

        local coords = GetEntityCoords(cache.ped)
        local players = lib.getNearbyPlayers(coords, 2.0)
        local playerId = nil

        for _, playerdata in pairs(players) do
            playerdata['playerId'] = GetPlayerServerId(playerdata.id)

            if IsEntityAttachedToEntity(cache.ped, playerdata.ped) then
                isAttached = true
                isEscorting = true
                break
            end
        end

        if not isAttached then
            isEscorting = false
        end

        Wait(100)
    end
end)