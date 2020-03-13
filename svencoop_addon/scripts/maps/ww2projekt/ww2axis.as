#include "ww2common"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "KernCore && D.N.I.O. 071" );
	g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/0wtJ6aAd7XOGI6vI" );
}

void MapInit()
{
	RegisterGerman();
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "9mm", "ammo_9mmAR", 1, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "556", "ammo_556", 2, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "357", "ammo_357", 3, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "rockets", "ammo_rpgclip", 4, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Stielhandgranate", GetSTICKName(), 5, "equipment", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Luger P08", GetLUGERName(), 5, "secondary", "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Mauser C96", GetC96Name(), 11, "secondary", "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "German Shovel", GetSPADEName(), 5, "secondary", "melee" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "MP40", GetMP40Name(), 15, "primary", "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "MP44", GetMP44Name(), 25, "primary", "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "FG42", GetFG42Name(), 35, "primary", "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Gewehr 43", GetG43Name(), 40, "primary", "semi_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Karabiner 98k w/ Bayonet", GetK98KName(), 50, "primary", "bolt_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "MG34", GetMG34Name(), 70, "primary", "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Karabiner 98k w/ Scope", GetSCOPED98KName(), 75, "primary", "bolt_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Panzerschreck", GetPANZERSName(), 90, "primary", "launcher" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "MG42", GetMG42Name(), 100, "primary", "lmg" ) );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}