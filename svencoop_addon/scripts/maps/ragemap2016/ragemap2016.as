#include "func_vehicle_fix"
#include "weapon_scientist"//Nero
#include "monster_blobturret"//Nero
#include "scipg_spawner"//Nero

void MapInit()
{
	g_Game.PrecacheModel( "sprites/explode1.spr" );//Nero
	g_Game.PrecacheModel( "sprites/spore_exp_01.spr" );//Nero
	g_Game.PrecacheModel( "sprites/spore_exp_c_01.spr" );//Nero
	g_Game.PrecacheModel( "sprites/WXplo1.spr" );//Nero
	g_Game.PrecacheModel( "models/ragemap2016/nero/turret_sentry.mdl" );//Nero
	g_Game.PrecacheModel( "models/custom_weapons/biorifle/w_biomass.mdl" );//Nero
	g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/bustflesh1.wav" );//Nero
	g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/bustflesh2.wav" );//Nero
	g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/biomass_exp.wav" );//Nero
	g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/biorifle_fire.wav" );//Nero
	g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/bustflesh1.wav" );//Nero
	g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/bustflesh2.wav" );//Nero
	g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/biomass_exp.wav" );//Nero
	g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/biorifle_fire.wav" );//Nero
		
	VehicleMapInit( true, true );
	RegisterSciPG();//Nero
	RegisterSciPGBolt();//Nero
	RegisterSciPGAmmoBox();//Nero
	RegisterBlobTurret();//Nero
	RegisterBiomass();//Nero
}