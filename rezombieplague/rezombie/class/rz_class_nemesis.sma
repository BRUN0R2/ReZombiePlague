#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iClass_Nemesis;

public plugin_precache()
{
	register_plugin("[ReZP] Class: Nemesis", REZP_VERSION_STR, "fl0wer");

	new class = g_iClass_Nemesis = rz_class_create("class_nemesis", TEAM_TERRORIST);
	new props = rz_class_get(class, RZ_CLASS_PROPS);
	new model = rz_class_get(class, RZ_CLASS_MODEL);
	new sound = rz_class_get(class, RZ_CLASS_SOUND);
	new nightVision = rz_class_get(class, RZ_CLASS_NIGHTVISION);
	new knife = rz_knife_create("knife_nemesis");

	rz_class_set(class, RZ_CLASS_NAME, "RZ_NEMESIS");
	rz_class_set(class, RZ_CLASS_HUD_COLOR, { 250, 250, 10 });
	rz_class_set(class, RZ_CLASS_KNIFE, knife);

	rz_class_set(class, RZ_CLASS_FOG_COLOR, { 20, 10, 10 });
	rz_class_set(class, RZ_CLASS_FOG_DISTANCE, 800.0);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_BASE_HEALTH, 2000.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 0.5);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_SPEED, 265.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_FOOTSTEPS, false);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_NO_IMPACT, true);

	rz_playermodel_add(model, "rz_source", .defaultHitboxes = true);

	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/nemesis/pain1.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/nemesis/pain2.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/nemesis/pain3.wav");
	
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_COLOR, { 220, 0, 0 });
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_ALPHA, 180);

	set_knife_var(knife, RZ_KNIFE_VIEW_MODEL, "models/rezombie/weapons/knifes/source_v.mdl");
	set_knife_var(knife, RZ_KNIFE_PLAYER_MODEL, "hide");
}

public plugin_init()
{
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Pre", false);
}

public rz_class_change_post(id, attacker, class, bool:preSpawn) {
	if (class != g_iClass_Nemesis || !is_user_alive(id))
		return;
	rz_longjump_player_give(id, true, 600.0, 390.0, 0.8);
	rz_nightvision_player_change(id, rz_player_get(id, RZ_PLAYER_NIGHTVISION), true);
}

public rz_fire_grenade_burn_pre(id)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Nemesis)
		return RZ_CONTINUE;

	return RZ_SUPERCEDE;
}

public rz_frost_grenade_freeze_pre(id)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Nemesis)
		return RZ_CONTINUE;

	return RZ_SUPERCEDE;
}

@CBasePlayer_Killed_Pre(id, attacker, gib)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) == g_iClass_Nemesis)
	{
		SetHookChainArg(3, ATYPE_INTEGER, GIB_ALWAYS);
		return;
	}

	if (id == attacker || !is_user_connected(attacker))
		return;

	if (rz_player_get(attacker, RZ_PLAYER_CLASS) != g_iClass_Nemesis)
		return;

	SetHookChainArg(3, ATYPE_INTEGER, GIB_ALWAYS);
}