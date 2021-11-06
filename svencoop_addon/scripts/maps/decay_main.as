#include "anti_rush"

#include "beast/checkpoint_spawner"
#include "beast/game_players_alive"
#include "beast/env_light"
#include "beast/game_hudsprite"
#include "beast/player_blocker"

#include "decay/info_cheathelper"
#include "decay/item_healthcharger"
#include "decay/item_recharge"
#include "decay/item_eyescanner"
#include "decay/monster_alienflyer"
#include "decay/weapon_slave"

bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled

void MapInit()
{
	RegisterCheckPointSpawnerEntity();
	RegisterGameHudSpriteEntity();
	RegisterEnvLightEntity();

	RegisterItemRechargeCustomEntity();
	RegisterItemHealthCustomEntity();
    RegisterItemEyeScannerEntity();
	RegisterInfoCheathelperCustomEntity();
	RegisterAlienflyer();

	if( g_Engine.mapname == "dy_alien" )
	{
		RegisterWeaponIslave();
		g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
	}

	ANTI_RUSH::RemoveEntities = "models/cubemath/*;percent_lock*;blocker_wall*";
	ANTI_RUSH::EntityRegister( blAntiRushEnabled );

	g_EngineFuncs.CVarSetFloat( "mp_npckill", 2 );

	g_EngineFuncs.ServerPrint( "Half-Life: Decay Version 1.7 - Download this campaign from scmapdb.com\n" );
}
