namespace CS16
{
	const int STARTMONEY					= 75; //when joining a server, players will receive this amount
	const float MONEY_WORTH					= 10; //how much money to give to the player when picking up dropped money-stacks
	const int MONEY_DROPAMOUNT_MIN			= 3; //minimum amount of money-stacks to drop upon monster death
	const int MONEY_DROPAMOUNT_MAX			= 6; //maximum amount of money-stacks to drop upon monster death
	const string MONEY_ENTNAME				= "cs16_money";

	const array<string> m_arrsNPCs = 
	{
		"monster_alien_babyvoltigore",
		"monster_alien_controller",
		"monster_alien_grunt",
		"monster_alien_slave",
		"monster_alien_tor",
		"monster_alien_voltigore",
		"monster_apache",
		"monster_babycrab",
		"monster_babygarg",
		"monster_barnacle",
		"monster_barney",
		"monster_bigmomma",
		"monster_blkop_apache",
		"monster_blkop_osprey",
		"monster_bloater",
		"monster_bodyguard",
		"monster_bullchicken",
		"monster_chumtoad",
		"monster_cleansuit_scientist",
		"monster_cockroach",
		"monster_flyer",
		"monster_flyer_flock",
		"monster_gargantua",
		"monster_gman",
		"monster_gonome",
		"monster_headcrab",
		"monster_houndeye",
		"monster_human_assassin",
		"monster_human_grunt",
		"monster_human_grunt_ally",
		"monster_human_medic_ally",
		"monster_human_torch_ally",
		"monster_hwgrunt",
		"monster_ichthyosaur",
		"monster_kingpin",
		"monster_leech",
		"monster_male_assassin",
		"monster_miniturret",
		"monster_nihilanth",
		"monster_op4loader",
		"monster_osprey",
		"monster_otis",
		"monster_pitdrone",
		"monster_rat",
		"monster_robogrunt",
		"monster_scientist",
		"monster_sentry",
		"monster_shockroach",
		"monster_shocktrooper",
		"monster_snark",
		"monster_stukabat",
		"monster_tentacle",
		"monster_turret",
		"monster_zombie",
		"monster_zombie_barney",
		"monster_zombie_soldier"
	};

	void CSMoneyMapInit()
	{
		g_Game.PrecacheModel( "models/cs16/money.mdl" );

		g_CustomEntityFuncs.RegisterCustomEntity( "CS16::func_buystation", "func_buystation" );
		g_CustomEntityFuncs.RegisterCustomEntity( "CS16::cs16_money", MONEY_ENTNAME );
		g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
		g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );

		//Precache these for downloading
		g_Game.PrecacheGeneric( "sound/kf/Cash_Pickup1.wav" );
		g_Game.PrecacheGeneric( "sound/kf/Cash_Pickup2.wav" );
		g_Game.PrecacheGeneric( "sound/kf/Cash_Pickup3.wav" );
		g_Game.PrecacheGeneric( "sound/kf/Cash_Pickup4.wav" );

		//Precache these for usage
		g_SoundSystem.PrecacheSound( "kf/Cash_Pickup1.wav" );
		g_SoundSystem.PrecacheSound( "kf/Cash_Pickup2.wav" );
		g_SoundSystem.PrecacheSound( "kf/Cash_Pickup3.wav" );
		g_SoundSystem.PrecacheSound( "kf/Cash_Pickup4.wav" );
	}

	void CSMoneyMapActivate()
	{
		CBaseEntity@ pEntity = null;

		const array<string> arrsEntsToRemove =
		{
			"ammo_357",
			"ammo_556",
			"ammo_762",
			"ammo_9mmbox",
			"ammo_9mmAR",
			"ammo_mp5clip",
			"ammo_glockclip",
			"ammo_9mmclip",
			"ammo_argrenades",
			"ammo_buckshot",
			"ammo_crossbow",
			"ammo_gaussclip",
			"ammo_rpgclip",
			"ammo_spore",
			"ammo_sporeclip",
			"ammo_uziclip",
			"item_battery",
			"item_healthkit",
			"weapon_357",
			"weapon_9mmar",
			"weapon_mp5",
			"weapon_9mmhandgun",
			"weapon_glock",
			"weapon_crossbow",
			"weapon_displacer",
			"weapon_eagle",
			"weapon_egon",
			"weapon_gauss",
			"weapon_grapple",
			"weapon_handgrenade",
			"weapon_hornetgun",
			"weapon_m16",
			"weapon_m249",
			"weapon_medkit",
			"weapon_minigun",
			"weapon_pipewrench",
			"weapon_rpg",
			"weapon_satchel",
			"weapon_shockrifle",
			"weapon_shotgun",
			"weapon_snark",
			"weapon_sniperrifle",
			"weapon_sporelauncher",
			"weapon_tripmine",
			"weapon_uzi",
			"weapon_uziakimbo",
			"weaponbox"
		};

		while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "*")) !is null )
		{
			if( pEntity.pev.ClassNameIs("func_healthcharger" ) or pEntity.pev.ClassNameIs("func_recharge" ) )
			{
				dictionary keys;
				keys["model"] = string(pEntity.pev.model);
				keys["frame"] = "0"; //set this to 1 if you want the "turned off"-skin

				g_EntityFuncs.Remove(pEntity);
				g_EntityFuncs.CreateEntity("func_buystation", keys);
			}

			if( arrsEntsToRemove.find(pEntity.GetClassname().ToLowercase()) >= 0 )
			{
				Vector origin = pEntity.GetOrigin();

				dictionary keys;
				keys["targetname"] = string(pEntity.pev.targetname);
				keys["target"] = string(pEntity.pev.target);
				keys["origin"] = "" + origin.x + " " + origin.y + " " + origin.z;
				keys["angles"] = "" + 0 + " " + pEntity.pev.angles.y + " " + 0;

				g_EntityFuncs.Remove(pEntity);
				g_EntityFuncs.CreateEntity("cs16_money", keys);
				//g_Game.AlertMessage( at_console, "FOUND AND REMOVED: %1\n", pEntity.GetClassname() );
			}

			if( pEntity.pev.ClassNameIs("weapon_crowbar") )
			{
				Vector origin = pEntity.GetOrigin();

				dictionary keys;
				keys["targetname"] = string(pEntity.pev.targetname);
				keys["target"] = string(pEntity.pev.target);
				keys["origin"] = "" + origin.x + " " + origin.y + " " + origin.z;
				keys["angles"] = "" + 0 + " " + pEntity.pev.angles.y + " " + 0;

				g_EntityFuncs.Remove(pEntity);
				g_EntityFuncs.CreateEntity("weapon_csknife", keys);
			}
		}
	}

	HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
	{
		pPlayer.pev.frags = STARTMONEY;

		return HOOK_CONTINUE;
	}

	HookReturnCode EntityCreated( CBaseEntity@ pEntity )
	{
		if( m_arrsNPCs.find(pEntity.GetClassname()) < 0 ) return HOOK_CONTINUE;

		g_Scheduler.SetTimeout( "entPostSpawn", 0.1f, g_EngineFuncs.IndexOfEdict(pEntity.edict()) );

		return HOOK_CONTINUE;
	}

	void entPostSpawn( int &in id )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( id );

		if( pEntity is null ) return;

		CBaseMonster@ pMonster = null;
		@pMonster = cast<CBaseMonster@>( pEntity );

		if( pMonster !is null )
		{
			if( pMonster.m_iTriggerCondition <= 0 ) //No trigger condition
				g_EntityFuncs.DispatchKeyValue( pMonster.edict(), "TriggerCondition", "4" ); //Trigger on death

			if( pMonster.m_iTriggerCondition == 4 ) //Trigger on death
			{
				string sTriggerTarget = pMonster.m_iszTriggerTarget;

				if( sTriggerTarget == "" ) sTriggerTarget = "cs16_doshdrop_" + string(pMonster.entindex());

				g_EntityFuncs.DispatchKeyValue( pMonster.edict(), "TriggerTarget", sTriggerTarget );

				dictionary keys;
				keys["targetname"] = sTriggerTarget;
				keys["m_iszScriptFile"] = "cs16/cs16money.as";
				keys["m_iszScriptFunctionName"] = "CS16::DropDosh";
				keys["killtarget"] = sTriggerTarget;
				g_EntityFuncs.CreateEntity( "trigger_script", keys );
			}
		}
	}

	void DropDosh( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		Vector origin = pActivator.GetOrigin();

		int iAmount = Math.RandomLong(MONEY_DROPAMOUNT_MIN, MONEY_DROPAMOUNT_MAX);

		for( int i = 0; i < iAmount; i++ )
		{
			Vector vecAiming = Vector( Math.RandomFloat(0, 360), Math.RandomFloat(0, 360), Math.RandomFloat(0, 360) );
			CBaseEntity@ pMoney = g_EntityFuncs.Create( MONEY_ENTNAME, origin, Vector(0, Math.RandomFloat(0, 360), 0), false, null );
			Math.MakeVectors( vecAiming );

			pMoney.pev.velocity = vecAiming.Normalize() + g_Engine.v_forward * 210;
		}
	}

	class func_buystation : ScriptBaseEntity
	{
		void Spawn()
		{
			pev.solid = SOLID_BSP;
			pev.movetype = MOVETYPE_PUSH;

			g_EntityFuncs.SetOrigin( self, pev.origin );
			g_EntityFuncs.SetSize( pev, pev.mins, pev.maxs );
			g_EntityFuncs.SetModel( self, string(pev.model) );

			pev.frame = 0;
		}

		void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
		{
			if( pActivator is null ) return;
			if( !pActivator.IsPlayer() ) return;

			CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

			g_BuyMenu.Show( pPlayer );
		}

		int	ObjectCaps() { return (BaseClass.ObjectCaps() | FCAP_ONOFF_USE) & ~FCAP_ACROSS_TRANSITION; }
	}

	class cs16_money : ScriptBaseEntity
	{
		void Spawn()
		{
			pev.movetype = MOVETYPE_TOSS;
			pev.solid = SOLID_TRIGGER;

			g_EntityFuncs.SetSize( pev, pev.mins, pev.maxs );
			g_EntityFuncs.SetModel( self, "models/cs16/money.mdl" );
		}

		void Touch( CBaseEntity@ pOther )
		{
			if( (pev.flags & FL_ONGROUND) == 0 )
				return;

			GiveMoney( pOther );
		}

		void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
		{
			if( (pev.flags & FL_ONGROUND) == 0 )
				return;

			GiveMoney( pActivator );
		}

		int	ObjectCaps() { return (BaseClass.ObjectCaps() | FCAP_ONOFF_USE) & ~FCAP_ACROSS_TRANSITION; }

		void GiveMoney( CBaseEntity@ pEntity )
		{
			if( !pEntity.IsPlayer() ) return;
			if( !pEntity.IsAlive() ) return;

			pEntity.pev.frags += MONEY_WORTH;

			SetTouch(null);
			SetUse(null);

			string sPickupSound = "kf/Cash_Pickup" + (Math.RandomLong(1, 4)) + ".wav";
			g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, sPickupSound, VOL_NORM, ATTN_NORM );

			g_EntityFuncs.Remove(self);
		}
	}
}