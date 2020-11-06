enum TOKAREVAnimation_e
{
	TOKAREV_IDLE = 0,
	TOKAREV_SHOOT1,
	TOKAREV_SHOOT2,
	TOKAREV_RELOAD,
	TOKAREV_RELOAD_NOSHOOT,
	TOKAREV_DRAW,
	TOKAREV_SHOOT_EMPTY,
	TOKAREV_EMPTY_IDLE
};

const int TOKAREV_MAX_CARRY		= 250;
const int TOKAREV_DEFAULT_GIVE	= 8 * 2;
const int TOKAREV_MAX_CLIP		= 8;
const int TOKAREV_WEIGHT		= 25;

class weapon_tokarev : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/tokarev/w_tokarev.mdl" );
		
		self.m_iDefaultAmmo = TOKAREV_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/tokarev/w_tokarev.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/tokarev/v_tokarev.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/tokarev/p_tokarev.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/tokarev_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/tokarev_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/tokarev_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/tokarev_reload_unlock.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/tokarev_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/tokarev_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/tokarev_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/tokarev_reload_unlock.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_tokarev.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= TOKAREV_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= TOKAREV_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= TOKAREV_WEIGHT;
		
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
			NetworkMessage soviet1( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet1.WriteLong( g_ItemRegistry.GetIdForName("weapon_tokarev") );
			soviet1.End();
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/tokarev/v_tokarev.mdl" ), self.GetP_Model( "models/ww2projekt/tokarev/p_tokarev.mdl" ), TOKAREV_DRAW, "onehanded" );
			
			float deployTime = 0.7f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
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

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( self.m_iClip == 0 )
			self.SendWeaponAnim( TOKAREV_SHOOT_EMPTY, 0, 0 );
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( TOKAREV_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( TOKAREV_SHOOT2, 0, 0 ); break;
			}
		}

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/tokarev_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		int m_iBulletDamage = 20;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -1.9, -1.1 );

		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 4096;
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		
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
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 6, -10, false, false );
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == TOKAREV_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		self.DefaultReload( TOKAREV_MAX_CLIP, TOKAREV_RELOAD, 2.79, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
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
		
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( (self.m_iClip == 0) ? TOKAREV_EMPTY_IDLE : TOKAREV_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetTOKAREVName()
{
	return "weapon_tokarev";
}

void RegisterTOKAREV()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetTOKAREVName(), GetTOKAREVName() );
	g_ItemRegistry.RegisterWeapon( GetTOKAREVName(), "ww2projekt", "9mm" );
}