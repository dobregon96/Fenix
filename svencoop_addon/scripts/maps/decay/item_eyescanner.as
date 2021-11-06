// PS2HL Eye Scanner Station
// Ported from https://github.com/supadupaplex/ya-ps2hl-dll
// and then properly finished by JTE.


// Flags
enum ScanFlag
{
	SCN_FLAG_LOCKED = 1
}

// Sequences
enum ScanSeq
{
	SCN_SEQ_CLOSED = 0, // idle closed
	SCN_SEQ_OPEN,       // idle open
	SCN_SEQ_ACTIVATE,   // opening
	SCN_SEQ_DEACTIVATE  // closing
};

// States for scanner
enum ScanState {
	SCN_STATE_IDLE,   // Hibernating
	SCN_STATE_OPEN,   // Opening / Active
	SCN_STATE_CLOSE   // Closing
};

// Timings
const float SCN_DELAY_THINK = 0.15f;	// Delay before Think() calls. Affects skin cycle & beep speed.
const float SCN_DELAY_ACTIVATE = 0.5f; // Defines time before cycling skins
const float SCN_USE_RADIUS = 25.0f;	// Defines distance at which player can use scanner

// Register
void RegisterItemEyeScannerEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity("CRetinalScanner", "item_eyescanner");
}

class CRetinalScanner : ScriptBaseAnimating
{
	private string MODEL_DEFAULT = "models/decay/eye_scanner.mdl";
	private string SOUND_WORKING = "buttons/blip1.wav";
	private string SOUND_SUCCESS = "buttons/blip2.wav";
	private string SOUND_DENIED = "buttons/button11.wav";

	// public
	float reset_delay;      // How many seconds to be inactive
	string locked_target;   // What to activate on deny
	string unlocked_target; // What to activate on accept
	string unlockersname;   // Which targetname will be accepted
	string master;			// Which multisource is locking

	// For Use()
	private float last_use_time; // Time when last used (used to track reset delay for player)

	// For Think()
	private ScanState state; // Current state of the scanner
	private bool access_state;      // Access granted if true, denied if false.

	// Precache handler
	void Precache()
	{
		BaseClass.Precache();
		if(string(self.pev.model).IsEmpty())
			g_Game.PrecacheModel(MODEL_DEFAULT);
		g_SoundSystem.PrecacheSound(SOUND_WORKING);
		g_SoundSystem.PrecacheSound(SOUND_SUCCESS);
		g_SoundSystem.PrecacheSound(SOUND_DENIED);
	}

	int ObjectCaps()
	{
		return (BaseClass.ObjectCaps() | FCAP_IMPULSE_USE) & ~FCAP_ACROSS_TRANSITION;
	}

	// Spawn handler
	void Spawn()
	{
		// Precache
		Precache();

		// Set model
		if (!self.SetupModel())
			g_EntityFuncs.SetModel(self, MODEL_DEFAULT);

		// Set up BBox and origin
		pev.solid = SOLID_NOT;
		self.SetSequenceBox();
		g_EntityFuncs.SetOrigin(self, pev.origin);

		// Set move type
		pev.movetype = MOVETYPE_FLY;		// This type enables bone controller interpolation in GoldSrc

		// Check flags
		//if ((pev.spawnflags & SCN_FLAG_LOCKED) != 0) g_Game.AlertMessage(at_console, "item_eyescanner: got flag 1 >> locked ...\n"); // DEBUG

		// Reset state
		ChangeState(SCN_STATE_IDLE, SCN_SEQ_CLOSED);
		last_use_time = g_Engine.time - reset_delay;

		// Set think
		pev.nextthink = -1;
	}

	// Parse keys
	bool KeyValue(const string& in szKey, const string& in szValue)
	{
		if ( szKey == "style" ||
			szKey == "height" ||
			szKey == "value1" ||
			szKey == "value2" ||
			szKey == "value3" )
		{
			return true;
		}
		else if (szKey == "reset_delay")
		{
			reset_delay = atof(szValue);
			return true;
		}
		else if (szKey == "locked_target")
		{
			// Target to fire when deny
			locked_target = szValue;
			return true;
		}
		else if (szKey == "unlocked_target")
		{
			// Target to fire when accept
			unlocked_target = szValue;
			return true;
		}
		else if (szKey == "unlockersname")
		{
			// targetname to accept
			unlockersname = szValue;
			return true;
		}
		else if (szKey == "master")
		{
			// multisource to lock
			master = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void ProcessAccess(void)
	{
		// Access granted / denied
		if (access_state)
		{
			pev.target = unlocked_target;
			if (unlocked_target == "" || g_EntityFuncs.FindEntityByTargetname(null, pev.target) is null)
				g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_ITEM, SOUND_DENIED, VOL_NORM, ATTN_NORM);
			else
				g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_ITEM, SOUND_SUCCESS, VOL_NORM, ATTN_NORM);
		}
		else
		{
			pev.target = locked_target;
			g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_ITEM, SOUND_DENIED, VOL_NORM, ATTN_NORM);
		}

		// Fire target
		self.SUB_UseTargets(self, USE_ON, 1);
		//if (pev.target != "") g_Game.AlertMessage(at_console, "item_eyescanner: fired target \"%1\"\n", pev.target); // DEBUG
	}

	// Think handler
	void Think(void)
	{
		// Set think delay
		pev.nextthink = g_Engine.time + SCN_DELAY_THINK;

		// Call animation handler
		self.StudioFrameAdvance(0);

		// State handler
		switch (state)
		{
		case SCN_STATE_OPEN:
			// Wait for opening animation
			if (self.m_fSequenceFinished)
			{
				ProcessAccess();

				// Start closing again.
				pev.skin = 0;
				ChangeState(SCN_STATE_CLOSE, SCN_SEQ_DEACTIVATE);
			}
			else
			{
				// While open, cycle skins, emit beeps
				pev.skin++;
				if (pev.skin > 3)
					pev.skin = 1;
				g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_ITEM, SOUND_WORKING, VOL_NORM, ATTN_NORM, 0, 200);
			}
			break;
		case SCN_STATE_CLOSE:
			if (self.m_fSequenceFinished)
			{
				// Go to idle state once closing animation is ended
				ChangeState(SCN_STATE_IDLE, SCN_SEQ_CLOSED);

				// Hibernate
				pev.nextthink = -1;
			}
			break;
		default:
			// Do nothing
			break;
		}
	}

	// Change sequence
	void ChangeSequence(int next_sequence)
	{
		// Prepare sequence
		pev.sequence = next_sequence;
		pev.frame = 0;
		self.ResetSequenceInfo();
	}

	// Change state for Think()
	void ChangeState(ScanState next_state, int next_sequence)
	{
		state = next_state;
		ChangeSequence(next_sequence);
	}

	// Use handler
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
	{
		// Get current time
		float current_time = g_Engine.time;
		// Outerbeast: - Check if multisource unlocked this
		if( master != "" && !g_EntityFuncs.IsMasterTriggered( master, null ) )
		{
			g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_ITEM, SOUND_DENIED, VOL_NORM, ATTN_NORM);
			return;
		}// - Outerbeast end
		// Check activator
		if (pActivator !is null && pActivator.IsPlayer())
		{
			// Player //

			// Check distance
			Vector dist = pev.origin - pActivator.pev.origin;
			if(dist.Length2D() > SCN_USE_RADIUS)
			{
				//g_Game.AlertMessage(at_console, "item_eyescanner: player is too far ...\n"); // DEBUG
				return;
			}

			// Check if busy
			if (state != SCN_STATE_IDLE)
			{
				// Busy - reject until the state is idle
				//g_Game.AlertMessage(at_console, "item_eyescanner: busy ...\n"); // DEBUG
				return;
			}

			// Check reset delay
			if ((current_time - last_use_time) < reset_delay)
			{
				// Hibernated - reject until after reset delay
				//g_Game.AlertMessage(at_console, "item_eyescanner: hibernated ...\n"); // DEBUG
				return;
			}

			// Select target
			//g_Game.AlertMessage(at_console, "item_eyescanner: started by player ...\n"); // DEBUG
			access_state = (pev.spawnflags & SCN_FLAG_LOCKED) == 0;

			// Start scanner
			ChangeState(SCN_STATE_OPEN, SCN_SEQ_ACTIVATE);
			pev.nextthink = current_time + SCN_DELAY_ACTIVATE;
		}
		else
		{
			// Script //

			//g_Game.AlertMessage(at_console, "item_eyescanner: started by script ...\n"); // DEBUG
			access_state = (pev.spawnflags & SCN_FLAG_LOCKED) == 0 || pCaller.GetTargetname() == unlockersname;

			// Start scanner
			ChangeState(SCN_STATE_OPEN, SCN_SEQ_ACTIVATE);
			pev.nextthink = current_time + SCN_DELAY_ACTIVATE;
		}

		// Update last use time
		last_use_time = current_time;
	}
}
