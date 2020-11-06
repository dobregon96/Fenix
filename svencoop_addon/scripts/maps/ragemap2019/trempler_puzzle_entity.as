class trempler_puzzle_entity : ScriptBaseEntity
{

	array<int> buttonState = { 0,0,0,0,0,0,0,0,0 };
	int szButtonPressed = 0;
	int szPuzzleID = 0;
	int timesPressed = 0;
	bool puzzleBlocked = false;
	
	array<int> setup1 = 	{ 0,1,0,0,0,0,0,0,0 };
	array<int> setup2 = 	{ 0,0,1,1,1,1,1,1,1 };
	array<int> setup3 = 	{ 0,0,0,1,1,1,1,1,1 };
	array<int> setup4 = 	{ 0,0,1,0,1,1,1,1,1 };
	array<int> setup5 = 	{ 0,0,1,1,0,1,1,1,1 };
	array<int> setup6 = 	{ 0,0,1,1,1,0,1,1,1 };
	array<int> setup7 = 	{ 0,0,0,1,1,1,1,1,0 };
	array<int> setup8 = 	{ 0,0,1,0,1,1,1,0,1 };
	array<int> setup9 = 	{ 0,0,0,1,0,1,1,1,1 };
	array<int> setup10 = 	{ 0,0,0,1,1,0,1,1,1 };
	array<int> setup11 = 	{ 0,0,1,0,1,0,1,0,1	};
	array<int> setup12 = 	{ 0,0,0,1,1,0,1,1,0 };
	array<int> setup13 = 	{ 0,0,0,1,1,0,0,1,1 };
	array<int> setup14 = 	{ 0,0,0,1,1,0,1,0,1 };
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		
		if(szKey == "button_pressed")
		{
			szButtonPressed = atoi( szValue );
			return true;
		}
		else if(szKey == "puzzle_id")
		{
			szPuzzleID = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
		
	}
		
	
	void Spawn ()
	{
		
	}
		
	
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{	
	
		if( puzzleBlocked == false )
		{
			
			if( szButtonPressed >= 1 && szButtonPressed <= 8 )
			{
				// toggle pressed button
				string buttonName = "trempler_status" + szPuzzleID + "_" + szButtonPressed;
				g_EntityFuncs.FireTargets( buttonName, null, null, USE_TOGGLE);
				ToggleButton( szButtonPressed );
			
				// toggle adjecent buttons		
				buttonName = "trempler_status" + szPuzzleID + "_" + getNeighbourPositive(szButtonPressed);
				g_EntityFuncs.FireTargets( buttonName, null, null, USE_TOGGLE);
				ToggleButton( getNeighbourPositive(szButtonPressed) );
				
				buttonName = "trempler_status" + szPuzzleID + "_" + getNeighbourNegative(szButtonPressed);
				g_EntityFuncs.FireTargets( buttonName, null, null, USE_TOGGLE);
				ToggleButton( getNeighbourNegative(szButtonPressed) );
				
				if( buttonState[1] == 1 && buttonState[2] == 1 && buttonState[3] == 1 && buttonState[4] == 1 && buttonState[5] == 1 && buttonState[6] == 1 && buttonState[7] == 1 && buttonState[8] == 1 )
				{
					string solvedName = "trempler_solved" + szPuzzleID;
					g_EntityFuncs.FireTargets( solvedName, null, null, USE_TOGGLE);
					puzzleBlocked = true;
				}
				else
				{
					timesPressed++;
					
					if(timesPressed >= 10)
					{
						timesPressed = 0;
						Failed();
					}
				}
			}
			else
			{
				GeneratePuzzle();
			}			
		}
		
		szButtonPressed = 0;
		
	}	

	
	int getNeighbourPositive ( int pressed = 0 )
	{
		int neighbour = pressed + 1;	
			
		if( neighbour > 8 ){ neighbour = 1; }
		
		return neighbour;
	}
	
	
	int getNeighbourNegative ( int pressed = 0 )
	{
		int neighbour = pressed - 1;	
			
		if( neighbour < 1 ){ neighbour = 8; }
		
		return neighbour;
	}
	
	
	void ToggleButton ( int button = 0 )
	{
		if( buttonState[button] == 0 )
		{ 
			buttonState[button] = 1;
		}
		else
		{
			buttonState[button] = 0;
		}
	}
	
	
	void GeneratePuzzle ()
	{
		array<int> tempSetup = { 0,0,0,0,0,0,0,0,0 };
	
		int randomSetup = Math.RandomLong(1,14);
		
		if( randomSetup == 1){ tempSetup = setup1; }
		if( randomSetup == 2){ tempSetup = setup2; }
		if( randomSetup == 3){ tempSetup = setup3; }
		if( randomSetup == 4){ tempSetup = setup4; }
		if( randomSetup == 5){ tempSetup = setup5; }
		if( randomSetup == 6){ tempSetup = setup6; }
		if( randomSetup == 7){ tempSetup = setup7; }
		if( randomSetup == 8){ tempSetup = setup8; }
		if( randomSetup == 9){ tempSetup = setup9; }
		if( randomSetup == 10){ tempSetup = setup10; }
		if( randomSetup == 11){ tempSetup = setup11; }
		if( randomSetup == 12){ tempSetup = setup12; }
		if( randomSetup == 13){ tempSetup = setup13; }
		if( randomSetup == 14){ tempSetup = setup14; }
	
		int randomRotate = Math.RandomLong(0,7);
		
		for( int i = 1; i <= 8; i++ )	
		{
			int newState = i + randomRotate;
			
			if( newState == 9 ){ newState = 1; }
			else if( newState == 10 ){ newState = 2; }
			else if( newState == 11 ){ newState = 3; }
			else if( newState == 12 ){ newState = 4; }
			else if( newState == 13 ){ newState = 5; }
			else if( newState == 14 ){ newState = 6; }
			else if( newState == 15 ){ newState = 7; }
			else if( newState == 16 ){ newState = 8; }
	
			buttonState[i] = tempSetup[newState];
			
			if( buttonState[i] == 1 )
			{
				string buttonName = "trempler_status" + szPuzzleID + "_" + i;
				g_EntityFuncs.FireTargets( buttonName, null, null, USE_TOGGLE);
			}
			
		}		
	}
	
	
	void Failed ()
	{
		string failedName = "trempler_fail" + szPuzzleID;
		g_EntityFuncs.FireTargets( failedName, null, null, USE_TOGGLE);
	
		for( int i = 1; i <= 8; i++ )	
		{
			if( buttonState[i] == 1 )
			{
				string buttonName = "trempler_status" + szPuzzleID + "_" + i;
				g_EntityFuncs.FireTargets( buttonName, null, null, USE_TOGGLE);			
			}
			
		}
		
		puzzleBlocked = true;
		
		g_Scheduler.SetTimeout( @this, "Unblock", 15.0);
		
	}
	
	
	void Unblock ()
	{
		string unlockName = "trempler_unlocked" + szPuzzleID;
		g_EntityFuncs.FireTargets( unlockName, null, null, USE_TOGGLE);
		
		puzzleBlocked = false;
		GeneratePuzzle();
	}
	
	
}









