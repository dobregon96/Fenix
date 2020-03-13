#include "ww2common"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "KernCore && D.N.I.O. 071" );
	g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/0wtJ6aAd7XOGI6vI" );
}

void MapInit()
{
	RegisterBritish();
	//AddItem( BuyMenu::BuyableItem( "Kitchen Knife", CoFKNIFEName(), 5, "primary", "melee" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "9mm", "ammo_9mmAR", 1, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "556", "ammo_556", 2, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "357", "ammo_357", 3, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "rockets", "ammo_rpgclip", 4, "ammo", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Mills Bomb", GetMILLSName(), 5, "equipment", "" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Webley Revolver", GetWEBLEYName(), 10, "secondary", "handgun" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Fairbairn-Sykes", GetFAIRBName(), 5, "secondary", "melee" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Sten MK2", GetSTENName(), 15, "primary", "smg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Lee Enfield w/ Bayonet", GetENFIELDName(), 60, "primary", "bolt_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "M1 Garand w/ Melee", GetGARANDName(), 55, "primary", "semi_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Bren LMG", GetBRENName(), 65, "primary", "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Lewis LMG", GetLEWISName(), 70, "primary", "lmg" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "Lee Enfield w/ Scope", GetENFIELDSName(), 80, "primary", "bolt_rifle" ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "PIAT", GetPIATName(), 90, "primary", "launcher" ) );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}