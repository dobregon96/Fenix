enum PPSH41Animation_e
{
	PPSH41_IDLE = 0,
	PPSH41_RELOAD,
	PPSH41_DRAW,
	PPSH41_SHOOT1,
	PPSH41_SHOOT2,
	PPSH41_SHOOT3
};

const int PPSH41_MAX_CARRY  	= 250;
const int PPSH41_DEFAULT_GIVE	= 71 * 2;
const int PPSH41_MAX_CLIP   	= 71;
const int PPSH41_WEIGHT     	= 25;

class weapon_ppsh41 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/ppsh41/w_ppsh.mdl" );
		
		self.m_iDefaultAmmo = PPSH41_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/ppsh41/w_ppsh.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/ppsh41/p_ppsh.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/ppsh41/v_ppsh.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/ppsh_shoot1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/ppsh_reload_magout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/ppsh_reload_magin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/ppsh_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/ppsh_reload_magout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/ppsh_reload_magin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_ppsh41.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= PPSH41_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= PPSH41_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= PPSH41_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage soviet2( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet2.WriteLong( g_ItemRegistry.GetIdForName("weapon_ppsh41") );
			soviet2.End();
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/ppsh41/v_ppsh.mdl" ), self.GetP_Model( "models/ww2projekt/ppsh41/p_ppsh.mdl" ), PPSH41_DRAW, "mp5" );
		
			float deployTime = 1.0f;
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.066;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.SendWeaponAnim( PPSH41_SHOOT1, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/ppsh_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 15;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2, -1.5 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
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
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 25, 5, -7, false, false );
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == PPSH41_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		self.DefaultReload( PPSH41_MAX_CLIP, PPSH41_RELOAD, 2.76, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( PPSH41_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetPPSH41Name()
{
	return "weapon_ppsh41";
}

void RegisterPPSH41()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetPPSH41Name(), GetPPSH41Name() );
	g_ItemRegistry.RegisterWeapon( GetPPSH41Name(), "ww2projekt", "9mm" );
}