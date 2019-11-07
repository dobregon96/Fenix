// Am I living in a box
// Am I living in a cardboard box
// Am I living in a box

bool is_moving;
EHandle boxent;
EHandle pUser = null;
Vector start_position;
int moving_direction;

class CMahBox : ScriptBaseEntity
{
	string szTargetToSearch = "";
	string szResetEntity = "";
	string szSolveTarget = "";
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "target_to_search" )
		{
			szTargetToSearch = szValue;
			return true;
		}
		else if ( szKey == "reset_entity" )
		{
			szResetEntity = szValue;
			return true;
		}
		else if ( szKey == "fire_on_solved" )
		{
			szSolveTarget = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype = MOVETYPE_FLY;
		self.pev.solid = SOLID_BBOX;
		
		g_EntityFuncs.SetModel( self, pev.model );
		g_EntityFuncs.SetSize( self.pev, Vector( -32.0, -32.0, -16.0 ), Vector( 32.0, 32.0, 16.0 ) );
		
		is_moving = false;
		
		boxent = self;
		start_position = self.pev.origin;
	}
	
	void Precache()
	{
		g_Game.PrecacheGeneric( "sound/ragemap2019/giegue/snd_box_start.ogg" );
		g_Game.PrecacheGeneric( "sound/ragemap2019/giegue/snd_box_stop.ogg" );
		
		g_SoundSystem.PrecacheSound( "ragemap2019/giegue/snd_box_start.ogg" );
		g_SoundSystem.PrecacheSound( "ragemap2019/giegue/snd_box_stop.ogg" );
	}
	
	void Touch( CBaseEntity@ pOther )
	{
		if ( is_moving )
		{
			string cname = pOther.pev.classname;
			if ( cname == "player" )
			{
				CBaseEntity @pUserEntity = pUser;
				if ( pOther !is pUserEntity )
					pOther.TakeDamage( pOther.pev, pOther.pev, 10000.0, ( DMG_CRUSH | DMG_ALWAYSGIB ) );
				
				if ( moving_direction == 1 )
					g_Scheduler.SetTimeout( "Box_MoveUp_Run", 0.01, boxent );
				else if ( moving_direction == 2 )
					g_Scheduler.SetTimeout( "Box_MoveRight_Run", 0.01, boxent );
				else if ( moving_direction == 3 )
					g_Scheduler.SetTimeout( "Box_MoveLeft_Run", 0.01, boxent );
				else if ( moving_direction == 4 )
					g_Scheduler.SetTimeout( "Box_MoveDown_Run", 0.01, boxent );
			}
			else
			{
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_AUTO, "ragemap2019/giegue/snd_box_stop.ogg", VOL_NORM, ATTN_NORM, 0, 150 );
				is_moving = false;
				pUser = null;
				
				Vector pOrigin = self.pev.origin;
				CBaseEntity@ ent = null;
				
				while( ( @ent = g_EntityFuncs.FindEntityInSphere( ent, pOrigin, 48.0, "*", "classname" ) ) !is null )
				{
					cname = ent.pev.targetname;
					if ( cname == szTargetToSearch )
						g_EntityFuncs.FireTargets( szSolveTarget, null, null, USE_TOGGLE, 0.0f, 0.5f );
					else if ( cname == szResetEntity )
						g_EntityFuncs.SetOrigin( self, start_position );
				}
			}
		}
	}
}

void Box_MoveUp_Init( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if ( is_moving )
		return;
	
	CBaseEntity@ ent = boxent;
	if ( ent !is null )
	{
		g_SoundSystem.EmitSoundDyn( ent.edict(), CHAN_AUTO, "ragemap2019/giegue/snd_box_start.ogg", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		is_moving = true;
		pUser = pActivator;
		moving_direction = 1;
		
		g_Scheduler.SetTimeout( "Box_MoveUp_Run", 0.01, boxent );
	}
}

void Box_MoveUp_Run( EHandle& in boxent )
{
	if ( is_moving )
	{
		CBaseEntity@ ent = boxent;
		if ( ent !is null )
		{
			g_EngineFuncs.MakeVectors( Vector( 0.0, 90.0, 0.0 ) );
			Vector pForward = g_Engine.v_forward;
			
			Vector vVelocity = g_vecZero;
			vVelocity = pForward * 250.0;
			ent.pev.velocity = vVelocity;
		}
	}
}

void Box_MoveRight_Init( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if ( is_moving )
		return;
	
	CBaseEntity@ ent = boxent;
	if ( ent !is null )
	{
		g_SoundSystem.EmitSoundDyn( ent.edict(), CHAN_AUTO, "ragemap2019/giegue/snd_box_start.ogg", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		is_moving = true;
		pUser = pActivator;
		moving_direction = 2;
		
		g_Scheduler.SetTimeout( "Box_MoveRight_Run", 0.01, boxent );
	}
}

void Box_MoveRight_Run( EHandle& in boxent )
{
	if ( is_moving )
	{
		CBaseEntity@ ent = boxent;
		if ( ent !is null )
		{
			g_EngineFuncs.MakeVectors( Vector( 0.0, 90.0, 0.0 ) );
			Vector pRight = g_Engine.v_right;
			
			Vector vVelocity = g_vecZero;
			vVelocity = pRight * 250.0;
			ent.pev.velocity = vVelocity;
		}
	}
}

void Box_MoveLeft_Init( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if ( is_moving )
		return;
	
	CBaseEntity@ ent = boxent;
	if ( ent !is null )
	{
		g_SoundSystem.EmitSoundDyn( ent.edict(), CHAN_AUTO, "ragemap2019/giegue/snd_box_start.ogg", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		is_moving = true;
		pUser = pActivator;
		moving_direction = 3;
		
		g_Scheduler.SetTimeout( "Box_MoveLeft_Run", 0.01, boxent );
	}
}

void Box_MoveLeft_Run( EHandle& in boxent )
{
	if ( is_moving )
	{
		CBaseEntity@ ent = boxent;
		if ( ent !is null )
		{
			g_EngineFuncs.MakeVectors( Vector( 0.0, 90.0, 0.0 ) );
			Vector pLeft = -( g_Engine.v_right );
			
			Vector vVelocity = g_vecZero;
			vVelocity = pLeft * 250.0;
			ent.pev.velocity = vVelocity;
		}
	}
}

void Box_MoveDown_Init( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if ( is_moving )
		return;
	
	CBaseEntity@ ent = boxent;
	if ( ent !is null )
	{
		g_SoundSystem.EmitSoundDyn( ent.edict(), CHAN_AUTO, "ragemap2019/giegue/snd_box_start.ogg", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		is_moving = true;
		pUser = pActivator;
		moving_direction = 4;
		
		g_Scheduler.SetTimeout( "Box_MoveDown_Run", 0.01, boxent );
	}
}

void Box_MoveDown_Run( EHandle& in boxent )
{
	if ( is_moving )
	{
		CBaseEntity@ ent = boxent;
		if ( ent !is null )
		{
			g_EngineFuncs.MakeVectors( Vector( 0.0, 90.0, 0.0 ) );
			Vector pDown = -( g_Engine.v_forward );
			
			Vector vVelocity = g_vecZero;
			vVelocity = pDown * 250.0;
			ent.pev.velocity = vVelocity;
		}
	}
}

void Box_Reset( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	CBaseEntity@ ent = boxent;
	if ( ent !is null )
	{
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "* The box was moved to it's starting position.\n" );
		
		ent.pev.velocity = g_vecZero;
		g_EntityFuncs.SetOrigin( ent, start_position );
		is_moving = false;
		pUser = null;
	}
}

void RegisterBOXEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CMahBox", "giegue_box" );
}
