#include "proj_gp25"

enum RG6Animation
{
	RG6_IDLE = 0,
	RG6_HOLSTER,
	RG6_DRAW,
	RG6_FIRE,
	RG6_RELOAD1,
	RG6_RELOAD2,
	RG6_RELOAD3
};

enum eLaunchMode
{
	MODE_BOUNCE = 0,
	MODE_INSTANT
};

const int RG6_DEFAULT_GIVE 		= 6;
const int RG6_MAX_CARRY			= RG6_DEFAULT_GIVE*5;
const int RG6_MAX_CLIP 			= 6;
const int RG6_WEIGHT 			= 15;
const float RG6_DAMAGE			= 90.0f;
const int RG6_GRENADE_VELOCITY	= 1500;
const float RG6_GRENADE_RADIUS	= 300.0f;
const float RG6_GRENADE_TIMER	= 3.0f;

const string RG6_MODEL_VIEW		= "models/custom_weapons/rg6/v_rg6.mdl";
const string RG6_MODEL_WORLD	= "models/custom_weapons/rg6/w_rg6.mdl";
const string RG6_MODEL_PLAYER	= "models/custom_weapons/rg6/p_rg6.mdl";
const string RG6_MODEL_CLIP		= "models/custom_weapons/rg6/w_rg6_grenade.mdl";

const string RG6_SOUND_FIRE		= "custom_weapons/rg6/fire1.wav";
const string RG6_SOUND_RELOAD_0	= "custom_weapons/rg6/start.wav";
const string RG6_SOUND_RELOAD_1	= "custom_weapons/rg6/grenload.wav";
const string RG6_SOUND_RELOAD_2	= "custom_weapons/rg6/next.wav";
const string RG6_SOUND_RELOAD_3	= "custom_weapons/rg6/end.wav";
const string RG6_SOUND_BOUNCE	= "weapons/grenade_hit1.wav";
const string RG6_SOUND_SWITCH	= "weapons/scock1.wav";
const string RG6_SPRITE_TRAIL	= "sprites/laserbeam.spr";
const string RG6_SPRITE_EXPLODE	= "sprites/exp_c.spr";
	
class CWeaponRG6 : ScriptBasePlayerWeaponEntity
{
	int g_iCurrentMode;
	int g_iInSpecialReload;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, RG6_MODEL_WORLD );

		self.m_iDefaultAmmo = RG6_DEFAULT_GIVE;
		g_iCurrentMode = 1;

		self.FallInit();
	}

	void Precache()
	{
		g_Game.PrecacheModel( RG6_MODEL_VIEW );
		g_Game.PrecacheModel( RG6_MODEL_WORLD );
		g_Game.PrecacheModel( RG6_MODEL_PLAYER );
		g_Game.PrecacheModel( RG6_MODEL_CLIP );
		g_Game.PrecacheModel( RG6_SPRITE_TRAIL );
		g_Game.PrecacheModel( RG6_SPRITE_EXPLODE );
		
		g_Game.PrecacheGeneric( "sound/" + RG6_SOUND_FIRE );
		g_Game.PrecacheGeneric( "sound/" + RG6_SOUND_RELOAD_0 );
		g_Game.PrecacheGeneric( "sound/" + RG6_SOUND_RELOAD_1 );
		g_Game.PrecacheGeneric( "sound/" + RG6_SOUND_RELOAD_2 );
		g_Game.PrecacheGeneric( "sound/" + RG6_SOUND_RELOAD_3 );

		g_SoundSystem.PrecacheSound( RG6_SOUND_FIRE );
		g_SoundSystem.PrecacheSound( RG6_SOUND_RELOAD_0 );
		g_SoundSystem.PrecacheSound( RG6_SOUND_RELOAD_1 );
		g_SoundSystem.PrecacheSound( RG6_SOUND_RELOAD_2 );
		g_SoundSystem.PrecacheSound( RG6_SOUND_RELOAD_3 );
		g_SoundSystem.PrecacheSound( RG6_SOUND_BOUNCE );
		g_SoundSystem.PrecacheSound( RG6_SOUND_SWITCH );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= RG6_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= RG6_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 5;
		info.iFlags 	= 0;
		info.iWeight 	= RG6_WEIGHT;

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
		return self.DefaultDeploy( self.GetV_Model( RG6_MODEL_VIEW ), self.GetP_Model( RG6_MODEL_PLAYER ), RG6_DRAW, "gauss" );
	}
	
	void Holster( int skipLocal = 0 )
	{	
		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	void PrimaryAttack()
	{
		Vector vecSrc, vecVelocity, vecAngles;
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		
		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		basePlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		basePlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;

		basePlayer.pev.effects = EF_MUZZLEFLASH;

		basePlayer.SetAnimation( PLAYER_ATTACK1 );

		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		vecSrc = basePlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 6;
		
		if( g_iCurrentMode == MODE_BOUNCE )
			ShootGP25Grenade( basePlayer.pev, vecSrc, g_Engine.v_forward * (RG6_GRENADE_VELOCITY/2), MODE_BOUNCE );
		else if( g_iCurrentMode == MODE_INSTANT )
			ShootGP25Grenade( basePlayer.pev, vecSrc, g_Engine.v_forward * RG6_GRENADE_VELOCITY, MODE_INSTANT );
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0f;
		
		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 5.0f;
		else
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.75f;
		
		g_iInSpecialReload = 0;
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, RG6_SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM );
		self.SendWeaponAnim( RG6_FIRE, 0, 0 );
		basePlayer.pev.punchangle.x = -7.0f;
	}

	void SecondaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		switch( g_iCurrentMode )
		{
			case MODE_INSTANT:
			{
				g_iCurrentMode = MODE_BOUNCE;
				g_EngineFuncs.ClientPrintf( basePlayer, print_center, "--> Switched to Grenade Bounce Mode <--\n" );
				break;
			}
			case MODE_BOUNCE:
			{
				g_iCurrentMode = MODE_INSTANT;
				g_EngineFuncs.ClientPrintf( basePlayer, print_center, "--> Switched to Instant Explosion Mode <--\n" );
				break;
			}
		}
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_ITEM, RG6_SOUND_SWITCH, 0.7, ATTN_NORM, 0, 92 );
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2f;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.8f;
	}

	void Reload()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		if( basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == RG6_MAX_CLIP )
			return;

		if( self.m_flNextPrimaryAttack > g_Engine.time )
			return;

		switch( g_iInSpecialReload )
		{
			case 0:
			{
				self.SendWeaponAnim( RG6_RELOAD1, 0, 0 );
				g_iInSpecialReload = 1;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5f;
				self.m_flNextPrimaryAttack = g_Engine.time + 1.0f;
				self.m_flNextSecondaryAttack = g_Engine.time + 1.0f;
				return;
			}
			case 1:
			{
				if( self.m_flTimeWeaponIdle > g_Engine.time )
					return;

				g_iInSpecialReload = 2;
				
				self.SendWeaponAnim( RG6_RELOAD2, 0, 0 );
				self.m_flTimeWeaponIdle = g_Engine.time + 1.25f;
			}
			default:
			{
				self.m_iClip += 1;
				basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType, basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
				
				g_iInSpecialReload = 1;
			}
		}	
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;
		
		int fInSpecialReload;
		fInSpecialReload = g_iInSpecialReload;
		
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		if( self.m_iClip <= 0 && fInSpecialReload <= 0 && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) >= 1 )
		{
			self.Reload();
		}
		else if( fInSpecialReload != 0 )
		{
			if( self.m_iClip != RG6_MAX_CLIP && basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
			{
				self.Reload();
			}
			else
			{
				self.SendWeaponAnim( RG6_RELOAD3, 0, 0 );
				
				g_iInSpecialReload = 0;
				self.m_flTimeWeaponIdle = g_Engine.time + 1.5f;
			}
		}
		else
		{
			self.SendWeaponAnim( RG6_IDLE, 0, 0 );
			self.m_flTimeWeaponIdle = g_Engine.time + 5.0f;
		}
	}
}

class RG6AmmoBox : ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{ 
		Precache();
		g_EntityFuncs.SetModel( self, RG6_MODEL_CLIP );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( RG6_MODEL_CLIP );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		int iGive;

		iGive = RG6_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "gp25_nade", RG6_MAX_CARRY ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

void RegisterRG6()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CWeaponRG6", "weapon_rg6" );
	g_ItemRegistry.RegisterWeapon( "weapon_rg6", "custom_weapons", "gp25_nade" );
}

void RegisterRG6AmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "RG6AmmoBox", "ammo_gp25" );
}