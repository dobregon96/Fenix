namespace CL_CASH
{

string CASH_MODEL = "models/counterlife/money.mdl";
string PICKUP_SOUND = "counterlife/cash_pickup.wav";

class item_cash : ScriptBaseItemEntity
{
	private int m_iValue = 1;
	private int m_iDespawn = 0;
	private int m_iDespawnTime = 300;
	private float m_fSpawnTimeInit = 0;
	
	private Vector m_vecMins, m_vecMaxs;
	
	int Value
	{
		get const { return m_iValue; }
	}
	
	int ShouldDespawn
	{
		get const { return m_iDespawn; }
	}
	
	int DespawnTime
	{
		get const { return m_iDespawnTime; }
	}
	
	float OnSpawnTime
	{
		get const { return m_fSpawnTimeInit; }
	}
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "value" )
		{
			m_iValue = atoi( szValue );
			
			return true;
		}
		else if( szKey == "should_despawn" )
		{
			m_iDespawn = atoi( szValue );
			
			return true;
		}
		else if( szKey == "despawntime" )
		{
			m_iDespawnTime = atoi( szValue );
			
			return true;
		}
		else
		{
			return BaseClass.KeyValue( szKey, szValue );
		}
	}
		
	void Precache()
	{
		BaseClass.Precache();
		g_SoundSystem.PrecacheSound( PICKUP_SOUND );
		g_Game.PrecacheGeneric( "sound/" + PICKUP_SOUND );			
		g_Game.PrecacheModel( self, CASH_MODEL );
	}
	
	void Spawn()
	{
		g_EntityFuncs.SetSize( pev, Vector( -20, -8, 0 ), Vector( 20, 8, 5 ) );
		g_EntityFuncs.SetModel( self, CASH_MODEL );
		g_EntityFuncs.SetOrigin( self, pev.origin );

		pev.movetype = MOVETYPE_PUSHSTEP;
		pev.solid = SOLID_TRIGGER;

		Setup();
	}
		
	private void Setup()
	{
		SetUse( UseFunction( this.DoUse ) );
		SetThink( ThinkFunction( this.DoThink ) );
		SetTouch( TouchFunction( this.SquareTouch ) );

		pev.rendermode = kRenderNormal;
		pev.renderfx = kRenderFxGlowShell;
		pev.renderamt = 10;
		pev.rendercolor = Vector( 0, 255, 0 );
		m_fSpawnTimeInit = g_Engine.time;
		pev.nextthink = g_Engine.time + 5;
	}
		
	void AddCash( CBasePlayer@ pPlayer )
	{
		if( pPlayer is null )
			return;

		if( !pPlayer.IsAlive() )
			return;

		pPlayer.pev.frags += m_iValue;

		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, PICKUP_SOUND, 1, ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ), 1 ); 
		g_EntityFuncs.Remove( self );
	}

	private void SquareTouch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() )
			return;

		AddCash( cast<CBasePlayer@>( pOther ) );
	}
	
	void DoUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		if( pActivator.IsPlayer() )
			AddCash( cast<CBasePlayer@>( pActivator ) );
	}

	void DoThink()
	{
		g_EngineFuncs.DropToFloor( self.edict() );

		if( m_iDespawn > 0 )
		{
			float fTimeDiff = g_Engine.time - m_fSpawnTimeInit;

			if( fTimeDiff > m_iDespawnTime*0.75 )
			{
				pev.rendercolor = Vector( 255, 0, 0 );

				if( fTimeDiff > m_iDespawnTime )
					g_EntityFuncs.Remove( self );
			}
		}

		pev.nextthink = g_Engine.time + 5;
	}

}

string GetName()
{
	return "item_cash";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CL_CASH::item_cash", GetName() );
	g_Game.PrecacheOther( "item_cash" );
}
	
}