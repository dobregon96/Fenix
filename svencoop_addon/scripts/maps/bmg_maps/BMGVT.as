
// This script implements script & entity specifically for bmg_* series


#include "point_checkpoint"

void MapInit()
{
	RegisterPointCheckPointEntity();
}

// Called via trigger_script

void ActivateSurvival ( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
{
    g_SurvivalMode.Activate();
}
