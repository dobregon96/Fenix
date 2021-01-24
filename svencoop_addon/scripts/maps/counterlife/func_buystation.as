namespace CL_BUYSTATION
{

class func_buystation : ScriptBaseItemEntity
{
	void Spawn()
	{
		g_EntityFuncs.SetSize( pev, pev.mins, pev.maxs );
		g_EntityFuncs.SetModel( self, string(pev.model) );
		g_EntityFuncs.SetOrigin( self, pev.origin );

		pev.solid = SOLID_BBOX;

		SetUse( UseFunction( this.DoUse ) );
	}

	void DoUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		if( pActivator is null )
			return;

		if( !pActivator.IsPlayer() )
			return;

		if( pActivator.IsPlayer() )
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer>( pActivator );
			g_BuyMenu.Show( pPlayer );
		}
	}
}

string GetName()
{
	return "func_buystation";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CL_BUYSTATION::func_buystation", GetName() );
	g_Game.PrecacheOther( "func_buystation" );
}

}