#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "HLSPClassicMode"
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_mediaplayer"
//#include "ofnvision"
#include "crouch_spawn"
void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMediaPlayerEntity();
	//g_nv.MapInit();
	g_crspawn.Enable();
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
}
