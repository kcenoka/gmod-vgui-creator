local currentFrame,VguiList,VguiOptions,VguiFunctions,OnClick,OnGetFocus,CreateObject,Clamp
VguiList = {
	DFrame = {}
}
VguiOptions = {
	DFrame = {"Resize","Delete","SetTitle","Add Button","Add Label","Add CheckBox","Add CheckBoxLabel","Add Collapsible","Add ListView"},
	DButton = {"Resize","Delete","SetText","Resize to Contents"},
	DCheckBox = {"Resize","Delete","Toggle"},
	DLabel = {"Resize","Delete","SetText","Resize to Contents"},
	DListView = {"Resize","Delete", "Add Column"},
	DCollapsibleCategory = {"Resize","Delete"},
}

OnGetFocus = function(self)
	self = self:GetParent()
	if !self.Think2 and self.Think then self.Think2 = self.Think end
	self.Think = function(self)
		if(!self:IsActive())then
			if self.Think2 then self.Think = self.Think2 self.Think2=nil end
			self:Close()
			self:Remove()
			return
		end
		if self.Think2 then self:Think2() end
	end
end

function CreateObject(self,type)
	local oldself = self
	self = self:GetParent():GetParent()
	if !self.DChildren then self.DChildren = {} end
	local index = vgui.Create(type,self)
	self.DChildren[index] = index
	//Print(self:GetParent():GetTable())
	local Panel = oldself:GetParent()
	index:SetPos(Panel.XClick-Panel.PanelX,Panel.YClick-Panel.PanelY)
	index.OnMousePressed = function(self,type)
		if !type then return end
		if type!=107 then
			OnClick(self,108)
			return
		end
		self:MouseCapture( true )
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
	end
	index.OnMouseReleased = function(self)
		self.Dragging = nil
		self:MouseCapture( false )
	end
	index.Think = function(self)
		if (!self.Dragging) then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		if Clamp then
			x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
			y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
		end
		self:SetPos( x, y )
	end
	return index
end

VguiFunctions = {
	["Resize"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent()
			dframe:SetSize(140,90)
			dframe:MakePopup()
			dframe:Center()
			dframe:ShowCloseButton(true)
			dframe:SetDraggable(true)
			dframe:SetTitle("Resize")
			dframe.Paint = function(self)
				surface.SetDrawColor( 80, 80, 80, 255 )
				surface.DrawRect( 0, 0, self:GetWide(),self:GetTall() )
			end

			local label = vgui.Create("DLabel",dframe)
			label:SetPos(5,30)
			label:SetText("X:")
			label = vgui.Create("DLabel",dframe)
			label:SetPos(5,60)
			label:SetText("Y:")

			dframe.PromptX = vgui.Create("DTextEntry",dframe)
			dframe.PromptX:SetPos(17,30)
			dframe.PromptX:SetSize(75,20)
			dframe.PromptX:SetText(self:GetParent():GetParent():GetWide())
			dframe.PromptX:SetEditable(true)
			dframe.PromptX:SetMultiline(false)
			dframe.PromptX:RequestFocus()
			dframe.PromptX.OnGetFocus = OnGetFocus
			dframe.PromptX.OnKeyCodeTyped = function(self,key)
				if key==64 then
					self:GetParent().Ok:DoClick()
				end
			end

			dframe.PromptY = vgui.Create("DTextEntry",dframe)
			dframe.PromptY:SetPos(17,60)
			dframe.PromptY:SetSize(75,20)
			dframe.PromptY:SetText(self:GetParent():GetParent():GetTall())
			dframe.PromptY:SetEditable(true)
			dframe.PromptY:SetMultiline(false)
			dframe.PromptY.OnKeyCodeTyped = function(self,key)
				if key==64 then
					self:GetParent().Ok:DoClick()
				end
			end

			dframe.Ok = vgui.Create("DButton",dframe)
			dframe.Ok:SetSize(40,50)
			dframe.Ok:SetText("Resize")
			dframe.Ok:SetPos(95,30)
			dframe.Ok.DoClick = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.PromptX:GetValue()),tonumber(self.PromptY:GetValue())
				if x<10 then x=10 end
				if y<10 then y=10 end
				self.owner:SetSize(x,y)
			end
				
		end,
	["SetTitle"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent()
			dframe:SetSize(140,60)
			dframe:MakePopup()
			dframe:Center()
			dframe:ShowCloseButton(true)
			dframe:SetDraggable(true)
			dframe:SetTitle("SetTitle")
			dframe.Paint = function(self)
				surface.SetDrawColor( 80, 80, 80, 255 )
				surface.DrawRect( 0, 0, self:GetWide(),self:GetTall() )
			end

			dframe.Prompt = vgui.Create("DTextEntry",dframe)
			dframe.Prompt:SetPos(8,30)
			dframe.Prompt:SetSize(85,20)
			dframe.Prompt:SetText(self:GetParent():GetParent().lblTitle:GetValue())
			dframe.Prompt:SetEditable(true)
			dframe.Prompt:SetMultiline(false)
			dframe.Prompt:RequestFocus()
			dframe.Prompt.OnGetFocus = OnGetFocus
			dframe.Prompt.OnKeyCodeTyped = function(self,key)
				if key==64 then
					self:GetParent().Ok:DoClick()
				end
			end

			dframe.Ok = vgui.Create("DButton",dframe)
			dframe.Ok:SetSize(30,20)
			dframe.Ok:SetText("Set")
			dframe.Ok:SetPos(105,30)
			dframe.Ok.DoClick = function(self)
				self = self:GetParent()
				local text = self.Prompt:GetValue()
				self.owner:SetTitle(text)
			end
				
		end,
	["SetText"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent()
			dframe:SetSize(140,60)
			dframe:MakePopup()
			dframe:Center()
			dframe:ShowCloseButton(true)
			dframe:SetDraggable(true)
			dframe:SetTitle("SetText")
			dframe.Paint = function(self)
				surface.SetDrawColor( 80, 80, 80, 255 )
				surface.DrawRect( 0, 0, self:GetWide(),self:GetTall() )
			end

			dframe.Prompt = vgui.Create("DTextEntry",dframe)
			dframe.Prompt:SetPos(8,30)
			dframe.Prompt:SetSize(85,20)
			dframe.Prompt:SetText(self:GetParent():GetParent():GetValue())
			dframe.Prompt:SetEditable(true)
			dframe.Prompt:SetMultiline(false)
			dframe.Prompt:RequestFocus()
			dframe.Prompt.OnGetFocus = OnGetFocus
			dframe.Prompt.OnKeyCodeTyped = function(self,key)
				if key==64 then
					self:GetParent().Ok:DoClick()
				end
			end

			dframe.Ok = vgui.Create("DButton",dframe)
			dframe.Ok:SetSize(30,20)
			dframe.Ok:SetText("Set")
			dframe.Ok:SetPos(105,30)
			dframe.Ok.DoClick = function(self)
				self = self:GetParent()
				local text = self.Prompt:GetValue()
				//Print(text)
				self.owner:SetText(text)
			end
				
		end,
	["Delete"] = function(self)
			//Print(self:GetParent():GetParent():GetParent().Derma)
			self = self:GetParent():GetParent()
			if self.Derma.ClassName~="DFrame" then
				self:GetParent().DChildren[self]=nil
			else
				//Print(self.DChildren)
			end
			self:Remove()
		end,
	["Add Button"] = function(self)
			CreateObject(self,"DButton")
		end,
	["Add Label"] = function(self)
			CreateObject(self,"DLabel"):SetMouseInputEnabled(true)
		end,
	["Resize to Contents"] = function(self)
			self = self:GetParent():GetParent()
			self:SizeToContents()
			self:SetSize(self:GetWide()+10,self:GetTall()+10)
		end,
	["Add CheckBox"] = function(self)
			CreateObject(self,"DCheckBox")
		end,
	["Toggle"] = function(self)
			self:GetParent():GetParent():Toggle()
		end,
	["Add Collapsible"] = function(self)
			local Col = CreateObject(self,"DCollapsibleCategory")
			//Col:SetSize(50,50)
		end,
	["Add ListView"] = function(self)
			local list = CreateObject(self,"DListView")
			list:SetSize(list:GetWide(),list:GetTall()+20)
		end,
	["Add Column"] = function(self)
			self = self:GetParent():GetParent()
			local column = self:AddColumn("None")
			column.OnMousePressed = function(self,type)
				if !type then return end
				if type!=107 then
					OnClick(self,108)
					return
				end
			end
		end,
}

function OnClick(self,type)
	if !type then return end
	if type==107 then
		if ( !self.GetDraggable or !self:GetDraggable() ) then return end
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
	//Print(self:GetTable())
	if !VguiOptions[self.ClassName] then
		//Print(self:GetTable())
		if self.Derma.ClassName then self.ClassName = self.Derma.ClassName
		else return end
	end
	self.Menu = vgui.Create("DMenu",self)
	self.Menu.XClick = gui.MouseX()
	self.Menu.YClick = gui.MouseY()
	self.Menu.PanelX = self.x
	self.Menu.PanelY = self.y
	for _,v in pairs(VguiOptions[self.ClassName])do
		self.Menu:AddOption(v,VguiFunctions[v])
	end
	self.Menu:Open()
end

function openVgui(player,command,args)

	if panel && type(panel)=="Panel" && panel:IsValid() then
		panel:Close()
	end
	// Panel to hold everything
	panel = vgui.Create("DFrame")
	panel:SetVisible(true)
	panel:SetDraggable(false)
	panel:SetSizable(true)
	panel:ShowCloseButton(true)
	panel:SetSizable(false)
	panel:MakePopup()
	panel:SetTitle("Lua Editor")
	panel:SetSize(ScrW(),50)

	local CheckBox = vgui.Create("DCheckBoxLabel", panel)
	CheckBox:SetPos(100,30)
	CheckBox:SetText("Clamp")
	CheckBox.OnChange = function(self)
		Clamp = self:GetValue()
	end

	local Button = vgui.Create( "DButton", panel )
	Button:SetPos(10,25)
	Button:SetText("Panel")
	Button.DoClick = function(self)

		local dframe = vgui.Create("DFrame")
		if #VguiList.DFrame then
			VguiList.DFrame[#VguiList.DFrame+1] = dframe
		else
			VguiList.DFrame[1] = dframe
		end
		dframe:SetSize(300,300)
		dframe:SetSizable(false)
		dframe:MakePopup()
		dframe:Center()
		dframe:ShowCloseButton(false)
		/*
		for k,v in pairs(file.Find("../lua/vgui/*"))do
			Print("lua/"..string.Left(v,string.len(v)-4)..".txt")
			file.Write("lua/"..string.Left(v,string.len(v)-4)..".txt",file.Read("../lua/vgui/"..v))
		end
		file.Write("DCheckBox.txt",file.Read("../lua/vgui/DCheckBox.lua"))
		Print(dframe)
		*/
		dframe.OnMousePressed = OnClick
	end
end