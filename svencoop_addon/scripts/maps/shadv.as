#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "cubemath/func_wall_custom"
#include "cubemath/player_respawn_zone_as"
#include "cubemath/player_hurt_zone"
#include "opfor/nvision"
#include "opfor/weapon_knife"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	// Enable custom trigger zone scripts for Anti-Rush
	RegisterTriggerOnceMpEntity();
	// Enable custom respawn zone script for Anti-Rush
	RegisterPlayerRespawnZoneASEntity();
	// Enable custom blocker entity script for Anti-Rush
	RegisterFuncWallCustomEntity();
	// Register original Opposing Force knife weapon
	RegisterPlayerHurtZoneEntity();
	RegisterKnife();

	// Enable Nightvision Support
	g_nv.MapInit();
	g_nv.SetNVColor( Vector(0, 255, 0) ); // Green Nightvision

	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}

void MapStart()
{
	// I can't be assed to go through each bsp and adding damage manually to every func_door just to prevent trolling- Outerbeast
    CBaseEntity@ pEntity = null;
    while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "func_door" ) ) !is null )
    { 
       if( pEntity.pev.dmg == 0.0f ){ pEntity.pev.dmg = 5000.0f; }
    }
}