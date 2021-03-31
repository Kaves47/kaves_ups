ESX = nil

local startjob = false
local showblip = true
local stop = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 750
        local player = PlayerPedId()
        local playerCoord = GetEntityCoords(player)
        local ups = #(playerCoord - Config.TakeJob)
        if ups <= 8 then
            wait = 0
        end
        if ups <= 3 then
            DrawText3D(Config.TakeJob.x, Config.TakeJob.y, Config.TakeJob.z + 0.90, 0.35,"~g~[E]~w~ Teslimat Menüsü ~w~")
        end
        Citizen.Wait(wait) 
    end
end)

RegisterNetEvent("kaves_ups:startJob")
AddEventHandler("kaves_ups:startJob", function()
    local level = exports["kaves_levelsistemi"]:level()
    local player = PlayerPedId()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'upstakejob', {
        title = ('Teslimat Menüsü'),
        align = 'top-left',
        elements = {{
            label = ('Posta Dağıtımı  (1)'),
            value = 1
        }, {
            label = ('Kargo Dağıtımı  (3)'),
            value = 2
        }, {
            label = ('Kargo Nakliyatı (6)'),
            value = 3
        }, {
            label = ('Şirkete Kargo Nakliyatı (12)'),
            value = 4
        }}
    }, function(data, menu)
        if data.current.value == 1 then --
            local foundSpawn, foundspawn = CheckSpawnPoint(1)
            if level >= 1 then
                if foundSpawn then
                    menu.close()
                    JobSetUniform()
                    FreezeEntityPosition(player, false)
                    TriggerEvent("kaves_ups:loadingcargo", Config.Motorcycle.vehicle, foundspawn,
                        "Postalar Araca Aktarılıyor...", 10000, Config.Motorcycle.postcount, Config.Motorcycle.type,
                        level)
                    startjob = true
                else
                    menu.close()
                    FreezeEntityPosition(player, false)
                end
            else
                menu.close()
                ESX.ShowNotification("Bu iş için yeterli değilsin.")
                FreezeEntityPosition(player, false)

            end
        end --

        if data.current.value == 2 then --
            local foundSpawn, foundspawn = CheckSpawnPoint(1)
            if level >= 1 then
                if foundSpawn then
                    menu.close()
                    JobSetUniform()
                    FreezeEntityPosition(player, false)
                    TriggerEvent("kaves_ups:loadingcargo", Config.Kargo.vehicle, foundspawn,
                        "Kargolar Araca Aktarılıyor...", 15000, Config.Kargo.postcount, Config.Kargo.type, level)
                    startjob = true
                else
                    menu.close()
                    FreezeEntityPosition(player, false)
                end
            else
                menu.close()
                ESX.ShowNotification("Bu iş için yeterli değilsin.")
                FreezeEntityPosition(player, false)
            end
        end --

        if data.current.value == 3 then --
            local foundSpawn, foundspawn = CheckSpawnPoint(2)
            if level >= 1 then
                if foundSpawn then
                    menu.close()
                    JobSetUniform()
                    FreezeEntityPosition(player, false)
                    TriggerEvent("kaves_ups:loadingcargo", Config.Nakliye.vehicle, foundspawn,
                        "Nakliye Aracına Yükleme Yapılıyor...", 20000, Config.Nakliye.postcount,
                        Config.Nakliye.type, level)
                    startjob = true
                else
                    menu.close()
                    FreezeEntityPosition(player, false)
                end
            else
                menu.close()
                ESX.ShowNotification("Bu iş için yeterli değilsin.")
                FreezeEntityPosition(player, false)
            end
        end --

        if data.current.value == 4 then --
            local foundSpawn, foundspawn = CheckSpawnPoint(2)
            local trailerSpawn, trailerspawn = CheckTrailerSpawn()
            if level >= 1 then
                if foundSpawn and trailerSpawn then
                    menu.close()
                    JobSetUniform()
                    FreezeEntityPosition(player, false)
                    TriggerEvent("kaves_ups:liman", Config.Liman.vehicle, foundspawn, trailerspawn,
                        "Dorseye Yük Yükleniyor...", 30000, Config.Liman.postcount)
                    startjob = true
                else
                    menu.close()
                    FreezeEntityPosition(player, false)
                end
            else
                menu.close()
                ESX.ShowNotification("Bu iş için yeterli değilsin.")
                FreezeEntityPosition(player, false)
            end
        end --
    end, function(data, menu)
        menu.close()
        FreezeEntityPosition(player, false)
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local player = PlayerPedId()
        local playerCoord = GetEntityCoords(player)
        local sleep = 1000
        local ups = #(playerCoord - Config.TakeJob)
        if ups <= 5 then
            sleep = 0
        end
        if ups <= 2 and IsControlJustPressed(0, 38) and not startjob then
            DisableControlAction(0, 38, true)
            SetEntityHeading(player, 344, 45)
            animasyon(player, "mp_common", "givetake1_a")
            Citizen.Wait(2300)
            ESX.TriggerServerCallback("kaves_ups:checkPost", function(output)
                if output then
                    DisableControlAction(0, 38, false)
                    FreezeEntityPosition(player, true)
                    TriggerEvent("kaves_ups:startJob")
                    stop = false
                elseif not output then
                    DisableControlAction(0, 38, false)
                    FreezeEntityPosition(player, false)
                    exports['mythic_notify']:SendAlert('error', 'Şirkette Ürün Kalmamış')
                    stop = true
                end
            end)
        elseif startjob and ups <= 2 and IsControlJustPressed(0, 38) then
            DisableControlAction(0, 38, false)
            ESX.ShowNotification("Zaten mevcut bir işe sahipsin!")
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent("kaves_ups:liman")
AddEventHandler("kaves_ups:liman", function(veh, location, locationt, labeltext, sure, count)
    local truck = loadVehicle(veh, location.coords, location.heading)
    local trailer = loadVehicle(Config.Liman.trailer, locationt.coords, locationt.heading)
    local veht = addBlip(GetEntityCoords(truck), 1, 3, "Teslimat Aracı", 0.7)
    local trailerl = addBlip(GetEntityCoords(trailer), 1, 2, "Dorse", 0.7)
    local load = addBlip(Config.Liman.take, 1, 1, "Yükleme Alanı", 0.7)
    local showblipa = true
    local bliptrailer = true
    local miktar = count
    SetVehicleColours(truck, 102, 102)
    local player = PlayerPedId()
    while true do
        Citizen.Wait(1)
        local playerCoord = GetEntityCoords(player)
        local dst = #(playerCoord - locationt.coords)
        if IsPedInVehicle(player, truck, true) and showblipa then
            RemoveBlip(veht)
            showblipa = false
        elseif not IsPedInVehicle(player, truck, true) and not showblipa then
            veht = addBlip(GetEntityCoords(truck), 1, 3, "Teslimat Aracı", 0.7)
            showblipa = true
        end
        if IsVehicleAttachedToTrailer(truck, trailer) and bliptrailer then
            RemoveBlip(trailerl)
            bliptrailer = false
        elseif not IsVehicleAttachedToTrailer(truck, trailer) and not bliptrailer then
            trailerl = addBlip(GetEntityCoords(trailer), 1, 2, "Dorse", 0.7)
            bliptrailer = true
        end
        if dst <= 10 then
            DrawText3D(locationt.coords.x, locationt.coords.y + 6.0, locationt.coords.z + 0.20, 0.30,
                "~g~[E]~w~ Yük Yükle ~w~")
        end
        if dst <= 10 and IsControlJustPressed(0, 38) then
            FreezeEntityPosition(player, true)
            FreezeEntityPosition(truck, true)
            TriggerEvent('pogressBar:drawBar', sure, labeltext)
            Citizen.Wait(sure)
            FreezeEntityPosition(player, false)
            FreezeEntityPosition(truck, false)
            RemoveBlip(load)
            RemoveBlip(trailerl)
            RemoveBlip(veht)
            exports['mythic_notify']:SendAlert('inform', miktar .. ' Ürün Dorseye Yüklendi.')
            TriggerEvent("kaves_ups:limanfinal", truck, trailer, miktar)
            break
        end
    end
end)

RegisterNetEvent("kaves_ups:limanfinal")
AddEventHandler("kaves_ups:limanfinal", function(veh, trailer, miktar)
    local player = PlayerPedId()
    local finish = addBlip(Config.Liman.finishcoord, 1, 1, "Aracı Teslim Et", 0.7)
    local trck = addBlip(GetEntityCoords(veh), 1, 3, "Teslimat Aracı", 0.7)
    local trail = addBlip(GetEntityCoords(trailer), 1, 2, "Dorse", 0.7)
    local bliptrail = true
    local showblipc = true
    while true do
        Citizen.Wait(1)
        local playerCoord = GetEntityCoords(player)
        local dst = #(playerCoord - Config.Liman.finishcoord)

        if IsPedInVehicle(player, veh, true) and showblipc then
            RemoveBlip(trck)
            showblipc = false
        elseif not IsPedInVehicle(player, veh, true) and not showblipc then
            trck = addBlip(GetEntityCoords(veh), 1, 3, "Teslimat Aracı", 0.7)
            showblipc = true
        end
        if IsVehicleAttachedToTrailer(veh, trailer) and bliptrail then
            RemoveBlip(trail)
            bliptrail = false
        elseif not IsVehicleAttachedToTrailer(veh, trailer) and not bliptrail then
            trail = addBlip(GetEntityCoords(trailer), 1, 2, "Dorse", 0.7)
            bliptrail = true
        end

        if dst <= 5 then
            DrawMarker(2, Config.Liman.finishcoord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 44, 194, 33, 255,
                false, false, false, 1, false, false, false)
            DrawText3D(Config.Liman.finishcoord.x, Config.Liman.finishcoord.y, Config.Liman.finishcoord.z + 0.20, 0.30,
                "~g~[E]~w~ Yükü Teslim Et ~w~")
        end
        if dst <= 3 and IsControlJustPressed(0, 38) and IsPedInVehicle(player, veh, true) and
            IsVehicleAttachedToTrailer(veh, trailer) then
            RemoveBlip(finish)
            DeleteVehicle(veh)
            DeleteVehicle(trailer)
            ResetSkin()
            startjob = false
            TriggerServerEvent("kaves_ups:limanpay", miktar)
            break
        elseif not IsPedInVehicle(player, veh, true) and dst <= 3 and IsControlJustPressed(0, 38) and
            IsVehicleAttachedToTrailer(veh, trailer) then
            ESX.ShowNotification("Teslimat Aracında Değilsin Yada Dorse Takılı Değil!")
        end
    end
end)

RegisterNetEvent("kaves_ups:loadingcargo")
AddEventHandler("kaves_ups:loadingcargo", function(veh, location, labeltext, sure, sayi, type, level)
    local display = true
    local arac = loadVehicle(veh, location.coords, location.heading)
    SetVehicleColours(arac, 102, 102)
    local vehicleloc = addBlip(GetEntityCoords(arac), 1, 3, "Teslimat Aracı", 0.7)
    local loadingzone = addBlip(Config.LoadingZone, 1, 1, "Yükleme Alanı", 0.7)
    local player = PlayerPedId()
    while true do
        Citizen.Wait(1)
        local playerCoord = GetEntityCoords(player)
        local distance = #(playerCoord - Config.LoadingZone)
        if IsPedInVehicle(player, arac, true) and showblip then
            RemoveBlip(vehicleloc)
            showblip = false
        elseif not IsPedInVehicle(player, arac, true) and not showblip then
            vehicleloc = addBlip(GetEntityCoords(arac), 1, 3, "Teslimat Aracı", 0.7)
            showblip = true
        end
        if IsPedInVehicle(player, arac, true) then
            if distance <= 5 and display then
                DrawMarker(2, Config.LoadingZone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 44, 194, 33, 255, false,
                    false, false, 1, false, false, false)
                DrawText3D(Config.LoadingZone.x, Config.LoadingZone.y, Config.LoadingZone.z + 0.20, 0.30,
                    "~g~[E]~w~ Yükleme Yap ~w~")
            end
            if distance <= 4 and IsControlJustPressed(0, 38) then
                display = false
                FreezeEntityPosition(player, true)
                FreezeEntityPosition(arac, true)
                TriggerEvent('pogressBar:drawBar', sure, labeltext)
                Citizen.Wait(sure)
                RemoveBlip(loadingzone)
                FreezeEntityPosition(player, false)
                FreezeEntityPosition(arac, false)
                TriggerEvent("kaves_ups:job", arac, sayi, type, level)
                break
            end
        end
    end
end)


RegisterNetEvent("kaves_ups:job")
AddEventHandler("kaves_ups:job", function(arac, sayi, type, level)
    local sayac = sayi
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    local trasportveh = arac
    local secim = nil
    if type == 1 then
        secim = Config.KasabaLokasyon
    elseif type == 2 then
        secim = Config.NakliyeLokasyon
    elseif type == 3 then
        secim = Config.Lokasyon
    end
    local t = secim
    local n = {}
    for i = 1, sayi, 1 do
        local r = math.random(1, #t)
        local p = t[r]
        table.insert(n, { delivered = false,coord = p})
        table.remove(t, r)
    end
    local blips = {}
    for k, v in pairs(n) do
        local gblip = AddBlipForCoord(v.coord.x, v.coord.y, v.coord.z)
        SetBlipSprite(gblip, 1)
        SetBlipDisplay(gblip, 4)
        SetBlipScale(gblip, 0.7)
        SetBlipColour(gblip, 5)
        SetBlipAsShortRange(gblip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Teslimat Noktası")
        EndTextCommandSetBlipName(gblip)
        table.insert(blips, gblip)
    end
    while true do
        local player = PlayerPedId()
        local playerCoord = GetEntityCoords(player)
        if IsPedInVehicle(player, trasportveh, true) and showblip then
            RemoveBlip(vehicleloc)
            showblip = false
        elseif not IsPedInVehicle(player, trasportveh, true) and not showblip then
            vehicleloc = addBlip(GetEntityCoords(trasportveh), 1, 3, "Teslimat Aracı", 0.7)
            showblip = true
        end
        for i = 1, #n do
            local dst = #(playerCoord - n[i].coord)
            if not n[i].delivered then
                if dst <= 5 then
                    DrawMarker(2, n[i].coord, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 44, 194, 33, 255, false,
                        false, false, 1, false, false, false)
                    DrawText3D(n[i].coord.x, n[i].coord.y, n[i].coord.z + 0.20, 0.30, "~g~[E]~w~ Teslimat ~w~")
                end

                if type == 1 or type == 3 then
                    if dst <= 2 and IsControlJustPressed(0, 38) and not IsPedInAnyVehicle(player) then
                        prop = CreateObject(GetHashKey('hei_prop_heist_box'), x, y, z + 0.2, true, true, true)
                        AttachEntityToEntity(prop, player, GetPedBoneIndex(GetPlayerPed(-1), 60309), 0.025, 0.08, 0.255,
                            -145.0, 290.0, 0.0, true, true, false, true, 1, true)
                        animasyon(player, "anim@heists@box_carry@", "idle")
                        sayac = sayac - 1
                        if DoesBlipExist(blips[i]) then
                            RemoveBlip(blips[i])
                            n[i].delivered = true
                        end
                        Citizen.Wait(2500)
                        ClearPedTasks(player)
                        DeleteEntity(prop)
                    elseif dst <= 2 and IsControlJustPressed(0, 38) and IsPedInAnyVehicle(player) then
                        ESX.ShowNotification("Araçta Teslimat Yapamazsın!")
                    end
                elseif type == 2 then
                    if IsPedInVehicle(player, trasportveh, true) and dst <= 5 and IsControlJustPressed(0, 38) then
                        TriggerEvent('pogressBar:drawBar', 15000, "Nakliye Boşaltılıyor...")
                        FreezeEntityPosition(player, true)
                        FreezeEntityPosition(trasportveh, true)
                        if DoesBlipExist(blips[i]) then
                            RemoveBlip(blips[i])
                            n[i].delivered = true
                        end
                        Citizen.Wait(2500)
                        FreezeEntityPosition(player, false)
                        FreezeEntityPosition(trasportveh, false)
                        sayac = sayac - 1
                    end
                end
            end
        end
        if sayac == 0 then
            TriggerEvent("kaves_ups:final", Config.FinalZone, trasportveh, sayi, level)
            break
        end
        Citizen.Wait(1)
    end
end)



RegisterNetEvent("kaves_ups:final")
AddEventHandler("kaves_ups:final", function(zone, trasportveh, sayi, level)
    local final = addBlip(zone, 1, 1, "Mesai Sonu", 0.7)
    local disable = false
    while true do
        Citizen.Wait(1)
        local player = PlayerPedId()
        local playerCoord = GetEntityCoords(player)
        local dst = #(playerCoord - zone)
        if IsPedInVehicle(player, trasportveh, true) and showblip then
            RemoveBlip(vehicleloc)
            showblip = false
        elseif not IsPedInVehicle(player, trasportveh, true) and not showblip then
            vehicleloc = addBlip(GetEntityCoords(trasportveh), 1, 3, "Teslimat Aracı", 0.7)
            showblip = true
        end
        if dst <= 5 then
            DrawMarker(2, zone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 44, 194, 33, 255, false, false, false, 1,false, false, false)
            DrawText3D(zone.x, zone.y, zone.z + 0.20, 0.30, "~g~[E]~w~ Teslimat Bitir ~w~")
        end
        if dst <= 3 and IsControlJustPressed(0, 38) and IsPedInVehicle(player, trasportveh, true) then
            RemoveBlip(final)
            DeleteVehicle(trasportveh)
            ResetSkin()
            startjob = false
            TriggerServerEvent("kaves_ups:pay", sayi, level)
            break
        elseif not IsPedInVehicle(player, trasportveh, true) and dst <= 3 and IsControlJustPressed(0, 38) then
            ESX.ShowNotification("Teslimat Aracında Değilsin!")
        end
    end
end)

function animasyon(ped, ad, anim) -- örnek // animasyon(playerPed, "mp_common", "givetake1_a")
    ESX.Streaming.RequestAnimDict(ad, function()
        TaskPlayAnim(ped, ad, anim, 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    end)
end

loadVehicle = function(vehicle, coords, heading)
    local model
    if type(vehicle) == 'number' then
        model = vehicle
    else
        model = GetHashKey(vehicle)
    end
    while not HasModelLoaded(model) do
        Wait(0)
        RequestModel(model)
    end
    local car = CreateVehicle(model, coords, heading, true, false)
    SetEntityAsMissionEntity(car, true, true)
    return car
end

function JobSetUniform()
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            if Config.JobUniforms.male ~= nil then
                TriggerEvent('skinchanger:loadClothes', skin, Config.JobUniforms.male)
            else
                ESX.ShowNotification("Kıyafet Bulunmamaktadır.")
            end
        else
            if Config.JobUniforms.female ~= nil then
                TriggerEvent('skinchanger:loadClothes', skin, Config.JobUniforms.female)
            else
                ESX.ShowNotification("Kıyafet Bulunmamaktadır.")
            end
        end
    end)
end

function ResetSkin()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

addBlip = function(coords, sprite, colour, text, scale)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

function CheckSpawnPoint(type)
    local found = false
    local SpawnPoint = nil
    local point = nil

    if type == 1 or type == 3 then
        point = Config.SpawnPoints
    elseif type == 2 then
        point = Config.NakliyePoints
    end
    for i = 1, #point do
        if ESX.Game.IsSpawnPointClear(point[i].coords, point[i].radius) then
            found = true
            SpawnPoint = point[i]
            break
        end
    end
    if found then
        return true, SpawnPoint
    else
        exports['mythic_notify']:SendAlert('inform', 'Çıkarma noktalarını araçlar engelliyor')
        return false
    end
end

function CheckTrailerSpawn()
    local founds = false
    local SpawnPoints = nil

    for i = 1, #Config.TrailerCoords do
        if ESX.Game.IsSpawnPointClear(Config.TrailerCoords[i].coords, Config.TrailerCoords[i].radius) then
            founds = true
            SpawnPoints = Config.TrailerCoords[i]
            break
        end
    end
    if founds then
        return true, SpawnPoints
    else
        exports['mythic_notify']:SendAlert('inform', 'Çıkarma noktaları dolu görünüyor')
        return false
    end
end

function DrawText3D(x, y, z, scale, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    -- local scale = 0.35
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 490
        DrawRect(_x, _y + 0.0120, 0.0 + factor, 0.025, 41, 11, 41, 100)
    end
end
