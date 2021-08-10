namespace HLWanted_Ramone
{

class monster_ramone : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/ramone/again.wav",
		"wanted/ramone/arghh.wav",
		"wanted/ramone/colonel.wav",
		"wanted/ramone/death.wav",
		"wanted/ramone/die.wav",
		"wanted/ramone/dieyoub.wav",
		"wanted/ramone/fast.wav",
		"wanted/ramone/hell.wav",
		"wanted/ramone/hellobro.wav",
		"wanted/ramone/isthisit.wav",
		"wanted/ramone/meet.wav",
		"wanted/ramone/men.wav",
		"wanted/ramone/present.wav",
		"wanted/ramone/ra_die1.wav",
		"wanted/ramone/ra_die2.wav",
		"wanted/ramone/ra_die3.wav",
		"wanted/ramone/ra_mgun1.wav",
		"wanted/ramone/ra_mgun2.wav",
		"wanted/ramone/ra_die1.wav",
		"wanted/ramone/ra_pain1.wav",
		"wanted/ramone/ra_pain2.wav",
		"wanted/ramone/ra_pain3.wav",
		"wanted/ramone/ra_pain4.wav",
		"wanted/ramone/ra_pain5.wav",
		"wanted/ramone/ra_reload1.wav",
		"wanted/ramone/until.wav",
		"wanted/ramone/weary.wav",
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/ramone.mdl" );

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

		dictionary keyvalues = {
			{ "model", "models/wanted/ramone.mdl" },
			{ "soundlist", "../wanted/ramone/ramone.txt" },
			{ "disable_minigun_drop", "1" },
			{ "displayname", "Ramone" }
		};
		string szClassname = "monster_hwgrunt";

		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, keyvalues, false );

		CBaseMonster@ pGrunt = pEntity.MyMonsterPointer();

		pGrunt.pev.origin = pev.origin;
		pGrunt.pev.angles = pev.angles;
		pGrunt.pev.health = pev.health;
		pGrunt.pev.targetname = pev.targetname;
		pGrunt.pev.netname = pev.netname;
		pGrunt.pev.weapons = 1;
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

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Ramone::monster_ramone", "monster_ramone" );
}

} // end of HLWanted_Ramone namespace