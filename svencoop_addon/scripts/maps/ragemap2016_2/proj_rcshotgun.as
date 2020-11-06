const int RCSHOTGUNSCI_DAMAGE	= 105;
const int RCSHOTGUNHEV_DAMAGE	= 200;

class RCShotgunScientist : ScriptBaseMonsterEntity
{
	int SCIENTIST_EXPLOSION;
	int SCIENTIST_WEXPLOSION;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/custom_weapons/rcshotgun/shotgunsci.mdl" );
		self.ResetSequenceInfo();
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;
		g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );
	}

	void Precache()
	{
		SCIENTIST_EXPLOSION = g_Game.PrecacheModel( "sprites/zerogxplode.spr" );
		SCIENTIST_WEXPLOSION = g_Game.PrecacheModel( "sprites/WXplo1.spr" );
	}
	
	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		//FX_Trail( pev.origin, entindex(), PROJ_REMOVE );
		g_EntityFuncs.Remove( self );
	}

	void ExplodeTouch( CBaseEntity@ pOther )
	{
		if( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_SKY )
		{
			g_EntityFuncs.Remove( self );
			return;
		}

		TraceResult tr;
		Vector vecSpot = self.pev.origin - self.pev.velocity.Normalize() * 32;
		Vector vecEnd = self.pev.origin + self.pev.velocity.Normalize() * 64;
		g_Utility.TraceLine( vecSpot, vecEnd, ignore_monsters, self.edict(), tr );

		entvars_t@ pevOwner = self.pev.owner.vars;
		g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, pevOwner, self.pev.dmg, self.pev.dmg*3, CLASS_NONE, DMG_BLAST );
		//Explosion1( self.pev.origin, ( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_WATER)?SCIENTIST_WEXPLOSION:SCIENTIST_EXPLOSION, RCSHOTGUNSCI_DAMAGE*1.2, 15, 0 );
		g_EntityFuncs.CreateExplosion( self.pev.origin, Vector(0,0,0), pevOwner.pContainingEntity, RCSHOTGUNSCI_DAMAGE*1.2, false);
		//FX_Trail( tr.vecEndPos + (tr.vecPlaneNormal * 15), entindex(), (UTIL_PointContents(pev.origin) == CONTENT_WATER)?PROJ_AK74_DETONATE_WATER:PROJ_AK74_DETONATE );

		//int tex = (int)TEXTURETYPE_Trace(&tr, vecSpot, vecEnd);
		//CBaseEntity *pEntity = CBaseEntity::Instance(tr.pHit);
		//FX_ImpRocket( tr.vecEndPos, tr.vecPlaneNormal, pEntity.IsBSPModel()?1:0, BULLET_NORMEXP, (float)tex );

		if( pOther.pev.takedamage == 1 )
		{
			g_WeaponFuncs.ClearMultiDamage();
			pOther.TraceAttack( pevOwner, self.pev.dmg/4, g_Engine.v_forward, tr, DMG_BULLET ); 
			g_WeaponFuncs.ApplyMultiDamage( self.pev, pevOwner);
		}
		for( uint i = 0; i < g_SciScreams.length(); ++i )
		{
			g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, g_SciScreams[i] );
		}
		
		g_EntityFuncs.Remove( self );
	}
	
	void AnimateThink()
	{
		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.05;
		
		if( !self.IsInWorld() )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
	}
}

RCShotgunScientist@ ShootRCShotgunScientist( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity )
{
	CBaseEntity@ cbeSci = g_EntityFuncs.CreateEntity( "shotgun_sci", null,  false);
	RCShotgunScientist@ pShotSci = cast<RCShotgunScientist@>(CastToScriptClass(cbeSci));
	g_EntityFuncs.SetOrigin( pShotSci.self, vecStart );
	g_EntityFuncs.DispatchSpawn( pShotSci.self.edict() );
	pShotSci.pev.gravity = 1.2;
	pShotSci.pev.velocity = vecVelocity + g_Engine.v_right * Math.RandomFloat( -100,100 ) + g_Engine.v_up * Math.RandomFloat( -100, 100 );
	pShotSci.pev.angles = Math.VecToAngles( -pShotSci.pev.velocity );
	pShotSci.pev.angles.z = 180;
	@pShotSci.pev.owner = pevOwner.pContainingEntity;
	pShotSci.SetThink( ThinkFunction( pShotSci.AnimateThink ) );
	pShotSci.pev.nextthink = g_Engine.time + 0.1;
	pShotSci.SetTouch( TouchFunction( pShotSci.ExplodeTouch ) );
	pShotSci.pev.dmg = RCSHOTGUNSCI_DAMAGE;
	
	return pShotSci;
}

class RCShotgunRocket : ScriptBaseEntity
{
	int m_iTrail;
	float m_flIgniteTime;
	CBeam@ m_pBeam;
	
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, "models/custom_weapons/rcshotgun/shotgunsuit.mdl" );
		self.pev.movetype = MOVETYPE_FLY;
		self.pev.solid = SOLID_BBOX;
		g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		SetThink( ThinkFunction( this.IgniteThink ) );
		SetTouch( TouchFunction( this.ExplodeTouch ) );
		Math.MakeVectors( self.pev.angles );
		self.pev.gravity = 0.5;
		self.pev.nextthink = g_Engine.time + 0.1;
		self.pev.dmg = RCSHOTGUNHEV_DAMAGE;
	}

	void Precache()
	{
		m_iTrail = g_Game.PrecacheModel( "sprites/smoke.spr" );
	}

	void IgniteThink()
	{
		int r=224, g=224, b=255, br=255;
		//self.pev.effects |= EF_LIGHT;

		g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/rocket1.wav", 1.0, 0.5 );
/*
		// rocket trail
		NetworkMessage trail1( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			trail1.WriteByte( TE_BEAMFOLLOW );
			trail1.WriteShort( self.entindex() );
			trail1.WriteShort( m_iTrail );
			trail1.WriteByte( 40 );//Life
			trail1.WriteByte( 5 );//Width
			trail1.WriteByte( int(r) );
			trail1.WriteByte( int(g) );
			trail1.WriteByte( int(b) );
			trail1.WriteByte( int(br) );
		trail1.End();
*/
		m_flIgniteTime = g_Engine.time;

		SetThink( ThinkFunction( this.FlyThink ) );
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void FlyThink()
	{
		self.pev.angles.z -= 45;

		float flSpeed = self.pev.velocity.Length();
		if( g_Engine.time - m_flIgniteTime < 1.0 )
		{	
			if( self.pev.velocity.Length() > 2000 )
			{
				self.pev.velocity = self.pev.velocity.Normalize() * 2000;
			}
		}
		else
		{
			if( self.pev.velocity.Length() < 1500 )
			{
				self.pev.movetype = MOVETYPE_BOUNCE;
			}
		}

		UpdateEffect( self.pev.origin );
		self.pev.nextthink = g_Engine.time + 0.1;
	}
	
	void RocketTouch( CBaseEntity@ pOther )
	{
		DestroyEffect();
		g_SoundSystem.StopSound( self.edict(), CHAN_VOICE, "weapons/rocket1.wav" );
		this.ExplodeTouch( pOther );
	}
	
	void ExplodeTouch( CBaseEntity@ pOther )
	{
		if( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_SKY )
		{
			g_EntityFuncs.Remove( self );
			return;
		}

		TraceResult tr;
		Vector vecSpot = self.pev.origin - self.pev.velocity.Normalize() * 32;
		Vector vecEnd = self.pev.origin + self.pev.velocity.Normalize() * 64;
		g_Utility.TraceLine( vecSpot, vecEnd, ignore_monsters, self.edict(), tr );

		entvars_t@ pevOwner = self.pev.owner.vars;
		g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, pevOwner, RCSHOTGUNSCI_DAMAGE, RCSHOTGUNSCI_DAMAGE*1.2, CLASS_NONE, DMG_BLAST );
		g_EntityFuncs.CreateExplosion( self.pev.origin, Vector(0,0,0), pevOwner.pContainingEntity, RCSHOTGUNSCI_DAMAGE*1.2, false);

		if( pOther.pev.takedamage == 1 )
		{
			g_WeaponFuncs.ClearMultiDamage();
			pOther.TraceAttack( pevOwner, self.pev.dmg/4, g_Engine.v_forward, tr, DMG_BULLET ); 
			g_WeaponFuncs.ApplyMultiDamage( self.pev, pevOwner);
		}
		
		g_EntityFuncs.Remove( self );
	}

	void UpdateEffect( const Vector startPoint )
	{
		if( m_pBeam is null )
		{
			CreateEffect();
		}

		m_pBeam.SetStartPos( startPoint );
		m_pBeam.SetBrightness( 190 );
		m_pBeam.SetWidth( 40 );

		m_pBeam.SetColor( 155, 160, 144 );
	}

	void CreateEffect()
	{
		DestroyEffect();

		@m_pBeam = g_EntityFuncs.CreateBeam( RCSHOTGUN_BEAM_SPRITE, 10 );
		m_pBeam.PointEntInit( self.pev.origin + g_Engine.v_forward*16, self.entindex() );
		
		m_pBeam.SetFlags( BEAM_FSINE );
		m_pBeam.SetEndAttachment( 1 );
		m_pBeam.pev.spawnflags |= SF_BEAM_TEMPORARY;	// Flag these to be destroyed on save/restore or level transition
		//m_pBeam.pev.flags |= FL_SKIPLOCALHOST;
		@m_pBeam.pev.owner = self.pev.owner;

		m_pBeam.SetScrollRate( 50 );
		m_pBeam.SetNoise( 20 );
	}

	void DestroyEffect()
	{
		if( m_pBeam !is null )
		{
			g_EntityFuncs.Remove( m_pBeam );
			@m_pBeam = null;
		}
	}
}

RCShotgunRocket@ ShootShotgunSuit( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity )
{
	CBaseEntity@ cbeHev = g_EntityFuncs.CreateEntity( "shotgun_hev", null,  false);
	RCShotgunRocket@ pShotHev = cast<RCShotgunRocket@>(CastToScriptClass(cbeHev));
	g_EntityFuncs.SetOrigin( pShotHev.self, vecStart );
	pShotHev.pev.velocity = vecVelocity;
	pShotHev.pev.angles = Math.VecToAngles( pShotHev.pev.velocity );
	g_EntityFuncs.DispatchSpawn( pShotHev.self.edict() );
	pShotHev.SetTouch( TouchFunction( pShotHev.RocketTouch ) );
	@pShotHev.pev.owner = pevOwner.pContainingEntity;

	return pShotHev;
}

void RegisterRCShotgunScientist()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "RCShotgunScientist", "shotgun_sci" );
}

void RegisterRCShotgunRocket()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "RCShotgunRocket", "shotgun_hev" );
}