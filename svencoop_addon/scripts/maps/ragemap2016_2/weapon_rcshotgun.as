#include "proj_rcshotgun"

const int RCSHOTGUN_DEFAULT_AMMO	= 12;
const int RCSHOTGUN_MAX_CARRY 		= 125;
const int RCSHOTGUN_MAX_CLIP 		= 6;
const int RCSHOTGUN_WEIGHT 			= 15;
const string RCSHOTGUN_BEAM_SPRITE	= "sprites/xbeam1.spr";

const array<string> g_SciScreams = {
	'scientist/scream01.wav',
	'scientist/scream02.wav',
	'scientist/scream03.wav',
	'scientist/scream04.wav',
	'scientist/scream05.wav',
	'scientist/scream06.wav',
	'scientist/scream07.wav',
	'scientist/scream08.wav',
	'scientist/scream09.wav',
	'scientist/scream20.wav',
	'scientist/scream22.wav',
	'scientist/scream23.wav',
	'scientist/scream3.wav',
	'scientist/scream4.wav'
};

enum RCShotgunAnimation
{
	RCSHOTGUN_IDLE = 0,
	RCSHOTGUN_FIRE,
	RCSHOTGUN_FIRE2,
	RCSHOTGUN_RELOAD,
	RCSHOTGUN_PUMP,
	RCSHOTGUN_START_RELOAD,
	RCSHOTGUN_DRAW,
	RCSHOTGUN_HOLSTER,
	RCSHOTGUN_IDLE4,
	RCSHOTGUN_IDLE_DEEP
};

class weapon_rcshotgun : ScriptBasePlayerWeaponEntity
{
	float m_flNextReload;
	int m_iShell;
	float m_flPumpTime;
	bool m_fPlayPumpSound;
	bool m_fShotgunReload;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/w_shotgun.mdl" );
		self.m_iDefaultAmmo = RCSHOTGUN_DEFAULT_AMMO;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/v_shotgun.mdl" );
		g_Game.PrecacheModel( "models/w_shotgun.mdl" );
		g_Game.PrecacheModel( "models/p_shotgun.mdl" );
		
		g_Game.PrecacheModel( "models/custom_weapons/rcshotgun/crate.mdl" );
		g_Game.PrecacheModel( "models/custom_weapons/rcshotgun/miniforklift.mdl" );
		g_Game.PrecacheModel( "models/custom_weapons/rcshotgun/shotgunsci.mdl" );
		g_Game.PrecacheModel( "models/custom_weapons/rcshotgun/shotgunsuit.mdl" );
		g_Game.PrecacheModel( RCSHOTGUN_BEAM_SPRITE );
		
		g_SoundSystem.PrecacheSound( "weapons/rocket1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/rocketfire1.wav" );

		m_iShell = g_Game.PrecacheModel( "models/shotgunshell.mdl" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "weapons/dbarrel1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/sbarrel1.wav" );

		g_SoundSystem.PrecacheSound( "weapons/reload1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/reload3.wav" );

		g_SoundSystem.PrecacheSound("weapons/sshell1.wav");
		g_SoundSystem.PrecacheSound("weapons/sshell3.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/scock1.wav" );
		
		for( uint i = 0; i < g_SciScreams.length(); ++i )
		{
			g_SoundSystem.PrecacheSound( g_SciScreams[i] );
		}
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= RCSHOTGUN_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= RCSHOTGUN_MAX_CLIP;
		info.iSlot 		= 2;
		info.iPosition 	= 7;
		info.iFlags 	= 0;
		info.iWeight 	= RCSHOTGUN_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
			g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/v_shotgun.mdl" ), self.GetP_Model( "models/p_shotgun.mdl" ), RCSHOTGUN_DRAW, "shotgun" );
	}
	
	void Holster( int skipLocal = 0 )
	{
		m_fShotgunReload = false;
		
		BaseClass.Holster( skipLocal );
	}

	void ItemPostFrame()
	{
		if( m_flPumpTime != 0 && m_flPumpTime < g_Engine.time && m_fPlayPumpSound )
		{
			CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
			g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_ITEM, "weapons/scock1.wav", 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0,0x1f ) );

			m_fPlayPumpSound = false;
		}

		BaseClass.ItemPostFrame();
	}
	
	void PrimaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			self.Reload();
			self.PlayEmptySound();
			return;
		}

		self.SendWeaponAnim( RCSHOTGUN_FIRE, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, "weapons/sbarrel1.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );
		
		basePlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		basePlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		basePlayer.SetAnimation( PLAYER_ATTACK1 );

		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		RCShotgunScientist@ pSci = ShootRCShotgunScientist( basePlayer.pev, basePlayer.pev.origin + basePlayer.pev.view_ofs + g_Engine.v_forward * 24 + g_Engine.v_right * 6 + g_Engine.v_up * -7, g_Engine.v_forward * 1600 );
		
		g_SoundSystem.EmitSound( pSci.self.edict(), CHAN_VOICE, g_SciScreams[Math.RandomLong(0,g_SciScreams.length()-1)], 1.0, ATTN_NORM );

		if( self.m_iClip == 0 && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			basePlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		if( self.m_iClip != 0 )
			m_flPumpTime = g_Engine.time + 0.5;

		basePlayer.pev.punchangle.x -= 6;

		self.m_flNextPrimaryAttack = g_Engine.time + 1;
		self.m_flNextSecondaryAttack = g_Engine.time + 2;

		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = g_Engine.time + 5.0;
		else
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;

		m_fShotgunReload = false;
		m_fPlayPumpSound = true;
	}

	void SecondaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		if( self.m_iClip <= 1 )
		{
			self.Reload();
			self.PlayEmptySound();
			return;
		}
		
		self.SendWeaponAnim( RCSHOTGUN_FIRE, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, "weapons/sbarrel1.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );
		g_SoundSystem.EmitSound( basePlayer.edict(), CHAN_ITEM, "weapons/rocketfire1.wav", 0.9, ATTN_NORM );

		basePlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		basePlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;

		basePlayer.SetAnimation( PLAYER_ATTACK1 );
		
		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		ShootShotgunSuit( basePlayer.pev, basePlayer.pev.origin + basePlayer.pev.view_ofs + g_Engine.v_forward * 24 + g_Engine.v_right * 6 + g_Engine.v_up * -7, g_Engine.v_forward * 800 );

		if( self.m_iClip == 0 && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			basePlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_flPumpTime = g_Engine.time + 0.95;

		self.m_flNextPrimaryAttack = g_Engine.time + 1.5;
		self.m_flNextSecondaryAttack = g_Engine.time + 1.5;
		
		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = g_Engine.time + 6.0;
		else
			self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
			
		//basePlayer.pev.punchangle.x = -10.0;

		m_fShotgunReload = false;
		m_fPlayPumpSound = true;
	}

	void Reload()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		if( basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == RCSHOTGUN_MAX_CLIP )
			return;

		if( m_flNextReload > g_Engine.time )
			return;

		// don't reload until recoil is done
		if( self.m_flNextPrimaryAttack > g_Engine.time && !m_fShotgunReload )
			return;

		// check to see if we're ready to reload
		if( !m_fShotgunReload )
		{
			self.SendWeaponAnim( RCSHOTGUN_START_RELOAD, 0, 0 );
			basePlayer.m_flNextAttack 	= 0.6;	//Always uses a relative time due to prediction
			self.m_flTimeWeaponIdle			= g_Engine.time + 0.6;
			self.m_flNextPrimaryAttack 		= g_Engine.time + 1.0;
			self.m_flNextSecondaryAttack	= g_Engine.time + 1.0;
			m_fShotgunReload = true;
			return;
		}
		else if( m_fShotgunReload )
		{
			if( self.m_flTimeWeaponIdle > g_Engine.time )
				return;

			if( self.m_iClip == RCSHOTGUN_MAX_CLIP )
			{
				m_fShotgunReload = false;
				return;
			}

			self.SendWeaponAnim( RCSHOTGUN_RELOAD, 0 );
			m_flNextReload 					= g_Engine.time + 0.5;
			self.m_flNextPrimaryAttack 		= g_Engine.time + 0.5;
			self.m_flNextSecondaryAttack 	= g_Engine.time + 0.5;
			self.m_flTimeWeaponIdle 		= g_Engine.time + 0.5;
				
			// Add them to the clip
			self.m_iClip += 1;
			basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType, basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
			
			switch( Math.RandomLong( 0, 1 ) )
			{
			case 0:
				g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_ITEM, "weapons/reload1.wav", 1, ATTN_NORM, 0, 85 + Math.RandomLong( 0, 0x1f ) );
				break;
			case 1:
				g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_ITEM, "weapons/reload3.wav", 1, ATTN_NORM, 0, 85 + Math.RandomLong( 0, 0x1f ) );
				break;
			}
		}

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		basePlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			if( self.m_iClip == 0 && !m_fShotgunReload && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0 )
			{
				self.Reload();
			}
			else if( m_fShotgunReload )
			{
				if( self.m_iClip != RCSHOTGUN_MAX_CLIP && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
				{
					self.Reload();
				}
				else
				{
					// reload debounce has timed out
					self.SendWeaponAnim( RCSHOTGUN_PUMP, 0, 0 );

					g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_ITEM, "weapons/scock1.wav", 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0,0x1f ) );
					m_fShotgunReload = false;
					self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
				}
			}
			else
			{
				int iAnim;
				float flRand = g_PlayerFuncs.SharedRandomFloat( basePlayer.random_seed, 0, 1 );
				if( flRand <= 0.8 )
				{
					iAnim = RCSHOTGUN_IDLE_DEEP;
					self.m_flTimeWeaponIdle = g_Engine.time + (60.0/12.0);
				}
				else if( flRand <= 0.95 )
				{
					iAnim = RCSHOTGUN_IDLE;
					self.m_flTimeWeaponIdle = g_Engine.time + (20.0/9.0);
				}
				else
				{
					iAnim = RCSHOTGUN_IDLE4;
					self.m_flTimeWeaponIdle = g_Engine.time+ (20.0/9.0);
				}
				self.SendWeaponAnim( iAnim, 1, 0 );
			}
		}
	}
}

void RegisterRCShotgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_rcshotgun", "weapon_rcshotgun" );
	g_ItemRegistry.RegisterWeapon( "weapon_rcshotgun", "custom_weapons", "buckshot" );
}