enum PANZERFAUSTAnimation_e
{
	PANZERFAUST_IDLE = 0,
	PANZERFAUST_IDLE_EMPTY,
	PANZERFAUST_DRAW,
	PANZERFAUST_DRAW_EMPTY,
	PANZERFAUST_AIMED,
	PANZERFAUST_AIMED_EMPTY,
	PANZERFAUST_LAUNCH,
	PANZERFAUST_DOWNTOUP,
	PANZERFAUST_DOWNTOUP_EMPTY,
	PANZERFAUST_UPTODOWN,
	PANZERFAUST_UPTODOWN_EMPTY,
	PANZERFAUST_RELOAD_IDLE,
	PANZERFAUST_RELOAD_AIMED
};

const int PANZERFAUST_MAX_CARRY  	= 7;
const int PANZERFAUST_DEFAULT_GIVE 	= 4;
const int PANZERFAUST_MAX_CLIP   	= 1;
const int PANZERFAUST_WEIGHT     	= 30;
const int PANZERFAUST_AMMO_GIVE  	= 1;

class weapon_panzerfaust : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;

	int g_iCurrentMode;
	CBaseEntity@ pRocket;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/panzerfaust/w_panzerfaust.mdl" );
		
		self.m_iDefaultAmmo = PANZERFAUST_DEFAULT_GIVE;

		self.KeyValue( "m_flCustomRespawnTime", 1 ); //fgsfds
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/panzerfaust/w_panzerfaust.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerfaust/p_panzerfaust.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerfaust/v_panzerfaust.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerfaust/w_panzerfaust_rocket.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerfaust/w_panzerfaust_empty.mdl" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/panzerfaust_rocket1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookadeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/faust_drop.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookapickup.wav" );

		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/panzerfaust_rocket1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookadeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/faust_drop.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookapickup.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/soviets_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/ammo_pfaust.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_panzerfaust.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= PANZERFAUST_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= PANZERFAUST_MAX_CLIP;
		info.iSlot  	= 4;
		info.iPosition	= 4;
		info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_NOAUTORELOAD | ITEM_FLAG_ESSENTIAL;
		info.iWeight	= PANZERFAUST_WEIGHT;
		
		return true;
	}

	//fgsfds
	void Materialize()
	{
		BaseClass.Materialize();
		SetTouch( TouchFunction( CustomTouch ) );
	}

	void CustomTouch( CBaseEntity@ pOther ) 
	{
		if( !pOther.IsPlayer() )
			return;
		
		CBasePlayer@ pPlayer = cast<CBasePlayer@> ( pOther );

		if( pPlayer.HasNamedPlayerItem( "weapon_panzerfaust" ) !is null )
		{
	  		if( pPlayer.GiveAmmo( PANZERFAUST_AMMO_GIVE, "weapon_panzerfaust", PANZERFAUST_MAX_CARRY ) != 0 ) 
			{
				self.CheckRespawn();
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
				g_EntityFuncs.Remove( self );
	  		}
	  		return;
		}
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded ) 
		{
	  		self.AttachToPlayer( pPlayer );
	  		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}
	//fgsfds

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage soviet10( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				soviet10.WriteLong( g_ItemRegistry.GetIdForName("weapon_panzerfaust") );
			soviet10.End();
			return true;
		}
		
		return false;
	}

	CBasePlayerItem@ DropItem() // Doesn't let the player drop the weapon
	{
		return null;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/panzerfaust/v_panzerfaust.mdl" ), self.GetP_Model( "models/ww2projekt/panzerfaust/p_panzerfaust.mdl" ), 
				(self.m_iClip > 0) ? PANZERFAUST_DRAW : PANZERFAUST_DRAW_EMPTY, "rpg" );
		
			float deployTime = 0.9f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void DestroyThink()
	{
		self.DestroyItem();
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		g_iCurrentMode = NotInShoulder;
		m_pPlayer.pev.maxspeed = 0;

		if( self.m_iClip <= 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName("weapon_panzerfaust") );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		else
		{
			SetThink( null );
		}

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( g_iCurrentMode == InShoulder )
		{
			if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
			{
				self.PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
				return;
			}
		
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
		
			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

			m_pPlayer.pev.punchangle.x -= 4;
			--self.m_iClip;
		
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
			self.SendWeaponAnim( PANZERFAUST_LAUNCH, 0, 0 );
		
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/panzerfaust_rocket1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
			Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );

			Vector vecOrigin = m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -8;
		
			@pRocket = g_EntityFuncs.CreateRPGRocket( vecOrigin, m_pPlayer.pev.v_angle, m_pPlayer.edict() );
			g_EntityFuncs.SetModel( pRocket, "models/ww2projekt/panzerfaust/w_panzerfaust_rocket.mdl" );
			
			pRocket.pev.dmg = 175; //projectile damage
			pRocket.pev.movetype = MOVETYPE_BOUNCE;
			
			if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
				m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}
		else if( g_iCurrentMode == NotInShoulder )
		{
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, ROCKETDeploy );
		}
	}

	void SecondaryAttack()
	{
		int iAnim;

		switch( g_iCurrentMode )
		{
			case NotInShoulder:
			{
				g_iCurrentMode = InShoulder;

				iAnim = (self.m_iClip > 0) ? PANZERFAUST_DOWNTOUP : PANZERFAUST_DOWNTOUP_EMPTY;

				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.83f;
				self.SendWeaponAnim( iAnim, 0, 0 );
				m_pPlayer.pev.maxspeed = 180; //will lower your speed
				break;
			}
			
			case InShoulder:
			{
				g_iCurrentMode = NotInShoulder;

				iAnim = (self.m_iClip > 0) ? PANZERFAUST_UPTODOWN : PANZERFAUST_UPTODOWN_EMPTY;

				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.03f;
				self.SendWeaponAnim( iAnim, 0, 0 );
				m_pPlayer.pev.maxspeed = 0;
				break;
			}
		}
	}

	void PanzerFWmodel(Vector pos, Vector size, Vector velocity, uint8 speedNoise = 0, string model = "models/ww2projekt/panzerfaust/w_panzerfaust_empty.mdl", 
	uint8 count = 1, uint8 life = 20, uint8 flags = 2,
	NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null)
	{
		NetworkMessage panzerfw( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
			panzerfw.WriteByte(TE_BREAKMODEL);
			panzerfw.WriteCoord( pos.x );
			panzerfw.WriteCoord( pos.y );
			panzerfw.WriteCoord( pos.z + 10);
			panzerfw.WriteCoord( size.x );
			panzerfw.WriteCoord( size.y );
			panzerfw.WriteCoord( size.z );
			panzerfw.WriteCoord( velocity.x );
			panzerfw.WriteCoord( velocity.y );
			panzerfw.WriteCoord( velocity.z );
			panzerfw.WriteByte( speedNoise );
			panzerfw.WriteShort( g_EngineFuncs.ModelIndex( model ) );
			panzerfw.WriteByte( count );
			panzerfw.WriteByte( life );
			panzerfw.WriteByte( flags );
		panzerfw.End();
	}

	void Reload()
	{
		if( self.m_iClip == PANZERFAUST_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		(g_iCurrentMode == NotInShoulder) ? self.DefaultReload( PANZERFAUST_MAX_CLIP, PANZERFAUST_RELOAD_IDLE, 3.03f, 0 ) : 
			self.DefaultReload( PANZERFAUST_MAX_CLIP, PANZERFAUST_RELOAD_AIMED, 3.33f, 0 );

		SetThink( ThinkFunction( DropThink ) );
		self.pev.nextthink = g_Engine.time + 0.56f;

		BaseClass.Reload();
	}

	void DropThink()
	{
		PanzerFWmodel( m_pPlayer.pev.origin, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		int iAnim;

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		if( g_iCurrentMode == InShoulder )
		{
			iAnim = (self.m_iClip > 0) ? PANZERFAUST_AIMED : PANZERFAUST_AIMED_EMPTY;
		}
		else if( g_iCurrentMode == NotInShoulder )
		{
			iAnim = (self.m_iClip > 0) ? PANZERFAUST_IDLE : PANZERFAUST_IDLE_EMPTY;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}

	void ItemPreFrame()
	{
		if( self.m_iClip <= 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.RetireWeapon();
			PanzerFWmodel( m_pPlayer.pev.origin, Vector( 0, 0, 0 ), Vector( -100, 0, 0 ) );
		}

		BaseClass.ItemPreFrame();
	}
}

string GetPANZERFName()
{
	return "weapon_panzerfaust";
}

void RegisterPANZERF()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetPANZERFName(), GetPANZERFName() );
	g_ItemRegistry.RegisterWeapon( GetPANZERFName(), "ww2projekt", "weapon_panzerfaust" );
}