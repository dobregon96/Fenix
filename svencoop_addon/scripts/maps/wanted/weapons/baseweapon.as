#include "weapon_knife"
#include "weapon_pick"
#include "weapon_pistol"
#include "weapon_colts"
#include "weapon_shotgun"
#include "weapon_winchester"
#include "weapon_bow"
#include "weapon_dynamite"
#include "weapon_gattlinggun"
#include "weapon_cannon"
#include "weapon_buffalo"
#include "weapon_beartrap"
#include "weapon_scorpion"

array<ItemMapping@> IM_WANTED_WEAPONS =
{
	ItemMapping( "weapon_9mmhandgun",	HLWanted_Pistol::GetPistolName() ),
	ItemMapping( "weapon_9mmAR",		HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_crowbar",		HLWanted_Knife::GetKnifeName() ),
	ItemMapping( "weapon_crossbow",		HLWanted_Bow::GetBowName() ),
	ItemMapping( "weapon_sniperrifle",	HLWanted_Buffalo::GetBuffaloName() ),
	ItemMapping( "weapon_mp5",			HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_m16",			HLWanted_Winchester::GetWinchesterName() ),
	ItemMapping( "weapon_357",			HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_eagle",		HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_uzi",			HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_uziakimbo",	HLWanted_Colts::GetColtsName() ),
	ItemMapping( "weapon_shotgun",		HLWanted_Shotgun::GetShotgunName() ),
	ItemMapping( "weapon_handgrenade",	HLWanted_Dynamite::GetDynamiteName() ),
	ItemMapping( "weapon_pipewrench",	HLWanted_PickAxe::GetPickName() ),
	ItemMapping( "weapon_satchel",		HLWanted_Beartrap::GetBeartrapName() ),
	ItemMapping( "weapon_tripmine",		HLWanted_Beartrap::GetBeartrapName() ),
	ItemMapping( "weapon_grapple",		HLWanted_Scorpion::GetScorpionName() ),
	ItemMapping( "weapon_snark",		HLWanted_Scorpion::GetScorpionName() ),
	ItemMapping( "weapon_sporelauncher",HLWanted_Scorpion::GetScorpionName() ),
	ItemMapping( "weapon_hornetgun",	HLWanted_Scorpion::GetScorpionName() ),
	ItemMapping( "weapon_shockrifle",	HLWanted_Scorpion::GetScorpionName() ),
	ItemMapping( "weapon_rpg",			HLWanted_Cannon::GetCannonName() ),
	ItemMapping( "weapon_pickaxe",		HLWanted_PickAxe::GetPickName() ),
	ItemMapping( "weapon_saw",			HLWanted_Gattlinggun::GetGattlinggunName() ),
	ItemMapping( "weapon_m249",			HLWanted_Gattlinggun::GetGattlinggunName() ),
	ItemMapping( "weapon_minigun",		HLWanted_Gattlinggun::GetGattlinggunName() ),
	ItemMapping( "weapon_egon",			HLWanted_Gattlinggun::GetGattlinggunName() ),
	ItemMapping( "weapon_gauss",		HLWanted_Cannon::GetCannonName() ),
	ItemMapping( "weapon_displacer",	HLWanted_Cannon::GetCannonName() ),
	ItemMapping( "ammo_9mmclip",		HLWanted_Pistol::GetPistolAmmoName() ),
	ItemMapping( "ammo_9mmuziclip",		HLWanted_Pistol::GetPistolAmmoName() ),
	ItemMapping( "ammo_9mmAR",			HLWanted_Pistol::GetPistolAmmoName() ),
	ItemMapping( "ammo_357",			HLWanted_Winchester::GetWinchesterAmmoName() ),
	ItemMapping( "ammo_762",			HLWanted_Buffalo::GetBuffaloAmmoName() ),
	ItemMapping( "ammo_crossbow",		HLWanted_Bow::GetBowAmmoName() ),
	ItemMapping( "ammo_rpgclip",		HLWanted_Cannon::GetCannonAmmoName() )
};

void HLWanted_WeaponsRegister()
{
	HLWanted_Knife::Register();
	HLWanted_PickAxe::Register();
	HLWanted_Pistol::Register();
	HLWanted_Colts::Register();
	HLWanted_Shotgun::Register();
	HLWanted_Winchester::Register();
	HLWanted_Bow::Register();
	HLWanted_Dynamite::Register();
	HLWanted_Gattlinggun::Register();
	HLWanted_Cannon::Register();
	HLWanted_Buffalo::Register();
	HLWanted_Beartrap::Register();
	HLWanted_Scorpion::Register();

	g_ClassicMode.SetItemMappings( @IM_WANTED_WEAPONS );
	g_ClassicMode.ForceItemRemap( true );

	g_Hooks.RegisterHook( Hooks::PickupObject::Materialize, @ReplaceSpawnedItems );
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
}
// Additional funcs for managing weapons and ammo in world - Outerbeast
bool blAmmoPlaced = false;

HookReturnCode ReplaceSpawnedItems(CBaseEntity@ pOldItem) 
{
    if( pOldItem is null ) 
        return HOOK_CONTINUE;

	if( pOldItem.GetTargetname() == "invisible_ammo" )
	{
		pOldItem.pev.rendermode = kRenderTransTexture;
		pOldItem.pev.renderamt = 0.0f;
	}

    for( uint w = 0; w < IM_WANTED_WEAPONS.length(); ++w )
    {
        if( pOldItem.GetClassname() != IM_WANTED_WEAPONS[w].get_From() )
			continue;
			
		CBaseEntity@ pNewItem = g_EntityFuncs.Create( IM_WANTED_WEAPONS[w].get_To(), pOldItem.GetOrigin(), pOldItem.pev.angles, false );

		if( pNewItem is null ) 
			continue;

		pNewItem.pev.movetype = pOldItem.pev.movetype;

		if( pOldItem.GetTargetname() != "" )
			g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "targetname", pOldItem.GetTargetname() );

		if( pOldItem.pev.target != "" )
			g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "target", pOldItem.pev.target );

		if( pOldItem.pev.netname != "" )
			g_EntityFuncs.DispatchKeyValue( pNewItem.edict(), "netname", pOldItem.pev.netname );

		PlaceAmmo( EHandle( pNewItem ) );
		
		g_EntityFuncs.Remove( pOldItem );
    }

	if( !blAmmoPlaced )
	{
		for( uint w = 0; w < IM_WANTED_WEAPONS.length(); ++w )
		{
			if( pOldItem.GetClassname() != IM_WANTED_WEAPONS[w].get_To() )
				continue;

			blAmmoPlaced = PlaceAmmo( EHandle( pOldItem ) );
		}
	}
    return HOOK_CONTINUE;
}
// Place ammo for the spawned weapons now
bool PlaceAmmo(EHandle hWeapon)
{
	if( !hWeapon || cast<CBasePlayerWeapon@>( hWeapon.GetEntity() ) is null )
		return false;

	dictionary ammo =
	{
		{ "origin", "" + hWeapon.GetEntity().GetOrigin().ToString() },
		// !-BUG-! item entities don't retain render settings upon respawn after collection, need to check this name and reapply the render in Pickup hook
		{ "targetname", "invisible_ammo" },
		{ "rendermode", "2" },
		{ "renderamt", "0" }	
	};
	CBaseEntity@ pAmmo = g_EntityFuncs.CreateEntity( "ammo_" + cast<CBasePlayerWeapon@>( hWeapon.GetEntity() ).pszAmmo1(), ammo, true );

	if( pAmmo !is null )
		return true;
	else
		return false;
}
// Temp fix for ammo_ entities not equippable from map cfgs
HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	if( pPlayer is null || !pPlayer.IsAlive() )
		return HOOK_CONTINUE;

	g_Scheduler.SetTimeout( "EquipAmmo", 0.0f, EHandle( pPlayer ) );

	return HOOK_CONTINUE;
}

void EquipAmmo(EHandle hPlayer)
{
	if( !hPlayer )
		return;
	
	CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
	array<string> STR_CHECKED;

	for( uint w = 0; w < IM_WANTED_WEAPONS.length(); ++w )
    {
		CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.HasNamedPlayerItem( IM_WANTED_WEAPONS[w].get_To() ) );
		
		if( pWeapon is null || STR_CHECKED.find( pWeapon.GetClassname() ) >= 0 )
			continue;

		STR_CHECKED.insertLast( pWeapon.GetClassname() );

		if( pWeapon.GetClassname() == HLWanted_Scorpion::GetScorpionName() || 
			pWeapon.GetClassname() == HLWanted_Knife::GetKnifeName() || 
			pWeapon.GetClassname() == HLWanted_PickAxe::GetPickName() )
			continue;
		
		/* int iAmmoGiven = */ pPlayer.GiveAmmo( pWeapon.iMaxClip(), pWeapon.pszAmmo1(), pWeapon.iMaxAmmo1() );
		//g_EngineFuncs.ServerPrint( "-- DEBUG: Wanted basweapon equipped " + pPlayer.pev.netname + " with weapon " + pWeapon.GetClassname() + "'s ammo " +  pWeapon.pszAmmo1() + " - amount : " + iAmmoGiven + "\n" );
    }
}

class CBaseCustomWeapon : ScriptBasePlayerWeaponEntity
{
	// Possible workaround for the SendWeaponAnim() access violation crash.
	// According to R4to0 this seems to provide at least some improvement.
	// GeckoN: TODO: Remove this once the core issue is addressed.
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}

	protected bool m_fDropped;
	CBasePlayerItem@ DropItem()
	{
		m_fDropped = true;
		return self;
	}

	void GetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity,
		Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale )
	{
		Vector vecForward, vecRight, vecUp;

		g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );

		const float fR = Math.RandomFloat( 50, 70 );
		const float fU = Math.RandomFloat( 100, 150 );

		for( int i = 0; i < 3; ++i )
		{
			ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
			ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
		}
	}
}

class CBaseCustomAmmo : ScriptBasePlayerAmmoEntity
{
	protected string m_strModel = "models/error.mdl";
	protected string m_strName;
	protected int m_iAmount = 0;
	protected int m_iMax = 0;

	protected string m_strPickupSound = "items/gunpickup2.wav";

	void Precache()
	{
		g_Game.PrecacheModel( m_strModel );

		g_SoundSystem.PrecacheSound( m_strPickupSound );
	}

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, m_strModel );
		BaseClass.Spawn();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( m_iAmount, m_strName, m_iMax, false ) == -1 )
			return false;

		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, m_strPickupSound, 1, ATTN_NORM );

		return true;
	}
}