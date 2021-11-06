#include "beast/checkpoint_spawner"

#include "anti_rush"

#include "opfor/nvision"
#include "opfor/weapon_knife"

const bool blAntiRushEnabled = false; // You can change this to have AntiRush mode enabled or disabled

void MapInit()
{
	// Register original Opposing Force knife weapon
	RegisterKnife();
	// Enable Nightvision Support
	NightVision::Enable();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	ANTI_RUSH::EntityRegister( blAntiRushEnabled );
	RegisterCheckPointSpawnerEntity();
}
