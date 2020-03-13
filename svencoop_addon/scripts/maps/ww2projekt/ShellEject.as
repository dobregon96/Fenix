/**
* NO MATTER WHAT YOU DO
* DO NOT DELETE THIS FILE
* IT IS USED BY ALL WEAPONS
* Author: KernCore & Solokiller
* Contact: Sven Co-op Forums
**/

void GetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity, Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale, bool leftShell, bool downShell )
{
	Vector vecForward, vecRight, vecUp;

	g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );

	const float fR = (leftShell == true) ? Math.RandomFloat( -100, -60 ) : Math.RandomFloat( 60, 100 );
	const float fU = (downShell == true) ? Math.RandomFloat( -150, -100 ) : Math.RandomFloat( 100, 150 );
	
	for( int i = 0; i < 3; ++i )
	{
		ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
		ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
	}
}

void WW2DynamicTracer( Vector start, Vector end, NetworkMessageDest msgType = MSG_PVS, edict_t@ dest = null )
{
	NetworkMessage WW2DT( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
		WW2DT.WriteByte( TE_TRACER );
		WW2DT.WriteCoord( start.x );
		WW2DT.WriteCoord( start.y );
		WW2DT.WriteCoord( start.z );
		WW2DT.WriteCoord( end.x );
		WW2DT.WriteCoord( end.y );
		WW2DT.WriteCoord( end.z );
	WW2DT.End();
}

void WW2DynamicLight( Vector vecPos, int radius, int r, int g, int b, int8 life, int decay )
{
	NetworkMessage WW2DL( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
		WW2DL.WriteByte( TE_DLIGHT );
		WW2DL.WriteCoord( vecPos.x );
		WW2DL.WriteCoord( vecPos.y );
		WW2DL.WriteCoord( vecPos.z );
		WW2DL.WriteByte( radius );
		WW2DL.WriteByte( int(r) );
		WW2DL.WriteByte( int(g) );
		WW2DL.WriteByte( int(b) );
		WW2DL.WriteByte( life );
		WW2DL.WriteByte( decay );
	WW2DL.End();
}

enum WW2InShoulder_e
{
	NotInShoulder = 0,
	InShoulder
};

enum WW2Bipod_e
{
	BIPOD_UNDEPLOY = 0,
	BIPOD_DEPLOY
};

enum WW2ScopedSniper_e
{
	MODE_NOSCOPE = 0,
	MODE_SCOPED
};

enum WW2ScopedRifle_e
{
	MODE_UNSCOPE = 0,
	MODE_SCOPE
};

/*
* Modify those strings below to
* Translate the messages to your language
*/

const string MGToDeploy = "Crouch before deploying \n";
const string MGWaterDeploy = "Cannot deploy while in the water \n";
const string MGReloadDeploy = "You need to deploy before reloading \n";
const string ROCKETDeploy = "Deploy before Firing \n";