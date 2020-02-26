#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "cubemath/func_wall_custom"
#include "crouch_spawn"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	// Enable custom trigger zone script for Anti-Rush
	RegisterTriggerOnceMpEntity();
	// Enable custom blocker entity script for Anti-Rush
	RegisterFuncWallCustomEntity();
		
	//Cvars, easier to put them here than in all of the map cfgs individually to save time
	g_EngineFuncs.CVarSetFloat( "skill", 2 );
}