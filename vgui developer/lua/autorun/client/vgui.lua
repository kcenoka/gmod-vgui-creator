local currentFrame,VguiList,VguiOptions,VguiFunctions,OnClick,OnGetFocus,CreateObject,DupeDerma,CollapseContents,GiveClickability,CollapsibleOptions,QueryPrompt
local SaveFile = "filename"
local dupe_xoff = CreateClientConVar("vgui_creator_xoff", "10", true, false)
local dupe_yoff = CreateClientConVar("vgui_creator_yoff", "10", true, false)
local Clamp = CreateClientConVar("vgui_creator_Clamp", "1", true, false)
VguiList = {
	DFrame = {}
}
VguiOptions = {
	DFrame = {{Name="Set","Size","Position","Title"},"Delete","Save",{Name="Center","CenterX","CenterY","Center"},{Name="Add","Button","Label","CheckBox","Number Slider","Collapsible"}},	//,"ListView","PanelList"}},
	DButton = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DCheckBox = {{Name="Set","Size","Position","Toggle"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"}},
	DNumSlider = {{Name="Set","Size","Position","Text","Max Min","Decimals"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DLabel = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DListView = {{Name="Set","Size","Position"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Add Column"},
	DCollapsibleCategory = {{Name="Set","Size","Position","Toggle","Title","Padding"},"Delete",{Name="Center","CenterX","CenterY","Center"},{Name="Contents","Button"}},	//,"PanelList"}},
}
CollapsibleOptions = {
	DFrame = {{Name="Set","Size","Title"},"Delete","Save",{Name="Add","Button","Label","CheckBox","Collapsible","ListView","PanelList"}},
	DButton = {{Name="Set","Size","Text"},"Delete"},
	DCheckBox = {{Name="Set","Size","Toggle"},"Delete"},
	DLabel = {{Name="Set","Size","Text"},"Delete"},
	DListView = {{Name="Set","Size"},"Delete","Add Column"},
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
	index.ClassName = class
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

function GiveClickability(self,nodrag)
	if nodrag then
		self.OnMousePressed = function(self,type)
			if !type or type!=108 then return end
			OnClick(self,108)
			return
		end
		return
	end
	self.OnMousePressed = function(self,type)
		if !type then return end
		if type!=107 then
			OnClick(self,108)
			return
		end
		self:MouseCapture( true )
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
	end
	self.OnMouseReleased = function(self)
		self.Dragging = nil
		self:MouseCapture( false )
	end
	self.Think = function(self)
		if (!self.Dragging) then return end
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]
		if Clamp:GetBool() then
			x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
			y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
		end
		self:SetPos( x, y )
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
	GiveClickability(index)
	return index
end

function QueryPrompt(owner, data)
	local dframe = vgui.Create("DFrame")
	dframe.owner = owner
	dframe:MakePopup()
	dframe:Center()
	dframe:ShowCloseButton(true)
	dframe:SetDraggable(true)
	dframe:SetTitle(data.Title)
	dframe.Paint = function(self)
		surface.SetDrawColor( 80, 80, 80, 255 )
		surface.DrawRect( 0, 0, self:GetWide(),self:GetTall() )
	end

	local total = -1
	for k,v in pairs(data.Prompt) do
		total = total+1
		dframe["Prompt"..k] = vgui.Create("DTextEntry",dframe)
		if !v.Label then
			dframe["Prompt"..k]:SetPos(8,30*k)
			dframe["Prompt"..k]:SetSize(85,20)
		else
			dframe["Prompt"..k]:SetPos(17,30*k)
			dframe["Prompt"..k]:SetSize(75,20)
			label = vgui.Create("DLabel",dframe)
			label:SetPos(5,30*k)
			label:SetText(v.Label)
		end
		dframe["Prompt"..k]:SetText(v.Text(dframe.owner))
		dframe["Prompt"..k]:SetEditable(true)
		dframe["Prompt"..k]:SetMultiline(false)
		if k==1 then dframe["Prompt"..k]:RequestFocus() end
		dframe["Prompt"..k].OnGetFocus = OnGetFocus
		dframe["Prompt"..k].OnKeyCodeTyped = function(self,key)
			if key==64 then
				self:GetParent().Ok:DoClick()
			end
		end
	end

	dframe.Ok = vgui.Create("DButton",dframe)
	dframe.Ok:SetSize(40,20+(total*30))
	dframe.Ok:SetText(data.Ok.Text)
	dframe.Ok:SetPos(95,30)
	dframe.Ok.DoClick = data.Ok.Func

	dframe:SetSize(140,60+30*total)
end

VguiFunctions = {
	["Size"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Resize"}
		data.Prompt = { {Text=function(pan) return pan:GetWide() end, Label="X:"},
			{Text=function(pan) return pan:GetTall() end, Label="Y:"}
		}
		data.Ok = { Text = "Set"}
		if self:GetParent():IsValid() and self:GetParent().ClassName=="DCollapsibleCategory" then
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if x<10 then x=10 end
				if y<10 then y=10 end
				self.owner:GetParent():SetWide(x)
				self.owner:SetTall(y)
				self.owner:GetParent():InvalidateLayout()
			end
		elseif self.ClassName=="DCollapsibleCategory" and self.Contents and self.Contents:IsValid() then
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if x<10 then x=10 end
				if y<10 then y=10 end
				self.owner:SetWide(x)
				self.owner.Contents:SetTall(y-22)
				self.owner:InvalidateLayout()
			end
		else
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if x<10 then x=10 end
				if y<10 then y=10 end
				self.owner:SetSize(x,y)
			end
		end
		QueryPrompt(self,data)
	end,
	["Position"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Reposition"}
		data.Prompt = { {Text=function(pan) return pan.x end, Label="X:"},
			{Text=function(pan) return pan.y end, Label="Y:"}
		}
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
			if Clamp:GetBool() then
				x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
				y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
			end
			self.owner:SetPos(x,y)
		end }
		QueryPrompt(self,data)
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
				elseif class=="DNumSlider" then
					text = text..class..":SetText('"..v.Label:GetValue().."')\r\n"..class..":SetMinMax("..v.Wang.m_numMin..", "..v.Wang.m_numMax..")\r\n"..class..":SetValue("..v:GetValue()..")\r\n"..class..":SetDecimals("..v:GetDecimals()..")\r\n"..class..":PerformLayout()\r\n\r\n"
				end
			end
		end
		local filen = SaveFile
		filen=string.gsub(filen,"%p","_")
		if string.Right(filen,4)!=".txt" then filen=filen..".txt" end
		file.Write("vguicreator/"..filen,text)
	end,
	["Title"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Set Title"}
		data.Ok = { Text = "Set"}
		if self.ClassName=="DCollapsibleCategory" then
			data.Prompt = { {Text=function(pan) return pan.Header:GetValue() end} }
			data.Ok.Func = function(self)
				self = self:GetParent()
				local text = self.Prompt1:GetValue()
				self.owner.Header:SetText(text)
			end
		else
			data.Prompt = { {Text=function(pan) return pan.lblTitle:GetValue() end} }
			data.Ok.Func = function(self)
				self = self:GetParent()
				local text = self.Prompt1:GetValue()
				self.owner:SetTitle(text)
			end
		end
		QueryPrompt(self,data)
	end,
	["Text"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Set Text"}
		data.Ok = { Text = "Set"}
		if self.ClassName == "DNumSlider" then
			data.Prompt = { {Text=function(pan) return pan.Label:GetValue() end} }
		else
			data.Prompt = { {Text=function(pan) return pan:GetValue() end} }
		end
		data.Ok.Func = function(self)
			self = self:GetParent()
			local text = self.Prompt1:GetValue()
			self.owner:SetText(text)
		end
		QueryPrompt(self,data)
	end,
	["Delete"] = function(self)
		self = self:GetParent():GetParent()
		if self.ClassName=="DFrame" or self.Derma.ClassName=="DFrame" then
			self:Close()
			return
		end
		if self:GetParent().DChildren then
			self:GetParent().DChildren[self]=nil
		end
		if self:GetParent().Contents then
			self:GetParent().Contents = nil
		end
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
		local oldself = self
		self = self:GetParent():GetParent():GetParent()
		if self.ClassName=="DCollapsibleCategory" then
			self:SetContents(vgui.Create("DButton"))
			GiveClickability(self.Contents,true)
			self:PerformLayout()
		else
			CreateObject(oldself:GetParent(),"DButton")
		end
	end,
	["Label"] = function(self)
		CreateObject(self:GetParent(),"DLabel"):SetMouseInputEnabled(true)
	end,
	["Number Slider"] = function(self)
		local pan = CreateObject(self:GetParent(),"DNumSlider")
		pan:SetSize(100,35)
		pan:PerformLayout()
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
		self:GetParent():GetParent():GetParent():Toggle()
	end,
	["Collapsible"] = function(self)
		local col = CreateObject(self:GetParent(),"DCollapsibleCategory")
		col:SetSize(50,50)
		col.Header.OnMousePressed = function(self,mcode)
			self:GetParent():OnMousePressed( mcode )
		end
		col.Header.OnMouseReleased = function(self,mcode)
			self:GetParent():OnMouseReleased( mcode )
		end
	end,
	["ListView"] = function(self)
		local list = CreateObject(self:GetParent(),"DListView")
		list:SetSize(list:GetWide(),list:GetTall()+20)
	end,
	["PanelList"] = function(self)
		local oldself = self
		self = self:GetParent():GetParent():GetParent()
		if self.ClassName=="DCollapsibleCategory" then
			self:SetContents(vgui.Create("DPanelList")) //CollapseContents(self,"DPanelList")
			self:PerformLayout()
		else
			CreateObject(oldself:GetParent(),"DPanelList")
		end
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
	["Padding"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Set Padding"}
		data.Prompt = { {Text=function(pan) return (pan:GetPadding() or 0) end} }
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			self.owner:SetPadding(self.Prompt1:GetValue())
			self.owner:InvalidateLayout()
		end }
		QueryPrompt(self,data)
	end,
	["Max Min"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Set Max and Min"}
		data.Prompt = { {Text=function(pan) return (pan.Wang.m_numMin or 0) end, Label="Min:"},
			{Text=function(pan) return (pan.Wang.m_numMax or 0) end, Label="Max:"}
		}
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local min,max = tonumber(self.Prompt1:GetValue()), tonumber(self.Prompt2:GetValue())
			if min>max then Print("Bad") return end
			self.owner:SetMinMax(min,max)
			if self.owner:GetValue()<min then
				self.owner:SetValue(min)
			elseif self.owner:GetValue()>max then
				self.owner:SetValue(max)
			end
			self.owner:PerformLayout()
		end }
		QueryPrompt(self,data)
	end,
	["Decimals"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local data = {Title = "Set Decimals"}
		data.Prompt = { {Text=function(pan) return pan:GetDecimals() end} }
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local dec = self.Prompt1:GetValue()
			dec = dec - dec % 1
			if dec<0 then dec = -dec end
			self.owner:SetDecimals(dec)
		end }
		QueryPrompt(self,data)
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
	local list = VguiOptions[self.ClassName]
	if self:GetParent().ClassName=="DCollapsibleCategory" then
		if !CollapsibleOptions[self.ClassName] then
			if self.Derma.ClassName then self.ClassName = self.Derma.ClassName end
			if !CollapsibleOptions[self.ClassName] then return end
		end
		list = CollapsibleOptions[self.ClassName]
	end
	for _,v in pairs(list)do
		if type(v)=="table" then
			local subMenu = self.Menu:AddSubMenu(v.Name)
			for _,o in ipairs(v)do
				subMenu:AddOption(o,VguiFunctions[o])
			end
		else
			self.Menu:AddOption(v,VguiFunctions[v])
		end
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