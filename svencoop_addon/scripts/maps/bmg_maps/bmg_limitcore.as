/*
* Ammo mod script
* This script wraps the functionality needed to set a custom max ammo setting and optionally set ammo count to max
* It also supports execution through trigger_script: use ApplyActiveAmmoModOnPlayer to do this
* Note that this requires an active ammo mod to be set
* Set AmmoMod::g_ActiveAmmoMod to an instance of the class to do so
* Modified version of AmmoMod by SC team specifically for limiting gameplay ammo
*	DO NOT ALTER THIS FILE
*/

namespace AmmoMod
{
class AmmoMod
{
	private dictionary m_AmmoCounts;
	
	dictionary@ AmmoCounts
	{
		get { return @m_AmmoCounts; }
	}
	
	void ApplyOnPlayer( CBasePlayer@ pPlayer )
	{
		if( pPlayer is null )
			return;
			
		array<string>@ ammoTypes = m_AmmoCounts.getKeys();
		
		const uint uiSize = ammoTypes.length();
		
		for( uint uiIndex = 0; uiIndex < uiSize; ++uiIndex )
		{
			pPlayer.SetMaxAmmo( ammoTypes[ uiIndex ], int( m_AmmoCounts[ ammoTypes[ uiIndex ] ] ) );
		}
	}
}

AmmoMod@ g_ActiveAmmoMod = null;
}

void ApplyActiveAmmoModOnPlayer( CBaseEntity@ pPlayer, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	AmmoMod::g_ActiveAmmoMod.ApplyOnPlayer( cast<CBasePlayer@>( pPlayer ) );
}
