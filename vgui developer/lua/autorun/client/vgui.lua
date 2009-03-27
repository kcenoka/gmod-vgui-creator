local currentFrame,VguiList,VguiOptions,VguiFunctions,OnClick,OnGetFocus,CreateObject,DupeDerma
local SaveFile = "filename"
local dupe_xoff = CreateClientConVar("vgui_creator_xoff", "10", true, false)
local dupe_yoff = CreateClientConVar("vgui_creator_yoff", "10", true, false)
local Clamp = CreateClientConVar("vgui_creator_Clamp", "1", true, false)
VguiList = {
	DFrame = {}
}
VguiOptions = {
	DFrame = {{Name="Set","Size","Position","Title"},"Delete","Save",{Name="Center","CenterX","CenterY","Center"},{Name="Add","Button","Label","CheckBox","Collapsible","ListView"}},
	DButton = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DCheckBox = {{Name="Set","Size","Position","Toggle"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"}},
	DLabel = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DListView = {{Name="Set","Size","Position"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Add Column"},
	DCollapsibleCategory = {{Name="Set","Size","Position","Title"},"Delete",{Name="Center","CenterX","CenterY","Center"}},
}

DupeDerma = function(self)
	local oldself = self
	self = self:GetParent():GetParent()
	local class = self.ClassName
	if !class then
		class = self.Derma.ClassName
	end
	local index = CreateObject(oldself,class,true)
	index:SetPos(self.x+dupe_xoff:GetInt(),self.y+dupe_yoff:GetInt())
	index:SetSize(self:GetWide(),self:GetTall())
	if class=="DButton" or class=="DLabel" then
		index:SetText(self:GetValue())
		if class=="DLabel" then
			index:SetMouseInputEnabled(true)
		end
	elseif class=="DCheckBox" then
		index:SetValue(index:GetChecked())
	end
	return index
end

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

function CreateObject(self,type,dupe)
	local oldself = self
	self = self:GetParent():GetParent()
	if dupe then self = self:GetParent() end
	if !self.DChildren then self.DChildren = {} end
	local index = vgui.Create(type,self)
	self.DChildren[index] = index
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
		if Clamp:GetBool() then
			x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
			y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
		end
		self:SetPos( x, y )
	end
	return index
end

VguiFunctions = {
	["Size"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent():GetParent()
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
			dframe.PromptX:SetText(dframe.owner:GetWide())
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
			dframe.PromptY:SetText(dframe.owner:GetTall())
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
	["Position"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent():GetParent()
			dframe:SetSize(140,90)
			dframe:MakePopup()
			dframe:Center()
			dframe:ShowCloseButton(true)
			dframe:SetDraggable(true)
			dframe:SetTitle("Reposition")
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
			dframe.PromptX:SetText(dframe.owner.x)
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
			dframe.PromptY:SetText(dframe.owner.y)
			dframe.PromptY:SetEditable(true)
			dframe.PromptY:SetMultiline(false)
			dframe.PromptY.OnKeyCodeTyped = function(self,key)
				if key==64 then
					self:GetParent().Ok:DoClick()
				end
			end

			dframe.Ok = vgui.Create("DButton",dframe)
			dframe.Ok:SetSize(40,50)
			dframe.Ok:SetText("SetPos")
			dframe.Ok:SetPos(95,30)
			dframe.Ok.DoClick = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.PromptX:GetValue()),tonumber(self.PromptY:GetValue())
				if Clamp:GetBool() then
					x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
					y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
				end
				self.owner:SetPos(x,y)
			end
				
		end,
	["Save"] = function(self)
			self = self:GetParent():GetParent()
			local text = "local DFrame = vgui.Create('DFrame')\r\nDFrame:SetPos("..self.x..","..self.y..")\r\nDFrame:SetSize("..self:GetWide()..","..self:GetTall()..")\r\nDFrame:SetTitle('"..self.lblTitle:GetValue().."')\r\nDFrame:ShowCloseButton(true)\r\n\r\n"
			local class
			if self.DChildren then
				for _,v in pairs(self.DChildren)do
					if v.ClassName then
						class=v.ClassName
					elseif v.Derma.ClassName then
						class=v.Derma.ClassName
					end
					text = text.."local "..class.." = vgui.Create('"..class.."',DFrame)\r\n"..class..":SetPos("..v.x..","..v.y..")\r\n"..class..":SetSize("..v:GetWide()..","..v:GetTall()..")\r\n"
					if class=="DButton" then
						text = text..class..":SetText('"..v:GetValue().."')\r\n\r\n"
					elseif class=="DCheckBox" then
						text = text..class..":SetValue("..tostring(v:GetChecked())..")\r\n\r\n"
					elseif class=="DLabel" then
						text = text..class..":SetText('"..v:GetValue().."')\r\n\r\n"
					end
				end
			end
			local filen = SaveFile
			filen=string.gsub(filen,"%p","_")
			if string.Right(filen,4)!=".txt" then filen=filen..".txt" end
			file.Write("vguicreator/"..filen,text)
		end,
	["Title"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent():GetParent()
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
			dframe.Prompt:SetText(dframe.owner.lblTitle:GetValue())
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
	["Text"] = function(self)
			local dframe = vgui.Create("DFrame")
			dframe.owner = self:GetParent():GetParent():GetParent()
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
			dframe.Prompt:SetText(dframe.owner:GetValue())
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
				self.owner:SetText(text)
			end
				
		end,
	["Delete"] = function(self)
			self = self:GetParent():GetParent()
			if self.ClassName=="DFrame" or self.Derma.ClassName=="DFrame" then
				self:Close()
				return
			end
			self:GetParent().DChildren[self]=nil
			self:Remove()
		end,
	["Duplicate"] = function(self)
			DupeDerma(self):GetParent()
		end,
	["CenterX"] = function(self)
			self:GetParent():GetParent():GetParent():CenterHorizontal()
		end,
	["CenterY"] = function(self)
			self:GetParent():GetParent():GetParent():CenterVertical()
		end,
	["Center"] = function(self)
			self:GetParent():GetParent():GetParent():Center()
		end,
	["Button"] = function(self)
			CreateObject(self:GetParent(),"DButton")
		end,
	["Label"] = function(self)
			CreateObject(self:GetParent(),"DLabel"):SetMouseInputEnabled(true)
		end,
	["Resize to Contents"] = function(self)
			self = self:GetParent():GetParent()
			self:SizeToContents()
			self:SetSize(self:GetWide()+10,self:GetTall()+10)
		end,
	["CheckBox"] = function(self)
			CreateObject(self:GetParent(),"DCheckBox"):SetValue(false)
		end,
	["Toggle"] = function(self)
			self:GetParent():GetParent():Toggle()
		end,
	["Collapsible"] = function(self)
			local Col = CreateObject(self:GetParent(),"DCollapsibleCategory")
			//Col:SetSize(50,50)
		end,
	["ListView"] = function(self)
			local list = CreateObject(self:GetParent(),"DListView")
			list:SetSize(list:GetWide(),list:GetTall()+20)
		end,
	["Column"] = function(self)
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

function OnClick(self,ctype)
	if !ctype then return end
	if ctype==107 then
		if ( !self.GetDraggable or !self:GetDraggable() ) then return end
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
	if !VguiOptions[self.ClassName] then
		if self.Derma.ClassName then self.ClassName = self.Derma.ClassName end
		if !VguiOptions[self.ClassName] then return end
	end
	self.Menu = vgui.Create("DMenu",self)
	self.Menu.XClick = gui.MouseX()
	self.Menu.YClick = gui.MouseY()
	self.Menu.PanelX = self.x
	self.Menu.PanelY = self.y
	for _,v in pairs(VguiOptions[self.ClassName])do
		if type(v)=="table" then
			local subMenu = self.Menu:AddSubMenu(v.Name)
			for _,o in ipairs(v)do
				subMenu:AddOption(o,VguiFunctions[o])
			end
		else
			self.Menu:AddOption(v,VguiFunctions[v])
		end
	end

	//Print(self.Menu:GetTable())
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
	panel.Close2 = panel.Close
	panel.Close = function(self)
		for _,v in pairs(VguiList.DFrame)do
			v:Close()
		end
		self:Close2()
	end

	local CheckBox = vgui.Create("DCheckBoxLabel", panel)
	CheckBox:SetPos(100,30)
	CheckBox:SetText("Clamp")
	CheckBox:SetValue(Clamp:GetBool())
	CheckBox:SetConVar( "vgui_creator_Clamp" )

	local Text = vgui.Create("DTextEntry",panel)
	Text:SetPos(180,26)
	Text:SetSize(100,20)
	Text:SetText(SaveFile)
	Text.OnTextChanged = function(self)
		SaveFile=self:GetValue()
	end

	local slider = vgui.Create( /*"DNumberWang"*/"DNumSlider", panel )
	slider:SetPos( 300,26 )
	slider:SetSize( 110, 20 )
	slider:SetText( "DupeX Offset" )
	slider:SetMin( -200 )
	slider:SetMax( 200 )
	slider:SetDecimals( 0 )
	slider:SetConVar( "vgui_creator_xoff" )

	local slider = vgui.Create( /*"DNumberWang"*/"DNumSlider", panel )
	slider:SetPos( 425,26 )
	slider:SetSize( 110, 20 )
	slider:SetText( "DupeY Offset" )
	slider:SetMin( -200 )
	slider:SetMax( 200 )
	slider:SetDecimals( 0 )
	slider:SetConVar( "vgui_creator_yoff" )

	local Button = vgui.Create( "DButton", panel )
	Button:SetPos(10,25)
	Button:SetText("Panel")
	Button.DoClick = function(self)

		local dframe = vgui.Create("DFrame")
		VguiList.DFrame[dframe] = dframe
		dframe:SetSize(300,300)
		dframe:SetSizable(false)
		dframe:MakePopup()
		dframe:Center()
		dframe:ShowCloseButton(false)
		dframe.Close2 = dframe.Close
		dframe.Close = function(self)
			VguiList.DFrame[dframe] = nil
			self:Close2()
		end
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