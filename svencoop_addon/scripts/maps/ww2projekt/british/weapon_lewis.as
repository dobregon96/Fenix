enum LEWISAnimation_e
{
	LEWIS_DEPLOY = 0,
	LEWIS_UP_IDLE,
	LEWIS_UP_FIRE1, 
	LEWIS_UP_FIRE2, 
	LEWIS_UP_FIRE3,
	LEWIS_UP_RELOAD_EMPTY,
	LEWIS_UP_RELOAD,
	LEWIS_UP_TO_DOWN,
	LEWIS_DOWN_IDLE1,
	LEWIS_DOWN_FIRE1,
	LEWIS_DOWN_FIRE2,
	LEWIS_DOWN_FIRE3,
	LEWIS_DOWN_RELOAD,
	LEWIS_DOWN_RELOAD_EMPTY,
	LEWIS_DOWN_TO_UP
};

const int LEWIS_MAX_CARRY    	= 600;
const int LEWIS_DEFAULT_GIVE 	= 47 * 2;
const int LEWIS_MAX_CLIP     	= 47;
const int LEWIS_WEIGHT       	= 35;

class weapon_lewis : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/lewis/w_lewis.mdl" );

		self.m_iDefaultAmmo = LEWIS_DEFAULT_GIVE;

		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		
		g_Game.PrecacheModel( "models/ww2projekt/lewis/w_lewis.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/lewis/v_lewis.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/lewis/p_lewis.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/ww2projekt/shell_medium.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_boltback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_maghit1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_magin1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_magout1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_magoutfull1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/lewis_sight_flip.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_boltback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_maghit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_magin1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_magout1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_magoutfull1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/lewis_sight_flip.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/britishs_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_lewis.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= LEWIS_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= LEWIS_MAX_CLIP;
		info.iSlot		= 6;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= LEWIS_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage british9( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				british9.WriteLong( g_ItemRegistry.GetIdForName("weapon_lewis") );
			british9.End();
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/lewis/v_lewis.mdl" ), self.GetP_Model( "models/ww2projekt/lewis/p_lewis.mdl" ), LEWIS_DEPLOY, "saw" );

			float deployTime = 1.3f;
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
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.1;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		self.m_iClip -= 1;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.SendWeaponAnim( LEWIS_UP_FIRE1 + Math.RandomLong( 0, 2 ), 0, 0 );
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.SendWeaponAnim( LEWIS_DOWN_FIRE1 + Math.RandomLong( 0, 2 ), 0, 0 );
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/lewis_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 40;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		Vector vecDir;
		TraceResult tr;
		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );

		if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			m_pPlayer.pev.punchangle.x -= 1.6;
			m_pPlayer.pev.punchangle.y -= Math.RandomFloat( -0.5f, 0.5f );
			
			vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
		}
		else if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			m_pPlayer.pev.punchangle.x = 1.2;
			
			vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		}
		
		Vector vecEnd = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin, vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );

		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );

		//Produces a tracer at the start of the attachment at a rate of 2 bullets
		switch( (self.m_iClip) % 2 )
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
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 10, 11, -8, false, false );
		else if( g_iCurrentMode == BIPOD_DEPLOY )
			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 10, -8, false, false );
			
		vecShellVelocity.y *= 1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
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
						
						self.SendWeaponAnim( LEWIS_UP_TO_DOWN );
						
						m_pPlayer.pev.maxspeed = -1.0;
						m_pPlayer.pev.fuser4 = 1;
						
						self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.9f;
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
				
				self.SendWeaponAnim( LEWIS_DOWN_TO_UP );
				
				m_pPlayer.pev.maxspeed = 0;
				m_pPlayer.pev.fuser4 = 0;
				
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.9f;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == LEWIS_MAX_CLIP )
			return;

		if( g_iCurrentMode == BIPOD_DEPLOY )
		{
			self.DefaultReload( LEWIS_MAX_CLIP, (self.m_iClip <= 0) ? LEWIS_DOWN_RELOAD_EMPTY : LEWIS_DOWN_RELOAD, 3.55f, 0 );
		}
		else if( g_iCurrentMode == BIPOD_UNDEPLOY )
		{
			self.DefaultReload( LEWIS_MAX_CLIP, (self.m_iClip <= 0) ? LEWIS_UP_RELOAD_EMPTY : LEWIS_UP_RELOAD, 3.55f, 0 );
		}
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( (g_iCurrentMode == BIPOD_UNDEPLOY) ? LEWIS_UP_IDLE : LEWIS_DOWN_IDLE1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetLEWISName()
{
	return "weapon_lewis";
}

void RegisterLEWIS()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetLEWISName(), GetLEWISName() );
	g_ItemRegistry.RegisterWeapon( GetLEWISName(), "ww2projekt", "556" );
}