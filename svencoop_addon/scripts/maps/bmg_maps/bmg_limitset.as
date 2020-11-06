#include "bmg_maps/bmg_limitcore"

//Test the ammo mod code
void MapInit()
{
	AmmoMod::AmmoMod@ pAmmoMod = AmmoMod::AmmoMod();
	
	@AmmoMod::g_ActiveAmmoMod = @pAmmoMod;
	
	pAmmoMod.AmmoCounts[ "9mm" ] = 150;
	
	pAmmoMod.AmmoCounts[ "buckshot" ] = 64;
	
	pAmmoMod.AmmoCounts[ "357" ] = 18;
	
	pAmmoMod.AmmoCounts[ "bolts" ] = 10;
	
	pAmmoMod.AmmoCounts[ "556" ] = 300;
	
	pAmmoMod.AmmoCounts[ "ARgrenades" ] = 3;
	
	pAmmoMod.AmmoCounts[ "rockets" ] = 5;
	
	pAmmoMod.AmmoCounts[ "uranium" ] = 100;
	
	pAmmoMod.AmmoCounts[ "Hand Grenade" ] = 10;
	
	pAmmoMod.AmmoCounts[ "Snarks" ] = 10;
	
	pAmmoMod.AmmoCounts[ "m40a1" ] = 15;
	
	pAmmoMod.AmmoCounts[ "Satchel Charge" ] = 5;
	
	pAmmoMod.AmmoCounts[ "Trip Mine" ] = 5;
	
	pAmmoMod.AmmoCounts[ "sporeclip" ] = 24;
}