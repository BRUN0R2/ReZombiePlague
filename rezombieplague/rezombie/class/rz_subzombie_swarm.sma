#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iSubClass_Swarm;

public plugin_precache()
{
	register_plugin("[ReZP] Zombie Sub-class: Swarm", REZP_VERSION_STR, "fl0wer");

	new const handle[] = "subclass_zombie_swarm";

	new class; RZ_CHECK_CLASS_EXISTS(class, "class_zombie");
	new pSubclass = g_iSubClass_Swarm = rz_subclass_create(handle, class);
	new nightVision = rz_subclass_get(pSubclass, RZ_SUBCLASS_NIGHTVISION);

	new props = rz_playerprops_create(handle);
	new model = rz_subclass_get(pSubclass, RZ_SUBCLASS_MODEL);
	new sound = rz_subclass_get(pSubclass, RZ_SUBCLASS_SOUND);
	new knife = rz_knife_create("knife_swarm");

	rz_subclass_set(pSubclass, RZ_SUBCLASS_NAME, "RZ_SUBZOMBIE_SWARM_NAME");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_DESC, "RZ_SUBZOMBIE_SWARM_DESC");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_PROPS, props);
	rz_subclass_set(pSubclass, RZ_SUBCLASS_KNIFE, knife);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_HEALTH, 2500.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_SPEED, 250.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 1.0);

	rz_playermodel_add(model, "rz_source", .defaultHitboxes = true);

	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/zombie/pain1.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/zombie/pain2.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/zombie/pain3.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/zombie/pain4.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_BHIT_FLESH, "rezombie/zombie/pain5.wav");

	rz_playersound_add(sound, RZ_PAIN_SOUND_DEATH, "rezombie/zombie/die1.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_DEATH, "rezombie/zombie/die2.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_DEATH, "rezombie/zombie/die3.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_DEATH, "rezombie/zombie/die4.wav");
	rz_playersound_add(sound, RZ_PAIN_SOUND_DEATH, "rezombie/zombie/die5.wav");

	rz_nightvision_set(nightVision, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_COLOR, { 100, 180, 100 });
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_ALPHA, 200);

	rz_knife_set(knife, RZ_KNIFE_VIEW_MODEL, "models/rezombie/weapons/knifes/source_v.mdl");
	rz_knife_set(knife, RZ_KNIFE_PLAYER_MODEL, "hide");
	rz_knife_set(knife, RZ_KNIFE_STAB_BASE_DAMAGE, 250.0);
	rz_knife_set(knife, RZ_KNIFE_SWING_BASE_DAMAGE, 100.0);
	rz_knife_set(knife, RZ_KNIFE_STAB_DISTANCE, 45.0);
	rz_knife_set(knife, RZ_KNIFE_SWING_DISTANCE, 60.0);
	rz_knife_set(knife, RZ_KNIFE_KNOCKBACK_POWER, 60.0);
}

public rz_subclass_change_post(id, subclass, pAttacker) {
	if (subclass != g_iSubClass_Swarm || !is_user_alive(id))
		return;

	rz_longjump_player_give(id, true, 520.0, 320.0, 12.0);
}