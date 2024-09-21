#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/util_tempentities>

new const INFECTION_VIEW_MODEL[] = "models/rezombie/weapons/grenades/infect_v.mdl";
new const INFECTION_EXPLODE_SOUND[] = "rezombie/weapons/grenades/infect.wav";

new g_iModelIndex_LaserBeam;
new g_iModelIndex_ShockWave;

new g_iGrenade_Infect;

new g_iClass_Zombie;
new g_iClass_Human;

public plugin_precache()
{
	register_plugin("[ReZP] Grenade: Infection", REZP_VERSION_STR, "fl0wer");

	RZ_CHECK_CLASS_EXISTS(g_iClass_Zombie, "class_zombie");
	RZ_CHECK_CLASS_EXISTS(g_iClass_Human, "class_human");

	precache_sound(INFECTION_EXPLODE_SOUND);

	g_iModelIndex_LaserBeam = precache_model("sprites/laserbeam.spr");
	g_iModelIndex_ShockWave = precache_model("sprites/shockwave.spr");

	new grenade = g_iGrenade_Infect = rz_grenade_create("grenade_infect", "weapon_hegrenade");

	set_grenade_var(grenade, RZ_GRENADE_NAME, "RZ_WPN_INFECT_GRENADE");
	set_grenade_var(grenade, RZ_GRENADE_VIEW_MODEL, INFECTION_VIEW_MODEL);
}

public rz_grenades_throw_post(id, entity, grenade)
{
	if (grenade != g_iGrenade_Infect)
		return;

	rz_util_set_rendering(entity, kRenderNormal, 16.0, Float:{ 0.0, 200.0, 0.0 }, kRenderFxGlowShell);

	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	TE_BeamFollow(entity, g_iModelIndex_LaserBeam, 10, 10, { 0, 200, 0 }, 200);
}

public rz_grenades_explode_pre(pEntity, grenade)
{
	if (grenade != g_iGrenade_Infect)
		return RZ_CONTINUE;

	new pAttacker = get_entvar(pEntity, var_owner);

	new Float:vecOrigin[3];
	new Float:vecOrigin2[3];
	new Float:vecAxis[3];

	get_entvar(pEntity, var_origin, vecOrigin);

	vecAxis = vecOrigin;
	vecAxis[2] += 555.0;

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	TE_BeamCylinder(vecOrigin, vecAxis, g_iModelIndex_ShockWave, 0, 0, 4, 60, 0, { 0, 200, 0 }, 200, 0);

	rh_emit_sound2(pEntity, 0, CHAN_WEAPON, INFECTION_EXPLODE_SOUND, VOL_NORM, ATTN_NORM);

	if (!is_user_connected(pAttacker) && rz_player_get(pAttacker, RZ_PLAYER_CLASS) != g_iClass_Zombie)
		pAttacker = 0;

	for (new pTarget = 1; pTarget <= MaxClients; pTarget++)
	{
		if (!is_user_alive(pTarget))
			continue;

		get_entvar(pTarget, var_origin, vecOrigin2);

		if (vector_distance(vecOrigin, vecOrigin2) > 350.0)
			continue;

		// Does not work with bots
		/*if (!ExecuteHamB(Ham_FVisible, pTarget, entity))
			continue;*/ // In the future I will replace it with another option

		if (rz_player_get(pTarget, RZ_PLAYER_CLASS) != g_iClass_Human)
			continue;

		rz_class_player_change(pTarget, pAttacker, g_iClass_Zombie);
	}

	return RZ_BREAK;
}
