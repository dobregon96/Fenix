namespace CLCash
{
enum SpawnFlag
{
	/**
	*	 If set, the cash will respawn
	*/
	SF_CASH_RESPAWN = 1 << 0,
}

/**
*	Here's hoping this model is never renamed or removed.
*/
const string CASH_MODEL = "models/cs16/counterlife/money.mdl";
const string PICKUP_SOUND = "sound/weapons/cs16/money_pickup.wav";

	class CCLCash : ScriptBaseItemEntity
	{
		private int m_iValue = 100;
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
			g_Game.PrecacheModel( self, CASH_MODEL );
		}
		
		void Spawn()
		{
			Setup();
		}
		
		private void Setup()
		{
			g_EntityFuncs.SetModel( self, CASH_MODEL );
			g_EntityFuncs.SetSize( pev, Vector( -20, -8, 0 ), Vector( 20, 8, 5 ) );
			pev.solid = SOLID_TRIGGER;
			SetTouch( TouchFunction( this.SquareTouch ) );
			SetUse( UseFunction( this.DoUse ) );
			SetThink( ThinkFunction( this.DoThink ) );
			g_EntityFuncs.SetOrigin( self, pev.origin );
			pev.movetype = MOVETYPE_PUSHSTEP;
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

			pPlayer.pev.frags = pPlayer.pev.frags + m_iValue;
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, PICKUP_SOUND, 1, ATTN_NORM, 0, 100, 1 ); 
			g_EntityFuncs.Remove( self );
		}
		
		void AddGroupCash()
		{
			float val = m_iValue / int( g_CLInitialized.getSize() );
			for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );
				
				if( pPlayer !is null )
				{
					pPlayer.pev.frags = pPlayer.pev.frags + val;
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, PICKUP_SOUND, 1, ATTN_NORM, 0, 100, 1 ); 
				}
			}
			g_EntityFuncs.Remove( self );
		}

		private void SquareTouch( CBaseEntity@ pOther )
		{
			if( pOther is null || !pOther.IsPlayer() )
				return;
			if( g_CLSharedCash )
			{
				AddGroupCash();
			}
			else
			{
				AddCash( cast<CBasePlayer@>( pOther ) );
			}
		}
		
		void DoUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
		{
			if (pActivator.IsPlayer())
			{
				if( g_CLSharedCash )
				{
					AddGroupCash();
				}
				else
				{
					AddCash( cast<CBasePlayer@>( pActivator ) );
				}
			}
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

	void RegisterCashEntity()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "CLCash::CCLCash", "item_cash" );
	}
	
}
