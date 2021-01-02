namespace CLKevlar
{
enum SpawnFlag
{
	/**
	*	 If set, the cash will respawn
	*/
	SF_KEVLAR_RESPAWN = 1 << 0,
}

/**
*	Here's hoping this model is never renamed or removed.
*/
const string KEVLAR_MODEL = "models/cs16/counterlife/kevlar.mdl";
const string PICKUP_SOUND = "sound/weapons/cs16/kevlar_pickup.wav";

	class CCLKevlar : ScriptBaseItemEntity
	{
		private int m_iValue = 200;
		
		private Vector m_vecMins, m_vecMaxs;
		
		int Value
		{
			get const { return m_iValue; }
		}
		
		bool KeyValue( const string& in szKey, const string& in szValue )
		{
			if( szKey == "value" )
			{
				m_iValue = atoi( szValue );
				
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
			g_Game.PrecacheModel( self, KEVLAR_MODEL );
		}
		
		void Spawn()
		{
			Setup();
		}
		
		private void Setup()
		{
			g_EntityFuncs.SetModel( self, KEVLAR_MODEL );
			g_EntityFuncs.SetSize( pev, Vector( -20, -15, 0 ), Vector( 20, 15, 15 ) );
			pev.solid = SOLID_TRIGGER;
			SetTouch( TouchFunction( this.SquareTouch ) );
			SetUse( UseFunction( this.DoUse ) );
			g_EntityFuncs.SetOrigin( self, pev.origin );
		}
		
		void AddKevlar( CBasePlayer@ pPlayer )
		{
			if( pPlayer is null )
				return;
			if( pPlayer.pev.armorvalue >= 100 ) 	
				return; 

			pPlayer.pev.armorvalue = 100;
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, PICKUP_SOUND, 1, ATTN_NORM, 0, 100, 1 ); 
			g_EntityFuncs.Remove( self );
		}

		private void SquareTouch( CBaseEntity@ pOther )
		{
			if( pOther is null || !pOther.IsPlayer() )
				return;
				
			AddKevlar( cast<CBasePlayer@>( pOther ) );
		}
		
		void DoUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
		{
			if (pActivator.IsPlayer())
			{
				AddKevlar( cast<CBasePlayer@>( pActivator ) );
			}
		}		

	}

	void RegisterKevlarEntity()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "CLKevlar::CCLKevlar", "item_kevlar" );
	}
	
}
