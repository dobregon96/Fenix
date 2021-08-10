#include "../beast/player_blocker"
#include "../beast/playsound_individual"

#include "nvision"

#include "items/item_elixer"
#include "items/item_herbs"
#include "items/item_telegram"

#include "monsters/basemonster"
#include "weapons/baseweapon"

// Set this to false if you want to let key npcs become mortal (at risk of level restarts)
bool blAllyNpcGodmode = true;

void MapInit()
{
	HLWanted_WeaponsRegister();
	HLWanted_MonstersRegister();

	HLWanted_Elixer::Register();
	HLWanted_Herbs::Register();
	HLWanted_Telegram::Register();
	// Nightvision, but configured to emulate a lantern effect
	NightVision::iRadius = 16;
	NightVision::iBrightness = 16;
	NightVision::iPosition = NightVision::CENTER;
	NightVision::szSndFLight = "wanted/items/flashlight1.wav";
	NightVision::szSndHudNV = "wanted/items/flashlight1.wav";
	NightVision::Enable( Vector( 128, 128, 128 ) ); // Init and set color

	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_banana", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_npckill", 2 );
}

void MapStart()
{
	PLAYSOUND_INDIVIDUAL::PatchAmbientGeneric(); // Patch the Sheriff's voice lines only audible to player only

	if( blAllyNpcGodmode )
		AddNpcGodmode( "monster_barney;monster_scientist" );
}
