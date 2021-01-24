//Counter-Strike 1.6's Specific BuyMenu
//Author: KernCore, Original script by Solokiller, improved by Zodemon
//Modified for Counter-Life
#include "BuyList"

namespace BuyMenu
{

//fall back for map_script
const int StartMoney = 10;

// Stop using comprar/shop in my buymenus, typing 'buy' is way better than typing 7/4 letters
bool FirstArgChecker( const CCommand@ args )
{
	return args.Arg(0).ToLowercase() == "buy" 
		|| args.Arg(0).ToLowercase() == "/buy" 
		|| args.Arg(0).ToLowercase() == "!buy" 
		|| args.Arg(0).ToLowercase() == ".buy" 
		|| args.Arg(0).ToLowercase() == "\\buy" 
		|| args.Arg(0).ToLowercase() == "#buy";
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( pPlayer is null ) //Null pointer checker
		return HOOK_CONTINUE;
	else
		pPlayer.pev.frags += StartMoney;

	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if( args.ArgC() == 1 && FirstArgChecker( args ) )
	{
		pParams.ShouldHide = true;

		if( !pPlayer.m_fLongJump ) //Nero
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You may only buy weapons from the charging stations.\n" );
			return HOOK_CONTINUE;
		}

		g_BuyMenu.Show( pPlayer );
	}
	else if( args.ArgC() == 3 && FirstArgChecker( args ) )
	{
		pParams.ShouldHide = true;
		bool bItemFound = false;
		string szItemName;
		string szItemType;
		uint uiCost;

		if( !pPlayer.m_fLongJump ) //Nero
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You may only buy weapons from the charging stations.\n" );
			return HOOK_CONTINUE;
		}

		if( args.Arg(1).ToLowercase() == "w" )
			szItemType = "weapon";
		else if( args.Arg(1).ToLowercase() == "a" )
			szItemType = "ammo";
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Invalid Item Type\n" );
			return HOOK_CONTINUE;
		}

		if( g_BuyMenu.m_Items.length() > 0 )
		{
			for( uint i = 0; i < g_BuyMenu.m_Items.length(); i++ )
			{
				if( szItemType + "_" + args.Arg(2).ToLowercase() == g_BuyMenu.m_Items[i].EntityName )
				{
					bItemFound = true;
					szItemName = g_BuyMenu.m_Items[i].EntityName;
					uiCost = g_BuyMenu.m_Items[i].Cost;
					break;
				}
				else
					bItemFound = false;
			}

			if( bItemFound )
			{
				if( pPlayer.pev.frags <= 0 )
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money (frags) - Cost: $" + uiCost + "\n" );
				}
				else
				{ 
					if( uint(pPlayer.pev.frags) >= uiCost )
					{
						pPlayer.pev.frags -= uiCost;
						pPlayer.GiveNamedItem( szItemName );
					}
					else
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money (frags) - Cost: $" + uiCost + "\n" );
				}
			}
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Invalid item: " + args.Arg(1) + "\n" );
		}
	}
	else if( args.ArgC() == 2 && FirstArgChecker( args ) )
	{
		if( !pPlayer.m_fLongJump ) //Nero
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You may only buy weapons from the charging stations.\n" );
			return HOOK_CONTINUE;
		}

		if( args.Arg(1).ToLowercase() == "ammo" )
		{
			pParams.ShouldHide = true;
			bool bItemFound = false;
			string szItemName;
			uint uiCost;

			if( pPlayer.m_hActiveItem.GetEntity() !is null )
			{
				CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_hActiveItem.GetEntity() );
				string szClassname = pWeapon.pev.classname;

				if( g_BuyMenu.m_Items.length() > 0 )
				{
					for( uint i = 0; i < g_BuyMenu.m_Items.length(); i++ )
					{
						//Identify the primary ammo entity first
						if( !(pPlayer.HasNamedPlayerItem( szClassname ).iFlags() < 0) && pPlayer.HasNamedPlayerItem( szClassname ).iFlags() & ITEM_FLAG_EXHAUSTIBLE != 0 )
						{
							if( szClassname == g_BuyMenu.m_Items[i].EntityName )
							{
								bItemFound = true;
								szItemName = g_BuyMenu.m_Items[i].EntityName;
								uiCost = g_BuyMenu.m_Items[i].Cost;
								break;
								}
						}
						else if( "ammo_" + szClassname.Split("_")[1] == g_BuyMenu.m_Items[i].EntityName )
						{
							bItemFound = true;
							szItemName = g_BuyMenu.m_Items[i].EntityName;
							uiCost = g_BuyMenu.m_Items[i].Cost;
							break;
						}
						else
						{
							bItemFound = false;
						}
					}
				}

				if( bItemFound )
				{
					if(  uint( pPlayer.pev.frags ) <= 0 )
					{
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money (frags) - Cost: $" + uiCost + "\n" );
					}
					//Very tedious check to see if the player already has max ammo for a exhaustible weapon
					else if( uint( pPlayer.pev.frags ) >= uiCost && pPlayer.HasNamedPlayerItem( szClassname ).iFlags() & ITEM_FLAG_EXHAUSTIBLE != 0 &&
						pPlayer.m_rgAmmo( pPlayer.HasNamedPlayerItem( szClassname ).GetWeaponPtr().m_iPrimaryAmmoType ) == pPlayer.GetMaxAmmo( szClassname ) )
					{
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Exhaustible weapon already at max ammo\n" );
					}
					else
					{ 
						if( uint( pPlayer.pev.frags ) >= uiCost )
						{
							pPlayer.GiveNamedItem( szItemName );
							pPlayer.pev.frags = uint( pPlayer.pev.frags ) - uiCost;
						}
						else
						{
							g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money to buy: " + szItemName + " - Cost: $" + uiCost + "\n" );
						}
					}
				}
				else
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Invalid Weapon or Ammo entity\n" );
				}
			}
		}
	}
	return HOOK_CONTINUE;
}

void Buy( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	if( args.ArgC() == 1 )
	{
		g_BuyMenu.Show( pPlayer );
	}
}

CClientCommand buy( "buy", "Opens the BuyMenu", @Buy );

void MoneyInit()
{
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

final class BuyableItem
{
	private string m_szDescription;
	private string m_szEntityName;
	private string m_szCategory;
	private string m_szSubCategory;
	private uint m_uiCost = 0;

	string Description
	{
		get const { return m_szDescription; }
		set { m_szDescription = value; }
	}

	string EntityName
	{
		get const { return m_szEntityName; }
		set { m_szEntityName = value; }
	}

	string Category
	{
		get const { return m_szCategory; }
		set { m_szCategory = value; }
	}

	string SubCategory
	{
		get const { return m_szSubCategory; }
		set { m_szSubCategory = value; }
	}

	uint Cost
	{
		get const { return m_uiCost; }
		set { m_uiCost = value; }
	}

	BuyableItem( const string& in szDescription, const string& in szEntityName, const uint uiCost, string sCategory, string sSubCategory = "" )
	{
		m_szDescription = "$" + string(uiCost) + " " + szDescription;
		m_szEntityName = szEntityName;
		m_uiCost = uiCost;
		m_szCategory = sCategory;
		m_szSubCategory = sSubCategory;
	}

	void Buy( CBasePlayer@ pPlayer = null )
	{
		GiveItem( pPlayer );
	}

	private void GiveItem( CBasePlayer@ pPlayer ) const
	{
		const uint uiMoney = uint( pPlayer.pev.frags );

		if( pPlayer.HasNamedPlayerItem( m_szEntityName ) !is null )
		{
			//KernCore start
			if( !( pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() < 0 ) && pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() & ITEM_FLAG_EXHAUSTIBLE != 0 )
			{
				if( pPlayer.GiveAmmo( pPlayer.HasNamedPlayerItem( m_szEntityName ).GetWeaponPtr().m_iDefaultAmmo, m_szEntityName, pPlayer.GetMaxAmmo( m_szEntityName ) ) != -1 )
				{
					//pPlayer.HasNamedPlayerItem( m_szEntityName ).CheckRespawn();
					//pPlayer.HasNamedPlayerItem( m_szEntityName ).AttachToPlayer( pPlayer );
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You bought ammo for: " + m_szEntityName + "\n" );
				}
				else
				{
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You already have max ammo for this item!\n" );
					return;
				}
			}
			else
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You already have that item!\n" );
				return;
			}
			//KernCore end
		}

		else if( uiMoney >= m_uiCost )
		{
			pPlayer.pev.frags -= m_uiCost;

			pPlayer.GiveNamedItem( m_szEntityName );
			pPlayer.SelectItem( m_szEntityName );
		}
		else
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money (frags) - Cost: $" + m_uiCost + "\n");
			return;
		}
	}
}

final class BuyMenu
{
	array<BuyableItem@> m_Items;

	//First Menu Object
	private CTextMenu@ m_pMenu      	= null;
	//First Menu Items
	private string szOpenPrimWeapMenu 	= "Melees";
	private string szOpenSecoWeapMenu 	= "Pistols";
	private string szOpenTercWeapMenu 	= "Shotguns";
	private string szOpenQuatWeapMenu 	= "Submachine Guns";
	private string szOpenQuinWeapMenu 	= "Rifles";
	private string szOpenSenaWeapMenu 	= "Machine Guns";
	private string szOpenEquiWeapMenu 	= "Equipment";
	private string szOpenAmmoWeapMenu 	= "Ammo";
	//Primary Menu
	private CTextMenu@ m_pFirstMenu  	= null;
	private CTextMenu@ m_pSecondMenu 	= null;
	private CTextMenu@ m_pThirdMenu  	= null;
	private CTextMenu@ m_pFourthMenu 	= null;
	private CTextMenu@ m_pFifthMenu  	= null;
	private CTextMenu@ m_pSixthMenu  	= null;
	private CTextMenu@ m_pEquipMenu  	= null;
	private CTextMenu@ m_pAmmoMenu   	= null;
	//Ammo Menu
	private CTextMenu@ m_pSecondAMenu 	= null;
	private CTextMenu@ m_pThirdAMenu 	= null;
	private CTextMenu@ m_pFourthAMenu 	= null;
	private CTextMenu@ m_pFifthAMenu 	= null;
	private CTextMenu@ m_pSixthAMenu 	= null;

	void RemoveItems()
	{
		if( m_Items !is null )
		{
			m_Items.removeRange( 0, m_Items.length() );
		}
	}

	void AddItem( BuyableItem@ pItem )
	{
		if( pItem is null )
			return;

		if( m_Items.findByRef( @pItem ) != -1 )
			return;

		m_Items.insertLast( pItem );

		if( m_pMenu !is null )
			@m_pMenu = null;
	}

	void Show( CBasePlayer@ pPlayer = null )
	{
		if( m_pMenu is null )
			CreateMenu();

		if( pPlayer !is null )
			m_pMenu.Open( 0, 0, pPlayer );
	}

	private void CreateMenu()
	{
		//This is the first menu you'll see when opening the Buy Menu Command
		@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
		m_pMenu.SetTitle( "Shop by Category\n" );
		m_pMenu.AddItem( szOpenPrimWeapMenu );
		m_pMenu.AddItem( szOpenSecoWeapMenu );
		m_pMenu.AddItem( szOpenTercWeapMenu );
		m_pMenu.AddItem( szOpenQuatWeapMenu );
		m_pMenu.AddItem( szOpenQuinWeapMenu );
		m_pMenu.AddItem( szOpenSenaWeapMenu );
		m_pMenu.AddItem( szOpenEquiWeapMenu );
		m_pMenu.AddItem( szOpenAmmoWeapMenu );
		m_pMenu.Register();

		//First sub menu to be opened by the player
		@m_pFirstMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFirstMenu.SetTitle( "Choose Melee (Secondary Weapon)\n" );

		//Second sub menu to be opened by the player
		@m_pSecondMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSecondMenu.SetTitle( "Choose Handgun (Secondary Weapon)\n" );

		//Third sub menu to be opened by the player
		@m_pThirdMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pThirdMenu.SetTitle( "Choose Shotgun (Primary Weapon)\n" );

		//Fourth sub menu to be opened by the player
		@m_pFourthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFourthMenu.SetTitle( "Choose SMG (Primary Weapon)\n" );

		//Fifth sub menu to be opened by the player
		@m_pFifthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pFifthMenu.SetTitle( "Choose Rifle (Primary Weapon)\n" );

		//Sixth sub menu to be opened by the player
		@m_pSixthMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSixthMenu.SetTitle( "Choose Machine Gun (Primary Weapon)\n" );

		//Sixth sub menu to be opened by the player
		@m_pEquipMenu = CTextMenu( TextMenuPlayerSlotCallback( this.EquipCallback ) );
		m_pEquipMenu.SetTitle( "Choose Equipment\n" );

		//Seventh sub menu to be opened by the player
		@m_pAmmoMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainAmmoCallback ) );
		m_pAmmoMenu.SetTitle( "Shop by Ammo Category\n" );
		m_pAmmoMenu.AddItem( szOpenSecoWeapMenu );
		m_pAmmoMenu.AddItem( szOpenTercWeapMenu );
		m_pAmmoMenu.AddItem( szOpenQuatWeapMenu );
		m_pAmmoMenu.AddItem( szOpenQuinWeapMenu );
		m_pAmmoMenu.AddItem( szOpenSenaWeapMenu );
		m_pAmmoMenu.Register();

		//Sets of Ammo Submenus
		@m_pSecondAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallback ) );
		m_pSecondAMenu.SetTitle( "Shop Secondary Ammo\n" );
		@m_pThirdAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallback ) );
		m_pThirdAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pFourthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallback ) );
		m_pFourthAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pFifthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallback ) );
		m_pFifthAMenu.SetTitle( "Shop Primary Ammo\n" );
		@m_pSixthAMenu	= CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallback ) );
		m_pSixthAMenu.SetTitle( "Shop Primary Ammo\n" );

		for( uint i = 0; i < m_Items.length(); i++ )
		{
			BuyableItem@ pItem = m_Items[i];
			if( pItem.Category == "melee" )
			{
				m_pFirstMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "handgun" )
			{
				m_pSecondMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "shotgun" )
			{
				m_pThirdMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "smg" )
			{
				m_pFourthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "rifle" )
			{
				m_pFifthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "lmg" )
			{
				m_pSixthMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "equip" )
			{
				m_pEquipMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "ammo" )
			{
				if( pItem.SubCategory == "handgun" )
				{
					m_pSecondAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "shotgun" )
				{
					m_pThirdAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "smg" )
				{
					m_pFourthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "rifle" )
				{
					m_pFifthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
				else if( pItem.SubCategory == "lmg" )
				{
					m_pSixthAMenu.AddItem( pItem.Description, any(@pItem) );
				}
			}
		}

		//Weapon related menus
		m_pFirstMenu.Register();
		m_pSecondMenu.Register();
		m_pThirdMenu.Register();
		m_pFourthMenu.Register();
		m_pFifthMenu.Register();
		m_pSixthMenu.Register();
		m_pEquipMenu.Register();

		//Ammo related menus
		m_pSecondAMenu.Register();
		m_pThirdAMenu.Register();
		m_pFourthAMenu.Register();
		m_pFifthAMenu.Register();
		m_pSixthAMenu.Register();
	}

	private void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == szOpenPrimWeapMenu )
			{
				m_pFirstMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSecoWeapMenu )
			{
				m_pSecondMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenTercWeapMenu )
			{
				m_pThirdMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuatWeapMenu )
			{
				m_pFourthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuinWeapMenu )
			{
				m_pFifthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSenaWeapMenu )
			{
				m_pSixthMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenEquiWeapMenu )
			{
				m_pEquipMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenAmmoWeapMenu )
			{
				m_pAmmoMenu.Open( 0, 0, pPlayer );
			}
		}
	}

	private void MainAmmoCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == szOpenSecoWeapMenu )
			{
				m_pSecondAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenTercWeapMenu )
			{
				m_pThirdAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuatWeapMenu )
			{
				m_pFourthAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenQuinWeapMenu )
			{
				m_pFifthAMenu.Open( 0, 0, pPlayer );
			}
			else if( sChoice == szOpenSenaWeapMenu )
			{
				m_pSixthAMenu.Open( 0, 0, pPlayer );
			}
		}
	}

	private void AmmoCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				menu.Open( 0, 0, pPlayer);
			}
		}
	}

	private void EquipCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );

				if( pPlayer.m_rgAmmo( pPlayer.HasNamedPlayerItem( pBuyItem.EntityName ).GetWeaponPtr().m_iPrimaryAmmoType ) != pPlayer.GetMaxAmmo( pBuyItem.EntityName ) )
					m_pEquipMenu.Open( 0, 0, pPlayer);
			}
		}
	}

	private void WeaponCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				//m_pMenu.Open( 0, 0, pPlayer);
			}
		}
	}
}

}