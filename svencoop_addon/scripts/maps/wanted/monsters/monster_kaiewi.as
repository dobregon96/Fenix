namespace HLWanted_Kaiewi
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEAD,
	BODYGROUP_GUN
}

enum HeadSubModel
{
	HEAD_1 = 0,
	HEAD_2,
	HEAD_3,
	HEAD_4
}

enum WeaponSubModel
{
	GUN_BOW = 0,
	GUN_WINCHESTER,
	GUN_NONE
}

class monster_kaiewi : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/kaiewi/ka_die1.wav",
		"wanted/kaiewi/ka_die2.wav",
		"wanted/kaiewi/ka_die3.wav",
		"wanted/kaiewi/ka_pain1.wav",
		"wanted/kaiewi/ka_pain2.wav",
		"wanted/kaiewi/ka_pain3.wav",
		"wanted/kaiewi/ka_pain4.wav",
		"wanted/kaiewi/ka_pain5.wav",
		"wanted/kaiewi/k_alert0.wav",
		"wanted/kaiewi/k_alert1.wav",
		"wanted/kaiewi/k_alert2.wav",
		"wanted/kaiewi/k_answer0.wav",
		"wanted/kaiewi/k_answer1.wav",
		"wanted/kaiewi/k_answer2.wav",
		"wanted/kaiewi/k_charge0.wav",
		"wanted/kaiewi/k_charge1.wav",
		"wanted/kaiewi/k_charge2.wav",
		"wanted/kaiewi/k_check0.wav",
		"wanted/kaiewi/k_check1.wav",
		"wanted/kaiewi/k_clear0.wav",
		"wanted/kaiewi/k_clear1.wav",
		"wanted/kaiewi/k_clear2.wav",
		"wanted/kaiewi/k_clear3.wav",
		"wanted/kaiewi/k_cover0.wav",
		"wanted/kaiewi/k_cover1.wav",
		"wanted/kaiewi/k_dynamite0.wav",
		"wanted/kaiewi/k_dynamite1.wav",
		"wanted/kaiewi/k_dynamite2.wav",
		"wanted/kaiewi/k_idle0.wav",
		"wanted/kaiewi/k_idle1.wav",
		"wanted/kaiewi/k_question0.wav",
		"wanted/kaiewi/k_question1.wav",
		"wanted/kaiewi/k_question2.wav",
		"wanted/kaiewi/k_question3.wav",
		"wanted/kaiewi/k_question4.wav",
		"wanted/kaiewi/k_taunt0.wav",
		"wanted/kaiewi/k_taunt1.wav",
		"wanted/kaiewi/k_taunt2.wav",
		"wanted/kaiewi/k_throw0.wav",
		"wanted/kaiewi/k_throw1.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/kaiewi.mdl" );

		for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
			g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
		}
	}

	void Spawn( void )
	{
		Precache();

		pev.solid = SOLID_NOT;

		if( pev.body == -1 )
			pev.body = Math.RandomLong( HEAD_1, HEAD_4 );

		dictionary keyvalues = {
			{ "model", "models/wanted/kaiewi.mdl" },
			{ "soundlist", "../wanted/kaiewi/kaiewi.txt" },
			{ "displayname", "Kaiewi" }
		};
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_human_grunt", keyvalues, false );

		CBaseMonster@ pGrunt = pEntity.MyMonsterPointer();

		pGrunt.pev.origin = pev.origin;
		pGrunt.pev.angles = pev.angles;
		pGrunt.pev.health = pev.health;
		pGrunt.pev.targetname = pev.targetname;
		pGrunt.pev.netname = pev.netname;
		pGrunt.pev.weapons = 8;
		pGrunt.pev.body = pev.body;
		pGrunt.pev.skin = pev.skin;
		pGrunt.pev.mins = pev.mins;
		pGrunt.pev.maxs = pev.maxs;
		pGrunt.pev.scale = pev.scale;
		pGrunt.pev.rendermode = pev.rendermode;
		pGrunt.pev.renderamt = pev.renderamt;
		pGrunt.pev.rendercolor = pev.rendercolor;
		pGrunt.pev.renderfx = pev.renderfx;
		pGrunt.pev.spawnflags = pev.spawnflags;

		g_EntityFuncs.DispatchSpawn( pGrunt.edict() );

		pGrunt.m_iTriggerCondition = self.m_iTriggerCondition;
		pGrunt.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_kaiewi_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "deadstomach", "deadside", "deadsitting" };

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "pose" )
		{
			m_iPose = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( self, "models/wanted/kaiewi.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/kaiewi.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		const float flHealth = self.pev.health;

		self.MonsterInitDead();

		self.pev.health = flHealth;

		if( self.pev.health == 0 )
			self.pev.health = 8;

		self.m_bloodColor 	= BLOOD_COLOR_RED;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_HUMAN_MILITARY );

		self.m_FormattedName = "Dead Kaiewi";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_3) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead kaiewi with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Kaiewi::monster_kaiewi", "monster_kaiewi" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Kaiewi::monster_kaiewi_dead", "monster_kaiewi_dead" );
}

} // end of HLWanted_Kaiewi namespace