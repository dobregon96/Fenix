/*  
* GluonGun Projectile
* 
*	
*	
*/

const int GLUON_DAMAGE = Math.RandomLong(150,200); // for primary fire

const int GLUON_DAMAGE_ALT = Math.RandomLong(45,60); // for secondary fire

class CGluon : ScriptBaseEntity
{
	int m_iTrail, m_iRingTexture;
	
	int m_iBallSprite, m_iBallSprite2;
	
	void ExplodeTouch( CBaseEntity@ pOther )
	{
		if( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_SKY )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
		
		TraceResult tr;
		
		Vector vecSpot = self.pev.origin - pev.velocity.Normalize() * 32;
		Vector vecEnd = self.pev.origin + pev.velocity.Normalize() * 64;
		
		g_Utility.TraceLine( vecSpot, vecEnd, ignore_monsters, self.edict(), tr );
		
		g_Utility.DecalTrace( tr, DECAL_SCORCH1 + Math.RandomLong(0,1) );

		entvars_t@ pevOwner = self.pev.owner.vars;
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, GLUONGUN_SOUND_EXPLODE, 1, ATTN_NONE );
		
		int r = 0, g = 255, b = 255, decay = 25;
	
		int8 dynlife = 5;
		
		int lifetime = 300;
		
		NetworkMessage dynlight( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			dynlight.WriteByte( TE_DLIGHT );
			dynlight.WriteCoord( self.pev.origin.x );
			dynlight.WriteCoord( self.pev.origin.y );
			dynlight.WriteCoord( self.pev.origin.z );
			dynlight.WriteByte( 16 );
			dynlight.WriteByte( int(r) );
			dynlight.WriteByte( int(g) );
			dynlight.WriteByte( int(b) );
			dynlight.WriteByte( dynlife );
			dynlight.WriteByte( decay );
		dynlight.End();
		
		int discLife = 4;
		int discWidth = 16;
		int discR = 255;
		int discG = 255;
		int discB = 255;
		int discBrightness = 255;
		int glowLife = int(self.pev.dmg/5);//20
		int glowScale = 255;
		int glowBrightness = 255;
		
		int offsetz = 16;
		
		NetworkMessage beamcylinder1( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			beamcylinder1.WriteByte( TE_BEAMCYLINDER );
			beamcylinder1.WriteCoord( self.pev.origin.x );
			beamcylinder1.WriteCoord( self.pev.origin.y );
			beamcylinder1.WriteCoord( self.pev.origin.z + offsetz );
			beamcylinder1.WriteCoord( self.pev.origin.x );
			beamcylinder1.WriteCoord( self.pev.origin.y );
			beamcylinder1.WriteCoord( self.pev.origin.z + 160 );
			beamcylinder1.WriteShort( m_iRingTexture );
			beamcylinder1.WriteByte( 0 );
			beamcylinder1.WriteByte( 0 );
			beamcylinder1.WriteByte( discLife );
			beamcylinder1.WriteByte( discWidth );
			beamcylinder1.WriteByte( 0 );
			beamcylinder1.WriteByte( int(discR) );
			beamcylinder1.WriteByte( int(discG) );
			beamcylinder1.WriteByte( int(discB) );
			beamcylinder1.WriteByte( int(discBrightness) );
			beamcylinder1.WriteByte( 0 );
		beamcylinder1.End();
		
		NetworkMessage beamcylinder2( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			beamcylinder2.WriteByte( TE_BEAMCYLINDER );
			beamcylinder2.WriteCoord( self.pev.origin.x );
			beamcylinder2.WriteCoord( self.pev.origin.y );
			beamcylinder2.WriteCoord( self.pev.origin.z + offsetz );
			beamcylinder2.WriteCoord( self.pev.origin.x );
			beamcylinder2.WriteCoord( self.pev.origin.y );
			beamcylinder2.WriteCoord( self.pev.origin.z + 320 );
			beamcylinder2.WriteShort( m_iRingTexture );
			beamcylinder2.WriteByte( 0 );
			beamcylinder2.WriteByte( 0 );
			beamcylinder2.WriteByte( discLife );
			beamcylinder2.WriteByte( discWidth );
			beamcylinder2.WriteByte( 0 );
			beamcylinder2.WriteByte( int(discR) );
			beamcylinder2.WriteByte( int(discG) );
			beamcylinder2.WriteByte( int(discB) );
			beamcylinder2.WriteByte( int(discBrightness) );
			beamcylinder2.WriteByte( 0 );
		beamcylinder2.End();
		
		NetworkMessage beamcylinder3( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			beamcylinder3.WriteByte( TE_BEAMCYLINDER );
			beamcylinder3.WriteCoord( self.pev.origin.x );
			beamcylinder3.WriteCoord( self.pev.origin.y );
			beamcylinder3.WriteCoord( self.pev.origin.z + offsetz);
			beamcylinder3.WriteCoord( self.pev.origin.x );
			beamcylinder3.WriteCoord( self.pev.origin.y );
			beamcylinder3.WriteCoord( self.pev.origin.z + 480 );
			beamcylinder3.WriteShort( m_iRingTexture );
			beamcylinder3.WriteByte( 0 );
			beamcylinder3.WriteByte( 0 );
			beamcylinder3.WriteByte( discLife );
			beamcylinder3.WriteByte( discWidth );
			beamcylinder3.WriteByte( 0 );
			beamcylinder3.WriteByte( int(discR) );
			beamcylinder3.WriteByte( int(discG) );
			beamcylinder3.WriteByte( int(discB) );
			beamcylinder3.WriteByte( int(discBrightness) );
			beamcylinder3.WriteByte( 0 );
		beamcylinder3.End();
		
		uint8 ballscale = 32;
		uint8 ballalpha = 255;
		uint8  balllife	= 1;
		
		
		NetworkMessage ballsprite(MSG_PVS, NetworkMessages::SVC_TEMPENTITY);
			ballsprite.WriteByte(TE_GLOWSPRITE);
			ballsprite.WriteCoord(self.pev.origin.x);
			ballsprite.WriteCoord(self.pev.origin.y);
			ballsprite.WriteCoord(self.pev.origin.z);
			ballsprite.WriteShort(m_iBallSprite);
			ballsprite.WriteByte(uint8(balllife));
			ballsprite.WriteByte(uint8(ballscale));
			ballsprite.WriteByte(uint8(ballalpha));
			ballsprite.End();
		
		NetworkMessage ballsprite2(MSG_PVS, NetworkMessages::SVC_TEMPENTITY);
			ballsprite2.WriteByte(TE_SPRITE);
			ballsprite2.WriteCoord(self.pev.origin.x);
			ballsprite2.WriteCoord(self.pev.origin.y);
			ballsprite2.WriteCoord(self.pev.origin.z);
			ballsprite2.WriteShort(m_iBallSprite2);
			ballsprite2.WriteByte(uint8(ballscale));
			ballsprite2.WriteByte(uint8(ballalpha));
			ballsprite2.End();
		
		// just a reference :)
		//void RadiusDamage(const Vector& in vecSrc, entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, float flRadius, int iClassIgnore, int bitsDamageType)
		
		g_WeaponFuncs.RadiusDamage(	self.pev.origin, self.pev, pevOwner, self.pev.dmg, 256, CLASS_NONE, DMG_ENERGYBEAM | DMG_NEVERGIB);
		
		g_EntityFuncs.Remove( self );
	
	}
	
	void ExplodeTouchAlt( CBaseEntity@ pOther )
	{
		if( g_EngineFuncs.PointContents( self.pev.origin ) == CONTENTS_SKY )
		{
			g_EntityFuncs.Remove( self );
			return;
		}
		
		TraceResult tr;
		
		Vector vecSpot = self.pev.origin - pev.velocity.Normalize() * 32;
		Vector vecEnd = self.pev.origin + pev.velocity.Normalize() * 64;
		
		g_Utility.TraceLine( vecSpot, vecEnd, ignore_monsters, self.edict(), tr );
		
		g_Utility.DecalTrace( tr, DECAL_SCORCH1 + Math.RandomLong(0,1) );

		entvars_t@ pevOwner = self.pev.owner.vars;
		
		g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, GLUONGUN_SOUND_EXPLODE2, 1, ATTN_NONE );
		
		int r = 0, g = 255, b = 255, decay = 25;
	
		int8 dynlife = 5;
		
		int lifetime = 300;
		
		NetworkMessage dynlightalt( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			dynlightalt.WriteByte( TE_DLIGHT );
			dynlightalt.WriteCoord( self.pev.origin.x );
			dynlightalt.WriteCoord( self.pev.origin.y );
			dynlightalt.WriteCoord( self.pev.origin.z );
			dynlightalt.WriteByte( 16 );
			dynlightalt.WriteByte( int(r) );
			dynlightalt.WriteByte( int(g) );
			dynlightalt.WriteByte( int(b) );
			dynlightalt.WriteByte( dynlife );
			dynlightalt.WriteByte( decay );
		dynlightalt.End();
		
		uint8 ballscale = 64;
		uint8 ballalpha = 255;
		uint8  balllife	= 1;
		
		NetworkMessage ballsprite(MSG_PVS, NetworkMessages::SVC_TEMPENTITY);
			ballsprite.WriteByte(TE_GLOWSPRITE);
			ballsprite.WriteCoord(self.pev.origin.x);
			ballsprite.WriteCoord(self.pev.origin.y);
			ballsprite.WriteCoord(self.pev.origin.z);
			ballsprite.WriteShort(m_iBallSprite);
			ballsprite.WriteByte(uint8(balllife));
			ballsprite.WriteByte(uint8(ballscale));
			ballsprite.WriteByte(uint8(ballalpha));
			ballsprite.End();
		
		NetworkMessage ballsprite2(MSG_PVS, NetworkMessages::SVC_TEMPENTITY);
			ballsprite2.WriteByte(TE_SPRITE);
			ballsprite2.WriteCoord(self.pev.origin.x);
			ballsprite2.WriteCoord(self.pev.origin.y);
			ballsprite2.WriteCoord(self.pev.origin.z);
			ballsprite2.WriteShort(m_iBallSprite2);
			ballsprite2.WriteByte(uint8(ballscale));
			ballsprite2.WriteByte(uint8(ballalpha));
			ballsprite2.End();
		
		g_WeaponFuncs.RadiusDamage(	self.pev.origin, self.pev, pevOwner, self.pev.dmg, 256, CLASS_NONE, DMG_ENERGYBEAM | DMG_NEVERGIB);
		
		g_EntityFuncs.Remove( self );
	
	}
	
	
	void Precache()
	{
		m_iTrail = g_Game.PrecacheModel(  "sprites/custom_weapons/gluongun_trail.spr" );
		m_iRingTexture = g_Game.PrecacheModel(  "sprites/custom_weapons/gluongun_ring.spr" );
		
		m_iBallSprite = g_Game.PrecacheModel(GLUONGUN_SPRITE_2);
		m_iBallSprite2 = g_Game.PrecacheModel(GLUONGUN_SPRITE_4);
	}
	
	void Spawn()
	{
		Precache();
		
		self.pev.solid = SOLID_BBOX;
		self.pev.rendermode = kRenderTransAdd;
		self.pev.renderamt = 255;
		self.pev.rendercolor = Vector(170,90,250);

		g_EntityFuncs.SetModel( self, GLUONGUN_SPRITE_PROJECTILE );
		
		g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );
		
		self.pev.frame = 0;
		
	}
	
	void Fly()
	{
		
		int r=153, g=64, b=189, br=128;
		int r2=255, g2=255, b2=255, br2=64;
		
		NetworkMessage ntrail1( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
			ntrail1.WriteByte( TE_BEAMFOLLOW );
			ntrail1.WriteShort( self.entindex() );
			ntrail1.WriteShort( m_iTrail  );
			ntrail1.WriteByte( Math.RandomLong(5,30) );//Life
			ntrail1.WriteByte( Math.RandomLong(8,10) );//Width
			ntrail1.WriteByte( int(r) );
			ntrail1.WriteByte( int(g) );
			ntrail1.WriteByte( int(b) );
			ntrail1.WriteByte( int(br) );
		ntrail1.End();
		
		self.pev.frame++;
	
		if ( self.pev.frame > 10 )
			self.pev.frame = 0;
			
		self.pev.nextthink = g_Engine.time + 0.05;
	}
	
	void FlyAlt()
	{
		
		self.pev.frame++;
	
		if ( self.pev.frame > 10 )
			self.pev.frame = 0;
			
		self.pev.nextthink = g_Engine.time + 0.05;
	
	}

}
	
CGluon@ ShootGluon( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity, bool m_bSecondaryFire, int iWastedAmmo )
{
	CBaseEntity@ cbeGluon = g_EntityFuncs.CreateEntity( "Gluon", null,  false);
	
	CGluon@ pGluon = cast<CGluon@>(CastToScriptClass(cbeGluon));
	
	g_EntityFuncs.DispatchSpawn( pGluon.self.edict() );
	
	g_EntityFuncs.SetOrigin( pGluon.self, vecStart );
	
	pGluon.pev.velocity = vecVelocity;
	
	pGluon.pev.angles = Math.VecToAngles( pGluon.pev.velocity );
	
	@pGluon.pev.owner = pevOwner.pContainingEntity;
	
	if ( m_bSecondaryFire )
	{
		pGluon.pev.movetype = MOVETYPE_FLY;
		
		pGluon.pev.dmg = GLUON_DAMAGE * iWastedAmmo;
		
		pGluon.pev.scale = iWastedAmmo / 2;
		
		pGluon.SetTouch( TouchFunction( pGluon.ExplodeTouchAlt) );
		
		pGluon.SetThink( ThinkFunction( pGluon.FlyAlt ) );
		
	}
	else
	{
		pGluon.pev.movetype = MOVETYPE_BOUNCE;
		
		pGluon.pev.gravity = 4;
		
		pGluon.pev.dmg = GLUON_DAMAGE;
		
		pGluon.SetTouch( TouchFunction( pGluon.ExplodeTouch) );
		
		pGluon.SetThink( ThinkFunction( pGluon.Fly ) );
	}
	
	pGluon.pev.nextthink =  0.1;
	
	return pGluon;
	
}
void RegisterGluon()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CGluon", "Gluon" );
}