AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	local init = file.Read("reloadableEntity/init.txt")
	local oldENT = ENT
	local oldInit = self.Initialize
	ENT = self
	RunString(init)
	ENT = oldENT
	if oldInit == self.Initialize then
		self.Initialize = function() end
	end
	self:Initialize()
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("reloadable")
	e:SetPos(t.HitPos+Vector(0,0,80))
	e:Spawn()
	e:Activate()
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang)
	return e
end