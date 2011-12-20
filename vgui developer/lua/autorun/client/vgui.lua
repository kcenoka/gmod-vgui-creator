local currentFrame,VguiList,VguiOptions,VguiFunctions,OnClick,OnGetFocus,CreateObject,DupeDerma,CollapseContents,GiveClickability,CollapsibleOptions,QueryPrompt
local SaveFile = "newGUI"
local dupe_xoff = CreateClientConVar("vgui_creator_xoff", "10", true, false)
local dupe_yoff = CreateClientConVar("vgui_creator_yoff", "10", true, false)
local Clamp = CreateClientConVar("vgui_creator_Clamp", "1", true, false)
VguiList = {
	DFrame = {}
}
VguiOptions = {
	DFrame = {{Name="Set","Size","Position","Title"},"Delete","Save",{Name="Center","CenterX","CenterY","Center"},{Name="Add","Button","Label","CheckBox","CheckBoxLabel","Number Slider"}},--,"Collapsible","ListView","PanelList"}},
	DButton = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DCheckBox = {{Name="Set","Size","Position","Toggle"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"}},
	DCheckBoxLabel = {{Name="Set","Size","Position","Text","Toggle"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"}},
	DNumSlider = {{Name="Set","Size","Position","Text","Min and Max","Decimals"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DLabel = {{Name="Set","Size","Position","Text"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Resize to Contents"},
	DListView = {{Name="Set","Size","Position"},"Delete","Duplicate",{Name="Center","CenterX","CenterY","Center"},"Add Column"},
	DCollapsibleCategory = {{Name="Set","Size","Position","Toggle","Title","Padding"},"Delete",{Name="Center","CenterX","CenterY","Center"}},--,"PanelList"},
}
CollapsibleOptions = {
	DFrame = {{Name="Set","Size","Title"},"Delete","Save",{Name="Add","Button","Label","CheckBox","Collapsible","ListView","PanelList"}},
	DButton = {{Name="Set","Size","Text"},"Delete"},
	DCheckBox = {{Name="Set","Size","Toggle"},"Delete"},
	DLabel = {{Name="Set","Size","Text"},"Delete"},
	DListView = {{Name="Set","Size"},"Delete","Add Column"},
}
local Query

DupeDerma = function(self)
	local oldself = self
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
	self = self:GetParent():GetParent()
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
	self = self:GetParent():GetParent()
	local oldself = self
	self = self:GetParent()
	if dupe then self = self:GetParent() end
	if !self.DChildren then self.DChildren = {} end
	local index = vgui.Create(type,self)
	self.DChildren[index] = index
	local Panel = oldself
	index:SetPos(Panel.XClick-Panel.PanelX,Panel.YClick-Panel.PanelY)
	GiveClickability(index)
	if type == "DCheckBoxLabel" then
		index:SetText("Label")
		index.Label.OnMousePressed = function(self,type)
			self = self:GetParent()
			self.OnMousePressed(self,type)
		end
		index.Label.OnMouseReleased = function(self)
			self = self:GetParent()
			self.OnMouseReleased(self)
		end
		index.Button.OnMousePressed = function(self,type)
			self = self:GetParent()
			self.OnMousePressed(self,type)
		end
		index.Button.OnMouseReleased = function(self)
			self = self:GetParent()
			self.OnMouseReleased(self)
		end
	end
	return index
end

function QueryPrompt(owner, data)
	Query = vgui.Create("DFrame")
	Query.owner = owner
	Query:MakePopup()
	Query:ShowCloseButton(true)
	Query:SetDraggable(true)
	Query:SetTitle(data.Title)
	Query.Paint = function(self)
		surface.SetDrawColor( 80, 80, 80, 255 )
		surface.DrawRect( 0, 0, self:GetWide(),self:GetTall() )
	end

	local total = -1
	local pan
	local labelLen = 0
	local labelWidth
	for k,v in pairs(data.Prompt) do
		if v.Label then
			labelWidth = surface.GetTextSize(v.Label)
			print(labelWidth)
			if labelWidth > labelLen then
				labelLen = labelWidth
			end
		end
	end
	if labelLen > 0 then
		labelLen = labelLen - 10
	end
	for k,v in pairs(data.Prompt) do
		total = total+1
		pan = vgui.Create("DTextEntry",Query)
		if not v.Label then
			pan:SetPos(8,30*k)
			pan:SetSize(85,20)
		else
			pan:SetPos(17+labelLen,30*k)
			pan:SetSize(75,20)
			label = vgui.Create("DLabel",Query)
			label:SetPos(5,30*k)
			label:SetText(v.Label)
		end
		pan:SetText(v.Text(Query.owner))
		pan.default = pan:GetText()
		pan:SetEditable(true)
		pan:SetMultiline(false)
		if k==1 then pan:RequestFocus() end
		pan.OnGetFocus = OnGetFocus
		pan.OnKeyCodeTyped = function(self,key)
			if key==64 then
				self:GetParent().Ok:DoClick()
			elseif key==67 then
				return false
			end
		end
		Query["Prompt"..k] = pan
	end

	Query.Ok = vgui.Create("DButton",Query)
	Query.Ok:SetSize(40,20+(total*30))
	Query.Ok:SetText(data.Ok.Text)
	Query.Ok:SetPos(95+labelLen,30)
	Query.Ok.DoClick = data.Ok.Func
	Query:SetSize(140+labelLen,60+30*total)
	local qWidth,qHeight = Query:GetSize()
	Query:SetPos(gui.MouseX() - qWidth/2, gui.MouseY() - qHeight/2)
	Query.Close2 = Query.Close
	Query.Close = function(self)
		Query = nil
		self:Close2()
	end
end

VguiFunctions = {
	["Size"] = function(self)
		self = self:GetParent():GetParent():GetParent():GetParent()
		local data = {Title = "Resize"}
		data.Prompt = { {Text=function(pan) return pan:GetWide() end, Label="Width:"},
			{Text=function(pan) return pan:GetTall() end, Label="Height:"}
		}
		data.Ok = { Text = "Set"}
		if self:GetParent():IsValid() and self:GetParent().ClassName=="DCollapsibleCategory" then
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if not x then
					x = self.Prompt1.default
					self.Prompt1:SetValue(x)
				elseif x<10 then
					x=10
					self.Prompt1:SetValue(x)
				end
				if not y then
					y = self.Prompt2.default
					self.Prompt2:SetValue(y)
				elseif y<10 then
					y=10
					self.Prompt2:SetValue(y)
				end
				self.owner:GetParent():SetWide(x)
				self.owner:SetTall(y)
				self.owner:GetParent():InvalidateLayout()
				self.Prompt1.default = x
				self.Prompt2.default = y
			end
		elseif self.ClassName=="DCollapsibleCategory" and self.Contents and self.Contents:IsValid() then
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if not x then
					x = self.Prompt1.default
					self.Prompt1:SetValue(x)
				elseif x<10 then
					x=10
					self.Prompt1:SetValue(x)
				end
				if not y then
					y = self.Prompt2.default
					self.Prompt2:SetValue(y)
				elseif y<10 then
					y=10
					self.Prompt2:SetValue(y)
				end
				self.owner:SetWide(x)
				self.owner.Contents:SetTall(y-22)
				self.owner:InvalidateLayout()
				self.Prompt1.default = x
				self.Prompt2.default = y
			end
		else
			data.Ok.Func = function(self)
				self = self:GetParent()
				local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
				if not x then
					x = self.Prompt1.default
					self.Prompt1:SetValue(x)
				elseif x<10 then
					x=10
					self.Prompt1:SetValue(x)
				end
				if not y then
					y = self.Prompt2.default
					self.Prompt2:SetValue(y)
				elseif y<10 then
					y=10
					self.Prompt2:SetValue(y)
				end
				self.owner:SetSize(x,y)
				self.Prompt1.default = x
				self.Prompt2.default = y
			end
		end
		QueryPrompt(self,data)
	end,
	["Position"] = function(self)
		self = self:GetParent():GetParent():GetParent():GetParent()
		local data = {Title = "Reposition"}
		data.Prompt = { {Text=function(pan) return pan.x end, Label="X:"},
			{Text=function(pan) return pan.y end, Label="Y:"}
		}
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local x,y = tonumber(self.Prompt1:GetValue()),tonumber(self.Prompt2:GetValue())
			if not x then
				x = self.Prompt1.default
				self.Prompt1:SetValue(x)
			end
			if not y then
				y = self.Prompt2.default
				self.Prompt2:SetValue(y)
			end
			if Clamp:GetBool() then
				x = math.Clamp( x, 0, self:GetParent():GetWide() - self:GetWide() )
				y = math.Clamp( y, 0, self:GetParent():GetTall() - self:GetTall() )
				self.Prompt1:SetValue(x)
				self.Prompt2:SetValue(y)
			end
			self.owner:SetPos(x,y)
			self.Prompt1.default = x
			self.Prompt2.default = y
		end }
		QueryPrompt(self,data)
	end,
	["Save"] = function(self)
		self = self:GetParent():GetParent():GetParent()
		local text = "local MasterDFrame = vgui.Create('DFrame')\r\nMasterDFrame:SetPos("..self.x..","..self.y..")\r\nMasterDFrame:SetSize("..self:GetWide()..","..self:GetTall()..")\r\nMasterDFrame:SetTitle('"..self.lblTitle:GetText().."')\r\nMasterDFrame:ShowCloseButton(true)\r\n\r\n"
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
				elseif class=="DCheckBoxLabel" then
					text = text..class..":SetText('"..v.Label:GetValue().."')\r\n"..class..":SetValue("..tostring(v:GetChecked())..")\r\n\r\n"
				elseif class=="DLabel" then
					text = text..class..":SetText('"..v:GetValue().."')\r\n\r\n"
				elseif class=="DNumSlider" then
					text = text..class..":SetText('"..v.Label:GetValue().."')\r\n"..class..":SetMinMax("..v.Wang.m_numMin..", "..v.Wang.m_numMax..")\r\n"..class..":SetValue("..v:GetValue()..")\r\n"..class..":SetDecimals("..v:GetDecimals()..")\r\n"..class..":PerformLayout()\r\n\r\n"
				end
			end
		end
		text = text.."MasterDFrame:MakePopup()"
		local filen = SaveFile
		filen=string.gsub(filen,"%p","_")
		if string.Right(filen,4)!=".txt" then filen=filen..".txt" end
		file.Write("vguicreator/"..filen,text)
	end,
	["Title"] = function(self)
		self = self:GetParent():GetParent():GetParent():GetParent()
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
			data.Prompt = { {Text=function(pan) return pan.lblTitle:GetText() end} }
			data.Ok.Func = function(self)
				self = self:GetParent()
				local text = self.Prompt1:GetValue()
				self.owner:SetTitle(text)
			end
		end
		QueryPrompt(self,data)
	end,
	["Text"] = function(self)
		self = self:GetParent():GetParent():GetParent():GetParent()
		local data = {Title = "Set Text"}
		data.Ok = { Text = "Set"}
		if self.ClassName == "DNumSlider" or self.ClassName == "DCheckBoxLabel" then
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
		self = self:GetParent():GetParent():GetParent()
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
		DupeDerma(self:GetParent():GetParent():GetParent())
	end,
	["CenterX"] = function(self)
		self:GetParent():GetParent():GetParent():GetParent():CenterHorizontal()
	end,
	["CenterY"] = function(self)
		self:GetParent():GetParent():GetParent():GetParent():CenterVertical()
	end,
	["Center"] = function(self)
		self:GetParent():GetParent():GetParent():GetParent():Center()
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
		self = self:GetParent():GetParent():GetParent()
		self:SizeToContents()
		self:SetSize(self:GetWide()+10,self:GetTall()+10)
	end,
	["CheckBox"] = function(self)
		CreateObject(self:GetParent(),"DCheckBox"):SetValue(false)
	end,
	["CheckBoxLabel"] = function(self)
		CreateObject(self:GetParent(),"DCheckBoxLabel"):SetValue(false)
	end,
	["Toggle"] = function(self)
		self:GetParent():GetParent():GetParent():GetParent():Toggle()
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
		self = self:GetParent():GetParent():GetParent()
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
		self = self:GetParent():GetParent():GetParent():GetParent()
		local data = {Title = "Set Padding"}
		data.Prompt = { {Text=function(pan) return (pan:GetPadding() or 0) end} }
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local padding = tonumber(self.Prompt1:GetValue())
			if not padding then
				padding = self.Prompt1.default
			else
				self.Prompt1.default = padding
			end
			self.owner:SetPadding(padding)
			self.owner:InvalidateLayout()
		end }
		QueryPrompt(self,data)
	end,
	["Min and Max"] = function(self)
		self = self:GetParent():GetParent():GetParent():GetParent()
		local data = {Title = "Set Min and Max"}
		data.Prompt = { {Text=function(pan) return (pan.Wang.m_numMin or 0) end, Label="Min:"},
			{Text=function(pan) return (pan.Wang.m_numMax or 0) end, Label="Max:"}
		}
		data.Ok = { Text = "Set", Func = function(self)
			self = self:GetParent()
			local min,max = tonumber(self.Prompt1:GetValue()), tonumber(self.Prompt2:GetValue())
			if not min then
				min = tonumber(self.Prompt1.default)
				self.Prompt1:SetValue(min)
			end
			if not max then
				max = tonumber(self.Prompt2.default)
				self.Prompt2:SetValue(max)
			end
			if min>max or min == max then
				min = self.Prompt1.default
				max = self.Prompt2.default
				self.Prompt1:SetValue(min)
				self.Prompt2:SetValue(max)
			else
				self.Prompt1.default = min
				self.Prompt2.default = max
			end
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
		self = self:GetParent():GetParent():GetParent():GetParent()
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
	if Query then
		Query:Close()
	end
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
	-- Panel to hold everything
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
		if Query then
			Query:Close()
		end
		self:Close2()
	end

	local CheckBox = vgui.Create("DCheckBoxLabel", panel)
	CheckBox:SetPos(100,30)
	CheckBox:SetText("Clamp")
	CheckBox:SetValue(Clamp:GetBool())
	CheckBox:SetConVar("vgui_creator_Clamp")

	local Text = vgui.Create("DTextEntry",panel)
	Text:SetPos(180,26)
	Text:SetSize(100,20)
	Text:SetText(SaveFile)
	Text.OnTextChanged = function(self)
		SaveFile=self:GetValue()
	end

	local slider = vgui.Create( --[["DNumberWang"]]"DNumSlider", panel )
	slider:SetPos(300,26)
	slider:SetSize(115,20)
	slider:SetText("DupeX Offset")
	slider:SetMin(-200)
	slider:SetMax(200)
	slider:SetDecimals(0)
	slider:SetConVar("vgui_creator_xoff")

	slider = vgui.Create( --[["DNumberWang"]]"DNumSlider", panel )
	slider:SetPos(430,26)
	slider:SetSize(115,20)
	slider:SetText("DupeY Offset" )
	slider:SetMin(-200)
	slider:SetMax(200)
	slider:SetDecimals(0)
	slider:SetConVar("vgui_creator_yoff")

	local Button = vgui.Create( "DButton", panel )
	Button:SetPos(10,25)
	Button:SetText("New Frame")
	Button.DoClick = function(self)

		local dframe = vgui.Create("DFrame")
		VguiList.DFrame[dframe] = dframe
		dframe:SetSize(300,300)
		dframe:SetSizable(false)
		dframe:MakePopup()
		dframe:Center()
		dframe:ShowCloseButton(true)
		dframe.Close2 = dframe.Close
		dframe.Close = function(self)
			VguiList.DFrame[dframe] = nil
			self:Close2()
		end
		dframe.OnMousePressed = OnClick
	end
end