#include "ww2common"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "KernCore && D.N.I.O. 071" );
	g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/0wtJ6aAd7XOGI6vI" );
}

void MapInit()
{
	RegisterAmerican();
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "9mm", "ammo_9mmAR", 1, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "556", "ammo_556", 2, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "357", "ammo_357", 3, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "rockets", "ammo_rpgclip", 4, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Mk.2 Grenade", GetMK2GRENADEName(), 5, "equipment", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Colt M1911", GetM1911Name(), 7, "secondary", "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M4 Bayonet", GetBAYOName(), 5, "secondary", "melee" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Thompson M1A1", GetTHOMPSONName(), 15, "primary", "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Thompson M3 Grease Gun", GetM3GREASEGUNName(), 25, "primary", "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "BAR", GetBARName(), 35, "primary", "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M1 Carbine", GetM1CARBName(), 45, "primary", "semi_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M1 Garand w/ Melee", GetGARANDName(), 55, "primary", "semi_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Springfield", GetSPRINGFName(), 75, "primary", "bolt_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M1A1 Bazooka", GetBAZOOKAName(), 90, "primary", "launcher" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M1919a4 .30 Cal", GetTHIRTYCALName(), 100, "primary", "lmg" ) );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}