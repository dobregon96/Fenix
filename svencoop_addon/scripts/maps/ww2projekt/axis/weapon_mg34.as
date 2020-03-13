enum MG34Animation_e
{
	MG34_DOWNIDLE = 0,
	MG34_DOWNIDLE_EMPTY,
	MG34_DOWNTOUP,
	MG34_DOWNTOUP_EMPTY,
	MG34_DOWNSHOOT,
	MG34_DOWNSHOOT_EMPTY,
	MG34_UPIDLE,
	MG34_UPIDLE_EMPTY,
	MG34_UPTODOWN,
	MG34_UPTODOWN_EMPTY,
	MG34_UPSHOOT,
	MG34_UPSHOOT_EMPTY,
	MG34_RELOAD
};

const int MG34_DEFAULT_GIVE 	= 175;
const int MG34_MAX_CARRY    	= 600;
const int MG34_MAX_CLIP     	= 100;
const int MG34_WEIGHT       	= 50;

class weapon_mg34 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/mg34/w_mg34.mdl" );
		
		self.m_iDefaultAmmo = MG34_DEFAULT_GIVE;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/mg34/w_mg34.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg34/v_mg34.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg34/p_mg34bd.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mg34_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgdeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mg34_magout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mg34_magin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );

		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mg34_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgdeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mg34_magout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mg34_magin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/germans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_mg34.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= MG34_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MG34_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 10;
		info.iFlags		= 0;
		info.iWeight	= MG34_WEIGHT;

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

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage axis8( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis8.WriteLong( g_ItemRegistry.GetIdForName("weapon_mg34") );
			axis8.End();
			return true;
		}

		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/mg34/v_mg34.mdl" ), self.GetP_Model( "models/ww2projekt/mg34/p_mg34bd.mdl" ), (self.m_iClip > 0) ? MG34_DOWNTOUP : MG34_DOWNTOUP_EMPTY, "saw" );

			float deployTime = 0.7f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;

		g_iCurrentMode = BIPOD_UNDEPLOY;
		m_pPlayer.pev.maxspeed = 0;
		m_pPlayer.pev.fuser4 = 0;
		
		BaseClass.Holster( skipLocal );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.0625;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( (self.m_iClip > 0) ? MG34_UPSHOOT : MG34_UPSHOOT_EMPTY );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( (self.m_iClip > 0) ? MG34_DOWNSHOOT : MG34_DOWNSHOOT_EMPTY );
		}

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/mg34_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );

		int m_iBulletDamage = 28;

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		Vector vecDir;

		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			m_pPlayer.pev.punchangle.x -= 1.4f;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -0.5f, 0.5f );
			
			if( m_pPlayer.pev.punchangle.x < -13 )
				m_pPlayer.pev.punchangle.x = -13;
			
			vecDir = vecAiming + x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = -1.5;
			
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		}
		
		Vector vecEnd = vecSrc + vecDir * 4096;
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment at a rate of 3 bullets
		switch( ( self.m_iClip ) % 3 )
		{
			case 0: WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos ); break;
		}
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
				{
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 11, 8, -8, false, true );
		else if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 8, 7, -8, false, true );

		vecShellVelocity.y *= 1;

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}

	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case BIPOD_UNDEPLOY:
			{
				if( m_pPlayer.pev.waterlevel == WATERLEVEL_DRY || m_pPlayer.pev.waterlevel == WATERLEVEL_FEET )
				{
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 )
					{
						g_iCurrentMode = BIPOD_DEPLOY;
						
						self.SendWeaponAnim( MG34_UPTODOWN );
						if( self.m_iClip == 0 )
						{
							self.SendWeaponAnim( MG34_UPTODOWN_EMPTY );
						}
				
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.45f;
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
					g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGWaterDeploy );
				
				break;
			}
			
			case BIPOD_DEPLOY:
			{
				g_iCurrentMode = BIPOD_UNDEPLOY;

				self.SendWeaponAnim( MG34_DOWNTOUP );
				if( self.m_iClip == 0 )
				{
					self.SendWeaponAnim( MG34_DOWNTOUP_EMPTY );
				}

				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.65f;

				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == MG34_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( g_iCurrentMode == BIPOD_DEPLOY )
		{			
			self.DefaultReload( MG34_MAX_CLIP, MG34_RELOAD, 5.73, 0 );
			BaseClass.Reload();
		}
		else
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGReloadDeploy );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( (self.m_iClip > 0) ? MG34_UPIDLE : MG34_UPIDLE_EMPTY );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( (self.m_iClip > 0) ? MG34_DOWNIDLE : MG34_DOWNIDLE_EMPTY );
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
	
	void ItemPreFrame()
	{
		/*if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			//m_pPlayer.pev.flags = FL_DUCKING;
			//m_pPlayer.pev.button = IN_DUCK;
			
			Vector vecAngles = m_pPlayer.pev.angles;
			Vector m_ShootAngles = m_pPlayer.pev.angles;
			Vector vecViewAngles = m_pPlayer.pev.v_angle;
			Vector m_ViewShootAngles = m_pPlayer.pev.v_angle;
			
			if( abs( vecAngles.x - m_ShootAngles.x ) > 90 )
			{
				if( vecAngles != m_pPlayer.pev.angles )
				{
					vecAngles.x = m_ShootAngles.x + Math.min( 90, Math.max( -90, vecAngles.x - m_ShootAngles.x ) );
					m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
				}
			}
			
			abs( vecViewAngles.x - m_ViewShootAngles.x ) > 90;
			vecViewAngles.x = m_ViewShootAngles.x + Math.min( 90, Math.max( -90, vecViewAngles.x - m_ViewShootAngles.x ) );
			if( vecViewAngles != m_pPlayer.pev.v_angle )
					m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
			
			//g_Game.AlertMessage( at_console, "true" );
			//g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, Deploy + "\n" );
			//m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
			//vecAngles.x = vecVAngles.x + Math.min( 90, Math.max( -90, vecAngles.x - vecVAngles.x ) );
		}*/
		
		BaseClass.ItemPreFrame();
	}
}

string GetMG34Name()
{
	return "weapon_mg34";
}

void RegisterMG34()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMG34Name(), GetMG34Name() );
	g_ItemRegistry.RegisterWeapon( GetMG34Name(), "ww2projekt", "556" );
}