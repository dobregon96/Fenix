// modified cs1.6 buymenu

namespace BuyMenu
{

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

	BuyableItem( const string& in szDescription, const string& in szEntityName, const uint uiCost, string sCategory, string sSubCategory )
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
			if( !(pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() < 0) && pPlayer.HasNamedPlayerItem( m_szEntityName ).iFlags() & ITEM_FLAG_EXHAUSTIBLE != 0 )
			{
				if( pPlayer.GiveAmmo( 1, m_szEntityName, pPlayer.GetMaxAmmo( m_szEntityName ) ) != -1 )
				{
					pPlayer.HasNamedPlayerItem( m_szEntityName ).AttachToPlayer( pPlayer );
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

		if( pPlayer.pev.frags <= 0 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money (frags) - Cost: $" + m_uiCost + "\n");
			return;
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

	private CTextMenu@ m_pMenu = null;
	//Primary Menu
	private CTextMenu@ m_pPrimaryMenu = null;
	private CTextMenu@ m_pSMGMenu = null;
	private CTextMenu@ m_pBoltRifleMenu = null;
	private CTextMenu@ m_pSemiRifleMenu = null;
	private CTextMenu@ m_pLMGMenu = null;
	private CTextMenu@ m_pAntiTankMenu = null;
	//Secondary Menu
	private CTextMenu@ m_pSecondaryMenu = null;
	private CTextMenu@ m_pHandgunMenu = null;
	private CTextMenu@ m_pMeleeMenu = null;
	//Equipment Menu
	private CTextMenu@ m_pEquipmentMenu = null;
	//Ammo Menu
	private CTextMenu@ m_pAmmoMenu = null;

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
		@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.MainCallback ) );
		m_pMenu.SetTitle( "Choose action: " );
		m_pMenu.AddItem( "Buy primary weapon", null );
		m_pMenu.AddItem( "Buy secondary weapon", null );
		m_pMenu.AddItem( "Buy equipment", null );
		m_pMenu.AddItem( "Buy ammo" );
		m_pMenu.Register();

		@m_pPrimaryMenu = CTextMenu( TextMenuPlayerSlotCallback( this.PrimaryCallback ) );
		m_pPrimaryMenu.SetTitle( "Choose primary weapon category: " );
		m_pPrimaryMenu.AddItem( "SMGs", null );
		m_pPrimaryMenu.AddItem( "Bolt-Action Rifles", null );
		m_pPrimaryMenu.AddItem( "Semi-Auto Rifles", null );
		m_pPrimaryMenu.AddItem( "Light MGs", null );
		m_pPrimaryMenu.AddItem( "Anti-Tank", null );
		m_pPrimaryMenu.Register();

		@m_pSecondaryMenu = CTextMenu( TextMenuPlayerSlotCallback( this.SecondaryCallback ) );
		m_pSecondaryMenu.SetTitle( "Choose secondary weapon category: " );
		m_pSecondaryMenu.AddItem( "Handguns", null );
		m_pSecondaryMenu.AddItem( "Melees", null );
		m_pSecondaryMenu.Register();

		@m_pEquipmentMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pEquipmentMenu.SetTitle( "Choose equipment: " );
		@m_pAmmoMenu = CTextMenu( TextMenuPlayerSlotCallback( this.AmmoCallBack ) );
		m_pAmmoMenu.SetTitle( "Choose Ammo: " );

		//Primary Menu
		@m_pSMGMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSMGMenu.SetTitle( "Choose SMG:" );
		@m_pBoltRifleMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pBoltRifleMenu.SetTitle( "Choose Bolt-Action Rifle:" );
		@m_pSemiRifleMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pSemiRifleMenu.SetTitle( "Choose Semi-Auto Rifle:" );
		@m_pLMGMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pLMGMenu.SetTitle( "Choose Light Machine Gun:" );
		@m_pAntiTankMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pAntiTankMenu.SetTitle( "Choose Anti-Tank Launcher:" );

		//Secondary menu
		@m_pHandgunMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pHandgunMenu.SetTitle( "Choose Pistol/Revolver:" );
		@m_pMeleeMenu = CTextMenu( TextMenuPlayerSlotCallback( this.WeaponCallback ) );
		m_pMeleeMenu.SetTitle( "Choose Melee:" );

		for( uint i = 0; i < m_Items.length(); i++ )
		{
			BuyableItem@ pItem = m_Items[i];
			if( pItem.Category == "primary" )
			{
				if( pItem.SubCategory == "smg" )
					m_pSMGMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "bolt_rifle" )
					m_pBoltRifleMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "semi_rifle" )
					m_pSemiRifleMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "lmg" )
					m_pLMGMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "launcher" )
					m_pAntiTankMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "secondary" )
			{
				if( pItem.SubCategory == "handgun" )
					m_pHandgunMenu.AddItem( pItem.Description, any(@pItem) );
				else if( pItem.SubCategory == "melee" )
					m_pMeleeMenu.AddItem( pItem.Description, any(@pItem) );
			}
			else if( pItem.Category == "equipment" )
				m_pEquipmentMenu.AddItem( pItem.Description, any(@pItem) );
			else if( pItem.Category == "ammo" )
				m_pAmmoMenu.AddItem( pItem.Description, any(@pItem) );
		}
		m_pEquipmentMenu.Register();
		m_pAmmoMenu.Register();
		m_pSMGMenu.Register();
		m_pBoltRifleMenu.Register();
		m_pSemiRifleMenu.Register();
		m_pLMGMenu.Register();
		m_pAntiTankMenu.Register();
		m_pHandgunMenu.Register();
		m_pMeleeMenu.Register();
	}

	private void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == "Buy primary weapon" )
				m_pPrimaryMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy secondary weapon" )
				m_pSecondaryMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy equipment" )
				m_pEquipmentMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Buy ammo" )
				m_pAmmoMenu.Open( 0, 0, pPlayer );
		}
	}

	private void PrimaryCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == "SMGs" )
				m_pSMGMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Bolt-Action Rifles" )
				m_pBoltRifleMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Semi-Auto Rifles" )
				m_pSemiRifleMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Light MGs" )
				m_pLMGMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Anti-Tank" )
				m_pAntiTankMenu.Open( 0, 0, pPlayer );
		}
	}

	private void SecondaryCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			string sChoice = pItem.m_szName;
			if( sChoice == "Handguns" )
				m_pHandgunMenu.Open( 0, 0, pPlayer );
			else if( sChoice == "Melees" )
				m_pMeleeMenu.Open( 0, 0, pPlayer );
		}
	}

	private void AmmoCallBack( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;

			pItem.m_pUserData.retrieve( @pBuyItem );

			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
				m_pAmmoMenu.Open( 0, 0, pPlayer );
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