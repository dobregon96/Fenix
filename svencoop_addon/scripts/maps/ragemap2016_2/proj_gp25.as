class CGP25Grenade : ScriptBaseMonsterEntity
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, RG6_MODEL_CLIP );
	}

	void Precache()
	{

	}
	
	void Think()
	{
		self.pev.angles.z = -Math.VecToAngles( self.pev.velocity ).x;
		if( !self.IsInWorld() )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
		
		if( self.pev.iuser1 == MODE_BOUNCE )
		{
			if( self.pev.velocity.Length()  <= 10.0f )
				Explode();
		}
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_SKY )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
		
		switch( self.pev.iuser1 )
		{
			case MODE_BOUNCE:
			{
				Vector vecVelocity = self.pev.velocity * 0.4f;
				self.pev.velocity = vecVelocity;
				
				if( self.pev.fuser1 <= 0.0f )
				{
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_ITEM, RG6_SOUND_BOUNCE, 1.0, ATTN_NORM, 0, 97 );
					self.pev.fuser1 = Math.RandomFloat( 0.5f, 0.9f );
				}
			}
			break;
			
			case MODE_INSTANT:
				Explode();
			break;
		}
	}

	void Explode()
	{
		TraceResult tr;
		if( self.pev.iuser1 == MODE_BOUNCE )
			g_Utility.TraceLine( self.pev.origin, self.pev.origin + Vector( 0, 0, -32 ),  ignore_monsters, self.edict(), tr );
		else
			tr = g_Utility.GetGlobalTrace();
			
		entvars_t@ pevOwner = self.pev.owner.vars;
		te_explosiongp( self.pev.origin, RG6_SPRITE_EXPLODE, int(self.pev.dmg), 15, TE_EXPLFLAG_NONE );
		g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, pevOwner, self.pev.dmg, RG6_GRENADE_RADIUS, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB );
		g_Utility.DecalTrace( tr, DECAL_SCORCH1 + Math.RandomLong(0,1) );
		g_EntityFuncs.Remove( self );
	}
}

CGP25Grenade ShootGP25Grenade( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity, int g_iGrenadeMode )
{
	int r = 250;
	int g = 0;
	int b = 0;
	int br = 250;
	
	CBaseEntity@ cbeGrenade = g_EntityFuncs.CreateEntity( "gp25_nade", null,  false);
	CGP25Grenade@ pGrenade = cast<CGP25Grenade@>(CastToScriptClass(cbeGrenade));
	g_EntityFuncs.SetOrigin( pGrenade.self, vecStart );
	g_EntityFuncs.DispatchSpawn( pGrenade.self.edict() );
	pGrenade.pev.gravity = 0.5f;
	pGrenade.pev.movetype = g_iGrenadeMode == MODE_BOUNCE ? MOVETYPE_BOUNCE : MOVETYPE_TOSS;
	pGrenade.pev.solid = SOLID_BBOX;
	g_EntityFuncs.SetSize( pGrenade.pev, g_vecZero, g_vecZero );
	@pGrenade.pev.owner = pevOwner.pContainingEntity;
	pGrenade.pev.velocity = vecVelocity;
	pGrenade.pev.angles = Math.VecToAngles( pGrenade.pev.velocity );
	const Vector vecAngles = Math.VecToAngles( pGrenade.pev.velocity );
    pGrenade.pev.angles.x = vecAngles.z;
    pGrenade.pev.angles.y = vecAngles.y + 90;
    pGrenade.pev.angles.z = vecAngles.x;
	pGrenade.SetThink( ThinkFunction( pGrenade.Think ) );
	pGrenade.pev.nextthink = g_Engine.time + 0.1f;
	pGrenade.SetTouch( TouchFunction( pGrenade.Touch ) );
	pGrenade.pev.dmg = RG6_DAMAGE;
	pGrenade.pev.iuser1 = g_iGrenadeMode;

	NetworkMessage trail( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
		trail.WriteByte( TE_BEAMFOLLOW );
		trail.WriteShort( pGrenade.self.entindex() );
		trail.WriteShort( g_EngineFuncs.ModelIndex(RG6_SPRITE_TRAIL) );
		trail.WriteByte( 25 );//Life
		trail.WriteByte( 5 );//Width
		trail.WriteByte( int(r) );
		trail.WriteByte( int(g) );
		trail.WriteByte( int(b) );
		trail.WriteByte( int(br) );
	trail.End();

	return pGrenade;
}

void te_explosiongp( Vector origin, string sprite, int scale, int frameRate, int flags )
{
	NetworkMessage exp1(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY);
		exp1.WriteByte( TE_EXPLOSION );
		exp1.WriteCoord( origin.x );
		exp1.WriteCoord( origin.y );
		exp1.WriteCoord( origin.z );
		exp1.WriteShort( g_EngineFuncs.ModelIndex(sprite) );
		exp1.WriteByte( int((scale-50) * .60) );
		exp1.WriteByte( frameRate );
		exp1.WriteByte( flags );
	exp1.End();
}

void RegisterGP25Grenade()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CGP25Grenade", "gp25_nade" );
}