#include "point_checkpoint"

#include "beast/trigger_command"
#include "beast/replace_weapon_sprites"

void MapInit()
{
	REPLACE_WEAPON_SPRITES::SetReplacements( "scmod/platoon", "wrenchaxe", "weapon_pipewrench" );
}
