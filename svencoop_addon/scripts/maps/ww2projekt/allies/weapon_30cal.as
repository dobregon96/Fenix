enum THIRTYCALAnimation_e
{
	THIRTYCAL_UPIDLE = 0,
	THIRTYCAL_UPIDLE_EMPTY,
	THIRTYCAL_DOWNIDLE,
	THIRTYCAL_DOWNIDLE_EMPTY,
	THIRTYCAL_DOWNTOUP,
	THIRTYCAL_DOWNTOUP_EMPTY,
	THIRTYCAL_UPTODOWN,
	THIRTYCAL_UPTODOWN_EMPTY,
	THIRTYCAL_UPSHOOT,
	THIRTYCAL_DOWNSHOOT,
	THIRTYCAL_RELOAD
};

const int THIRTYCAL_DEFAULT_GIVE	= 300;
const int THIRTYCAL_MAX_CARRY		= 600;
const int THIRTYCAL_MAX_CLIP		= 200;
const int THIRTYCAL_WEIGHT			= 50;

enum THIRTYCALBulletBodygroup_e
{
	THIRTYCAL_Bullet01 = 0,
	THIRTYCAL_Bullet02,
	THIRTYCAL_Bullet03,
	THIRTYCAL_Bullet04,
	THIRTYCAL_Bullet05,
	THIRTYCAL_Bullet06,
	THIRTYCAL_Bullet07,
	THIRTYCAL_Bullet08,
	THIRTYCAL_Bullet09,
	THIRTYCAL_Bullet10,
	THIRTYCAL_Bullet11,
	THIRTYCAL_Bullet12
}

class weapon_30cal : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/30cal/w_30cal.mdl" );
		
		self.m_iDefaultAmmo = THIRTYCAL_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/30cal/w_30cal.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/30cal/v_30cal.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/30cal/p_30cal.mdl" );
		m_iShell = g_Game.PrecacheModel( "models/ww2projekt/shell_medium.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/30cal_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/30cal_handle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bulletchain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/30cal_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/30cal_handle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bulletchain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/americans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_30cal.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= THIRTYCAL_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= THIRTYCAL_MAX_CLIP;
		info.iSlot		= 6;
		info.iPosition	= 4;
		info.iFlags		= 0;
		info.iWeight	= THIRTYCAL_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage allies8( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies8.WriteLong( g_ItemRegistry.GetIdForName("weapon_30cal") );
			allies8.End();
			return true;
		}
		
		return false;
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
	
	bool Deploy()
	{
		int AmmoAnim;
		bool bResult;
		{
			AmmoAnim = (self.m_iClip <= 11) ? THIRTYCAL_Bullet12 - self.m_iClip : THIRTYCAL_Bullet01;
			
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/30cal/v_30cal.mdl" ), self.GetP_Model( "models/ww2projekt/30cal/p_30cal.mdl" ), THIRTYCAL_DOWNTOUP, "saw", 0, AmmoAnim );
			
			float deployTime = 1.20f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
			SecondaryAttack();
		
		g_iCurrentMode = 0;
		m_pPlayer.pev.maxspeed = 0;
		m_pPlayer.pev.fuser4 = 0;
		
		BaseClass.Holster( skipLocal );
	}
	
	void PrimaryAttack()
	{
		int AmmoAnim;
		
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.095;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		AmmoAnim = (self.m_iClip <= 11) ? THIRTYCAL_Bullet12 - self.m_iClip : THIRTYCAL_Bullet01;
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( THIRTYCAL_UPSHOOT, 0, AmmoAnim );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( THIRTYCAL_DOWNSHOOT, 0, AmmoAnim );
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/30cal_shoot.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 23;
		
		m_pPlayer.FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

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
			m_pPlayer.pev.punchangle.x -= 1.5;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -0.6f, 0.6f );
			
			if( m_pPlayer.pev.punchangle.x < -17 ) //defines a max recoil
				m_pPlayer.pev.punchangle.x = -17;
			
			vecDir = vecAiming + x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = -1.65;
			
			vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		}
		
		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
		Vector vecShellVelocity, vecShellOrigin;
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 10, 6, -8, false, true );
		else if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 12, 6, -8, false, true );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		//Produces a tracer at the start of the attachment at a rate of 4 bullets
		switch( ( self.m_iClip ) % 4 )
		{
			case 0: WW2DynamicTracer( vecAttachOrigin, tr.vecEndPos ); break;
		}
	}
	
	void SecondaryAttack()
	{
		int AmmoAnim; // oh shiet...

		switch( g_iCurrentMode )
		{
			case BIPOD_UNDEPLOY:
			{
				if( m_pPlayer.pev.waterlevel == WATERLEVEL_DRY || m_pPlayer.pev.waterlevel == WATERLEVEL_FEET )
				{
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 ) //needs to be fully crouched and not jumping-crouched
					{
						g_iCurrentMode = BIPOD_DEPLOY;
					
						AmmoAnim = (self.m_iClip <= 11) ? THIRTYCAL_Bullet12 - self.m_iClip : THIRTYCAL_Bullet01;

						self.SendWeaponAnim( THIRTYCAL_UPTODOWN, 0, AmmoAnim );
				
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						m_pPlayer.m_flNextAttack = 0.62f;
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
				g_iCurrentMode = BIPOD_UNDEPLOY;

				AmmoAnim = (self.m_iClip <= 11) ? THIRTYCAL_Bullet12 - self.m_iClip : THIRTYCAL_Bullet01;

				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				self.SendWeaponAnim( THIRTYCAL_DOWNTOUP, 0, AmmoAnim );
				m_pPlayer.m_flNextAttack = 1.2f;

				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == THIRTYCAL_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.DefaultReload( THIRTYCAL_MAX_CLIP, THIRTYCAL_RELOAD, 6.05, THIRTYCAL_Bullet01 );
			BaseClass.Reload();
		}
		else
		{
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGReloadDeploy );
		}
	}
	
	void WeaponIdle()
	{
		int AmmoAnim; 

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		AmmoAnim = self.m_iClip <= 11 ? THIRTYCAL_Bullet12 - self.m_iClip : THIRTYCAL_Bullet01;

		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( THIRTYCAL_UPIDLE, 0, AmmoAnim );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( THIRTYCAL_DOWNIDLE, 0, AmmoAnim );
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetTHIRTYCALName()
{
	return "weapon_30cal";
}

void RegisterTHIRTYCAL()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetTHIRTYCALName(), GetTHIRTYCALName() );
	g_ItemRegistry.RegisterWeapon( GetTHIRTYCALName(), "ww2projekt", "556" );
}