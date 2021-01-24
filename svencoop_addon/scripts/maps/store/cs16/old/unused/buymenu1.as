dictionary g_CLHandguns = {
	{ 'Glock18 Select Fire', dictionary = {
		{ 'Entity', "weapon_csglock18" }, { 'Price', 800 } 
	}}, 
	{ 'H&K USP .45 Tactical', dictionary = { 
		{'Entity', "weapon_usp" }, { 'Price', 500 } 
	}}, 
	{ 'SIG P228', dictionary = {
		{'Entity', "weapon_p228" }, { 'Price', 600 } 
	}}, 
	{ 'FN Five-Seven', dictionary = {
		{'Entity', "weapon_fiveseven" }, { 'Price', 650 } 
	}}, 
	{ 'Desert Eagle .50 AE', dictionary = {
		{'Entity', "weapon_csdeagle" }, { 'Price', 750 } 
	}}, 
	{ 'Dual Beretta 96G Elite II', dictionary = {
		{'Entity', "weapon_dualelites" }, { 'Price', 800 } 
	}} 
};

dictionary g_CLShotguns = {
	{ 'Benelli M3 Super90', dictionary = {
		{ 'Entity', "weapon_m3" }, { 'Price', 1700 } 
	}}, 
	{ 'Benelli M4 Super90', dictionary = {
		{'Entity', "weapon_xm1014" }, { 'Price', 3000 } 
	}}
};

dictionary g_CLSMG = {
	{ 'Steyr Tactical Machine Pistol', dictionary = {
		{ 'Entity', "weapon_tmp" }, { 'Price', 1250 } 
	}}, 
	{ 'H&K MP5-Navy', dictionary = {
		{'Entity', "weapon_mp5navy" }, { 'Price', 1500 } 
	}}, 
	{ 'H&K UMP45', dictionary = {
		{'Entity', "weapon_ump45" }, { 'Price', 1700 } 
	}}, 
	{ 'FN P90', dictionary = {
		{'Entity', "weapon_p90" }, { 'Price', 2350 } 
	}}, 
	{ 'Ingram Mac10', dictionary = {
		{'Entity', "weapon_mac10" }, { 'Price', 1400 } 
	}}
};

dictionary g_CLAssault = {
	{ 'IMI Galil AR/ARM', dictionary = {
		{ 'Entity', "weapon_galil" }, { 'Price', 2000 } 
	}}, 
	{ 'GIAT Industries FAMAS', dictionary = {
		{'Entity', "weapon_famas" }, { 'Price', 2250 } 
	}}, 
	{ 'Kalishnikov AK-47', dictionary = {
		{'Entity', "weapon_ak47" }, { 'Price', 2800 } 
	}}, 
	{ 'Colt M4A1 Carbine', dictionary = {
		{'Entity', "weapon_m4a1" }, { 'Price', 2800 } 
	}}, 
	{ 'Steyr Aug A1', dictionary = {
		{'Entity', "weapon_aug" }, { 'Price', 3500 } 
	}}, 
	{ 'SIG SG-552 Commando', dictionary = {
		{'Entity', "weapon_sg552" }, { 'Price', 3500 } 
	}}
};

dictionary g_CLSniper = {
	{ 'Steyr Scout Tactical', dictionary = {
		{ 'Entity', "weapon_scout" }, { 'Price', 2000 } 
	}}, 
	{ 'Arctic Warfare Magnum', dictionary = {
		{'Entity', "weapon_awp" }, { 'Price', 4500 } 
	}}, 
	{ 'SIG SG-550 Sniper Rifle', dictionary = {
		{'Entity', "weapon_sg550" }, { 'Price', 5000 } 
	}}, 
	{ 'H&K G3/SG-1 Sniper Rifle', dictionary = {
		{'Entity', "weapon_g3sg1" }, { 'Price', 5000 } 
	}}
};

dictionary g_CLHeavy = {
	{ 'FN M249 Minimi', dictionary = {
		{ 'Entity', "weapon_csm249" }, { 'Price', 5750 } 
	}}, 
	{ 'RPG LAW', dictionary = {
		{'Entity', "weapon_rpg" }, { 'Price', 4500 } 
	}}
};

dictionary g_CLMisc = {
	{ 'Medical Kit', dictionary = {
		{ 'Entity', "item_healthkit" }, { 'Price', 100 } 
	}}, 
	{ 'Kevlar', dictionary = {
		{ 'Entity', "item_kevlar" }, { 'Price', 1000 } 
	}}, 
	{ 'High Explosive Grenade', dictionary = {
		{'Entity', "weapon_hegrenade" }, { 'Price', 1500 } 
	}},
	{ 'C4 Charge', dictionary = {
		{'Entity', "weapon_c4" }, { 'Price', 1500 } 
	}}
};
/*
dictionary g_CLAmmo = {
	{ '7.62 Nato Rounds', dictionary = {
		{ 'Entity', "ammo_cs_762" }, { 'Price', 10 } 
	}}, 
	{ '.50 AE Rounds', dictionary = {
		{'Entity', "ammo_cs_50ae" }, { 'Price', 10 } 
	}},
	{ '.338 Lapua Rounds', dictionary = {
		{ 'Entity', "ammo_cs_338lapua" }, { 'Price', 10 } 
	}}, 
	{ '9mm Rounds', dictionary = {
		{'Entity', "ammo_cs_9mm" }, { 'Price', 10 } 
	}},
	{ '.357 SIG Rounds', dictionary = {
		{ 'Entity', "ammo_cs_357sig" }, { 'Price', 10 } 
	}}, 
	{ '.45 ACP Rounds', dictionary = {
		{'Entity', "ammo_cs_45acp" }, { 'Price', 10 } 
	}},
	{ '.357 SIG Rounds', dictionary = {
		{ 'Entity', "ammo_cs_357sig" }, { 'Price', 10 } 
	}}, 
	{ '.57 FN Rounds', dictionary = {
		{'Entity', "ammo_cs_fn57" }, { 'Price', 10 } 
	}},
	{ '5.56 Nato Rounds', dictionary = {
		{ 'Entity', "ammo_cs_556" }, { 'Price', 10 } 
	}}, 
	{ '5.56 Box Rounds', dictionary = {
		{'Entity', "ammo_cs_556box" }, { 'Price', 10 } 
	}},
	{ '12 Gauge Shells', dictionary = {
		{ 'Entity', "ammo_cs_buckshot" }, { 'Price', 10 } 
	}}
};
*/

dictionary g_CLAmmo = {
	{ 'Buy Current Ammo', dictionary = {
		{ 'Entity', "n/a" }, { 'Price', 50 } 
	}}, 
	{ 'Fill All Ammo', dictionary = {
		{'Entity', "n/a" }, { 'Price', 200 } 
	}}
};

CTextMenu@ MainMenu = CTextMenu(CategoryRespond);
CTextMenu@ HandgunsMenu = CTextMenu(shopMenuRespond);
CTextMenu@ ShotgunsMenu = CTextMenu(shopMenuRespond);
CTextMenu@ SubMachineMenu = CTextMenu(shopMenuRespond);
CTextMenu@ RifleSubMenu = CTextMenu(SubMenuRespond);
CTextMenu@ AssaultRifleMenu = CTextMenu(shopMenuRespond);
CTextMenu@ SniperRifleMenu = CTextMenu(shopMenuRespond);
CTextMenu@ HeavyMenu = CTextMenu(shopMenuRespond);
CTextMenu@ AmmoMenu = CTextMenu(shopMenuRespond);
CTextMenu@ EquipmentMenu = CTextMenu(shopMenuRespond);

void LoadBuyMenu()
{

	MainMenu.SetTitle("Buy Item\n");
	MainMenu.AddItem("Handguns", null);
	MainMenu.AddItem("Shotguns", null);
	MainMenu.AddItem("Sub-Machine Guns", null);
	MainMenu.AddItem("Rifles", null);
	MainMenu.AddItem("Heavy Weapons", null);
	MainMenu.AddItem("Equipment", null);
	MainMenu.AddItem("Ammo", null);
	MainMenu.Register();
	
  
	RifleSubMenu.SetTitle("Choose Rifle Type\n");
	RifleSubMenu.AddItem("Assault Rifles", null);
	RifleSubMenu.AddItem("Sniper Rifles", null);
	RifleSubMenu.AddItem("Back", null);
	RifleSubMenu.Register();
  
	array<string> m_Guns = g_CLHandguns.getKeys(); 
	HandgunsMenu.SetTitle("Buy Handgun\n");
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLHandguns[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		HandgunsMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}  
	HandgunsMenu.AddItem("Back", null);
	HandgunsMenu.Register();
  
	ShotgunsMenu.SetTitle("Buy Shotgun\n");
	m_Guns = g_CLShotguns.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLShotguns[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		ShotgunsMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	ShotgunsMenu.AddItem("Back", null);
	ShotgunsMenu.Register();

	SubMachineMenu.SetTitle("Buy Sub-Machine Gun\n");
	m_Guns = g_CLSMG.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLSMG[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		SubMachineMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	SubMachineMenu.AddItem("Back", null);
	SubMachineMenu.Register();
  
	AssaultRifleMenu.SetTitle("Buy Assault Rifles\n");
	m_Guns = g_CLAssault.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLAssault[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		AssaultRifleMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	AssaultRifleMenu.AddItem("Back", null);
	AssaultRifleMenu.Register();
  
	SniperRifleMenu.SetTitle("Buy Sniper Rifles\n");
	m_Guns = g_CLSniper.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLSniper[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		SniperRifleMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	SniperRifleMenu.AddItem("Back", null);
	SniperRifleMenu.Register();
  
	HeavyMenu.SetTitle("Buy Anti-Personnel/Tank\n");
	m_Guns = g_CLHeavy.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLHeavy[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		HeavyMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	HeavyMenu.AddItem("Back", null);
	HeavyMenu.Register();
  
	EquipmentMenu.SetTitle("Buy Equipment\n");
	m_Guns = g_CLMisc.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLMisc[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		EquipmentMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	EquipmentMenu.AddItem("Back", null);
	EquipmentMenu.Register();
  
	AmmoMenu.SetTitle("Buy Ammo\n");
	m_Guns = g_CLAmmo.getKeys();
	for( uint uiIndex = 0; uiIndex < m_Guns.length(); ++uiIndex )
	{
		string szName = m_Guns[ uiIndex ];
		dictionary data = cast<dictionary>( g_CLAmmo[ szName ] );
		int iPrice = 0;
		iPrice = int( data[ "Price" ] );
		AmmoMenu.AddItem( szName + "								$" + formatInt( iPrice ), null );
	}
	AmmoMenu.AddItem("Back", null);
	AmmoMenu.Register();
}

void openMainMenu(CBasePlayer@ pPlayer){

	if( !pPlayer.HasSuit() )
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] You need an HEV suit to access the buy station!");
		return;
	}

	MainMenu.Open(0, 0, pPlayer);
}

void CategoryRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Handguns")
	{
		HandgunsMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Shotguns")
	{
		ShotgunsMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Sub-Machine Guns")
	{
		SubMachineMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Rifles")
	{
		RifleSubMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Heavy Weapons")
	{
		HeavyMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Equipment")
	{
		EquipmentMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Ammo")
	{
		AmmoMenu.Open( 0, 0, pPlayer );
	}
  }
}

void SubMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Assault Rifles")
	{
		AssaultRifleMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Sniper Rifles")
	{
		SniperRifleMenu.Open( 0, 0, pPlayer );
	}
    else if(mItem.m_szName == "Back")
	{
		MainMenu.Open( 0, 0, pPlayer );
	}
  }
}

void shopMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
	
	// Alive Buys
	if( !pPlayer.IsAlive() )
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] You can not buy while you are dead!");		
		return;
	}
	
	// Buy Station distance buys
	array<CBaseEntity@> pArray( 255 );
	int box = 64;
	uint numents = uint( g_EntityFuncs.EntitiesInBox( @pArray, pPlayer.pev.origin - Vector( box, box, 0 ), pPlayer.pev.origin + Vector( box, box, 64 ), 0 ) );
	bool bCanBuy = false;
	for( uint n = 0; n < numents; n++ )
	{
		if( pArray[n].GetClassname() == "func_buystation" )
		{
			bCanBuy = true;
			break;
		}
	}
	if( g_TotalStations > 0 && !bCanBuy )
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] You must be near a Buy Station to purchase items!" );		
		return;
	}
	
	//Regular Operation
	dictionary data;
	int splitter = mItem.m_szName.Find( "	" );
	string szTrimmedName = mItem.m_szName.SubString( 0, splitter );
	bool fIsAmmo = false;
    if( g_CLHandguns.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLHandguns[ szTrimmedName ] );
	}
    else if( g_CLShotguns.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLShotguns[ szTrimmedName ] );
	}
    else if( g_CLSMG.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLSMG[ szTrimmedName ] );
	}
    else if( g_CLAssault.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLAssault[ szTrimmedName ] );
	}
    else if( g_CLSniper.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLSniper[ szTrimmedName ] );
	}
    else if( g_CLHeavy.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLHeavy[ szTrimmedName ] );
	}
    else if( g_CLMisc.exists( szTrimmedName ) )
	{
		data = cast<dictionary>( g_CLMisc[ szTrimmedName ] );
	}
    else if( g_CLAmmo.exists( szTrimmedName ) )
	{
		if( szTrimmedName == "Buy Current Ammo" )
		{
			if( pPlayer.m_hActiveItem.GetEntity() !is null )
			{
				CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_hActiveItem.GetEntity() );
				if( deductCurrency( 50, pPlayer ) )
				{
					string szAmmo = pWeapon.pszAmmo1();
					pPlayer.GiveAmmo( pWeapon.iMaxAmmo1(), szAmmo, pWeapon.iMaxAmmo1(), false ); 
				}				
			}
		}
		else
		{
			if( deductCurrency( 200, pPlayer ) )
			{
				for( uint i = 0; i < MAX_ITEM_TYPES; i++ )
				{
					if( pPlayer.m_rgpPlayerItems(i) !is null )
					{
						CBasePlayerItem@ pPlayerItem = pPlayer.m_rgpPlayerItems(i);

						while( pPlayerItem !is null )
						{
							CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayerItem );
							if( pWeapon.PrimaryAmmoIndex() > 0 )
							{
								string szAmmo = pWeapon.pszAmmo1();
								pPlayer.GiveAmmo( pWeapon.iMaxAmmo1(), szAmmo, pWeapon.iMaxAmmo1(), false ); 
							}
							@pPlayerItem = cast<CBasePlayerItem@>( pPlayerItem.m_hNextItem.GetEntity() );
						}
					}
				}
			}				
		}
		return;
	}
	else if(szTrimmedName == "Back")
	{
      openMainMenu(pPlayer);
	  return;
    }
	if( data.exists( "Price" ) )
	{
		if( deductCurrency( int( data[ "Price" ] ), pPlayer ) )
		{
			pPlayer.GiveNamedItem( string( data[ "Entity" ] ) );
		}
	}
  }
}

bool deductCurrency(int amount, CBasePlayer@ pPlayer){
  if(pPlayer !is null){
    if(amount <= pPlayer.pev.frags){
      pPlayer.pev.frags -= amount;
      return true;
    }else{
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Counter-Life] You don't have enough money to purchase this!");
      return false;
    }
  }else{
    return false;
  }
}
