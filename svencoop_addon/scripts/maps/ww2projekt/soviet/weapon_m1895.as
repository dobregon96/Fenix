enum M1895Animation_e
{
	M1895_IDLE = 0,
	M1895_SHOOT,
	M1895_RELOAD,
	M1895_DRAW
};

const int M1895_MAX_CARRY    	= 36;
const int M1895_DEFAULT_GIVE 	= 6 * 2;
const int M1895_MAX_CLIP     	= 6;
const int M1895_WEIGHT       	= 25;

class weapon_m1895 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/m1885/w_nagm1885.mdl" );
		
		self.m_iDefaultAmmo = M1895_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/m1885/w_nagm1885.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/m1885/v_nagm1885.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/m1885/p_nagm1885.mdl" );
		
		//Precache for Download
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1885_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/webley_cock.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/webley_open.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/webley_insert.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/webley_close.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		//Precache for the Engine
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1885_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/webley_cock.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/webley_open.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/webley_insert.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/webley_close.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_m1895.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= M1895_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= M1895_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 8;
		info.iFlags		= 0;
		info.iWeight	= M1895_WEIGHT;
		
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
			NetworkMessage soviet7( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet7.WriteLong( g_ItemRegistry.GetIdForName("weapon_m1895") );
			soviet7.End();
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/m1885/v_nagm1885.mdl" ), self.GetP_Model( "models/ww2projekt/m1885/p_nagm1885.mdl" ), M1895_DRAW, "python" );
			
			float deployTime = 0.66f;
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.25;
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.SendWeaponAnim( M1895_SHOOT, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/m1885_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 45;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = -6.5;

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );

		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
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
	}
	
	void Reload()
	{
		if( self.m_iClip == M1895_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		self.DefaultReload( M1895_MAX_CLIP, M1895_RELOAD, 3.76, 0 );
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
		
		self.SendWeaponAnim( M1895_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetM1895Name()
{
	return "weapon_m1895";
}

void RegisterM1895()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM1895Name(), GetM1895Name() );
	g_ItemRegistry.RegisterWeapon( GetM1895Name(), "ww2projekt", "357" );
}