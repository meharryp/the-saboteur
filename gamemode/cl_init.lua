include( "shared.lua" )

-- Gamemode functions


-- Assorted functions

function util.IsIn2DBox( x1, x2, y1, y2, xMax, yMax ) -- There's got to be a better way of doing this...
	if x1 >= x2 and y1 >= y2 and ( x1 - x2 ) <= xMax and ( y1 - y2 ) <= yMax then
		return true
	end
end

function util.ClickIn2DBox( x1, x2, y1, y2, xMax, yMax )
	if util.IsIn2DBox( x1, x2, y1, y2, xMax, yMax ) and input.IsMouseDown( MOUSE_LEFT ) then
		return true
	else
		return false
	end
end

-- Saboteur functions

function Saboteur.GetSaboteur()
	return game.GetWorld() -- Temproary fix for a bug.
end

-- Net recievers
net.Receive( "SendRole", function()
	local role = net.ReadBit()
	hook.Add( "HUDPaint", "DrawGameInfo", function()
		draw.SimpleText( Saboteur.ActiveGame.Name, "ChatFont", ScrW() / 2, ScrH() / 2 - 10, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( Saboteur.ActiveGame.Desc, "ChatFont", ScrW() / 2, ScrH() / 2 + 10, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if role == TEAM_SABOTEUR then
			draw.SimpleText( "You are The Saboteur! Make sure your team fail at their task, but don't get spotted doing it.", "ChatFont", ScrW() / 2, ScrH() / 2 + 40, Color( 255, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end )
	timer.Simple( 5, function()
		hook.Remove( "HUDPaint", "DrawGameInfo" )
	end )
end )

net.Receive( "SendGameData", function()
	Saboteur.ActiveGame:OnGameData( net.ReadTable() )
end )

net.Receive( "SendGameResult", function()
	timer.Simple( 5, function()
		Saboteur.CleanUpMap()
		hook.Add( "CalcView", "SelctTraitor", function()
			local tab = {}
			tab.origin = Vector( -1245.733398 - ( ( #player.GetAll() + 1 ) / 2 * 100 ), -4252.423340, -192.468750 )
			tab.angles = Angle( 0, -90, 0 )
			tab.fov = 90
			tab.drawviewer = true
			return tab
		end )
		gui.EnableScreenClicker( true )
		hook.Add( "HUDPaint", "Test2", function()
			for k,v in pairs( player.GetAll() ) do
				draw.SimpleText( v:Nick(), "ChatFont", v:EyePos():ToScreen().x, v:EyePos():ToScreen().y - 20, Color( 255, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			draw.SimpleText( "Who was The Saboteur?", "ChatFont", ScrW() / 2, 250, Color( 255, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			for k,v in pairs( player.GetAll() ) do
				local pos = v:LocalToWorld( v:OBBMins() ):ToScreen()
				local pos2 = v:LocalToWorld( v:OBBMaxs() ):ToScreen()
				draw.RoundedBox( 0, pos.x, pos2.y, 100, 100, Color( 255, 0, 0 ) )
				if util.ClickIn2DBox( gui.MouseX(), pos.x, gui.MouseY(), pos.y, pos.x - pos2.x, pos.y - pos2.y ) then
					chat.AddText( v:Nick() )
				end
			end
		end )
	end )
end )