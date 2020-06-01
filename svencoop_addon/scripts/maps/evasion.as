#include "point_checkpoint"
#include "cubemath/player_respawn_zone_as"
#include "opfor/weapon_knife"
#include "opfor/nvision"
#include "crouch_spawn"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	RegisterPlayerRespawnZoneASEntity();
	// Register Opposing Force knife weapon
	RegisterKnife();
	
	// Enable Nightvision Support
	g_nv.MapInit();
	g_nv.SetNVColor( Vector(0, 255, 0) );// Green Nightvision
	
	array<string> map_names = {"evasion3", "evasion5"};
    if(map_names.find(g_Engine.mapname) < 0)
	    g_crspawn.Disable(); // Disable, if not needed, because its enabled by default
		
	//Cvars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}


