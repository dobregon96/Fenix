#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "cubemath/func_wall_custom"
#include "crouch_spawn"
#include "azuresheep/monster_barniel_custom"
#include "azuresheep/monster_kate_custom"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	// Enable custom trigger zone script for Anti-Rush
	RegisterTriggerOnceMpEntity();
	// Enable custom blocker entity script for Anti-Rush
	RegisterFuncWallCustomEntity();
	
	// Register Custom NPCS
	barnielCustom::Register();
	kateCustom::Register();
}