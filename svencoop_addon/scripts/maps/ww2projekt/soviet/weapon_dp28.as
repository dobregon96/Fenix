enum DP28Animation_e
{
	DP28_UPIDLE = 0,
	DP28_UPRELOAD,
	DP28_DRAW,
	DP28_UPSHOOT,
	DP28_UPTODOWN,
	DP28_DOWNIDLE,
	DP28_DOWNRELOAD,
	DP28_DOWNSHOOT,
	DP28_DOWNTOUP
};

const int DP28_MAX_CARRY     	= 600;
const int DP28_DEFAULT_GIVE  	= 47 * 2;
const int DP28_MAX_CLIP      	= 47;
const int DP28_WEIGHT        	= 35;

class weapon_dp28 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/dp28/w_dp28.mdl" );
		
		self.m_iDefaultAmmo = DP28_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/dp28/w_dp28.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/dp28/v_dp28.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/dp28/p_dp28bd.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/dp28/p_dp28bu.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_medium.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/dp28_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgdeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bren_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/dp28_reload_clipin1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/dp28_reload_clipin2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mgbolt.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/dp28_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgdeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bren_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/dp28_reload_clipin1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/dp28_reload_clipin2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mgbolt.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_dp28.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= DP28_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= DP28_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= DP28_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage soviet4( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet4.WriteLong( g_ItemRegistry.GetIdForName("weapon_dp28") );
			soviet4.End();
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
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/dp28/v_dp28.mdl" ), self.GetP_Model( "models/ww2projekt/dp28/p_dp28bu.mdl" ), DP28_DRAW, "saw" );
			
			float deployTime = 1.16f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		
		if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			SecondaryAttack();
		}

		g_iCurrentMode = 0;
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.109;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( DP28_UPSHOOT, 0, 0 );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( DP28_DOWNSHOOT, 0, 0 );
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/dp28_shoot.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 34;
		
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
			m_pPlayer.pev.punchangle.x -= 1.65;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -0.5f, 0.5f );
			vecDir = vecAiming + x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = 1.1;
			vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		}
		
		Vector vecEnd	= vecSrc + vecDir * 4096;

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
		
		Vector vecShellVelocity, vecShellOrigin;
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 3, -9, false, true );
		else if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 14, 1, -7, false, true );
			
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
					if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 ) //needs to be fully crouched and not jump-crouched
					{
						g_iCurrentMode = BIPOD_DEPLOY;
						
						self.SendWeaponAnim( DP28_UPTODOWN );
						
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/dp28/p_dp28bd.mdl" );
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.3f;
					}
					else if( m_pPlayer.pev.flags & FL_DUCKING == 0 )
					{
						if( m_pPlayer.pev.flags & FL_ONGROUND == 0 )
							g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, MGToDeploy );
						
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
				
				self.SendWeaponAnim( DP28_DOWNTOUP );
				
				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				m_pPlayer.pev.weaponmodel = ( "models/ww2projekt/dp28/p_dp28bu.mdl" );
				
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.65f;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == DP28_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		if( g_iCurrentMode == BIPOD_DEPLOY )
			self.DefaultReload( DP28_MAX_CLIP, DP28_DOWNRELOAD, 3.85, 0 );
		else if( g_iCurrentMode == BIPOD_UNDEPLOY )
			self.DefaultReload( DP28_MAX_CLIP, DP28_UPRELOAD, 3.75, 0 );

		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( (g_iCurrentMode == BIPOD_UNDEPLOY) ? DP28_UPIDLE : DP28_DOWNIDLE );
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetDP28Name()
{
	return "weapon_dp28";
}

void RegisterDP28()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetDP28Name(), GetDP28Name() );
	g_ItemRegistry.RegisterWeapon( GetDP28Name(), "ww2projekt", "556" );
}