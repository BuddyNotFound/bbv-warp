Main = {
    ped = PlayerPedId
}

function Main:Warp(coords,heading)
    if IsPedInAnyVehicle(self.ped()) then 
        self.veh = GetVehiclePedIsIn(PlayerPedId())
        self.WarpPos = coords
        self.heading = heading
        self.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        RenderScriptCams(true, 1, 1500,  true,  true)
        self:processCamera(self.Cam)
    else
        self.WarpPos = coords
        self.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        self:processCamera(self.Cam)
    end
end

function Main:processCamera(cam)
	local vehpos = GetEntityCoords(self.veh)
	local vehfront = GetEntityForwardVector(self.veh)
	local vehfrontpos = vector3(vehpos.x - (vehfront.x * 3),vehpos.y - (vehfront.y * 3) ,vehpos.z - (vehfront.z * 2) )

	local rotx, roty, rotz = table.unpack(GetEntityRotation(PlayerPedId()))
	local camX, camY, camZ = table.unpack(GetGameplayCamCoord())
	local camRX, camRY, camRZ = GetGameplayCamRelativePitch(), 0.0, GetGameplayCamRelativeHeading()
	local camF = GetGameplayCamFov()
	local camRZ = (rotz+camRZ)

	SetCamCoord(cam, vehfrontpos.x, vehfrontpos.y, vehfrontpos.z + 0.2)
	PointCamAtCoord(cam, vehpos.x,vehpos.y,vehpos.z + 0.2)
	SetCamFov(cam, camF - 20)

    Wait(1500)
    SetPedCoordsKeepVehicle(PlayerPedId(), self.WarpPos)
    SetEntityHeading(PlayerPedId(), self.heading)
	local vehpos = GetEntityCoords(self.veh)
	local vehfront = GetEntityForwardVector(self.veh)
	local vehfrontpos = vector3(vehpos.x - (vehfront.x * 3),vehpos.y - (vehfront.y * 3) ,vehpos.z - (vehfront.z * 2) )
    SetCamCoord(cam, vehfrontpos.x, vehfrontpos.y, vehfrontpos.z + 0.2)
    PointCamAtCoord(cam, vehpos.x,vehpos.y,vehpos.z + 0.2)

    Wait(1000)
    RenderScriptCams(false, 1, 1500,  false,  false)
end

local sleep = 1000

CreateThread(function()
    while true do 
        Wait(sleep)
        for k,v in pairs(Config.Warps) do
            local pos = GetEntityCoords(Main.ped())
            local vpos = Config.Warps[k].Enter
            local dist = #(pos-vpos)
            if dist < 5 then 
                sleep = 0 
                DrawMarker(2, Config.Warps[k].Enter.x, Config.Warps[k].Enter.y, Config.Warps[k].Enter.z , 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255, 255, 255, false, true, 2, nil, nil, false)
                Draw3DText(Config.Warps[k].Enter.x, Config.Warps[k].Enter.y, Config.Warps[k].Enter.z + 0.2, 0.2, '[E] - Warp')
                if IsControlJustReleased(1, 38) then
                    Main:Warp(Config.Warps[k].Exit ,Config.Warps[k].HeadingExit)
                end
            end
        end
    end
end)

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end