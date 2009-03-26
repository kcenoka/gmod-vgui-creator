concommand.Add("vguiReload",function (player, command, arg)
	RunString(file.Read("../lua/autorun/client/vgui.lua"))
	openVgui()
end)
