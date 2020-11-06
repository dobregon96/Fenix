//PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS PENIS

void SpawnWeapon( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	CBaseEntity@ ent = g_EntityFuncs.FindEntityByTargetname( ent, "weapon_nerospawnzone" );
	CBaseEntity@ ent1 = g_EntityFuncs.FindEntityByTargetname( ent1, "ammo_nerospawnzone" );
	CBaseEntity@ ent2 = g_EntityFuncs.FindEntityByTargetname( ent2, "ammo_nerospawnzone2" );
	CBaseEntity@ ent3 = g_EntityFuncs.FindEntityByTargetname( ent3, "ammo_nerospawnzone3" );
	CBaseEntity@ ent4 = g_EntityFuncs.FindEntityByTargetname( ent4, "ammo_nerospawnzone4" );

	CBaseEntity@ pEntity1 = g_EntityFuncs.Create( "weapon_scientist", ent.pev.origin, Vector(0, 0, 0), true );
	CBaseEntity@ pEntity2 = g_EntityFuncs.Create( "ammo_scientist", ent1.pev.origin, Vector(0, 0, 0), true );
	CBaseEntity@ pEntity3 = g_EntityFuncs.Create( "ammo_scientist", ent2.pev.origin, Vector(0, 0, 0), true );
	CBaseEntity@ pEntity4 = g_EntityFuncs.Create( "ammo_scientist", ent3.pev.origin, Vector(0, 0, 0), true );
	CBaseEntity@ pEntity5 = g_EntityFuncs.Create( "ammo_scientist", ent4.pev.origin, Vector(0, 0, 0), true );
	g_EntityFuncs.DispatchKeyValue( pEntity1.edict(), "targetname", "nero_bosskiller_wpn" );
	g_EntityFuncs.DispatchKeyValue( pEntity1.edict(), "m_flCustomRespawnTime", "0" );
	g_EntityFuncs.DispatchKeyValue( pEntity2.edict(), "targetname", "nero_bosskiller_ammo" );
	g_EntityFuncs.DispatchKeyValue( pEntity3.edict(), "targetname", "nero_bosskiller_ammo" );
	g_EntityFuncs.DispatchKeyValue( pEntity4.edict(), "targetname", "nero_bosskiller_ammo" );
	g_EntityFuncs.DispatchKeyValue( pEntity5.edict(), "targetname", "nero_bosskiller_ammo" );
	g_EntityFuncs.DispatchSpawn( pEntity1.edict() );
	g_EntityFuncs.DispatchSpawn( pEntity2.edict() );
	g_EntityFuncs.DispatchSpawn( pEntity3.edict() );
	g_EntityFuncs.DispatchSpawn( pEntity4.edict() );
	g_EntityFuncs.DispatchSpawn( pEntity5.edict() );
}

void RemoveWeapon( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	CBaseEntity@ pEntity1;
	CBaseEntity@ pEntity2;
	
	while( ( @pEntity1 = g_EntityFuncs.FindEntityInSphere( pEntity1, Vector(4800, 7360, -704), 16384, "weapon_scientist", "classname" ) ) !is null )
	{
		g_EntityFuncs.Remove( pEntity1 );
	}

	while( ( @pEntity2 = g_EntityFuncs.FindEntityInSphere( pEntity2, Vector(4800, 7360, -704), 16384, "ammo_scientist", "classname" ) ) !is null )
	{
		g_EntityFuncs.Remove( pEntity2 );
	}
}