namespace HLWanted_Telegram
{

class item_telegram : ScriptBasePlayerItemEntity
{
    private HUDSpriteParams hspNote;
    private string strNoteImage;
    private float flReadTime = 20.0f;

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
        if( szKey == "useimage" ) 
        {
            strNoteImage = szValue;
            return true;
        }
        else if( szKey == "readdelay" ) 
        {
            flReadTime = atof( szValue );
            return true;
        }
        else
		    return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		BaseClass.Precache();

        g_Game.PrecacheModel( self.pev.model );
		g_Game.PrecacheModel( strNoteImage );
		g_Game.PrecacheGeneric( "sprites/" + strNoteImage );
		// Doing it this way causes crashing for some reason
		//g_Game.PrecacheModel( "sprites/" + strNoteImage );
		//string strPrecache = "sprites/" + string( strNoteImage );
		//g_Game.PrecacheModel( string( strPrecache ) );

/* 		int iMdlIndex = g_ModelFuncs.ModelIndex( self.pev.model );
		int iSprIndex = g_ModelFuncs.ModelIndex( strNoteImage );

		g_EngineFuncs.ServerPrint( "Mdl Index: " + iMdlIndex + " | Spr Index: " + iSprIndex + "\n" ); */

		g_SoundSystem.PrecacheSound( "extended/papers.wav" );
	}

	void Spawn()
	{
		Precache();

		g_EntityFuncs.SetModel( self, self.pev.model );

		hspNote.spritename	= "" + strNoteImage;
		hspNote.x			= 0.0f;
		hspNote.y			= 0.40f;
		hspNote.frame		= 0;
		hspNote.numframes	= 1;
		hspNote.framerate	= 1;
		hspNote.fadeinTime	= 0.0f;
		hspNote.fadeoutTime	= 0;
		hspNote.holdTime	= flReadTime;
		hspNote.color1		= RGBA_WHITE;
		hspNote.channel		= 4;
		hspNote.flags		= HUD_ELEM_SCR_CENTER_X | HUD_SPR_MASKED;

		BaseClass.Spawn();
	}

	void Touch(CBaseEntity@ pOther)
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

        if( pPlayer is null )
            return;
        
        g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "extended/papers.wav", 1.0f, 1.0f );
        g_PlayerFuncs.HudCustomSprite( pPlayer, hspNote );
		//g_PlayerFuncs.ScreenFade( pPlayer, Vector( 0, 0, 0 ), 0.0f, flReadTime, 165, FFADE_OUT );// !-BUG-!: Doesn't obey the flReadTime duration
		g_EntityFuncs.FireTargets( "" + self.pev.target, pOther, self, USE_TOGGLE, 0.0f, self.m_flDelay );
        g_EntityFuncs.Remove( self );
	}

	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
	{
		if( self.pev.SpawnFlagBitSet( 256 ) )
			return;
	
		Touch( pActivator );
	}
}

string GetTelegramName()
{
	return "item_telegram";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Telegram::item_telegram", GetTelegramName() );
	g_ItemRegistry.RegisterItem( GetTelegramName(), "" );
}

} //namespace HLWanted_Telegram END