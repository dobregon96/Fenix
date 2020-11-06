enum FG42Animation_e
{
	FG42_UP_IDLE = 0,
	FG42_UP_RELOAD,
	FG42_UP_DRAW,
	FG42_UP_SHOOT,
	FG42_UPTODOWN,
	FG42_DOWN_IDLE,
	FG42_DOWN_RELOAD,
	FG42_DOWN_SHOOT,
	FG42_DOWNTOUP,
	FG42_UP_OUTOFWAY
};

const int FG42_MAX_CARRY     	= 600;
const int FG42_DEFAULT_GIVE  	= 20 * 2;
const int FG42_MAX_CLIP      	= 20;
const int FG42_WEIGHT        	= 25;

class weapon_fg42 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int g_iCurrentModeBipod;
	int m_iShotsFired;
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/fg42/w_fg42s.mdl" );
		
		self.m_iDefaultAmmo = FG42_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/fg42/w_fg42s.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/fg42/v_dscopedfg42.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/fg42/p_fg42s.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/fg42/p_fg42sbd.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_large.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/fg42_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/fg42_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/fg42_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mp44_draw_slideback.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/fg42_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/fg42_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/fg42_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mp44_draw_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/germans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/german_scope1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_fg42.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= FG42_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= FG42_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= FG42_WEIGHT;
		
		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage axis5( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis5.WriteLong( g_ItemRegistry.GetIdForName("weapon_fg42") );
			axis5.End();
			return true;
		}
		
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/fg42/v_dscopedfg42.mdl" ), self.GetP_Model( "models/ww2projekt/fg42/p_fg42s.mdl" ), FG42_UP_DRAW, "m16" );
			
			float deployTime = 0.95f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 )
	{    
		self.m_fInReload = false;
		 
		if ( g_iCurrentMode == MODE_SCOPE || g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			//SecondaryAttack();
			g_iCurrentMode = MODE_UNSCOPE;
			g_iCurrentModeBipod = BIPOD_UNDEPLOY;
		}
		m_iShotsFired = 0;
		m_pPlayer.pev.fuser4 = 0;
		ToggleZoom( 0 );
		m_pPlayer.pev.maxspeed = 0;
		
		BaseClass.Holster( skipLocal );
    }
	
	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}
	
	void ToggleZoom( int zoomedFOV )
	{
		if ( self.m_fInZoom == true )
		{
			SetFOV( 0 ); // 0 means reset to default fov
		}
		else if ( self.m_fInZoom == false )
		{
			SetFOV( zoomedFOV );
		}
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		if( g_iCurrentMode == MODE_SCOPE )
		{
			m_iShotsFired++;
			if( m_iShotsFired > 1 )
			{
				return;
			}
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.1;
		}
		else if( g_iCurrentMode == MODE_UNSCOPE)
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.083;
		}
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		int m_ShootMode;

		Vector vecShellVelocity, vecShellOrigin;
		
		vecShellVelocity.y *= 1;

		if( g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			m_ShootMode = FG42_DOWN_SHOOT;
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 4, -10, false, false );
		}
		else if( g_iCurrentModeBipod == BIPOD_UNDEPLOY )
		{
			m_ShootMode = FG42_UP_SHOOT;
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 14, 6, -10, false, false );
		}

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		self.SendWeaponAnim( m_ShootMode, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/fg42_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 39;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -3.0f, -1.9f );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		if( g_iCurrentMode == MODE_SCOPE && g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			vecDir = vecAiming + x * g_vecZero.x * g_Engine.v_right + y * g_vecZero.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x = -1.9f;
		}
		else if( g_iCurrentMode == MODE_SCOPE && g_iCurrentModeBipod == BIPOD_UNDEPLOY )
		{
			vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.5f, -1.9f );
		}
		else if( g_iCurrentMode == MODE_UNSCOPE && g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.5f, -1.9f );
		}
		else
		{
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
			m_pPlayer.pev.punchangle.x = Math.RandomFloat( -3.0f, -1.9f );
		}

		Vector vecEnd = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment at a rate of 2 bullets
		switch( ( self.m_iClip ) % 2 )
		{
			case 0: WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos ); break;
		}
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case MODE_UNSCOPE:
			{
				g_iCurrentMode = MODE_SCOPE;
				ToggleZoom( 35 );

				m_pPlayer.pev.maxspeed = (g_iCurrentModeBipod == BIPOD_DEPLOY) ? -1 : 180;
				break;
			}
		
			case MODE_SCOPE:
			{
				g_iCurrentMode = MODE_UNSCOPE;
				ToggleZoom( 0 );

				m_pPlayer.pev.maxspeed = (g_iCurrentModeBipod == BIPOD_DEPLOY) ? -1 : 0;
				break;
			}
		}
	}

	void TertiaryAttack()
	{
		switch ( g_iCurrentModeBipod )
		{
			case BIPOD_UNDEPLOY:
			{
				if( m_pPlayer.pev.waterlevel == WATERLEVEL_DRY || m_pPlayer.pev.waterlevel == WATERLEVEL_FEET )
				{
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 ) //needs to be fully crouched and not jumping-crouched
					{
						g_iCurrentModeBipod = BIPOD_DEPLOY;

						self.SendWeaponAnim( FG42_UPTODOWN, 0, 0 );
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						m_pPlayer.pev.weaponmodel = "models/ww2projekt/fg42/p_fg42sbd.mdl";
						self.m_flNextTertiaryAttack = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.225f;
					}
					else if( m_pPlayer.pev.flags & FL_DUCKING == 0 )
					{
						if( m_pPlayer.pev.flags & FL_ONGROUND == 0 )
						{
							g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
						}
						g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
					}
				}
				else
				{
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGWaterDeploy );
				}

				break;
			}

			case BIPOD_DEPLOY:
			{
				g_iCurrentModeBipod = BIPOD_UNDEPLOY;

				m_pPlayer.pev.maxspeed = (g_iCurrentMode == MODE_SCOPE) ? 180 : 0;

				m_pPlayer.pev.fuser4 = 0;
				m_pPlayer.pev.weaponmodel = "models/ww2projekt/fg42/p_fg42s.mdl";

				self.SendWeaponAnim( FG42_DOWNTOUP, 0, 0 );
				self.m_flNextTertiaryAttack = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == FG42_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		g_iCurrentMode = 0;
		ToggleZoom( 0 );
		m_iShotsFired = 0;
		m_pPlayer.pev.maxspeed = (g_iCurrentModeBipod == BIPOD_DEPLOY) ? -1 : 0;

		if( g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			self.DefaultReload( FG42_MAX_CLIP, FG42_DOWN_RELOAD, 3.74f, 0 );
		}
		else if( g_iCurrentModeBipod == BIPOD_UNDEPLOY )
		{
			self.DefaultReload( FG42_MAX_CLIP, FG42_UP_RELOAD, 3.875f, 0 );
		}

		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		if( g_iCurrentMode == MODE_SCOPE )
		{
			// Can we fire?
			if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			{
			// If the player is still holding the attack button, m_iShotsFired won't reset to 0
			// Preventing the automatic firing of the weapon
				if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
				{
					// Player released the button, reset now
					m_iShotsFired = 0;
				}
			}
		}
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
		{
			return;
		}

		int m_IdleMode;

		if( g_iCurrentModeBipod == BIPOD_DEPLOY )
		{
			m_IdleMode = FG42_DOWN_IDLE;
		}
		else if( g_iCurrentModeBipod == BIPOD_UNDEPLOY )
		{
			m_IdleMode = FG42_UP_IDLE;
		}
		
		self.SendWeaponAnim( m_IdleMode, 0, 0 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetFG42Name()
{
	return "weapon_fg42";
}

void RegisterFG42()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetFG42Name(), GetFG42Name() );
	g_ItemRegistry.RegisterWeapon( GetFG42Name(), "ww2projekt", "556" );
}