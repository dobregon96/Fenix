#include "proj_nuke"

const int REDEEMER_DEFAULT_GIVE			= 4;
const int REDEEMER_MAX_CARRY			= 20;
const int REDEEMER_MAX_CLIP				= 2;
const int REDEEMER_WEIGHT				= 110;
const int REDEEMER_DAMAGE				= 1500;

const string REDEEMER_SOUND_DRAW		= "custom_weapons/redeemer/redeemer_draw.wav";
const string REDEEMER_SOUND_FIRE		= "custom_weapons/redeemer/redeemer_fire.wav";
const string REDEEMER_SOUND_RELOAD		= "custom_weapons/redeemer/redeemer_reload.wav";
const string REDEEMER_SOUND_FLY			= "custom_weapons/redeemer/redeemer_WH_fly.wav";
const string REDEEMER_SOUND_EXPLODE		= "custom_weapons/redeemer/redeemer_WH_explode.wav";

const string REDEEMER_MODEL_VIEW		= "models/custom_weapons/redeemer/v_redeemer.mdl";
const string REDEEMER_MODEL_PLAYER		= "models/custom_weapons/redeemer/p_redeemer.mdl";
const string REDEEMER_MODEL_PROJECTILE	= "models/custom_weapons/hlwe/projectiles.mdl";
//const string REDEEMER_MODEL_CLIP		= "models/w_weaponbox.mdl";
const string REDEEMER_MODEL_CLIP		= "models/custom_weapons/hlwe/projectiles.mdl";

array<bool> g_bIsNukeFlying(33);

enum redeemer_e
{
	REDEEMER_IDLE,
	REDEEMER_DRAW,
	REDEEMER_FIRE,
	REDEEMER_FIRE_SOLID,
	REDEEMER_HOLSTER,
	REDEEMER_RELOAD
};

class CRedeemer : ScriptBasePlayerWeaponEntity
{
	float ATTN_LOW = 0.5;
	
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, REDEEMER_MODEL_PLAYER );
		self.m_iDefaultAmmo = REDEEMER_DEFAULT_GIVE;
		self.pev.sequence = 1;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( REDEEMER_MODEL_VIEW );
		g_Game.PrecacheModel( REDEEMER_MODEL_PLAYER );
		g_Game.PrecacheModel( REDEEMER_MODEL_PROJECTILE );
		g_Game.PrecacheModel( "sprites/spray.spr" );
		
		g_Game.PrecacheModel( "sprites/fexplo.spr" );
		g_Game.PrecacheModel( "sprites/white.spr" );
		g_Game.PrecacheModel( "sprites/spray.spr" );
		g_Game.PrecacheModel( "sprites/hotglow.spr" );
		g_Game.PrecacheModel( "sprites/steam1.spr" );
		g_Game.PrecacheModel( "sprites/smoke.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + REDEEMER_SOUND_DRAW );
		g_Game.PrecacheGeneric( "sound/" + REDEEMER_SOUND_FIRE );
		g_Game.PrecacheGeneric( "sound/" + REDEEMER_SOUND_RELOAD );
		g_Game.PrecacheGeneric( "sound/" + REDEEMER_SOUND_FLY );
		g_Game.PrecacheGeneric( "sound/" + REDEEMER_SOUND_EXPLODE );
		g_SoundSystem.PrecacheSound( REDEEMER_SOUND_DRAW );
		g_SoundSystem.PrecacheSound( REDEEMER_SOUND_FIRE );
		g_SoundSystem.PrecacheSound( REDEEMER_SOUND_RELOAD );
		g_SoundSystem.PrecacheSound( REDEEMER_SOUND_FLY );
		g_SoundSystem.PrecacheSound( REDEEMER_SOUND_EXPLODE );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= REDEEMER_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= REDEEMER_MAX_CLIP;
		info.iSlot 		= 8;
		info.iPosition 	= 8;
		info.iFlags 	= ITEM_FLAG_SELECTONEMPTY | ITEM_FLAG_NOAUTORELOAD;
		info.iWeight 	= REDEEMER_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
			int iIndex = basePlayer.entindex();
			g_bIsNukeFlying[ iIndex ] = false;
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( REDEEMER_MODEL_VIEW ), self.GetP_Model( REDEEMER_MODEL_PLAYER ), REDEEMER_DRAW, "gauss" );
	}

	bool CanHolster()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		int iIndex = basePlayer.entindex();
		return ( !g_bIsNukeFlying[ iIndex ] );
	}

	void Holster( int skipLocal = 0 )
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		basePlayer.m_flNextAttack = WeaponTimeBase() + 0.7;
		self.SendWeaponAnim( REDEEMER_HOLSTER );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		int iIndex = basePlayer.entindex();
		
		if( g_bIsNukeFlying[ iIndex ] )
			return;

		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			return;
		}

		basePlayer.SetAnimation( PLAYER_ATTACK1 );
		self.SendWeaponAnim( REDEEMER_FIRE );
		g_SoundSystem.EmitSound( basePlayer.edict(), CHAN_WEAPON, REDEEMER_SOUND_FIRE, 1.0, ATTN_LOW );
		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle);
		ShootNuke( basePlayer.pev, basePlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * 2 + g_Engine.v_right * -2, g_Engine.v_forward * 1500, false );

		--self.m_iClip;
		self.m_flNextPrimaryAttack = g_Engine.time + 1.5;
		self.m_flNextSecondaryAttack = g_Engine.time + 1.5;
		self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
		basePlayer.pev.punchangle.x -= 15;
	}

	void SecondaryAttack()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		int iIndex = basePlayer.entindex();
		
		if( g_bIsNukeFlying[ iIndex ] )
			return;

		if( basePlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
			return;
		}

		basePlayer.SetAnimation( PLAYER_ATTACK1 );
		self.SendWeaponAnim( REDEEMER_FIRE );
		g_SoundSystem.EmitSound( basePlayer.edict(), CHAN_WEAPON, REDEEMER_SOUND_FIRE, 1.0, ATTN_LOW );
		Math.MakeVectors( basePlayer.pev.v_angle + basePlayer.pev.punchangle );
		ShootNuke( basePlayer.pev, basePlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * 2 + g_Engine.v_right * -2, g_Engine.v_forward * 800, true );
		g_bIsNukeFlying[ iIndex ] = true;

		--self.m_iClip;
		self.m_flNextPrimaryAttack = g_Engine.time + 1.5;
		self.m_flNextSecondaryAttack = g_Engine.time + 1.5;
		self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
		basePlayer.pev.punchangle.x -= 15;
	}

	void WeaponIdle()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		int iIndex = basePlayer.entindex();
		self.m_bExclusiveHold = g_bIsNukeFlying[iIndex] ? true : false;

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		self.SendWeaponAnim( REDEEMER_IDLE );
		self.m_flTimeWeaponIdle = g_Engine.time + 10.0;
	}

	void Reload()
	{
		CBasePlayer@ basePlayer = cast<CBasePlayer>(self.m_hPlayer.GetEntity());
		int iIndex = basePlayer.entindex();
		
		if( self.m_iClip != 0 || g_bIsNukeFlying[ iIndex ] )
			return;
		
		self.DefaultReload( 1, REDEEMER_RELOAD, 3.6 );
	}
}

class NukeAmmoBox : ScriptBasePlayerAmmoEntity
{	
	void Spawn()
	{ 
		Precache();
		g_EntityFuncs.SetModel( self, REDEEMER_MODEL_CLIP );
		self.pev.body = 15;
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( REDEEMER_MODEL_CLIP );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		int iGive;

		iGive = REDEEMER_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "nuke", REDEEMER_MAX_CARRY ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

void RegisterRedeemer()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CRedeemer", "weapon_redeemer" );
	g_ItemRegistry.RegisterWeapon( "weapon_redeemer", "custom_weapons", "nuke" );
}

void RegisterNukeAmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "NukeAmmoBox", "ammo_nuke" );
}
