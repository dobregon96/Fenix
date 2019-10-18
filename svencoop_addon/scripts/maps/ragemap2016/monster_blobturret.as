#include "proj_biomass"

const int TURRET_TURNRATE	= 30;// angles per 0.1 second
const int TURRET_MAXWAIT	= 15;// seconds turret will stay active w/o a target
const float TURRET_FIRERATE	= 1.5f;
const int BIORIFLE_DAMAGE	= 60;

enum TURRET_ANIM
{
	TURRET_ANIM_NONE = 0,
	TURRET_ANIM_FIRE,
	TURRET_ANIM_FIRE_ION,
	TURRET_ANIM_FIRE_MISSILE,
	TURRET_ANIM_SPIN,
	TURRET_ANIM_DEPLOY,
	TURRET_ANIM_RETIRE,
	TURRET_ANIM_DIE,
};

class CBlobTurret : ScriptBaseMonsterEntity
{
	int		m_iDeployHeight;
	int 	m_iMinPitch;
	int 	m_iBaseTurnRate;// angles per second
	float 	m_fTurnRate;// actual turn rate
	bool	m_iOn;

	Vector 	m_vecLastSight;
	float 	m_flLastSight;	// Last time we saw a target
	float 	m_flMaxWait;	// Max time to seach w/o a target

	float	ShieldRegen;
	float	flMaxArmor;
	int		fTookDamage;

	// movement
	float	m_flStartYaw;
	Vector	m_vecCurAngles;
	Vector	m_vecGoalAngles;
	float	m_flPingTime;
	float	m_flShootTime;
	
	bool fEnemyVisible;
	
	void Spawn()
	{
		Precache();
		self.pev.nextthink	= g_Engine.time + 1;
		self.pev.movetype	= MOVETYPE_NOCLIP;//MOVETYPE_BOUNCE
		self.pev.sequence	= 0;
		self.pev.frame		= 0;
		self.pev.solid		= SOLID_NOT;//SOLID_SLIDEBOX
		self.pev.takedamage	= DAMAGE_NO;
		self.pev.angles.x 	= 0;
		self.pev.angles.y 	= 0;
		self.pev.angles.z 	= 0;

		self.pev.gravity 	= 2;
		self.pev.friction 	= 1;

		self.pev.scale		= 0;
		self.pev.renderfx	= kRenderFxGlowShell;
		self.pev.rendermode	= kRenderTransAdd;
		self.pev.renderamt	= 0;

		self.ResetSequenceInfo();
		self.SetBoneController(0, 0);
		self.SetBoneController(1, 0);
		self.m_flFieldOfView = VIEW_FIELD_FULL;

		@self.pev.owner = null;
		
		g_EntityFuncs.SetModel( self, "models/ragemap2016/nero/turret_sentry.mdl" );
		self.pev.body		= 1;
		self.pev.health		= 7777;
		self.pev.max_health	= self.pev.health;
		self.pev.armorvalue	= 100;
		flMaxArmor	        = 100;
		self.m_HackedGunPos	= Vector(0,0,48);
		self.pev.view_ofs.z	= 48;
		m_flMaxWait 		= 1E6;
		m_iDeployHeight 	= 64;
		m_iMinPitch			= -60;
		g_EntityFuncs.SetSize( self.pev, Vector(-16, -16, 0), Vector(16, 16, 32) );
		SetThink( ThinkFunction(this.Initialize) );
		self.pev.nextthink = g_Engine.time + 1; 
	}

	void Precache()
	{
/*
		g_Game.PrecacheModel( "sprites/explode1.spr" );
		g_Game.PrecacheModel( "sprites/spore_exp_01.spr" );
		g_Game.PrecacheModel( "sprites/spore_exp_c_01.spr" );
		g_Game.PrecacheModel( "sprites/WXplo1.spr" );
		g_Game.PrecacheModel( "models/turret.mdl" );
		g_Game.PrecacheModel( "models/custom_weapons/biorifle/w_biomass.mdl" );
		g_Game.PrecacheModel( "models/ragemap2016/nero/turret_sentry.mdl" );
		g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/bustflesh1.wav" );
		g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/bustflesh2.wav" );
		g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/biomass_exp.wav" );
		g_Game.PrecacheGeneric( "sound/custom_weapons/biorifle/biorifle_fire.wav" );
		g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/bustflesh1.wav" );
		g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/bustflesh2.wav" );
		g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/biomass_exp.wav" );
		g_SoundSystem.PrecacheSound( "custom_weapons/biorifle/biorifle_fire.wav" );
*/
	}

	void Initialize()
	{
		m_iOn = false;
		self.SetBoneController( 0, 0 );
		self.SetBoneController( 1, 0 );

		if( m_iBaseTurnRate == 0 )
		m_iBaseTurnRate = TURRET_TURNRATE;

		if( m_flMaxWait == 0 )
		m_flMaxWait = TURRET_MAXWAIT;

		m_flStartYaw = self.pev.angles.y;
		m_vecGoalAngles.x = 0;

		m_flLastSight = g_Engine.time + m_flMaxWait;

		SetThink( ThinkFunction( this.Materialize ) );		
		self.pev.nextthink = g_Engine.time + 0.05;
	}

	void Materialize()
	{
		self.pev.scale += 0.01;
		self.pev.renderamt += 3;

		if( self.pev.scale >= 1 )
		{
			self.pev.scale = 1;
		}

		if( self.pev.renderamt >= 255 )
		{
			self.pev.renderamt = 255;
			self.pev.renderfx &= ~kRenderFxGlowShell;
			self.pev.rendermode = kRenderNormal;
			SetThink( ThinkFunction( this.AutoSearchThink ) );
		}
		self.pev.nextthink = g_Engine.time + 0.02;
	}

	void Ping()
	{
		if( g_Engine.time >= m_flPingTime )
		{
			//g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, TUR_SOUND_PING, 1, ATTN_NORM );
			m_flPingTime = g_Engine.time + 1;
		}
		if( self.pev.armorvalue < flMaxArmor )
		{
			++ShieldRegen;
			if( ShieldRegen == 10 )
			{
				ShieldRegen = 0;
				self.pev.armorvalue += 1;
				if( self.pev.armorvalue > flMaxArmor )
				self.pev.armorvalue = flMaxArmor;
			}
		}
	}

	void ActiveThink()
	{
		bool fAttack = false;
		Vector vecDirToEnemy;

		self.pev.nextthink = g_Engine.time + 0.1;
		self.StudioFrameAdvance();

		if( !m_iOn || self.m_hEnemy.GetEntity() is null )
		{
			self.m_hEnemy = null;
			m_flLastSight = g_Engine.time + m_flMaxWait;
			SetThink( ThinkFunction( this.SearchThink ) );
			return;
		}

		if( !self.m_hEnemy.GetEntity().IsAlive() )
		{
			if( m_flLastSight <= 0.0 )
				m_flLastSight = g_Engine.time;
			else
			{
				if( g_Engine.time > m_flLastSight )
				{ 
					self.m_hEnemy = null;
					m_flLastSight = g_Engine.time + m_flMaxWait;
					SetThink( ThinkFunction( this.SearchThink ) );
				return;
				}
			}
		}

		Vector vecMid = self.pev.origin + self.pev.view_ofs;
		Vector vecMidEnemy = self.m_hEnemy.GetEntity().BodyTarget( vecMid );
		// Look for our current enemy
		fEnemyVisible = self.m_hEnemy.GetEntity().FVisible( self, false );
		vecDirToEnemy = vecMidEnemy - vecMid;	// calculate dir and dist to enemy
		float flDistToEnemy = vecDirToEnemy.Length();
		Vector vec = Math.VecToAngles( vecMidEnemy - vecMid );

		// Current enemy is not visible.
		if( !fEnemyVisible || flDistToEnemy > 16384 )
		{
			if( m_flLastSight <= 0.0 )
				m_flLastSight = g_Engine.time;
			else
			{
				// Should we look for a new target?
				if( g_Engine.time > m_flLastSight )
				{
					self.m_hEnemy = null;
					m_flLastSight = g_Engine.time + m_flMaxWait;
					SetThink( ThinkFunction( SearchThink ) );
					return;
				}
			}
			fEnemyVisible = false;
		}
		else
			m_vecLastSight = vecMidEnemy;

		Math.MakeAimVectors( m_vecCurAngles );

		Vector vecLOS = vecDirToEnemy;
		vecLOS = vecLOS.Normalize();

		// Is the Gun looking at the target
		if( DotProduct(vecLOS, g_Engine.v_forward) <= 0.996 ) // 5 degree slop
			fAttack = false;
		else
			fAttack = true;

		if( fAttack )
		{
			Vector vecSrc, vecAng;
			self.GetAttachment( 0, vecSrc, vecAng );
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "custom_weapons/biorifle/biorifle_fire.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0, 0xF ) );
			Shoot( vecSrc + Vector(0,0,-7), g_Engine.v_forward );
		}
		else
		{
			SetTurretAnim( TURRET_ANIM_SPIN );
		}

		if( fEnemyVisible )
		{
			if( vec.y > 360 )
				vec.y -= 360;

			if( vec.y < 0 )
				vec.y += 360;

			if( vec.x < -180 )
				vec.x += 360;

			if( vec.x > 180 )
				vec.x -= 360;

				if( vec.x > 90 )
					vec.x = 90;
				else if( vec.x < m_iMinPitch )
					vec.x = m_iMinPitch;

			m_vecGoalAngles.y = vec.y;
			m_vecGoalAngles.x = vec.x;
		}
		MoveTurret();
	}

	void Deploy()
	{
		self.pev.nextthink = g_Engine.time + 0.1;
		self.StudioFrameAdvance();

		if( self.pev.sequence != TURRET_ANIM_DEPLOY )
		{
			m_iOn = true;
			SetTurretAnim( TURRET_ANIM_DEPLOY );
			//g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, TUR_SOUND_DEPLOY, 1, ATTN_NORM );
			self.SUB_UseTargets( self, USE_ON, 0 );
		}

		if( self.m_fSequenceFinished )
		{
			self.pev.maxs.z = m_iDeployHeight;
			self.pev.mins.z = -m_iDeployHeight;
			g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );

			m_vecCurAngles.x = 0;

			SetTurretAnim( TURRET_ANIM_SPIN );
			self.pev.framerate = 0;
			SetThink( ThinkFunction( SearchThink ) );
		}
		m_flLastSight = g_Engine.time + m_flMaxWait;
	}

	void SetTurretAnim( int anim )
	{
		if( self.pev.sequence != anim )
		{
			switch( anim )
			{
			case TURRET_ANIM_FIRE:
			case TURRET_ANIM_SPIN:
				if( self.pev.sequence != TURRET_ANIM_FIRE && self.pev.sequence != TURRET_ANIM_SPIN )
				{
					self.pev.frame = 0;
				}
				break;
			default:
				self.pev.frame = 0;
				break;
			}

			self.pev.sequence = anim;
			self.ResetSequenceInfo();

			switch( anim )
			{
			case TURRET_ANIM_RETIRE:
				self.pev.frame		= 255;
				self.pev.framerate		= -1.0;
				break;
			case TURRET_ANIM_DIE:
				self.pev.framerate		= 1.0;
				break;
			}
		}
	}

	void SearchThink()
	{
		// ensure rethink
		SetTurretAnim( TURRET_ANIM_SPIN );
		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.1;

		Ping();

		// If we have a target and we're still healthy
		if( self.m_hEnemy.GetEntity() !is null )
		{
			if( !self.m_hEnemy.GetEntity().IsAlive() )
				self.m_hEnemy = null;// Dead enemy forces a search for new one
		}

		// Acquire Target
		if( self.m_hEnemy.GetEntity() is null )
		{
			self.Look( 16384 );
			self.m_hEnemy = BestVisibleEnemy();
		}

		if( self.m_hEnemy.GetEntity() !is null )
		{
			m_flLastSight = 0;
			SetThink( ThinkFunction( this.ActiveThink ) );
		}
		else
		{
			// generic hunt for new victims
			m_vecGoalAngles.y = (m_vecGoalAngles.y + 0.1 * m_fTurnRate);
			if( m_vecGoalAngles.y >= 360 )
				m_vecGoalAngles.y -= 360;
			MoveTurret();
		}
	}

	void AutoSearchThink()
	{
		// ensure rethink
		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.3;

		// If we have a target and we're still healthy
		if( self.m_hEnemy.GetEntity() !is null )
		{
			if( !self.m_hEnemy.GetEntity().IsAlive() )
				self.m_hEnemy = null;// Dead enemy forces a search for new one
		}

		// Acquire Target
		if( self.m_hEnemy.GetEntity() is null )
		{
			self.Look(16384);
			self.m_hEnemy = BestVisibleEnemy();
		}

		if( self.m_hEnemy.GetEntity() !is null )
			SetThink( ThinkFunction( this.Deploy ) );
	}

	int MoveTurret()
	{
		int state = 0;
		if( m_vecCurAngles.x != m_vecGoalAngles.x )
		{
			float flDir = m_vecGoalAngles.x > m_vecCurAngles.x ? 1 : -1 ;

			m_vecCurAngles.x += 0.1 * m_fTurnRate * flDir;

			// if we started below the goal, and now we're past, peg to goal
			if( flDir == 1 )
			{
				if( m_vecCurAngles.x > m_vecGoalAngles.x )
					m_vecCurAngles.x = m_vecGoalAngles.x;
			} 
			else
			{
				if( m_vecCurAngles.x < m_vecGoalAngles.x )
					m_vecCurAngles.x = m_vecGoalAngles.x;
			}

				self.SetBoneController( 1, -m_vecCurAngles.x );
			state = 1;
		}

		if( m_vecCurAngles.y != m_vecGoalAngles.y )
		{
			float flDir = m_vecGoalAngles.y > m_vecCurAngles.y ? 1 : -1 ;
			float flDist = abs( m_vecGoalAngles.y - m_vecCurAngles.y );
			
			if( flDist > 180 )
			{
				flDist = 360 - flDist;
				flDir = -flDir;
			}
			if( flDist > 30 )
			{
				if( m_fTurnRate < m_iBaseTurnRate * 10 )
				{
					m_fTurnRate += m_iBaseTurnRate;
				}
			}
			else if( m_fTurnRate > 45 )
			{
				m_fTurnRate -= m_iBaseTurnRate;
			}
			else
			{
				m_fTurnRate += m_iBaseTurnRate;
			}

			m_vecCurAngles.y += 0.1 * m_fTurnRate * flDir;

			if( m_vecCurAngles.y < 0 )
				m_vecCurAngles.y += 360;
			else if( m_vecCurAngles.y >= 360 )
				m_vecCurAngles.y -= 360;

			if( flDist < (0.05 * m_iBaseTurnRate) )
				m_vecCurAngles.y = m_vecGoalAngles.y;

				self.SetBoneController( 0, m_vecCurAngles.y - pev.angles.y );
			state = 1;
		}

		if( state == 0 )
			m_fTurnRate = m_iBaseTurnRate;

		return state;
	}

	int	Classify ()
	{
		return CLASS_MACHINE;
	}

	CBaseEntity@ BestVisibleEnemy()
	{
		CBaseEntity@ pReturn = null;

		while( ( @pReturn = g_EntityFuncs.FindEntityInSphere( pReturn, self.pev.origin, 16384, "player", "classname" ) ) !is null )
		{
			if( pReturn.IsAlive() )
				return pReturn;
		}
		return pReturn;
	}

	void Shoot( Vector& in vecSrc, Vector& in vecDirToEnemy )
	{
		if( g_Engine.time >= m_flShootTime )
		{
			Math.MakeVectors( m_vecCurAngles );
			ShootBiomass( self.pev, vecSrc, g_Engine.v_forward * 1500, 500 );
			SetTurretAnim(TURRET_ANIM_FIRE_MISSILE);
			m_flShootTime = g_Engine.time + TURRET_FIRERATE;
		}
	}
}

void RegisterBlobTurret()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CBlobTurret", "monster_blobturret" );
}