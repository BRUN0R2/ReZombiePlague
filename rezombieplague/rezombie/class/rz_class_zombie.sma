#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new const ARMOR_HIT_SOUND[] = "player/bhit_helmet-1.wav";

new g_iClass_Zombie;
new g_iSubClass_Swarm;

public plugin_precache()
{
	register_plugin("[ReZP] Class: Zombie", REZP_VERSION_STR, "fl0wer");

	precache_sound(ARMOR_HIT_SOUND);

	g_iSubClass_Swarm = rz_subclass_find("subclass_zombie_swarm");

	new class = g_iClass_Zombie = rz_class_create("class_zombie", TEAM_TERRORIST);
	new props = rz_class_get(class, RZ_CLASS_PROPS);
	new model = rz_class_get(class, RZ_CLASS_MODEL);
	new sound = rz_class_get(class, RZ_CLASS_SOUND);
	new nightVision = rz_class_get(class, RZ_CLASS_NIGHTVISION);
	new knife = rz_knife_create("knife_zombie");

	rz_class_set(class, RZ_CLASS_NAME, "RZ_ZOMBIE");
	rz_class_set(class, RZ_CLASS_HUD_COLOR, { 250, 250, 10 });
	rz_class_set(class, RZ_CLASS_KNIFE, knife);

	rz_class_set(class, RZ_CLASS_FOG_COLOR, { 10, 20, 10 });
	rz_class_set(class, RZ_CLASS_FOG_DISTANCE, 800.0);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 0.8);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_SPEED, 270.0);
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

	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_HIT, "weapons/knife_hit1.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_HIT, "weapons/knife_hit2.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_HIT, "weapons/knife_hit3.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_HIT, "weapons/knife_hit4.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_SLASH, "weapons/knife_slash1.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_SLASH, "weapons/knife_slash2.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_STAB, "weapons/knife_stab.wav");
	rz_knife_sound_add(knife, RZ_KNIFE_SOUND_HITWALL, "weapons/knife_hitwall1.wav");

	rz_nightvision_set(nightVision, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_COLOR, { 0, 200, 40 });
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_ALPHA, 200);

	set_knife_var(knife, RZ_KNIFE_VIEW_MODEL, "models/rezombie/weapons/knifes/source_v.mdl");
	set_knife_var(knife, RZ_KNIFE_PLAYER_MODEL, "hide");
}

public plugin_init() {
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Pre", .post = false);
}

public rz_class_change_post(id, attacker, class, bool:preSpawn) {
	if (class != g_iClass_Zombie || !is_user_alive(id))
		return;

	rz_nightvision_player_change(id, rz_player_get(id, RZ_PLAYER_NIGHTVISION), true);
}

@CBasePlayer_TakeDamage_Pre(pVictim, inflictor, pAttacker, Float:damage, bitsDamageType)
{	
	if (pVictim == pAttacker || !is_user_connected(pAttacker)) {
		return HC_CONTINUE;
	}

	if (!rg_is_player_can_takedamage(pVictim, pAttacker)) {
		return HC_CONTINUE;
	}

	if (rz_player_get(pAttacker, RZ_PLAYER_CLASS) != g_iClass_Zombie) {
		return HC_CONTINUE;
	}

	new gameMode = rz_gamemodes_get(RZ_GAMEMODES_CURRENT);

	if (!gameMode) {
		return HC_CONTINUE;
	}

	if (!rz_gamemode_get(gameMode, RZ_GAMEMODE_CHANGE_CLASS)) {
		return HC_CONTINUE;
	}

	new activeItem = get_member(pAttacker, m_pActiveItem);

	if (is_nullent(activeItem) || get_member(activeItem, m_iId) != WEAPON_KNIFE) {
		return HC_CONTINUE;
	}
	
	new Float:armorValue = get_entvar(pVictim, var_armorvalue);

	if (armorValue > 0.0)
	{
		armorValue = floatmax(armorValue - damage, 0.0);

		set_entvar(pVictim, var_armorvalue, armorValue);
		SetHookChainArg(4, ATYPE_FLOAT, 0.0);

		rh_emit_sound2(pVictim, 0, CHAN_BODY, ARMOR_HIT_SOUND);
	}

	if (armorValue > 0.0 || (get_member(pVictim, m_iKevlar) == ARMOR_VESTHELM && get_member(pVictim, m_LastHitGroup) == HITGROUP_HEAD)) {
		return HC_CONTINUE;
	}

	//new numAliveCT; rg_initialize_player_counts(_, numAliveCT);

	if (rz_player_get(pAttacker, RZ_PLAYER_SUBCLASS) == g_iSubClass_Swarm) {
		return HC_CONTINUE;
	}

	/*if (numAliveCT == 1 || rz_player_get(pAttacker, RZ_PLAYER_SUBCLASS) == g_iSubClass_Swarm) {
		return HC_CONTINUE;
	}*/

	if (!rz_class_player_change(pVictim, pAttacker, g_iClass_Zombie)) {
		return HC_CONTINUE;
	}

	SetHookChainArg(4, ATYPE_FLOAT, 0.0);

	return HC_CONTINUE;
}