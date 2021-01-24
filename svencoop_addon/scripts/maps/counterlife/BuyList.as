// Buymenu
#include "BuyMenu"

BuyMenu::BuyMenu g_BuyMenu;

void BuyableRegister()
{
	g_BuyMenu.RemoveItems();

	//Melees
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_KNIFE::WPN_NAME, CS16_KNIFE::GetName(), uint( CS16_KNIFE::WPN_PRICE / 10 ), "melee" ) );


	//Pistols and Handguns
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_GLOCK18::WPN_NAME, CS16_GLOCK18::GetName(), uint( CS16_GLOCK18::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_GLOCK18::AMMO_NAME, CS16_GLOCK18::GetAmmoName(), uint( CS16_GLOCK18::AMMO_PRICE / 10 ), "ammo", "handgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_USP::WPN_NAME, CS16_USP::GetName(), uint( CS16_USP::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_USP::AMMO_NAME, CS16_USP::GetAmmoName(), uint(CS16_USP::AMMO_PRICE / 10 ), "ammo", "handgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_P228::WPN_NAME, CS16_P228::GetName(), uint( CS16_P228::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_P228::AMMO_NAME, CS16_P228::GetAmmoName(), uint( CS16_P228::AMMO_PRICE / 10 ), "ammo", "handgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_57::WPN_NAME, CS16_57::GetName(), uint( CS16_57::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_57::AMMO_NAME, CS16_57::GetAmmoName(), uint( CS16_57::AMMO_PRICE / 10 ), "ammo", "handgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_ELITES::WPN_NAME, CS16_ELITES::GetName(), uint( CS16_ELITES::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_ELITES::AMMO_NAME, CS16_ELITES::GetAmmoName(), uint( CS16_ELITES::AMMO_PRICE / 10 ), "ammo", "handgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_DEAGLE::WPN_NAME, CS16_DEAGLE::GetName(), uint( CS16_DEAGLE::WPN_PRICE / 10 ), "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_DEAGLE::AMMO_NAME, CS16_DEAGLE::GetAmmoName(), uint( CS16_DEAGLE::AMMO_PRICE / 10 ), "ammo", "handgun" ) );


	//Shotguns
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M3::WPN_NAME, CS16_M3::GetName(), uint( CS16_M3::WPN_PRICE / 10 ), "shotgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M3::AMMO_NAME, CS16_M3::GetAmmoName(), uint( CS16_M3::AMMO_PRICE / 10 ), "ammo", "shotgun" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_XM1014::WPN_NAME, CS16_XM1014::GetName(), uint( CS16_XM1014::WPN_PRICE / 10 ), "shotgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_XM1014::AMMO_NAME, CS16_XM1014::GetAmmoName(), uint( CS16_XM1014::AMMO_PRICE / 10 ), "ammo", "shotgun" ) );


	//Submachine guns
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_MAC10::WPN_NAME, CS16_MAC10::GetName(), uint( CS16_MAC10::WPN_PRICE / 10 ), "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_MAC10::AMMO_NAME, CS16_MAC10::GetAmmoName(), uint( CS16_MAC10::AMMO_PRICE / 10 ), "ammo", "smg" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_TMP::WPN_NAME, CS16_TMP::GetName(), uint( CS16_TMP::WPN_PRICE / 10 ), "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_TMP::AMMO_NAME, CS16_TMP::GetAmmoName(), uint( CS16_TMP::AMMO_PRICE / 10 ), "ammo", "smg" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_MP5::WPN_NAME, CS16_MP5::GetName(), uint( CS16_MP5::WPN_PRICE / 10 ), "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_MP5::AMMO_NAME, CS16_MP5::GetAmmoName(), uint( CS16_MP5::AMMO_PRICE / 10 ), "ammo", "smg" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_UMP45::WPN_NAME, CS16_UMP45::GetName(), uint( CS16_UMP45::WPN_PRICE / 10 ), "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_UMP45::AMMO_NAME, CS16_UMP45::GetAmmoName(), uint( CS16_UMP45::AMMO_PRICE / 10 ), "ammo", "smg" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_P90::WPN_NAME, CS16_P90::GetName(), uint( CS16_P90::WPN_PRICE / 10 ), "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_P90::AMMO_NAME, CS16_P90::GetAmmoName(), uint( CS16_P90::AMMO_PRICE / 10 ), "ammo", "smg" ) );


	//Assault Rifles & Sniper Rifles
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_FAMAS::WPN_NAME, CS16_FAMAS::GetName(), uint( CS16_FAMAS::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_FAMAS::AMMO_NAME, CS16_FAMAS::GetAmmoName(), uint( CS16_FAMAS::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_GALIL::WPN_NAME, CS16_GALIL::GetName(), uint( CS16_GALIL::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_GALIL::AMMO_NAME, CS16_GALIL::GetAmmoName(), uint( CS16_GALIL::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AK47::WPN_NAME, CS16_AK47::GetName(), uint( CS16_AK47::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AK47::AMMO_NAME, CS16_AK47::GetAmmoName(), uint( CS16_AK47::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M4A1::WPN_NAME, CS16_M4A1::GetName(),uint(  CS16_M4A1::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M4A1::AMMO_NAME, CS16_M4A1::GetAmmoName(), uint( CS16_M4A1::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AUG::WPN_NAME, CS16_AUG::GetName(), uint( CS16_AUG::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AUG::AMMO_NAME, CS16_AUG::GetAmmoName(), uint( CS16_AUG::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SG552::WPN_NAME, CS16_SG552::GetName(), uint( CS16_SG552::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SG552::AMMO_NAME, CS16_SG552::GetAmmoName(), uint( CS16_SG552::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SCOUT::WPN_NAME, CS16_SCOUT::GetName(), uint( CS16_SCOUT::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SCOUT::AMMO_NAME, CS16_SCOUT::GetAmmoName(), uint( CS16_SCOUT::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AWP::WPN_NAME, CS16_AWP::GetName(), uint( CS16_AWP::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_AWP::AMMO_NAME, CS16_AWP::GetAmmoName(), uint( CS16_AWP::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SG550::WPN_NAME, CS16_SG550::GetName(), uint( CS16_SG550::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_SG550::AMMO_NAME, CS16_SG550::GetAmmoName(), uint( CS16_SG550::AMMO_PRICE / 10 ), "ammo", "rifle" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_G3SG1::WPN_NAME, CS16_G3SG1::GetName(), uint( CS16_G3SG1::WPN_PRICE / 10 ), "rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_G3SG1::AMMO_NAME, CS16_G3SG1::GetAmmoName(), uint( CS16_G3SG1::AMMO_PRICE / 10 ), "ammo", "rifle" ) );


	//Light Machine Guns
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M249::WPN_NAME, CS16_M249::GetName(), uint( CS16_M249::WPN_PRICE / 10 ), "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_M249::AMMO_NAME, CS16_M249::GetAmmoName(), uint( CS16_M249::AMMO_PRICE / 10 ), "ammo", "lmg" ) );


	//Explosives and Equipment
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_HEGRENADE::WPN_NAME, CS16_HEGRENADE::GetName(), uint( CS16_HEGRENADE::WPN_PRICE / 10 ), "equip" ) );

	g_BuyMenu.AddItem( BuyMenu::BuyableItem( CS16_C4::WPN_NAME, CS16_C4::GetName(), uint( CS16_C4::WPN_PRICE / 10 ), "equip" ) );
}