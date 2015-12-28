include( "shared.lua" )

-- Gamemode functions


-- Saboteur functions

function Saboteur.GetSaboteur()
	return game.GetWorld() -- Temproary fix for a bug.
end

-- Net recievers
net.Receive( "SendRole", function()
	local role = net.ReadBit()
	hook.Add( "HUDPaint", "DrawGameInfo", function()
		draw.SimpleText( Saboteur.ActiveGame.Name, "ChatText", ScrW() / 2, ScrH() / 2 - 10, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( Saboteur.ActiveGame.Desc, "ChatText", ScrW() / 2, ScrH() / 2 + 10, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if role == TEAM_SABOTEUR then
			draw.SimpleText( "You are The Saboteur! Make sure your team fail at their task, but don't get spotted doing it.", "ChatText", ScrW() / 2, ScrH() / 2 + 10, Color( 255, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end )
	timer.Simple( 5, function()
		hook.Remove( "HUDPaint", "DrawGameInfo" )
	end )
end )