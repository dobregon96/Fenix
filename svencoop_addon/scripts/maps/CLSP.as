// Counter-Life version of wiltOS modified
#include "counterlife/item_cash"
#include "counterlife/func_buystation"
#include "counterlife/BuyList" // BuyMenu
// Counter-Strike 1.6 Project - Author: KernCore
#include "cs16/weapons"
// Anti-Rush
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_multiple_mp"
#include "cubemath/func_wall_custom"
// HLSP
#include "point_checkpoint" // checkpoint
#include "hlsp/trigger_suitcheck" // custom trigger for hl_c01_a1

dictionary g_MonsterList;
int g_UniqueID = 0;

CScheduledFunction@ g_MonsterDropDosh = null;

class CLMonsterSave { 
	edict_t@ ent;
	float health;
	Vector lastpos, lastang;
};

array<string> arrsEntsNoDropDosh = {
	"monster_tripmine",
	"monster_babycrab",
	"monster_shockroach",
	"monster_sqknest",
	"monster_snark",
	"monster_satchel",
	"monster_rat",
	"monster_leech",
	"monster_cockroach",
	"monster_chumtoad",
	"monster_barnacle",
	"monster_miniturret",
	"monster_turret",
	"monster_sentry",
	"monster_scientist",
	"monster_barney",
	"monster_otis",
	"monster_barney_dead",
	"monster_hevsuit_dead",
	"monster_hgrunt_dead",
	"monster_otis_dead",
	"monster_scientist_dead",
	"monster_sitting_scientist"
};

array<string> arrsEntsToRemove = {
	"ammo_357",
	"ammo_556",
	"ammo_762",
	"ammo_9mmbox",
	"ammo_9mmAR",
	"ammo_mp5clip",
	"ammo_glockclip",
	"ammo_9mmclip",
	"ammo_argrenades",
	"ammo_buckshot",
	"ammo_crossbow",
	"ammo_gaussclip",
	"ammo_rpgclip",
	"ammo_spore",
	"ammo_sporeclip",
	"ammo_uziclip",
	"weapon_357",
	"weapon_9mmar",
	"weapon_mp5",
	"weapon_crossbow",
	"weapon_displacer",
	"weapon_eagle",
	"weapon_egon",
	"weapon_gauss",
	"weapon_grapple",
	"weapon_handgrenade",
	"weapon_hornetgun",
	"weapon_m16",
	"weapon_m249",
	"weapon_medkit",
	"weapon_minigun",
	"weapon_pipewrench",
	"weapon_rpg",
	"weapon_satchel",
	"weapon_shockrifle",
	"weapon_shotgun",
	"weapon_snark",
	"weapon_sniperrifle",
	"weapon_sporelauncher",
	"weapon_tripmine",
	"weapon_uzi",
	"weapon_uziakimbo",
	"weapon_shockrifle",
	"weapon_minigun",
	"weaponbox"
};

array<ItemMapping@> arrsItemMapping = {
	ItemMapping( "weapon_crowbar", "weapon_csknife" ),
	ItemMapping( "weapon_pipewrench", "weapon_csknife" ),
	ItemMapping( "weapon_grapple", "weapon_csknife" ),
	ItemMapping( "weapon_9mmhandgun", "weapon_usp" ),
	ItemMapping( "weapon_glock", "weapon_usp" ),
	ItemMapping( "weapon_357", "weapon_usp" ),
	ItemMapping( "weapon_python", "weapon_usp" ),
	ItemMapping( "weapon_eagle", "weapon_usp" ),
	ItemMapping( "weapon_uzi", "weapon_usp" ),
	ItemMapping( "weapon_uziakimbo", "weapon_usp" ),
	ItemMapping( "weapon_9mmAR", "weapon_usp" ),
	ItemMapping( "weapon_mp5", "weapon_usp" ),
	ItemMapping( "weapon_shotgun", "weapon_usp" ),
	ItemMapping( "weapon_crossbow", "weapon_usp" ),
	ItemMapping( "weapon_m16", "weapon_usp" ),
	ItemMapping( "weapon_rpg", "weapon_usp" ),
	ItemMapping( "weapon_egon", "weapon_usp" ),
	ItemMapping( "weapon_gauss", "weapon_usp" ),
	ItemMapping( "weapon_hornetgun", "weapon_usp" ),
	ItemMapping( "weapon_handgrenade", "weapon_hegrenade" ),
	ItemMapping( "weapon_satchel", "weapon_hegrenade" ),
	ItemMapping( "weapon_tripmine", "weapon_hegrenade" ),
	ItemMapping( "weapon_snark", "weapon_hegrenade" ),
	ItemMapping( "weapon_sniperrifle", "weapon_usp" ),
	ItemMapping( "weapon_sporelauncher", "weapon_usp" ),
	ItemMapping( "weapon_m249", "weapon_usp" ),
	ItemMapping( "weapon_displacer", "weapon_usp" ),
	ItemMapping( "weapon_shockrifle", "weapon_usp" ),
	ItemMapping( "weapon_minigun", "weapon_usp" ),
	ItemMapping( "ammo_357", "ammo_usp" ),
	ItemMapping( "ammo_556", "ammo_usp" ),
	ItemMapping( "ammo_762", "ammo_usp" ),
	ItemMapping( "ammo_9mmAR", "ammo_usp" ),
	ItemMapping( "ammo_mp5clip", "ammo_usp" ),
	ItemMapping( "ammo_9mmbox", "ammo_usp" ),
	ItemMapping( "ammo_9mmclip", "ammo_usp" ),
	ItemMapping( "ammo_glockclip", "ammo_usp" ),
	ItemMapping( "ammo_ARgrenades", "ammo_usp" ),
	ItemMapping( "ammo_buckshot", "ammo_usp" ),
	ItemMapping( "ammo_crossbow", "ammo_usp" ),
	ItemMapping( "ammo_gaussclip", "ammo_usp" ),
	ItemMapping( "ammo_rpgclip", "ammo_usp" ),
	ItemMapping( "ammo_spore", "ammo_usp" ),
	ItemMapping( "ammo_sporeclip", "ammo_usp" ),
	ItemMapping( "ammo_uziclip", "ammo_usp" ),
	ItemMapping( "ammo_556clip", "ammo_usp" ),
	ItemMapping( "ammo_9mmuziclip", "ammo_usp" )
};

void MapInit() {
	// Counter-Life Entities
	CL_CASH::Register();
	CL_BUYSTATION::Register();
	// Anti-Rush Stuff
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMultipleMpEntity();
	RegisterFuncWallCustomEntity();
	// point_checkpoint - trigger_suitcheck
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	// Hooks 
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
	g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @EntityCreated);
	g_Hooks.RegisterHook( Hooks::PickupObject::Materialize, @Materialize );
	// Item Mapping
	g_ClassicMode.SetItemMappings( @arrsItemMapping );
	g_ClassicMode.ForceItemRemap( true );
	// Think function
	@g_MonsterDropDosh = g_Scheduler.SetInterval( "DropDoshThink", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES);
	// Helper method to register all weapons
	RegisterAll();
	// Helper method to register all items buyables
	BuyableRegister();
	//Initializes hooks and precaches used by the Buy Menu Plugin
	BuyMenu::MoneyInit();
}

void MapActivate() {
	InitializeStarters();
	ReplaceSuit();
	ReplaceHealth();
	ReplaceItem();
}

void DropDoshThink() {
	array<string> m_Monsters = g_MonsterList.getKeys(); 
	for( uint uiIndex = 0; uiIndex < m_Monsters.length(); ++uiIndex ) {
		string szName = m_Monsters[ uiIndex ];
		CLMonsterSave data = cast<CLMonsterSave>( g_MonsterList[ szName ] );
		CBaseEntity@ pMonster = g_EntityFuncs.Instance( data.ent );
		if( pMonster is null ) {
			g_MonsterList.delete( szName );
		} else {
			if( pMonster.pev.deadflag >= DEAD_DYING ) {
				int iAmount = Math.RandomLong( 1, 3 );
				for( int i = 0; i < iAmount; i++ ) {
					Vector vecAiming = Vector( Math.RandomFloat( 0, 360 ), Math.RandomFloat( 0, 360 ), Math.RandomFloat( 0, 360 ) );
					CBaseEntity@ cash = g_EntityFuncs.Create( "item_cash", pMonster.pev.origin, Vector( 0, Math.RandomFloat( 0, 360 ), 0 ), false, null );
					Math.MakeVectors( vecAiming );
					cash.pev.velocity = vecAiming.Normalize() + g_Engine.v_forward * 210;
					if( cash !is null ) {
						g_EngineFuncs.DropToFloor( cash.edict() );
						cash.KeyValue("m_flCustomRespawnTime", "-1");
						cash.KeyValue("should_despawn", "1" );
					}
					g_MonsterList.delete( szName );
				}			
			}
			else {
				CLMonsterSave ndata;
				@ndata.ent = pMonster.edict();
				float nhealth = data.health;
				if( nhealth < pMonster.pev.health )
					nhealth = pMonster.pev.health;

				ndata.health = nhealth;
				ndata.lastpos = pMonster.pev.origin;
				ndata.lastang = pMonster.pev.angles;
				g_MonsterList[ szName ] = ndata;
			}
		}		
	}
}

void InitializeStarters() {
	CBaseEntity@ pMonster = g_EntityFuncs.FindEntityByClassname( null, "monster_*" );
	while( pMonster !is null ) {
		string szClass = pMonster.GetClassname();
		if( !( arrsEntsNoDropDosh.find( pMonster.GetClassname().ToLowercase() ) >= 0 ) ) {
			CLMonsterSave data;
			@data.ent = pMonster.edict();
			data.health = pMonster.pev.health;
			data.lastpos = pMonster.pev.origin;
			data.lastang = pMonster.pev.angles;
			g_MonsterList[ szClass + formatInt( g_UniqueID ) ] = data;
			g_UniqueID++;	
		}
		@pMonster = g_EntityFuncs.FindEntityByClassname( pMonster, "monster_*" );		
	}
}

void ReplaceSuit() {
	CBaseEntity@ pSuit = g_EntityFuncs.FindEntityByClassname( null, "func_recharge" );
	if( pSuit !is null ) {
		CBaseEntity@ pStation = g_EntityFuncs.Create( "func_buystation", pSuit.pev.origin, pSuit.pev.angles, false );
		if( pStation !is null ) {
			g_EntityFuncs.SetModel( pStation, pSuit.pev.model );
			g_EntityFuncs.Remove( pSuit );
			g_Scheduler.SetTimeout( "ReplaceSuit", 0.001 );
		}
	}
}

void ReplaceHealth() {
	CBaseEntity@ pHealth = g_EntityFuncs.FindEntityByClassname( null, "func_healthcharger" );
	if( pHealth !is null ) {
		CBaseEntity@ pStation = g_EntityFuncs.Create( "func_buystation", pHealth.pev.origin, pHealth.pev.angles, false );
		if( pStation !is null ) {
			g_EntityFuncs.SetModel( pStation, pHealth.pev.model );
			g_EntityFuncs.Remove( pHealth );
			g_Scheduler.SetTimeout( "ReplaceHealth", 0.001 );
		}
	}
}

void ReplaceItem() {
	CBaseEntity@ pItem = g_EntityFuncs.FindEntityByClassname( pItem, "*" );
	if( pItem !is null ) {
		if( arrsEntsToRemove.find( pItem.GetClassname().ToLowercase() ) >= 0 ) {
			CBaseEntity@ pDosh = g_EntityFuncs.Create( "item_cash", pItem.pev.origin, pItem.pev.angles, false );
			if( pDosh !is null ) {
				g_EntityFuncs.SetModel( pDosh, pItem.pev.model );
				g_EntityFuncs.Remove( pItem );
				g_Scheduler.SetTimeout( "ReplaceItem", 0.001 );
			}
		}
	}
}

HookReturnCode MapChange() {
	g_Scheduler.RemoveTimer( g_MonsterDropDosh );
	@g_MonsterDropDosh = null;
	
	g_MonsterList.deleteAll();

	return HOOK_CONTINUE;
}

HookReturnCode EntityCreated( CBaseEntity@ pMonster ) {
	string szClass = pMonster.GetClassname();
	if( szClass.Find( "monster_" ) != String::INVALID_INDEX ) {
		if( !( arrsEntsNoDropDosh.find( pMonster.GetClassname().ToLowercase() ) >= 0 ) ) {
			CLMonsterSave data;
			@data.ent = pMonster.edict();
			data.health = pMonster.pev.health;
			data.lastpos = pMonster.pev.origin;
			data.lastang = pMonster.pev.angles;
			g_MonsterList[ szClass + formatInt( g_UniqueID ) ] = data;
			g_UniqueID++;
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode Materialize( CBaseEntity@ pOldItem ) {
	if( pOldItem is null ) 
		return HOOK_CONTINUE;

	for( uint i = 0; i < arrsItemMapping.length(); ++i ) {
		if( pOldItem.GetClassname() == arrsItemMapping[i].get_From() ) {
			CBaseEntity@ pNewItem = g_EntityFuncs.Create( arrsItemMapping[i].get_To(), pOldItem.GetOrigin(), pOldItem.pev.angles, false );
			if( pNewItem is null ) 
				return HOOK_CONTINUE;

			pNewItem.pev.movetype = pOldItem.pev.movetype;

			if( pOldItem.GetTargetname() != "" )
				g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "targetname", pOldItem.GetTargetname() );

			if( pOldItem.pev.target != "" )
				g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "target", pOldItem.pev.target );

			if( pOldItem.pev.netname != "" )
				g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "netname", pOldItem.pev.netname );

			g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "m_flCustomRespawnTime", "-1" );
			g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "should_despawn", "1" );

			g_EntityFuncs.Remove( pOldItem );
		}
	}
	return HOOK_CONTINUE;
}
