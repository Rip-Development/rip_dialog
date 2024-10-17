local display = false
local Invisible = false
local cam = nil
local npcped = nil
local RefreshTime = 100
local NPCs = {}
local DisableControls = false
local sendData = nil
local target = nil

if GetResourceState("ox_target") ~= 'missing' then
	target = "ox_target"
elseif GetResourceState("qb-target") ~= 'missing' then
	target = "qb-target"
else
	target = "no_target"
end

function openMenu(info, options, coords)
	if npcped ~= nil then
		if coords then
			TaskLookAtCoord(npcped, coords.x, coords.y, coords.z, -1, 2048, 2)
			SetCursorLocation(0.7,0.5)
		end
		NPCplayAnimation('mp_facial', 'mic_chatter', npcped)
	else
		SetCursorLocation(0.7,0.5)
	end
	display = true
	SetNuiFocus(true, true)
	sendData = options.options
    SendNUIMessage({
        status = true,
        info = info,
		options = options
    })
	if info.invisible ~= nil then
		if info.invisible == true then
			SetInvisible()
		end
	else
		SetInvisible()
	end
end
exports('openMenu', openMenu)

function closeMenu()
	if display then
		PlaySoundFrontend(-1, 'Highlight_Cancel', 'DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
	end
	display = false
	Invisible = false
	sendData = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = false
    })
	ClearPedTasks(PlayerPedId())
	if cam ~= nil then
		RenderScriptCams(false, true, 500, true, false)
		DestroyCam(cam)
	end
	cam = nil
	if npcped ~= nil then
		StopAnimTask(npcped, 'mp_facial', 'mic_chatter', 10.0)
		TaskClearLookAt(npcped)
	end
	npcped = nil
end
exports('closeMenu', closeMenu)

RegisterNUICallback('selectTarget', function(id)
	if sendData then
		if id.id then
			local data = sendData[tonumber(id.id+1)]
			sendData = nil
			if data then
				if data.params ~= nil and data.params.type ~= nil then
					if data.params.type == 'server' then
						TriggerServerEvent(data.params.event, data.params.args)
					elseif data.params.type == 'isCommand' then
					   ExecuteCommand(data.params.event)
					elseif data.params.type == 'isQBCommand' then
						TriggerServerEvent('QBCore:CallCommand', data.params.event, data.params.args)
					elseif data.params.type == 'action' then
						data.params.event(data.params.args)
					else
						TriggerEvent(data.params.event, data.params.args)
					end
				end
			end
		end
	end
	closeMenu()
end)

RegisterNUICallback("exit", function(data)
    closeMenu()
end)

RegisterNUICallback("error", function(data)
    closeMenu()
end)

RegisterNUICallback("stopanim", function()
	if npcped ~= nil then
		StopAnimTask(npcped, 'mp_facial', 'mic_chatter', 10.0)
	end
end)

function SetInvisible()
    local playerPed = PlayerPedId()
	Invisible = true
	while Invisible do
        Wait(0)
		SetEntityLocallyInvisible(playerPed)
		if IsEntityDead(playerPed) then
			closeMenu()
		end
    end
end

function openNpcMenu(npc, info, options)
	npcped = npc
	forwardcam = GetOffsetFromEntityInWorldCoords(npcped, 0.0, 0.7, 0.5)
	p2 = GetEntityCoords(npcped, true)
	DisableControls = true
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(cam, forwardcam.x, forwardcam.y, forwardcam.z)
	PointCamAtCoord(cam, p2.x, p2.y, p2.z+0.5)
	SetCamActive(cam, true)
	RenderScriptCams(1, true, 1000, 1, 1)
	Wait(1000)
	openMenu(info, options, forwardcam)
	DisableControls = false
	Wait(100)
	EnableAllControlActions(0)
end

function CreateNPC(name, model, position, info, options)
	local model = GetHashKey(model)
    ped = nil
    RequestModel(model)

    local timeoutCount = 0

    while not HasModelLoaded(model) and timeoutCount < RefreshTime do
        timeoutCount = timeoutCount + 1

        Citizen.Wait(100)
    end

    local ped = CreatePed(4, model, position.x, position.y, position.z - 1, position.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
	local job = nil
	local distance = 3.0
	if info.job then
		job = info.job
	end
	if info.distance then
		distance = info.distance
	end
	if info.blip then
		local blip = AddBlipForCoord(position.x, position.y, position.z)
		local blipName = info.blip.name or info.title
		local blipSprite = info.blip.sprite or 480
		local blipColour = info.blip.color or 28
		local blipScale = info.blip.scale or 0.7
		SetBlipSprite (blip, blipSprite)
		SetBlipColour (blip, blipColour)
		SetBlipScale  (blip, blipScale)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(blipName)
		EndTextCommandSetBlipName(blip)
		table.insert(NPCs, {name=name, blip=blip, ped=ped, info=info, options=options})
	else
		table.insert(NPCs, {name=name, ped=ped, info=info, options=options})
	end
	if target == "ox_target" then
		exports.ox_target:addLocalEntity(ped, {
			{
				name = name,
				distance = distance,
				onSelect = function(data)
					openNpcMenu(ped, info, options)
				end,
				icon = info.icon,
				label = info.label,
				groups = job,
			},
		})
	elseif target == "qb-target" then
		exports['qb-target']:AddTargetEntity(ped, {
			options = {
				{
					action = function(entity)
						openNpcMenu(ped, info, options)
					end,
					icon = info.icon,
					label = info.label,
					job = job,
				},
			},
			distance = distance
		})
	end
end
exports('CreateNPC', CreateNPC)

function ChangeNpcOptions(name, info, options)
	for i,npc in ipairs(NPCs) do
		if npc.name == name then
			table.remove(NPCs, i)
			local job = nil
			local distance = 3.0
			if info.job then
				job = info.job
			end
			if info.distance then
				distance = info.distance
			end
			if npc.blip then
				RemoveBlip(npc.blip)
			end
			if info.blip then
				local blip = AddBlipForCoord(position.x, position.y, position.z)
				local blipName = info.blip.name or info.title
				local blipSprite = info.blip.sprite or 480
				local blipColour = info.blip.color or 28
				local blipScale = info.blip.scale or 0.7
				SetBlipSprite (blip, blipSprite)
				SetBlipColour (blip, blipColour)
				SetBlipScale  (blip, blipScale)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(blipName)
				EndTextCommandSetBlipName(blip)
				table.insert(NPCs, {name=name, blip=blip, ped=npc.ped, info=info, options=options})
			else
				table.insert(NPCs, {name=name, ped=npc.ped, info=info, options=options})
			end
			if target == "ox_target" then
				exports.ox_target:removeLocalEntity(npc.ped, name)
				exports.ox_target:addLocalEntity(npc.ped, {
					{
						name = name,
						distance = distance,
						onSelect = function(data)
							openNpcMenu(npc.ped, info, options)
						end,
						icon = info.icon,
						label = info.label,
						groups = job,
					},
				})
			elseif target == "qb-target" then
				exports['qb-target']:RemoveTargetEntity(npc.ped, npc.info.label)
				exports['qb-target']:AddTargetEntity(npc.ped, {
					options = {
						{
							action = function(entity)
								openNpcMenu(npc.ped, info, options)
							end,
							icon = info.icon,
							label = info.label,
							job = job,
						},
					},
					distance = distance
				})
			end
		end
	end
end
exports('ChangeNpcOptions', ChangeNpcOptions)

function DeleteNpc(name)
	for i,npc in ipairs(NPCs) do
		if npc.name == name then
			table.remove(NPCs, i)
			if target == "ox_target" then
				exports.ox_target:removeLocalEntity(npc.ped, name)
			elseif target == "qb-target" then
				exports['qb-target']:RemoveTargetEntity(npc.ped, npc.info.label)
			end
			DeletePed(npc.ped)
			if npc.blip then
				RemoveBlip(npc.blip)
			end
		end
	end
end
exports('DeleteNpc', DeleteNpc)

function NPCplayAnimation(animationDict, animationName, ped)
    RequestAnimDict(animationDict)

    while not HasAnimDictLoaded(animationDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(ped, animationDict, animationName, 1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
end

function ShowHelpNotification(msg)
	if not display then
		BeginTextCommandDisplayHelp('STRING')
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandDisplayHelp(0, false, true, -1)
	end
end

Citizen.CreateThread(function()
	if target == "no_target" then
		while true do
			Wait(0)
			if #NPCs > 0 then
				local playerPos = GetEntityCoords(PlayerPedId())
				for i,ped in ipairs(NPCs) do
					local pedPos = GetOffsetFromEntityInWorldCoords(ped.ped, 0.0, 1.0, 0.0)
					if #(playerPos - vector3(pedPos.x, pedPos.y, pedPos.z)) < ped.info.distance then
						ShowHelpNotification(ped.info.label)
						if IsControlJustReleased(0, 38) then
							openNpcMenu(ped.ped, ped.info, ped.options)
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(500)
		if #NPCs > 0 then
			local playerped = PlayerPedId()
			local playerPos = GetEntityCoords(playerped)
			local isInMarker  = false
			local currentZone = nil
			local zonenpc = nil
			for i,ped in ipairs(NPCs) do
				local pedPos = GetOffsetFromEntityInWorldCoords(ped.ped, 0.0, 3.0, 0.0)
				if #(playerPos - vector3(pedPos.x, pedPos.y, pedPos.z)) < 3 then
					isInMarker  = true
					currentZone = i
					zonenpc = ped.ped
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone = currentZone
				TaskLookAtEntity(zonenpc, playerped, 4000, 2048, 2)
				PlayPedAmbientSpeechNative(zonenpc, "GENERIC_HI", "SPEECH_PARAMS_FORCE")
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
			end
		end
	end
end)

local inrepeat = false

CreateThread(function()
    while true do
        Wait(200)
        if DisableControls and not inrepeat then
			inrepeat = true
			repeat 
				Wait(0)
				DisableAllControlActions(0)
			until not DisableControls
			inrepeat = false
		end
    end
end)