include("shared.lua")

function ENT:Initialize(num)
	local cl_init = file.Read("reloadableEntity/cl_init.txt")
	local oldENT = ENT
	local oldInit = self.Initialize
	ENT = self
	RunString(cl_init)
	ENT = oldENT
	if oldInit == self.Initialize then
		self.Initialize = function() end
	end
	self:Initialize()
end