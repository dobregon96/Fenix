#include "func_vehicle_fix"
#include "weapon_gluongun"
#include "weapon_scientist"//Nero
#include "weapon_redeemer"//Nero
#include "weapon_rg6"//Nero
#include "weapon_biorifle"//Nero
#include "monster_blobturret2"//Nero
#include "weapon_rcshotgun"//Nero

void MapInit()
{
	VehicleMapInit( true, true );
	g_Game.PrecacheModel( "models/ragemap2016/nero/turret_sentry.mdl" );//Nero

	RegisterGluonGun();
	RegisterGluon();
	RegisterGluonAmmo();
	
	RegisterSciPG();//Nero
	RegisterSciPGBolt();//Nero
	RegisterSciPGAmmoBox();//Nero
	RegisterBlobTurret2();//Nero
	RegisterBiorifle();//Nero
	RegisterBiomass();//Nero
	RegisterBRAmmoBox();//Nero
	RegisterRedeemer();//Nero
	RegisterNuke();//Nero
	RegisterNukeAmmoBox();//Nero
	RegisterRG6();//Nero
	RegisterGP25Grenade();//Nero
	RegisterRG6AmmoBox();//Nero
	RegisterRCShotgun();//Nero
	RegisterRCShotgunScientist();//Nero
	RegisterRCShotgunRocket();//Nero
}