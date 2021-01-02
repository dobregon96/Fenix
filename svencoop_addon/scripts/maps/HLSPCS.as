/*
* This script implements HLSP survival mode
*/

#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "hlsp/trigger_suitcheck"
#include "HLSPClassicMode"
#include "cs16/cs16register"

void MapInit()
{
	CS16MapInit();

	RegisterPointCheckPointEntity();
	RegisterTriggerOnceMpEntity();
	RegisterTriggerSuitcheckEntity();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
}
