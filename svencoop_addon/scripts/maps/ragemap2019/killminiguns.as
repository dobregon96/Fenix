void KillMinigunsEnable( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	g_Scheduler.SetInterval("KillMiniguns", 0.1);
}

void KillMiniguns()
{
	CBaseEntity@ eEntity;
		
	while( ( @eEntity = g_EntityFuncs.FindEntityByClassname(eEntity, "weapon_minigun") ) !is null )
	{	
		g_EntityFuncs.Remove( eEntity );
	}
}