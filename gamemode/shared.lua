Saboteur = Saboteur or {}

-- These aren't actually teams, they are just numbers representing who wins. 
-- If we did assign people to teams dirty hackers would be able to figure out who is who easily.
TEAM_PLAYERS = 0
TEAM_SABOTEUR = 1

-- Gamemode functions
function GM:PlayerNoClip()
	return true -- For some reason on a listen server this has to be done, but on a dedi it works without this. Leaving it in regardless.
end

function GM:ShouldCollide( ent1, ent2 )
	if IsValid( ent1 ) and IsValid( ent2 ) and ent1:IsPlayer() and ent2:IsPlayer() then
		return false
	else
		return true
	end
end

-- Saboteur functions

function Saboteur.GetName( team ) -- I don't want to have to write this if statement every time I want to show the name of who won.
	if team == TEAM_PLAYERS then
		return "Players"
	else
		return "The Saboteur"
	end
end

-- Main round logic
function Saboteur.StartGame( sGame ) -- Maybe games should be loaded with the gamemode? Look in to this.
	game.CleanUpMap()
	GAME = {}

	if SERVER then
		AddCSLuaFile( "the-saboteur/gamemode/games/" .. sGame .. ".lua" )
	end

	include( "the-saboteur/gamemode/games/" .. sGame .. ".lua" )

	Saboteur.ActiveGame = table.Copy( GAME )

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

function Saboteur.CleanUpMap()
	if SERVER then
		for k,v in pairs( Saboteur.ActiveEnts ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
		Saboteur.ActiveEnts = {}

		game.CleanUpMap()
	end

	for k,v in pairs( Saboteur.ActiveHooks ) do
		hook.Remove( v[ 1 ], v[ 2 ] )
	end
	Saboteur.ActiveHooks = {}

	for k,v in pairs( Saboteur.ActiveTimers ) do
		timer.Remove( v )
	end
	Saboteur.ActiveTimes = {}
end

-- Overwritten functions
-- These functions are here to assist in making games easier to create.
-- To create a persistent prop, hook or timer you should use the Saboteur.* functions.

Saboteur.AddHook = Saboteur.AddHook or hook.Add
Saboteur.CreateTimer = Saboteur.CreateTimer or timer.Create

Saboteur.ActiveHooks = Saboteur.ActiveHooks or {}
Saboteur.ActiveTimers = Saboteur.ActiveTimers or {}

function hook.Add( gHook, name, func )
	table.insert( Saboteur.ActiveHooks, { hook, name } )
	Saboteur.AddHook( gHook, name, func )
end

function timer.Create( name, time, reps, func )
	table.insert( Saboteur.ActiveTimers, name )
	Saboteur.CreateTimer( name, time, reps, func )
end