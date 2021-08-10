#include "monster_annie"
#include "monster_bear"
#include "monster_bigminer"
#include "monster_chicken"
#include "monster_cowboy"
#include "monster_crispen"
#include "monster_dyndave"
#include "monster_eagle" // Precache
#include "monster_horse"
#include "monster_hoss"
#include "monster_kaiewi"
#include "monster_masala"
#include "monster_mexbandit"
#include "monster_nagatow"
#include "monster_puma"
#include "monster_ramone"
#include "monster_smallminer"
#include "monster_snake"
#include "monster_tied_colonel"
#include "monster_townmex"
#include "monster_townwes"

void HLWanted_MonstersRegister()
{
	CTalkMonster talkmonster();
	@g_TalkMonster = @talkmonster;
	
	HLWanted_Annie::Register();
	HLWanted_Bear::Register();
	HLWanted_BigMiner::Register();
	HLWanted_Chicken::Register();
	HLWanted_ColonelTied::Register();
	HLWanted_Cowboy::Register();
	HLWanted_Crispen::Register();
	HLWanted_DynDave::Register();
	HLWanted_Eagle::Precache();
	HLWanted_Horse::Register();
	HLWanted_Hoss::Register();
	HLWanted_Kaiewi::Register();
	HLWanted_Masala::Register();
	HLWanted_MexBandit::Register();
	HLWanted_Nagatow::Register();
	HLWanted_Ramone::Register();
	HLWanted_Puma::Register();
	HLWanted_SmallMiner::Register();
	HLWanted_Snake::Register();
	HLWanted_TownMex::Register();
	HLWanted_TownWes::Register();
}
// Make ally npcs that restart the level when killed unkillable - Outerbeast
void AddNpcGodmode(string strNpcNames, int iMaxEntities = 128)
{
	if( strNpcNames == "" )
		return;

	array<string> STR_ALLY_NPCS = strNpcNames.Split( ";" );
	array<CBaseEntity@> P_ENTITIES( iMaxEntities );
	int iNumEntities = g_EntityFuncs.Instance( 0 ).FindMonstersInWorld( @P_ENTITIES, FL_MONSTER );

	if( iNumEntities > 0 )
	{
		for( uint i = 0; i < P_ENTITIES.length(); i++ )
		{
			if( P_ENTITIES[i] is null || !P_ENTITIES[i].IsMonster() || !P_ENTITIES[i].IsAlive() )
				continue;

			if( STR_ALLY_NPCS.find( P_ENTITIES[i].GetClassname() ) < 0 )
				continue;

			if( P_ENTITIES[i].GetTargetname() == "poorbarn" )
				continue;
				
			P_ENTITIES[i].pev.takedamage = DAMAGE_NO;
		}
	}
	// Not really necessary but might as well
	CBaseEntity@ pRestart;
	while( ( @pRestart = g_EntityFuncs.FindEntityByClassname( pRestart, "player_loadsaved" ) ) !is null )
		g_EntityFuncs.Remove( pRestart );

	P_ENTITIES.resize( 0 );
}
// ??? Is this even needed? Shoved this in here anyway - Outerbeast
void ManipulateEntities( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	// Increment Bear's health per player
	int iHealth;

	CBaseEntity@ pEntity = null;
	while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "monster_*")) !is null )
	{
		if( pEntity.pev.deadflag != DEAD_NO )
			continue;
		if( pEntity.pev.classname != "monster_bear" )
			continue;

		iHealth = CalcNewHealth( int( pEntity.pev.health ), 500 );
	}
}
// Apply full health for every even player count and half on odd player count
int CalcNewHealth( int iBaseHealth, int iPerPlayerInc, bool bEvenOddNum = false )
{
	bool bSurvival = false;

	if( g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive() )
		bSurvival = true;

	int iNumPlayers = 0;
	int iCalcNewHealth = 0;

	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;

		if( bSurvival )
		{
			if( !pPlayer.IsAlive() )
				continue;
		}

		iNumPlayers++;

		if( iNumPlayers == 1 )
			continue;

		if( bEvenOddNum )
		{
			if( iNumPlayers % 2 == 0 )
			{ // even number
				iCalcNewHealth += iPerPlayerInc;
			}
			else
			{ // odd number
				iCalcNewHealth += iPerPlayerInc / 2;
			}
		}
		else
			iCalcNewHealth += iPerPlayerInc;
	}

	return iBaseHealth + iCalcNewHealth;
}

CTalkMonster@ g_TalkMonster;

final class CTalkMonster
{
	int g_fMinerQuestion = 0; // true if an idle miner asked a question. Cleared when someone answers.

	float g_talkWaitTime = g_Engine.time;
}

class CBaseCustomMonster : ScriptBaseMonsterEntity
{
	int SF_MONSTER_GAG = 2;
	int SF_MONSTER_FADECORPSE = 512;

	Vector VecCheckToss( edict_t@& in pEdict, const Vector& in vecSpot1, Vector vecSpot2, const float flGravityAdj = 1.0 )
	{
		TraceResult	tr;
		Vector		vecMidPoint;// halfway point between Spot1 and Spot2
		Vector		vecApex;// highest point 
		Vector		vecScale;
		Vector		vecGrenadeVel;
		Vector		vecTemp;
		//float flGravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" ) * flGravityAdj;
		float flGravity = 800.0f * flGravityAdj;

		if( vecSpot2.z - vecSpot1.z > 500 )
			return g_vecZero; // to high, fail

		g_EngineFuncs.MakeVectors(pev.angles);

		// toss a little bit to the left or right, not right down on the enemy's bean (head). 
		vecSpot2 = vecSpot2 + g_Engine.v_right * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );
		vecSpot2 = vecSpot2 + g_Engine.v_forward * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );

		// calculate the midpoint and apex of the 'triangle'
		// UNDONE: normalize any Z position differences between spot1 and spot2 so that triangle is always RIGHT

		// How much time does it take to get there?

		// get a rough idea of how high it can be thrown
		vecMidPoint = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
		g_Utility.TraceLine(vecMidPoint, vecMidPoint + Vector(0,0,500), ignore_monsters, self.edict(), tr);
		vecMidPoint = tr.vecEndPos;
		// (subtract 15 so the grenade doesn't hit the ceiling)
		vecMidPoint.z -= 15;

		if( vecMidPoint.z < vecSpot1.z || vecMidPoint.z < vecSpot2.z )
			return g_vecZero; // to not enough space, fail

		// How high should the grenade travel to reach the apex
		float distance1 = (vecMidPoint.z - vecSpot1.z);
		float distance2 = (vecMidPoint.z - vecSpot2.z);

		// How long will it take for the grenade to travel this distance
		float time1 = sqrt( distance1 / (0.5 * flGravity) );
		float time2 = sqrt( distance2 / (0.5 * flGravity) );

		if( time1 < 0.1 )
			return g_vecZero; // too close

		// how hard to throw sideways to get there in time.
		vecGrenadeVel = (vecSpot2 - vecSpot1) / (time1 + time2);
		// how hard upwards to reach the apex at the right time.
		vecGrenadeVel.z = flGravity * time1;

		// find the apex
		vecApex  = vecSpot1 + vecGrenadeVel * time1;
		vecApex.z = vecMidPoint.z;

		g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, self.edict(), tr);
		if (tr.flFraction != 1.0)
			return g_vecZero; // fail!

		// UNDONE: either ignore monsters or change it to not care if we hit our enemy
		g_Utility.TraceLine(vecSpot2, vecApex, ignore_monsters, self.edict(), tr); 
		if (tr.flFraction != 1.0)
			return g_vecZero; // fail!

		return vecGrenadeVel;
	}

	Vector VecCheckThrow( edict_t@& in pEdict, const Vector& in vecSpot1, Vector vecSpot2, const float flSpeed, const float flGravityAdj = 1.0 )
	{
		//float flGravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" ) * flGravityAdj;
		float flGravity = 800.0f * flGravityAdj;

		Vector vecGrenadeVel = (vecSpot2 - vecSpot1);

		// throw at a constant time
		float time = vecGrenadeVel.Length( ) / flSpeed;
		vecGrenadeVel = vecGrenadeVel * (1.0 / time);

		// adjust upward toss to compensate for gravity loss
		vecGrenadeVel.z += flGravity * time * 0.5;

		Vector vecApex = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
		vecApex.z += 0.5 * flGravity * (time * 0.5) * (time * 0.5);

		TraceResult tr;
		g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, pEdict, tr);
		if (tr.flFraction != 1.0)
				return g_vecZero; // fail!

		g_Utility.TraceLine(vecSpot2, vecApex, ignore_monsters, pEdict, tr);
		if (tr.flFraction != 1.0)
				return g_vecZero; // fail!

		return vecGrenadeVel;
	}
}