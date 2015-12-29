AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local PLAYER = FindMetaTable( "Player" )

-- Networking
util.AddNetworkString( "SendGameResult" )
util.AddNetworkString( "SendVote" )
util.AddNetworkString( "SendRole" )
util.AddNetworkString( "SendGameData" ) -- Generic data sending net message to clients

-- Gamemode functions
function GM:PlayerSpawn( ply )
	ply:GodEnable( true ) -- Players can't die by default.
	self.BaseClass:PlayerSpawn( ply )
end

function GM:PlayerSetModel( ply ) -- Playtest this, it might be better to go the TTT route.
	ply:SetModel( player_manager.TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) ) )
end

-- Saboteur functions
function Saboteur.GameEnd( team )
	net.Start( "SendGameResult" )
	net.WriteBit( team ) -- If we really wanted we could net.ReadBool clientside.
	net.Broadcast()
	PrintMessage( HUD_PRINTTALK, Saboteur.GetName( team ) .. " has won!" )
	timer.Simple( 5, function()
		Saboteur.CleanUpMap()
		for k,v in pairs( player.GetAll() ) do
			v:SetPos( Vector( -1245.733398 - ( k * 100 ), -4552.468750, -192.468750 ) )
			v:SetEyeAngles( Angle( 0, 90, 0 ) )
			v:StripWeapons()
			v:Freeze( true )
		end
	end )
end

function Saboteur.GetSaboteur()
	for k,v in pairs( player.GetAll() ) do
		if v:IsSaboteur() then return v end
	end
end

-- Net recievers


-- Meta functions
-- Only network the roles to players that need them, so people can't cheat.
function PLAYER:SetRole( role )
	self.Role = role
end

function PLAYER:GetRole() -- These functions can be made redundant by just getting/setting Player.Role but it makes the code look nicer.
	return self.Role
end

function PLAYER:IsSaboteur()
	return self.Role == 1
end

-- Calls GAME:OnGameData( tab ) clientside. Only use when a game is active.
function PLAYER:SendGameData( ... ) -- There needs to be a better way of doing this, look into it.
	net.Start( "SendGameData" )
	net.WriteTable( { ... } )
	net.Send( self )
end

-- Overwritten functions
-- These functions are here to assist in making games easier to create.
-- To create a persistent prop, hook or timer you should use the Saboteur.* functions.

Saboteur.CreateEnt = Saboteur.CreateEnt or ents.Create
Saboteur.ActiveEnts = Saboteur.ActiveEnts or {}

function ents.Create( ent )
	local sEnt = Saboteur.CreateEnt( ent )
	table.insert( Saboteur.ActiveEnts, sEnt )
	return sEnt
end