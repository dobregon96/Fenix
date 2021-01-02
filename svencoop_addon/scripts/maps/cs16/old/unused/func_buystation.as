namespace CLBuyStation
{
	enum SpawnFlag
	{
		/**
		*	 If set, the cash will respawn
		*/
		SF_CAN_ARMOR = 1 << 0,
	}

	/**
	*	Here's hoping this model is never renamed or removed.
	*/
	const string BUYSTATION_MODEL = "models/error.mdl";

	class CCLBuyStation : ScriptBaseItemEntity
	{
		private int m_iArmor = 1;
		private Vector m_vecMins, m_vecMaxs;	
		
		int Armor
		{
			get const { return m_iArmor; }
		}
		
		bool KeyValue( const string& in szKey, const string& in szValue )
		{
			if( szKey == "armor" )
			{
				m_iArmor = atoi( szValue );
				
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
		}
		
		void ChangeModel( string model )
		{
			g_EntityFuncs.SetModel( self, model );
		}
		
		void Spawn()
		{
			Setup();
		}
		
		private void Setup()
		{
			m_vecMins = pev.mins;
			m_vecMaxs = pev.maxs;
			pev.solid = SOLID_BBOX;
			g_EntityFuncs.SetOrigin( self, pev.origin );		
			SetUse( UseFunction( this.DoUse ) );
		}
		
		void DoUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
		{
			if (pActivator.IsPlayer())
			{
				CBasePlayer@ pPlayer = cast<CBasePlayer>( pActivator );
				openMainMenu( pPlayer );
			}
		}
	}

	void RegisterBuystation()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "CLBuyStation::CCLBuyStation", "func_buystation" );
	}
	
}
