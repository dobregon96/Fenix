// SCREAMING SCIENTIST

void SciS_Init( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	CBaseEntity@ pMonster = g_EntityFuncs.FindEntityByTargetname( null, "giegue_the_sci" );
	CBaseEntity@ pSound = g_EntityFuncs.FindEntityByTargetname( null, "giegue_scream_snd" );
	CBaseEntity@ pSequence = g_EntityFuncs.FindEntityByTargetname( null, "giegue_thesequence" );
	
	if ( pMonster is null || pSound is null || pSequence is null )
	{
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* One or more entities required for this area couldn't be found\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* You don't ripent with the ripent or you'll make mess like this\n" );
		g_EntityFuncs.FireTargets( "giegue_sci_end_mm", null, null, USE_TOGGLE, 0.0f, 5.0f );
	}
	else
	{
		g_EntityFuncs.FireTargets( "giegue_scream_snd", null, null, USE_TOGGLE, 0.0f, 0.0f );
		
		pMonster.pev.solid = SOLID_NOT;
		pMonster.pev.movetype = MOVETYPE_NOCLIP;
		
		Vector vecOrigin = pMonster.pev.origin;
		vecOrigin.z += 16;
		g_EntityFuncs.SetOrigin( pMonster, vecOrigin );
		
		pMonster.pev.avelocity.x = Math.RandomFloat( -999, 999 );
		pMonster.pev.avelocity.y = Math.RandomFloat( -999, 999 );
		pMonster.pev.avelocity.z = Math.RandomFloat( -999, 999 );
		
		g_Scheduler.SetTimeout( "SciS_Phase2", 4.5 );
	}
}

void SciS_Phase2()
{
	CBaseEntity@ pMonster = g_EntityFuncs.FindEntityByTargetname( null, "giegue_the_sci" );
	
	pMonster.pev.angles.x = 0.0;
	pMonster.pev.angles.y = 0.0;
	pMonster.pev.angles.z = 0.0;
	
	if ( Math.RandomLong( 1, 2 ) == 1 )
	{
		pMonster.pev.avelocity.x = -99;
		pMonster.pev.avelocity.y = -99;
		pMonster.pev.avelocity.z = -99;
	}
	else
	{
		pMonster.pev.avelocity.x = 99;
		pMonster.pev.avelocity.y = 99;
		pMonster.pev.avelocity.z = 99;
	}
	
	SciS_Phase2_A( 70 );
}

void SciS_Phase2_A( int& in iLoop = 70 )
{
	CBaseEntity@ pMonster = g_EntityFuncs.FindEntityByTargetname( null, "giegue_the_sci" );
	
	pMonster.pev.scale = pMonster.pev.scale + 0.04;
	if ( iLoop == 0 )
	{
		pMonster.pev.avelocity = g_vecZero;
		pMonster.pev.angles = Vector( 0, 90, 0 );
		g_EntityFuncs.FireTargets( "giegue_thesequence", null, null, USE_TOGGLE, 0.0f, 0.0f );
		g_Scheduler.SetTimeout( "SciS_Phase3", 0.8 );
	}
	else
	{
		iLoop--;
		g_Scheduler.SetTimeout( "SciS_Phase2_A", 0.1, iLoop );
	}
}

void SciS_Phase3()
{
	g_EntityFuncs.FireTargets( "giegue_sci_fade", null, null, USE_TOGGLE, 0.0f, 0.0f );
	SciS_Phase3_A( 21 );
}

void SciS_Phase3_A( int& in iLoop = 21 )
{
	CBaseEntity@ pExplosion = g_EntityFuncs.RandomTargetname( "giegue_sci_explosion" );
	if ( pExplosion !is null )
		pExplosion.Use( null, null, USE_TOGGLE, 0.0f );
	
	if ( iLoop == 0 )
		g_EntityFuncs.FireTargets( "giegue_sci_end_mm", null, null, USE_TOGGLE, 0.0f, 5.0f );
	else
	{
		iLoop--;
		g_Scheduler.SetTimeout( "SciS_Phase3_A", 0.5, iLoop );
	}
}
