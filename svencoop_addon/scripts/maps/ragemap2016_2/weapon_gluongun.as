/*  
* Gluongun - Converted from Half-Life: Weapons Edition
* 
*	
*	
*/

#include "proj_gluon"

enum gluongun_e 
{
	GLUONGUN_IDLE,
	GLUONGUN_IDLE2,
	GLUONGUN_FIRE,
	GLUONGUN_FIRE_SOLID,
	GLUONGUN_CHARGE,
	GLUONGUN_RELOAD,
	GLUONGUN_DRAW,
	GLUONGUN_HOLSTER
};

const int GLUONGUN_DEFAULT_GIVE 	= 20;
const int GLUONGUN_MAX_AMMO			= 100;
const int GLUONGUN_MAX_CLIP 		= 20;
const int GLUONGUN_WEIGHT 			= 69;
const int GLUON_VELOCITY			= 2500;

const float GLUONGUN_FIRE_RATE		= 1.0;

const string GLUONGUN_PLAYERMODEL 			= 					"models/custom_weapons/gluongun/p_gluongun.mdl";
const string GLUONGUN_VIEWMODEL				=  					"models/custom_weapons/gluongun/v_gluongun.mdl";
const string GLUONGUN_WORLDMODEL 			= 					"models/custom_weapons/gluongun/w_gluongun.mdl";
const string GLUONGUN_MODEL_AMMO			=					"models/custom_weapons/hlwe/w_clips_all.mdl";
const string GLUONGUN_MODEL_CLIP			=					"models/custom_weapons/gluongun/w_clip_gluoncell.mdl";

const string GLUONGUN_SOUND_FIRE			=					"custom_weapons/gluongun/gluongun_zap.wav";
const string GLUONGUN_SOUND_FIRE2			=					"custom_weapons/gluongun/gluongun_fire.wav";
const string GLUONGUN_SOUND_EXPLODE			=					"custom_weapons/gluongun/gluon_hitwall2.wav";
const string GLUONGUN_SOUND_EXPLODE2		=					"custom_weapons/gluongun/gluon_hitwall.wav";
const string GLUONGUN_SOUND_CHARGE			=					"custom_weapons/gluongun/gluongun_charge.wav";

const string GLUONGUN_SPRITE_PROJECTILE 	=					"sprites/custom_weapons/anim_spr6.spr";
const string GLUONGUN_SPRITE_2 				=					"sprites/custom_weapons/anim_spr2.spr";
const string GLUONGUN_SPRITE_4 				=					"sprites/custom_weapons/anim_spr4.spr";

class CGluongun : ScriptBasePlayerWeaponEntity
{
	
	int m_fInAttack;
	int m_iWastedAmmo;
	int m_iDroppedClip;
	int m_iGluonClip;
	
	float m_flNextAmmoBurn;
	float m_flStartCharge;
	float m_flAmmoStartCharge;
	float m_flIdleDelay;
	
	void Spawn()
	{
		Precache();
		
		g_EntityFuncs.SetModel( self, GLUONGUN_WORLDMODEL );
		
		self.m_iDefaultAmmo = GLUONGUN_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		
		self.PrecacheCustomModels();
		
		// MODELS
		
		g_Game.PrecacheModel( GLUONGUN_VIEWMODEL );
		g_Game.PrecacheModel( GLUONGUN_PLAYERMODEL );
		g_Game.PrecacheModel( GLUONGUN_WORLDMODEL );
		g_Game.PrecacheModel( GLUONGUN_MODEL_AMMO);
		
		m_iGluonClip = g_Game.PrecacheModel( GLUONGUN_MODEL_CLIP);
		
		// SPRITES
		
		g_Game.PrecacheModel( "sprites/custom_weapons/gluongun_ring.spr" );
		g_Game.PrecacheModel( "sprites/custom_weapons/gluongun_trail.spr" );
		g_Game.PrecacheModel( GLUONGUN_SPRITE_2 );
		g_Game.PrecacheModel( GLUONGUN_SPRITE_4 );
		g_Game.PrecacheModel( GLUONGUN_SPRITE_PROJECTILE );
		
		// SOUNDS
		
		g_Game.PrecacheGeneric( "sound/" + GLUONGUN_SOUND_FIRE );
		g_Game.PrecacheGeneric( "sound/" + GLUONGUN_SOUND_CHARGE );
		g_Game.PrecacheGeneric( "sound/" + GLUONGUN_SOUND_EXPLODE );
		g_Game.PrecacheGeneric( "sound/" + GLUONGUN_SOUND_EXPLODE2 );
		g_Game.PrecacheGeneric( "sound/" + GLUONGUN_SOUND_FIRE2);
		
		g_SoundSystem.PrecacheSound( GLUONGUN_SOUND_FIRE );
		g_SoundSystem.PrecacheSound( GLUONGUN_SOUND_FIRE2 );
		g_SoundSystem.PrecacheSound( GLUONGUN_SOUND_CHARGE );
		g_SoundSystem.PrecacheSound( GLUONGUN_SOUND_EXPLODE );
		g_SoundSystem.PrecacheSound( GLUONGUN_SOUND_EXPLODE2 );
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
		
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= GLUONGUN_MAX_AMMO;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= GLUONGUN_MAX_CLIP;
		info.iSlot 		= 5;
		info.iPosition 	= 9;
		info.iFlags 	= 0;
		info.iWeight 	= GLUONGUN_WEIGHT;

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
		if( self.m_bPlayEmptySound  )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( self.m_hPlayer.GetEntity().edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( GLUONGUN_VIEWMODEL ), self.GetP_Model( GLUONGUN_PLAYERMODEL ), GLUONGUN_DRAW, "saw"  ); 
			
			m_flIdleDelay = WeaponTimeBase() + 3.0; // let the viewmodel fully play its deploy animation.
		
			self.m_flTimeWeaponIdle = g_Engine.time + m_flIdleDelay;
			
			return bResult;
		}
		
	}
	
	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false; 
		
		m_fInAttack = 0;
		
		SetThink( null );
		
		g_SoundSystem.StopSound(self.m_hPlayer.GetEntity().edict(), CHAN_WEAPON, GLUONGUN_SOUND_CHARGE);
		
		cast<CBasePlayer>(self.m_hPlayer.GetEntity()).m_flNextAttack = WeaponTimeBase() + 3.0;
		
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
	
		 // don't fire underwater
		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.55;
			return;
		}
		
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.55;
			return;
		}
		
		basePlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		
		self.m_iClip -= 2;
		
		self.SendWeaponAnim( GLUONGUN_FIRE, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_FIRE, 1.0, ATTN_NORM, 0, 100 );
		
		// player "shoot" animation
		basePlayer.SetAnimation( PLAYER_ATTACK1 );
		
		// Shoot the gluon projectile!
		ShootGluon( basePlayer.pev, basePlayer.pev.origin + basePlayer.pev.view_ofs + g_Engine.v_forward * 12 + g_Engine.v_right * 3 + g_Engine.v_up * -8, g_Engine.v_forward * GLUON_VELOCITY , false , 0 );
		
		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		
		basePlayer.pev.punchangle.x -= 8;
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE;
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( basePlayer.random_seed,  7, 12 );
		
	}
	
	void SecondaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		
		// don't fire underwater
		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55;
			return;
		}

		if ( m_fInAttack == 0 )
		{
			if( self.m_iClip <= 0 )
			{
				self.PlayEmptySound();
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.55;
				return;
			}

			self.m_iClip-=2;
			
			m_iWastedAmmo+=2;
			
			m_flNextAmmoBurn = WeaponTimeBase();
			
			m_fInAttack = 1;
			
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.25;
			
			m_flStartCharge = WeaponTimeBase();
			
			m_flAmmoStartCharge = WeaponTimeBase() + 3.2;

			g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_CHARGE, 1.0, ATTN_NORM, 0, 100 );
			
			self.SendWeaponAnim( GLUONGUN_CHARGE, 0, 0 );
			
			if ( self.m_iClip <= 0 )
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
				self.m_iClip = 0;
				return;
			}
		}
		
		else if (m_fInAttack == 1)
		{
			if (self.m_flTimeWeaponIdle < WeaponTimeBase())
			{
				m_fInAttack = 2;
			}
		}
		
		else
		{
			// during the charging process, eat one bit of ammo every once in a while
			if ( WeaponTimeBase() >= m_flNextAmmoBurn && m_flNextAmmoBurn != 1000 )
			{
				
				self.m_iClip-=2;
				
				m_iWastedAmmo+=2;
				
				m_flNextAmmoBurn = WeaponTimeBase() + 0.6;
				
			}
			
			if ( self.m_iClip <= 0 )
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;
				self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
				self.m_iClip = 0;
				return;
			}
		
			if ( WeaponTimeBase() >= m_flAmmoStartCharge )
				m_flNextAmmoBurn = 1000;

			if ( m_flStartCharge < WeaponTimeBase() - 3.4)
			{
				StartFire();
				m_fInAttack = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
				self.m_flNextPrimaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE;
				return;
			}
		}
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE / 4;
	}
	
	void StartFire()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
	
		basePlayer.SetAnimation( PLAYER_ATTACK1 );
		
		g_SoundSystem.StopSound(basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_CHARGE);
		
		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		
		self.SendWeaponAnim( GLUONGUN_FIRE, 0, 0 );
	
		ShootGluon( basePlayer.pev, basePlayer.pev.origin + basePlayer.pev.view_ofs + g_Engine.v_forward * 12 + g_Engine.v_right * 3 + g_Engine.v_up * -8, g_Engine.v_forward * (m_iWastedAmmo*700) , true , m_iWastedAmmo );
		
		g_SoundSystem.EmitSoundDyn( basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_FIRE2, 1.0, ATTN_NORM, 0, 100 );
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
		
		basePlayer.pev.punchangle.x -= 8 + m_iWastedAmmo;
		
		m_iWastedAmmo = 0;
		
		m_fInAttack = 0;
	
	}
	
	void Reload()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		
		if ( m_fInAttack != 0 )
		return;
		
		if (self.m_iClip == GLUONGUN_MAX_CLIP) // Can't reload if we have a full magazine already!
			return;
		
		if ( basePlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 ) // This is so you can't call this function with no Primary Ammo in reserve.
			return;
			
		g_SoundSystem.StopSound(basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_CHARGE);
		
		self.DefaultReload( GLUONGUN_MAX_CLIP, GLUONGUN_RELOAD, 4.8, 0 );
		
		self.pev.nextthink = WeaponTimeBase() + 2.2;
		
		self.m_flTimeWeaponIdle = g_Engine.time + 4.8;
		
		SetThink( ThinkFunction( EjectClipThink ) );
		
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		
		if (m_fInAttack != 0)
		{
			StartFire();
			m_fInAttack = 0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0;
			self.m_flNextSecondaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE * 2;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + GLUONGUN_FIRE_RATE;
			
			g_SoundSystem.StopSound(basePlayer.edict(), CHAN_WEAPON, GLUONGUN_SOUND_CHARGE);
		}
		
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;
		
		int iAnim;
		
		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0:	iAnim = GLUONGUN_IDLE;	break;
			case 1:	iAnim = GLUONGUN_IDLE2;	break;
			
		}
		
		if ( m_iDroppedClip == 1)
		{
		
			m_iDroppedClip = 0;
		
		}
		
		self.SendWeaponAnim( iAnim );
		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 5, 7 );
		
	}
	
	// EXPERIMENTAL CLIP CASTING
	void EjectClipThink()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		ClipCasting( basePlayer.pev.origin, g_Engine.v_up * -8);
	}
	
	void ClipCasting( Vector origin, Vector angles )
	{
		
		if (m_iDroppedClip == 1) // Check to see if I already dropped them
			return;
			
		int lifetime = 100;
		
		if (self.m_iClip <= GLUONGUN_MAX_CLIP / 2) // Drop one clip if we're between 1 - 10
		{
		
			NetworkMessage gluoncell1(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
				gluoncell1.WriteByte(TE_MODEL);
				gluoncell1.WriteCoord(origin.x);
				gluoncell1.WriteCoord(origin.y);
				gluoncell1.WriteCoord(origin.z);
				gluoncell1.WriteCoord(Math.RandomFloat(50,75)); // velocity
				gluoncell1.WriteCoord(Math.RandomFloat(50,75)); // velocity
				gluoncell1.WriteCoord(Math.RandomFloat(50,75)); // velocity
				gluoncell1.WriteAngle(Math.RandomFloat(0,180)); // yaw
				gluoncell1.WriteShort(m_iGluonClip); // model
				gluoncell1.WriteByte(2); // bouncesound
				gluoncell1.WriteByte(int(lifetime)); // decay time
			gluoncell1.End();
		
			m_iDroppedClip = 1;
		
		}
		
		if (self.m_iClip == 0) // drop an additional clip if we're completely empty!
		{
		
			NetworkMessage gluoncell2a(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
				gluoncell2a.WriteByte(TE_MODEL);
				gluoncell2a.WriteCoord(origin.x);
				gluoncell2a.WriteCoord(origin.y);
				gluoncell2a.WriteCoord(origin.z);
				gluoncell2a.WriteCoord(0); // velocity
				gluoncell2a.WriteCoord(0); // velocity
				gluoncell2a.WriteCoord(Math.RandomLong(5,30)); // velocity
				gluoncell2a.WriteAngle(0); // yaw
				gluoncell2a.WriteShort(m_iGluonClip); // model
				gluoncell2a.WriteByte(2); // bouncesound
				gluoncell2a.WriteByte(int(lifetime)); // decay time
			gluoncell2a.End();
		
			m_iDroppedClip = 1;
		
		}
		
	}
}

class GluonAmmo : ScriptBasePlayerAmmoEntity
{	
	void Spawn()
	{ 
		Precache();
		
		g_EntityFuncs.SetModel( self, GLUONGUN_MODEL_AMMO );
		
		self.pev.body = 30; // use the gluoncell bodygroup of w_clips_all.mdl
		
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( GLUONGUN_MODEL_AMMO );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		int iGive;

		iGive = GLUONGUN_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "gluoncells", GLUONGUN_MAX_AMMO ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

string GetGluonGunName()
{
	return "weapon_gluongun";
}

void RegisterGluonGun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CGluongun", GetGluonGunName() );
	g_ItemRegistry.RegisterWeapon( GetGluonGunName(), "custom_weapons", "gluoncells" );
}

void RegisterGluonAmmo()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "GluonAmmo", "ammo_gluoncell" );
}