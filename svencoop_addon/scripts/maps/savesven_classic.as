/*
* This script implements HL classic weapons
*/
#include "hl_weapons/weapon_hlmp5"
#include "hl_weapons/weapon_hlshotgun"

array<ItemMapping@> g_ItemMappings = { ItemMapping( "weapon_9mmAR", GetHLMP5Name() ), ItemMapping( "weapon_shotgun", GetHLShotgunName() ), ItemMapping( "weapon_m16", GetHLMP5Name() ) };

void MapInit()
{
	RegisterHLMP5();
	RegisterHLShotgun();
}
