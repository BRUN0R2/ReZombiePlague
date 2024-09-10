#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new Float:Updatetime[MAX_PLAYERS + 1];

new g_SubClass_Hector;

public plugin_precache()
{
	register_plugin("[ReZP] Zombie Sub-class: Hector", REZP_VERSION_STR, "fl0wer");

	new const handle[] = "subclass_zombie_hector";

	new class; RZ_CHECK_CLASS_EXISTS(class, "class_zombie");
	new SubClass = g_SubClass_Hector = rz_subclass_create(handle, class);
	new nvg = rz_subclass_get(SubClass, RZ_SUBCLASS_NIGHTVISION);

	new props = rz_playerprops_create(handle);
	new model = rz_subclass_get(SubClass, RZ_SUBCLASS_MODEL);
	new sound = rz_subclass_get(SubClass, RZ_SUBCLASS_SOUND);
	new knife = rz_knife_create("knife_hector");
	
	rz_subclass_set(SubClass, RZ_SUBCLASS_NAME, "RZ_SUBZOMBIE_HECTOR_NAME");
	rz_subclass_set(SubClass, RZ_SUBCLASS_DESC, "RZ_SUBZOMBIE_HECTOR_DESC");
	rz_subclass_set(SubClass, RZ_SUBCLASS_PROPS, props);
	rz_subclass_set(SubClass, RZ_SUBCLASS_KNIFE, knife);

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

	rz_nightvision_set(nvg, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nvg, RZ_NIGHTVISION_COLOR, { 0, 100, 200 });
	rz_nightvision_set(nvg, RZ_NIGHTVISION_ALPHA, 63);

	rz_knife_set(knife, RZ_KNIFE_VIEW_MODEL, "models/rezombie/weapons/knifes/source_v.mdl");
	rz_knife_set(knife, RZ_KNIFE_PLAYER_MODEL, "hide");
	rz_knife_set(knife, RZ_KNIFE_STAB_BASE_DAMAGE, 250.0);
	rz_knife_set(knife, RZ_KNIFE_SWING_BASE_DAMAGE, 100.0);
	rz_knife_set(knife, RZ_KNIFE_STAB_DISTANCE, 75.0);
	rz_knife_set(knife, RZ_KNIFE_SWING_DISTANCE, 100.0);
	rz_knife_set(knife, RZ_KNIFE_KNOCKBACK_POWER, 60.0);
}

public plugin_init() {
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@Player_TakeDamage_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@Player_UpdateClientData_Post", .post = true);
}

public rz_subclass_change_post(ePlayer, subclass) {
	if (subclass != g_SubClass_Hector) {
		return;
	}

	Updatetime[ePlayer] = get_gametime();
}

@Player_TakeDamage_Post(victim, inflictor, attacker, Float:damage, bitsDamageType) {
	if (!is_user_connected(attacker) || !is_user_alive(victim)) {
		return;
	}
	
	if (rz_player_get(victim, RZ_PLAYER_SUBCLASS) != g_SubClass_Hector) {
		return;
	}

	if (!rg_is_player_can_takedamage(victim, attacker)) {
		return;
	}

	if (Updatetime[victim] > 0.0) {
		return;
	}

	Updatetime[victim] = get_gametime();
}

@Player_UpdateClientData_Post(const pPlayer) {
	if (!is_user_alive(pPlayer) || !Updatetime[pPlayer] || rz_player_get(pPlayer, RZ_PLAYER_SUBCLASS) != g_SubClass_Hector) {
		return;
	}

	static Float:Gametime; Gametime = get_gametime();
	static Float:gethp; get_entvar(pPlayer, var_health, gethp);

	if (Updatetime[pPlayer] > Gametime) {
		return;
	}

	if (!is_user_alive(pPlayer) || gethp >= Float:get_entvar(pPlayer, var_max_health)) {
		Updatetime[pPlayer] = 0.0;
		set_entvar(pPlayer, var_health, Float:get_entvar(pPlayer, var_max_health));
		return;
	}

	Updatetime[pPlayer] = Gametime + 0.1;
	set_entvar(pPlayer, var_health, gethp + 5.0);
}