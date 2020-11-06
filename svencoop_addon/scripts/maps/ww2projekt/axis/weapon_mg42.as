enum MG42Animation_e
{
	MG42_UPIDLE = 0,
	MG42_UPIDLE_EMPTY,
	MG42_UPSHOOT,
	MG42_UPTODOWN,
	MG42_UPTODOWN_EMPTY,
	MG42_DOWNIDLE,
	MG42_DOWNIDLE_EMPTY,
	MG42_DOWNTOUP,
	MG42_DOWNTOUP_EMPTY,
	MG42_DOWNSHOOT,
	MG42_RELOAD
};

const int MG42_DEFAULT_GIVE  	= 300;
const int MG42_MAX_CARRY     	= 600;
const int MG42_MAX_CLIP      	= 200;
const int MG42_WEIGHT        	= 50;

enum MG42BulletBodygroup_e
{
	MG42_Bullet01 = 0,
	MG42_Bullet02 = 1,
	MG42_Bullet03 = 2,
	MG42_Bullet04 = 3,
	MG42_Bullet05 = 4,
	MG42_Bullet06 = 5,
	MG42_Bullet07 = 6,
	MG42_Bullet08 = 7,
	MG42_Bullet09 = 8,
	MG42_Bullet10 = 9
}

class weapon_mg42 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/mg42/w_mg42.mdl" );

		self.m_iDefaultAmmo = MG42_DEFAULT_GIVE;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/mg42/w_mg42.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/v_mg42.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/p_mg42bu.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/mg42/p_mg42bd.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mg42_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bulletchain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgchainpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgclampdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgdeploy.wav" );

		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mg42_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bulletchain.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgchainpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgclampdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgdeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/germans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_mg42.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= MG42_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MG42_MAX_CLIP;
		info.iSlot		= 6;
		info.iPosition	= 2;
		info.iFlags		= 0;
		info.iWeight	= MG42_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage axis11( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis11.WriteLong( g_ItemRegistry.GetIdForName("weapon_mg42") );
			axis11.End();
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
		int AmmoAnim; //here we go
		bool bResult;
		{
			AmmoAnim = (self.m_iClip <= 9) ? MG42_Bullet10 - self.m_iClip : MG42_Bullet01;

			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/mg42/v_mg42.mdl" ), self.GetP_Model( "models/ww2projekt/mg42/p_mg42bu.mdl" ), MG42_DOWNTOUP, "saw", 0, AmmoAnim );

			float deployTime = 1.20f;
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
		int AmmoAnim;

		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.05;

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		AmmoAnim = (self.m_iClip <= 9) ? MG42_Bullet10 - self.m_iClip : MG42_Bullet01;

		self.SendWeaponAnim( (g_iCurrentMode == BIPOD_UNDEPLOY) ? MG42_UPSHOOT : MG42_DOWNSHOOT, 0, AmmoAnim );

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/mg42_shoot1.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		int m_iBulletDamage = 20;

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
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -0.5f, 0.5f );
			
			if( m_pPlayer.pev.punchangle.x < -15 ) //defines a max recoil
				m_pPlayer.pev.punchangle.x = -15;
			
			vecDir = vecAiming + x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = -1.65;
			
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		}
		
		Vector vecEnd = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
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
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 14, 5, -8, false, true );
		else if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 9, 5, -8, false, true );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
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
					
						AmmoAnim = (self.m_iClip <= 9) ? MG42_Bullet10 - self.m_iClip : MG42_Bullet01;
				
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						self.SendWeaponAnim( MG42_UPTODOWN, 0, AmmoAnim );
						m_pPlayer.pev.weaponmodel = "models/ww2projekt/mg42/p_mg42bd.mdl";
						m_pPlayer.m_flNextAttack = 1.15f;
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

				AmmoAnim = (self.m_iClip <= 9) ? MG42_Bullet10 - self.m_iClip : MG42_Bullet01;

				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				m_pPlayer.pev.weaponmodel = "models/ww2projekt/mg42/p_mg42bu.mdl";
				
				self.SendWeaponAnim( MG42_DOWNTOUP, 0, AmmoAnim );
				m_pPlayer.m_flNextAttack = 1.2f;

				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == MG42_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.DefaultReload( MG42_MAX_CLIP, MG42_RELOAD, 6.95, MG42_Bullet01 );
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

		AmmoAnim = (self.m_iClip <= 9) ? MG42_Bullet10 - self.m_iClip : MG42_Bullet01;

		self.SendWeaponAnim( (g_iCurrentMode == BIPOD_UNDEPLOY) ? MG42_UPIDLE : MG42_DOWNIDLE, 0, AmmoAnim );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetMG42Name()
{
	return "weapon_mg42";
}

void RegisterMG42()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMG42Name(), GetMG42Name() );
	g_ItemRegistry.RegisterWeapon( GetMG42Name(), "ww2projekt", "556" );
}