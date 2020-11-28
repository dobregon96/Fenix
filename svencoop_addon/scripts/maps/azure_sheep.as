#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_multiple_mp"
#include "cubemath/player_respawn_zone_as"
#include "cubemath/func_wall_custom"
#include "azuresheep/monster_barniel"
#include "azuresheep/monster_kate"
#include "anggaranothing/trigger_sound"
#include "crouch_spawn"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	// Enable custom trigger zone scripts for Anti-Rush
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMultipleMpEntity();
	RegisterPlayerRespawnZoneASEntity();
	// Enable custom blocker entity script for Anti-Rush
	RegisterFuncWallCustomEntity();
	// Enable this fucking catastrophe
	RegisterTriggerSoundEntity();
	
	// Register these bitches
	barnielCustom::Register();
	kateCustom::Register();

	// Crouch Spawn
	array<string> CROUCH_MAPS = { "asmap01b","asmap03e","asmap04","asmap09b" };
    if( CROUCH_MAPS.find(g_Engine.mapname ) < 0 ){ g_crspawn.Disable(); }

	// Global CVars
	// Uncomment the line below if you want to disable monsterinfo on all maps
	//g_EngineFuncs.CVarSetFloat( "mp_allowmonsterinfo", 0 );
}

void MapStart()
{
	g_EngineFuncs.ServerPrint( "Azure Sheep SC Version 1.4 - Download this campaign at scmapdb.com\n" );
}
