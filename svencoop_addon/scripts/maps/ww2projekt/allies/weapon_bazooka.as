enum M1BAZOOKAAnimation_e
{
	BAZOOKA_IDLE = 0,
	BAZOOKA_DRAW,
	BAZOOKA_AIMED,
	BAZOOKA_LAUNCH,
	BAZOOKA_DOWNTOUP,
	BAZOOKA_UPTODOWN,
	BAZOOKA_RELOAD_AIMED,
	BAZOOKA_RELOAD_IDLE
};

const int BAZOOKA_DEFAULT_GIVE 	= 2;
const int BAZOOKA_MAX_CARRY  	= 5;
const int BAZOOKA_MAX_CLIP   	= 1;
const int BAZOOKA_WEIGHT     	= 50;

class weapon_bazooka : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	CBaseEntity@ pRocket;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/bazooka/w_bazooka.mdl" );
		
		self.m_iDefaultAmmo = BAZOOKA_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/bazooka/w_bazooka.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bazooka/w_bazooka_rocket.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bazooka/v_bazooka.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/bazooka/p_bazooka.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazooka_rocket1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookadeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookapickup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazooka_rocket1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookadeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookapickup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/americans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_bazooka.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= BAZOOKA_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= BAZOOKA_MAX_CLIP;
		info.iSlot		= 4;
		info.iPosition	= 8;
		info.iFlags		= ITEM_FLAG_NOAUTORELOAD;
		info.iWeight	= BAZOOKA_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage allies9( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies9.WriteLong( g_ItemRegistry.GetIdForName("weapon_bazooka") );
			allies9.End();
			return true;
		}
		
		return false;
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/ww2projekt/bazooka/v_bazooka.mdl" ), self.GetP_Model( "models/ww2projekt/bazooka/p_bazooka.mdl" ), BAZOOKA_DRAW, "rpg" );
			
			float deployTime = 1.17f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		
		if( g_iCurrentMode == InShoulder )
			SecondaryAttack();
		
		g_iCurrentMode = 0;
		m_pPlayer.pev.maxspeed = 0;
		
		BaseClass.Holster( skipLocal );
	}
	
	void PrimaryAttack()
	{
		if( g_iCurrentMode == InShoulder )
		{
			if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
			{
				self.PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
				return;
			}
		
			if( self.m_iClip <= 0 )
			{
				self.PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
				return;
			}
		
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.7;
		
			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
			--self.m_iClip;
		
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
			self.SendWeaponAnim( BAZOOKA_LAUNCH );

			m_pPlayer.pev.punchangle.x -= 4;
		
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/bazooka_rocket1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
			Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
			@pRocket = g_EntityFuncs.CreateRPGRocket( m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -8, m_pPlayer.pev.v_angle, m_pPlayer.edict() );
			g_EntityFuncs.SetModel( pRocket, "models/ww2projekt/bazooka/w_bazooka_rocket.mdl" );
			
			pRocket.pev.dmg = 190; //projectile damage
			
			if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
				m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}
		else if( g_iCurrentMode == NotInShoulder )
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, ROCKETDeploy );
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75;
		switch( g_iCurrentMode )
		{
			case NotInShoulder:
			{
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.823;
				g_iCurrentMode = InShoulder;
				self.SendWeaponAnim( BAZOOKA_DOWNTOUP );
				m_pPlayer.pev.maxspeed = 160; //will lower your speed
				break;
			}

			case InShoulder:
			{
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.035;
				g_iCurrentMode = NotInShoulder;
				self.SendWeaponAnim( BAZOOKA_UPTODOWN );
				m_pPlayer.pev.maxspeed = 0;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == BAZOOKA_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		if( g_iCurrentMode == NotInShoulder )
			self.DefaultReload( BAZOOKA_MAX_CLIP, BAZOOKA_RELOAD_IDLE, 3.05, 0 );
		else
			self.DefaultReload( BAZOOKA_MAX_CLIP, BAZOOKA_RELOAD_AIMED, 3.05, 0 );

		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( (g_iCurrentMode == InShoulder) ? BAZOOKA_AIMED : BAZOOKA_IDLE );
		
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetBAZOOKAName()
{
	return "weapon_bazooka";
}

void RegisterBAZOOKA()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetBAZOOKAName(), GetBAZOOKAName() );
	g_ItemRegistry.RegisterWeapon( GetBAZOOKAName(), "ww2projekt", "rockets" );
}