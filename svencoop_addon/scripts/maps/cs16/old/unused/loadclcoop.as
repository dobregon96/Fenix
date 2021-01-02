//#include "ShopMenu"
#include "item_cash"
#include "item_kevlar"
#include "func_buystation"
#include "buymenu1"
#include "whitelist"
#include "blacklist"


dictionary g_CLInitialized;
dictionary g_CLShouldRemoveMoney;
dictionary g_CLMonsterList;

CScheduledFunction@ g_pCLThink = null;
CScheduledFunction@ g_pCLMoneyMonster = null;

int g_TotalStations = 0;
int g_CLUniqueID = 0;
int g_CLScale = 1;
bool g_CLSharedCash = true;

class CLMonsterSave
{ 
	edict_t@ ent;
	float health;
	Vector lastpos, lastang;
};

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "wiltOS Technologies" );
	g_Module.ScriptInfo.SetContactInfo( "www.wiltostech.com" );
	
	LoadBuyMenu();
	
}

void RemovalThink()
{
	ReplaceEntities( "weapon_*", "item_cash" );
	ReplaceEntities( "ammo_*", "item_cash" );	
	ReplaceEntities( "item_battery", "item_kevlar" );
}

void DropCashThink()
{
	array<string> m_Monsters = g_CLMonsterList.getKeys(); 
	for( uint uiIndex = 0; uiIndex < m_Monsters.length(); ++uiIndex )
	{
		string szName = m_Monsters[ uiIndex ];
		CLMonsterSave data = cast<CLMonsterSave>( g_CLMonsterList[ szName ] );
		CBaseEntity@ pMonster = g_EntityFuncs.Instance( data.ent );
		if( pMonster is null )
		{
			g_CLMonsterList.delete( szName );
		}
		else
		{
			if( pMonster.pev.deadflag >= DEAD_DYING )
			{
				CBaseEntity@ cash = g_EntityFuncs.Create( "item_cash", pMonster.pev.origin, pMonster.pev.angles, false );
				if( cash !is null )
				{
					int val = int( data.health * g_CLScale );
					g_EngineFuncs.DropToFloor( cash.edict() );
					cash.KeyValue("m_flCustomRespawnTime", "-1");
					cash.KeyValue("value", formatInt( val ) );
					cash.KeyValue("should_despawn", "1" );
				}
				g_CLMonsterList.delete( szName );			
			}
			else
			{
				CLMonsterSave ndata;
				@ndata.ent = pMonster.edict();
				float nhealth = data.health;
				if( nhealth < pMonster.pev.health )
				{
					nhealth = pMonster.pev.health;
				}
				ndata.health = nhealth;
				ndata.lastpos = pMonster.pev.origin;
				ndata.lastang = pMonster.pev.angles;
				g_CLMonsterList[ szName ] = ndata;
			}
		}
		//g_Game.AlertMessage( at_console, "LOOPED AND GOT THIS BAD BOY: %1\n", data.ent.GetClassname() );		
	}
}

void MapInit()
{
	CLCash::RegisterCashEntity();
	g_Game.PrecacheOther( "item_cash" );
	
	CLKevlar::RegisterKevlarEntity();
	g_Game.PrecacheOther( "item_kevlar" );
	
	CLBuyStation::RegisterBuystation();
	g_Game.PrecacheOther( "func_buystation" );	
	
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
	g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange); 
	g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @EntityCreated);
	
	@g_pCLThink = g_Scheduler.SetInterval( "RemovalThink", 0.001 );
	@g_pCLMoneyMonster = g_Scheduler.SetInterval( "DropCashThink", 0.001 );
	


}

void MapActivate()
{
	InitializeStarters();
	ReplaceSuit();
	ReplaceHealth();
}

string HandleClass( string oldclass )
{
	if( oldclass == "weapon_crowbar" )
	{
		return "weapon_csknife"; 	
	}
	else if( oldclass == "weapon_pipewrench" )
	{
		return "weapon_csknife"; 	
	}
	else if( oldclass == "weapon_9mmhandgun" )
	{
		return "weapon_usp";
	}
	else if( oldclass == "weapon_eagle" )
	{
		return "weapon_csdeagle";
	}
	else if( oldclass == "weapon_handgrenade" )
	{
		return "weapon_hegrenade";
	}
	else
	{
		return oldclass;
	}
}

void ReplaceEntities( string szOldClass, string szNewClass )
{
	CBaseEntity@ weapon = g_EntityFuncs.FindEntityByClassname( null, szOldClass );
	while( weapon !is null )
	{
		CustomKeyvalues@ pCustom = weapon.GetCustomKeyvalues();
		bool fExists = pCustom.HasKeyvalue( "$i_CLReplaced" );
		
		bool fPlayerOwner = false;
		if( weapon.pev.owner !is null )
		{
			CBaseEntity@ pOwner = g_EntityFuncs.Instance( weapon.pev.owner );
			if( pOwner !is null )
			{
				fPlayerOwner = pOwner.IsPlayer();
			}
		}
		
		if( ShouldIgnore( weapon.GetClassname() ) || fExists || fPlayerOwner )
		{
			@weapon = g_EntityFuncs.FindEntityByClassname( weapon, szOldClass );			
			continue;
		}
		string szCNewClass = HandleClass( weapon.GetClassname() );
		bool fRespawn = true;
		if( szCNewClass == weapon.GetClassname() ){
			szCNewClass = szNewClass;
			fRespawn = false;
		}
		Vector origin = weapon.pev.origin;
		Vector angles = weapon.pev.angles;
		g_EntityFuncs.Remove( weapon );
		CBaseEntity@ cash = g_EntityFuncs.Create( szCNewClass, origin, angles, false );
		if( cash !is null )
		{
			g_EngineFuncs.DropToFloor( cash.edict() );
			CustomKeyvalues@ cCustom = cash.GetCustomKeyvalues();
			if( !fRespawn )
			{
				cash.KeyValue("m_flCustomRespawnTime", "-1");
			}
			cCustom.SetKeyvalue( "$i_CLReplaced", 1 );
			@weapon = g_EntityFuncs.FindEntityByClassname( cash, szOldClass );
		}
	}
}

void ReplaceHealth()
{
	CBaseEntity@ weapon = g_EntityFuncs.FindEntityByClassname( null, "func_healthcharger" );
	if( weapon !is null ){
		CBaseEntity@ cash = g_EntityFuncs.Create("func_buystation", weapon.pev.origin, weapon.pev.angles, false );
		if( cash !is null ){
			g_EntityFuncs.SetModel( cash, weapon.pev.model );
			g_EntityFuncs.Remove( weapon );
			g_TotalStations++;
			g_Scheduler.SetTimeout( "ReplaceHealth", 0.001 );
		}
	}
}

void ReplaceSuit()
{
	CBaseEntity@ weapon = g_EntityFuncs.FindEntityByClassname( null, "func_recharge" );
	if( weapon !is null ){
		CBaseEntity@ cash = g_EntityFuncs.Create("func_buystation", weapon.pev.origin, weapon.pev.angles, false );
		if( cash !is null ){
			g_EntityFuncs.SetModel( cash, weapon.pev.model );
			g_EntityFuncs.Remove( weapon );
			g_TotalStations++;
			g_Scheduler.SetTimeout( "ReplaceSuit", 0.001 );
		}
	}
}

void InitializeStarters()
{
	CBaseEntity@ pMonster = g_EntityFuncs.FindEntityByClassname( null, "monster_*" );
	while( pMonster !is null ){
		string szClass = pMonster.GetClassname();
		if( !ShouldNotDrop( szClass ) )
		{
			CLMonsterSave data;
			@data.ent = pMonster.edict();
			data.health = pMonster.pev.health;
			data.lastpos = pMonster.pev.origin;
			data.lastang = pMonster.pev.angles;
			g_CLMonsterList[ szClass + formatInt( g_CLUniqueID ) ] = data;
			g_CLUniqueID++;	
		}
		@pMonster = g_EntityFuncs.FindEntityByClassname( pMonster, "monster_*" );
	}
}

void ShowPlayerAlert( edict_t@ pInstance )
{
	CBasePlayer@ pPlayer = cast< CBasePlayer@ >(g_EntityFuncs.Instance( pInstance ));
	if( g_TotalStations > 0 ){
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] Mobile Buy Station is disabled on this map. Go to HEV/Medical stations for equipment.");			
	}
	else
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] Mobile Buy Station is enabled on this map. Type \"!buymenu\" to access it.");		
	}
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if( !g_CLInitialized.exists( szSteamId ) ){
		pPlayer.pev.frags = 800;
		g_CLInitialized[ szSteamId ] = true;
		g_Scheduler.SetTimeout( "ShowPlayerAlert", 5, null, pPlayer.edict() );
	}
	
	if( g_CLShouldRemoveMoney.exists( szSteamId ) )
	{
		if( pPlayer.pev.frags >= 2 ){
			pPlayer.pev.frags = Math.Ceil( pPlayer.pev.frags*0.66 ) + 1;
			g_CLShouldRemoveMoney.delete( szSteamId );
		}
	}

	bool fGivePistol = false;
	for( uint i = 0; i < MAX_ITEM_TYPES; i++ )
	{
		if( pPlayer.m_rgpPlayerItems(i) !is null )
		{
			CBasePlayerItem@ pPlayerItem = pPlayer.m_rgpPlayerItems(i);

			while( pPlayerItem !is null )
			{
				CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayerItem );
				bool fShouldIgnore = ShouldIgnore( pWeapon.GetClassname() );
				if( !fShouldIgnore )
				{
					string szNWClass = HandleClass( pWeapon.GetClassname() );
					if( szNWClass != "weapon_medkit" || szNWClass != "weapon_crowbar" )
					{
						fGivePistol = true;
					}
					if( szNWClass != pWeapon.GetClassname() )
					{
						pPlayer.GiveNamedItem( szNWClass );				
					}
					g_EntityFuncs.Remove( pWeapon );
				}
				@pPlayerItem = cast<CBasePlayerItem@>( pPlayerItem.m_hNextItem.GetEntity() );
			}
		}
	}
	if( fGivePistol )
	{
		pPlayer.GiveNamedItem( "weapon_usp" );				
	}
	
	return HOOK_HANDLED;
}

HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib){
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	g_CLShouldRemoveMoney[ szSteamId ] = true;
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	g_CLInitialized.delete( szSteamId );
	g_CLShouldRemoveMoney.delete( szSteamId );
	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	g_Scheduler.RemoveTimer( g_pCLThink );
	@g_pCLThink = null;
	
	g_Scheduler.RemoveTimer( g_pCLMoneyMonster );	
	@g_pCLMoneyMonster = null;
	

	g_TotalStations = 0;
	g_CLInitialized.deleteAll();
	g_CLShouldRemoveMoney.deleteAll();
	g_CLUniqueID = 0;	
	g_CLMonsterList.deleteAll();
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if( args.ArgC() == 1 && ( args.Arg(0) == "!buymenu" || args.Arg(0) == "/buymenu" ) )
	{
		pParams.ShouldHide = true;
		if( g_TotalStations > 0 ){
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] Buy Stations available on this map. Go to one to buy your equipment!");			
		}
		else
		{
			openMainMenu( pPlayer );		
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode EntityCreated( CBaseEntity@ pMonster )
{
	string szClass = pMonster.GetClassname();
	if( szClass.Find( "monster_" ) != String::INVALID_INDEX )
	{
		if( !ShouldNotDrop( szClass ) )
		{
			CLMonsterSave data;
			@data.ent = pMonster.edict();
			data.health = pMonster.pev.health;
			data.lastpos = pMonster.pev.origin;
			data.lastang = pMonster.pev.angles;
			g_CLMonsterList[ szClass + formatInt( g_CLUniqueID ) ] = data;
			g_CLUniqueID++;
		}
	}
	return HOOK_CONTINUE;
}
