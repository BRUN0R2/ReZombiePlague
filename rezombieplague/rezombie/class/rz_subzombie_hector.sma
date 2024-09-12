#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new Float:SubclassHectorUpdatetime[MAX_PLAYERS + 1];

new g_SubClass_Hector;

public plugin_precache()
{
	register_plugin("[ReZP] Zombie Sub-class: Hector", REZP_VERSION_STR, "fl0wer");

	new const handle[] = "subclass_zombie_hector";

	new class; RZ_CHECK_CLASS_EXISTS(class, "class_zombie");
	new pSubclass = g_SubClass_Hector = rz_subclass_create(handle, class);
	new nightVision = rz_subclass_get(pSubclass, RZ_SUBCLASS_NIGHTVISION);

	new props = rz_playerprops_create(handle);
	new model = rz_subclass_get(pSubclass, RZ_SUBCLASS_MODEL);
	new sound = rz_subclass_get(pSubclass, RZ_SUBCLASS_SOUND);
	new knife = rz_knife_create("knife_hector");
	
	rz_subclass_set(pSubclass, RZ_SUBCLASS_NAME, "RZ_SUBZOMBIE_HECTOR_NAME");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_DESC, "RZ_SUBZOMBIE_HECTOR_DESC");
	rz_subclass_set(pSubclass, RZ_SUBCLASS_PROPS, props);
	rz_subclass_set(pSubclass, RZ_SUBCLASS_KNIFE, knife);

	rz_subclass_set(pSubclass, RZ_SUBCLASS_FOG_COLOR, { 15, 20, 18 });
	rz_subclass_set(pSubclass, RZ_SUBCLASS_FOG_DISTANCE, 800.0);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_HEALTH, 2500.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_SPEED, 250.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 1.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_FOOTSTEPS, false);

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

public plugin_init() {
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@Player_TakeDamage_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@Player_UpdateClientData_Post", .post = true);
}

public rz_subclass_change_post(id, subclass, pAttacker) {
	if (subclass != g_SubClass_Hector || !is_user_alive(id)) {
		return;
	}
	SubclassHectorUpdatetime[id] = get_gametime();
	rz_longjump_player_give(id, true, 520.0, 320.0, 12.0);
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

	if (SubclassHectorUpdatetime[victim] > 0.0) {
		return;
	}

	SubclassHectorUpdatetime[victim] = get_gametime();
}

@Player_UpdateClientData_Post(const pPlayer) {
	if (!is_user_connected(pPlayer) || !SubclassHectorUpdatetime[pPlayer] || rz_player_get(pPlayer, RZ_PLAYER_SUBCLASS) != g_SubClass_Hector) {
		return;
	}

	static Float:Gametime; Gametime = get_gametime();
	static Float:gethp; get_entvar(pPlayer, var_health, gethp);

	if (SubclassHectorUpdatetime[pPlayer] > Gametime) {
		return;
	}

	if (!is_user_alive(pPlayer) || gethp >= Float:get_entvar(pPlayer, var_max_health)) {
		SubclassHectorUpdatetime[pPlayer] = 0.0;
		set_entvar(pPlayer, var_health, Float:get_entvar(pPlayer, var_max_health));
		return;
	}

	SubclassHectorUpdatetime[pPlayer] = Gametime + 0.1;
	set_entvar(pPlayer, var_health, gethp + 5.0);
}