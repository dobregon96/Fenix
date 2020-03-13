enum WW2C96Animation_e
{
	BROOMHANDLE_IDLE1 = 0,
	BROOMHANDLE_IDLE2,
	BROOMHANDLE_SHOOT1,
	BROOMHANDLE_SHOOT2,
	BROOMHANDLE_SHOOT3,
	BROOMHANDLE_SHOOT_EMPTY,
	BROOMHANDLE_IDLE_EMPTY,
	BROOMHANDLE_RELOAD1,
	BROOMHANDLE_RELOAD2,
	BROOMHANDLE_RELOAD3,
	BROOMHANDLE_DEPLOY_FIRST,
	BROOMHANDLE_DEPLOY
};

const int C96_MAX_CARRY  	= 250;
const int C96_DEFAULT_GIVE 	= 10 * 2;
const int C96_MAX_CLIP   	= 10;
const int C96_WEIGHT     	= 25;

class weapon_c96 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;
	bool m_WasDrawn;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/c96/w_c96.mdl" );
		
		self.m_iDefaultAmmo = C96_DEFAULT_GIVE;
		m_iShotsFired = 0;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "models/ww2projekt/c96/w_c96.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/c96/v_c96.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/c96/p_c96.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/ww2projekt/shell_small.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_boltrelease.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_clip_in.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_clip_load.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_clip_loadfull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_clip_out.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_rattle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/c96_shoot.wav" );

		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_boltrelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_clip_in.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_clip_load.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_clip_loadfull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_clip_out.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_rattle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/c96_shoot.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/germans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_c96.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= C96_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= C96_MAX_CLIP;
		info.iSlot   	= 1;
		info.iPosition	= 5;
		info.iFlags  	= 0;
		info.iWeight 	= C96_WEIGHT;

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
			NetworkMessage axis13( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis13.WriteLong( g_ItemRegistry.GetIdForName("weapon_c96") );
			axis13.End();

			m_WasDrawn = false;
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
			float deployTime;
			if( m_WasDrawn == false )
			{
				bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/c96/v_c96.mdl" ), self.GetP_Model( "models/ww2projekt/c96/p_c96.mdl" ), BROOMHANDLE_DEPLOY_FIRST, "onehanded" );
				deployTime = 2.0f;
				m_WasDrawn = true;
			}
			else
			{
				bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/c96/v_c96.mdl" ), self.GetP_Model( "models/ww2projekt/c96/p_c96.mdl" ), BROOMHANDLE_DEPLOY, "onehanded" );
				deployTime = 1.0f;
			}

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
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.0;
			return;
		}

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}

		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.11;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/c96_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_iClip == 0 )
			self.SendWeaponAnim( BROOMHANDLE_SHOOT_EMPTY, 0, 0 );
		else
			self.SendWeaponAnim( BROOMHANDLE_SHOOT1 + Math.RandomLong( 0, 2 ), 0, 0 );

		int m_iBulletDamage = 20;
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -1.9, -1.1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 6, 9 );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 8192;

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
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 22, 5, -4, false, false );
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}

	void Reload()
	{
		if( self.m_iClip == C96_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		switch( Math.RandomLong( 0, 2 ) )
		{
			case 0: self.DefaultReload( C96_MAX_CLIP, BROOMHANDLE_RELOAD1, 3.83f, 0 );
			break;
			case 1: self.DefaultReload( C96_MAX_CLIP, BROOMHANDLE_RELOAD2, 4.25f, 0 );
			break;
			case 2: self.DefaultReload( C96_MAX_CLIP, BROOMHANDLE_RELOAD3, 5.27f, 0 );
			break;
		}
		
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		// Can we fire?
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
		// If the player is still holding the attack button, m_iShotsFired won't reset to 0
		// Preventing the automatic firing of the weapon
			if ( !( (m_pPlayer.pev.button & IN_ATTACK) != 0 ) )
			{
				// Player released the button, reset now
				m_iShotsFired = 0;
			}
		}

		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( self.m_iClip == 0 )
			self.SendWeaponAnim( BROOMHANDLE_IDLE_EMPTY );
		else
			self.SendWeaponAnim( BROOMHANDLE_IDLE1 + Math.RandomLong( 0, 1 ) );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetC96Name()
{
	return "weapon_c96";
}

void RegisterC96()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetC96Name(), GetC96Name() );
	g_ItemRegistry.RegisterWeapon( GetC96Name(), "ww2projekt", "9mm" );
}