AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local PLAYER = FindMetaTable( "Player" )

-- Networking
util.AddNetworkString( "SendGameResult" )
util.AddNetworkString( "SendVote" )
util.AddNetworkString( "SendRole" )

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