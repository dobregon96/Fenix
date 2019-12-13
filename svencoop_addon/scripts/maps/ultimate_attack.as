/*
* |====================================================================|
* | HALF LIFE: ULTIMATE ATTACK MAP SCRIPT                              |
* | Author: Neo (SC, Discord),  Version 1.22, September, 27th 2019     |
* |====================================================================|
* |This plugin enables SC Point CheckPoint,BlkOps NightVision view mode|
* |and Crouch Spawn support.                                           |
* |====================================================================|
* |Usage of Survival Mode, BLKOPS NightVision and Crouch Spawn support:|
* |--------------------------------------------------------------------|
* |Survival mode must be activated over map/server config.             |
* |OF NightVision view mode must be initiated and replaces Flash Light |
* |Crouch Spawn support must be initiated on MapInit, if needed for map|
* |====================================================================|
*/

#include "point_checkpoint"
#include "blkopsnvision"
#include "crouch_spawn"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();

	// Enable OF Nightvision Support
	g_NightVision.OnMapInit();
	
    // CROUCH SPAWN Support (only in map ss2a1)
    if(g_Engine.mapname != "ss2a1")
        g_crspawn.Disable(); // Disable, if not needed, because its enabled by default
}