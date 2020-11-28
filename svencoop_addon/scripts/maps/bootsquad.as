#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "opfor/weapon_knife"
#include "opfor/nvision"
#include "beast/trigger_playerfreeze"

void MapInit()
{
	// Enable SC CheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	// Register original Opposing Force knife weapon
	RegisterKnife();
	RegisterTriggerPlayerFreezeEntity();

	// Enable Nightvision Support
	g_nv.MapInit();
	g_nv.SetNVColor( Vector(0, 255, 0) ); // Green Nightvision

	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
}
