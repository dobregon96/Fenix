enum RGD33Animation_e
{
	RGD33_IDLE = 0,
	RGD33_DRAW,
	RGD33_PINPULL,
	RGD33_HOLSTER,
	RGD33_THROW,
	RGD33_E_IDLE,
	RGD33_E_DRAW,
	RGD33_E_PINPULL,
	RGD33_E_THROW
};

const int RGD33_DEFAULT_GIVE	= 5;
const int RGD33_MAX_CARRY		= 10;
const int RGD33_WEIGHT			= 30;
const int RGD33_DAMAGE			= 160;

class weapon_rgd33 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float m_flStartThrow;
	float m_flReleaseThrow;
	CBaseEntity@ pGrenade;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/rgdgren/w_rgdgren.mdl" );
		
		self.m_iDefaultAmmo = RGD33_DEFAULT_GIVE;
		m_flReleaseThrow = -1.0f;
		m_flStartThrow = 0;

		self.KeyValue( "m_flCustomRespawnTime", 1 ); //fgsfds
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/rgdgren/w_rgdgren.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/rgdgren/v_rgdgren.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/rgdgren/p_rgdgren.mdl" );
		
		//Precache for Download
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/grenpinpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/grenthrow.wav" );
		
		//Precache for the Engine
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/grenpinpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/grenthrow.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_rgd33.txt" );
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage soviet8( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet8.WriteLong( g_ItemRegistry.GetIdForName("weapon_rgd33") );
			soviet8.End();
			return true;
		}

		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= RGD33_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 5;
		info.iWeight 	= RGD33_WEIGHT;
		info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE | ITEM_FLAG_ESSENTIAL;

		return true;
	}

	//fgsfds
	void Materialize()
	{
		BaseClass.Materialize();
		SetTouch(TouchFunction(CustomTouch));
	}

	void CustomTouch(CBaseEntity@ pOther) 
	{
		if (!pOther.IsPlayer())
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);

		if (pPlayer.HasNamedPlayerItem("weapon_rgd33") !is null) 
		{
      		if (pPlayer.GiveAmmo(RGD33_DEFAULT_GIVE, "weapon_rgd33", RGD33_MAX_CARRY) != -1) 
			{
        		self.CheckRespawn();
        		g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
        		g_EntityFuncs.Remove(self);
      		}
      		return;
    	}
		else if (pPlayer.AddPlayerItem(self) != APIR_NotAdded) 
		{
      		self.AttachToPlayer(pPlayer);
      		g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);
    	}
	}
	//fgsfds

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flReleaseThrow = -1;
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/rgdgren/v_rgdgren.mdl" ), self.GetP_Model( "models/ww2projekt/rgdgren/p_rgdgren.mdl" ), RGD33_DRAW, "gren" );

			float deployTime = 0.77f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	CBasePlayerItem@ DropItem() // Doesn't let the player drop the weapon
	{
		return null;
	}
	
	bool CanHolster()
	{
		// can only holster hand grenades when not primed!
		return ( m_flStartThrow == 0 );
	}
	
	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}
	
	void DestroyThink()
	{
		self.DestroyItem();
	}
	
	void Holster( int skiplocal )
	{
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5f;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName("weapon_rgd33") );
			self.SendWeaponAnim( RGD33_HOLSTER );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		m_flStartThrow = 0;
		m_flReleaseThrow = -1.0f;

		BaseClass.Holster( skiplocal );
	}
	
	void PrimaryAttack()
	{
		if( m_flStartThrow == 0 && m_pPlayer.m_rgAmmo ( self.m_iPrimaryAmmoType ) > 0 )
		{
			m_flReleaseThrow = 0;
			m_flStartThrow = g_Engine.time;
		
			self.SendWeaponAnim( RGD33_PINPULL );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
		}
	}
	
	void WeaponIdle()
	{
		if ( m_flReleaseThrow == 0 && m_flStartThrow > 0.0 )
			m_flReleaseThrow = g_Engine.time;

		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if ( m_flStartThrow > 0.0 )
		{
			Vector angThrow = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;

			if ( angThrow.x < 0 )
				angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
			else
				angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );

			float flVel = ( 90.0f - angThrow.x ) * 6;

			if ( flVel > 750.0f )
				flVel = 750.0f;

			Math.MakeVectors ( angThrow );

			Vector vecSrc = m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs + g_Engine.v_forward * 16;
			Vector vecThrow = g_Engine.v_forward * flVel + m_pPlayer.pev.velocity;

			// always explode 3 seconds after the pin was pulled
			float time = m_flStartThrow - g_Engine.time + 4.0;
			if( time < 0 )
				time = 0;

			@pGrenade = g_EntityFuncs.ShootTimed( m_pPlayer.pev, vecSrc, vecThrow, time );
			g_EntityFuncs.SetModel( pGrenade, "models/ww2projekt/rgdgren/w_rgdgren.mdl" );
			
			//te_trail( pGrenade );
			pGrenade.pev.dmg = RGD33_DAMAGE;

			if ( flVel < 500 )
			{
				self.SendWeaponAnim ( RGD33_THROW );
			}
			else if ( flVel < 1000 )
			{
				self.SendWeaponAnim ( RGD33_THROW );
			}
			else
			{
				self.SendWeaponAnim ( RGD33_THROW );
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flReleaseThrow = g_Engine.time;
			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.4;

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			{
				// just threw last grenade
				// set attack times in the future, and weapon idle in the future so we can see the whole throw
				// animation, weapon idle will automatically retire the weapon for us.
				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.4;
			}
			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			m_flStartThrow = 0;

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
			{
				self.SendWeaponAnim( RGD33_DRAW );
			}
			else
			{
				self.RetireWeapon();
				return;
			}

			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			m_flReleaseThrow = -1;
			return;
		}

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
			if( flRand <= 1.0 )
			{
				self.SendWeaponAnim( RGD33_IDLE );
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			}
		}
	}
}

string GetRGD33Name()
{
	return "weapon_rgd33";
}

void RegisterRGD33()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetRGD33Name(), GetRGD33Name() );
	g_ItemRegistry.RegisterWeapon( GetRGD33Name(), "ww2projekt", "weapon_rgd33" );
}