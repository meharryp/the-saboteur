Saboteur = {}

-- These aren't actually teams, they are just numbers representing who wins. 
-- If we did assign people to teams dirty hackers would be able to figure out who is who easily.
TEAM_PLAYERS = 0
TEAM_SABOTEUR = 1

-- Gamemode functions
function GM:PlayerNoClip()
	return false -- For some reason on a listen server this has to be done, but on a dedi it works without this. Leaving it in regardless.
end

-- Saboteur functions
-- Main round logic
function Saboteur.StartGame( sGame ) -- Maybe games should be loaded with the gamemode? Look in to this.
	game.CleanUpMap()
	GAME = {}

	if SERVER then
		AddCSLuaFile( "the-saboteur/gamemode/games/" .. sGame .. ".lua" )
	end

	include( "the-saboteur/gamemode/games/" .. sGame .. ".lua" )

	Saboteur.ActiveGame = GAME

	if SERVER then
		local saboteur = math.random( 1, #player.GetAll() )
		for k,v in pairs( player.GetAll() ) do
			if k == saboteur then
				v:SetRole( TEAM_SABOTEUR )
			else
				v:SetRole( TEAM_PLAYERs )
			end

			net.Start( "SendRole" )
			net.WriteBit( v:GetRole() )
			net.Send( v )

			v:Spawn()
			v:Freeze( true )
		end
	end

	timer.Simple( 5, function()
		if SERVER then
			for k,v in pairs( player.GetAll() ) do
				v:Freeze( false )
			end
		end
		Saboteur.ActiveGame:Start( Saboteur.GetSaboteur() )
	end )
end