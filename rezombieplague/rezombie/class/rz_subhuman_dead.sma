#pragma semicolon 1

#include <amxmodx>
#include <rezp_inc/rezp_main>

public plugin_precache()
{
	register_plugin("[ReZP] Human Sub-class: Dead Inside", REZP_VERSION_STR, "fl0wer");

	new class;
	RZ_CHECK_CLASS_EXISTS(class, "class_human");

	new const handle[] = "subclass_human_deadinside";

	new pSubclass = rz_subclass_create(handle, class);
	new props = rz_playerprops_create(handle);
	
	rz_subclass_set(pSubclass, RZ_SUBCLASS_NAME, "RZ_SUBHUMAN_DEAD_NAME");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_DESC, "RZ_SUBHUMAN_DEAD_DESC");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_PROPS, props);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_HEALTH, 600.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_ARMOR, 350.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_INTERACT, true);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_CANDROP, true);
}
