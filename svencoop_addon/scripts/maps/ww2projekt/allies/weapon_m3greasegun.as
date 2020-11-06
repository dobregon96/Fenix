enum GREASEGUNAnimation_e
{
	GREASEGUN_IDLE = 0,
	GREASEGUN_RELOAD,
	GREASEGUN_DRAW,
	GREASEGUN_SHOOT1,
	GREASEGUN_SHOOT2,
	GREASEGUN_IDLE_EMPTY,
	GREASEGUN_FASTDRAW
};

const int GREASEGUN_MAX_CARRY    	= 250;
const int GREASEGUN_DEFAULT_GIVE 	= 30 * 2;
const int GREASEGUN_MAX_CLIP     	= 30;
const int GREASEGUN_WEIGHT       	= 25;

class weapon_m3greasegun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	bool m_WasDrawn;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/greasegun/w_greasegun.mdl" );
		
		self.m_iDefaultAmmo = GREASEGUN_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/greasegun/w_greasegun.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/greasegun/v_greaseg.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/greasegun/p_grease.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/greasegun_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mp40_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mp44_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/mp44_draw_slideback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/greaseg_draw01.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/greaseg_draw02.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/greaseg_draw03.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/greaseg_draw04.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/greasegun_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mp40_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mp44_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/mp44_draw_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/americans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_m3greasegun.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= GREASEGUN_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= GREASEGUN_MAX_CLIP;
		info.iSlot  	= 2;
		info.iPosition	= 7;
		info.iFlags 	= 0;
		info.iWeight	= GREASEGUN_WEIGHT;
		
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
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage allies3( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies3.WriteLong( g_ItemRegistry.GetIdForName("weapon_m3greasegun") );
			allies3.End();

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
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/greasegun/v_greaseg.mdl" ), self.GetP_Model( "models/ww2projekt/greasegun/p_grease.mdl" ), GREASEGUN_DRAW, "mp5" );
				m_WasDrawn = true;
				deployTime = 1.6f;
			}
			else if( m_WasDrawn == true )
			{
				bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/greasegun/v_greaseg.mdl" ), self.GetP_Model( "models/ww2projekt/greasegun/p_grease.mdl" ), GREASEGUN_FASTDRAW, "mp5" );
				deployTime = 1.01f;
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
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.133;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( GREASEGUN_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( GREASEGUN_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/greasegun_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 30;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.75f, -1.75f );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
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
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 4, -9, false, false );
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
	}
	
	void Reload()
	{
		if( self.m_iClip == GREASEGUN_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		self.DefaultReload( GREASEGUN_MAX_CLIP, GREASEGUN_RELOAD, 4.1, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( self.m_iClip <= 0 )
			self.SendWeaponAnim( GREASEGUN_IDLE_EMPTY );
		else
			self.SendWeaponAnim( GREASEGUN_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetM3GREASEGUNName()
{
	return "weapon_m3greasegun";
}

void RegisterM3GREASEGUN()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM3GREASEGUNName(), GetM3GREASEGUNName() );
	g_ItemRegistry.RegisterWeapon( GetM3GREASEGUNName(), "ww2projekt", "9mm" );
}