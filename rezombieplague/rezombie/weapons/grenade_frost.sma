#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/util_messages>
#include <rezp_inc/util_tempentities>

new const FROST_VIEW_MODEL[] = "models/rezombie/weapons/grenades/frost_v.mdl";
new const FROST_EXPLODE_SOUND[]= "rezombie/weapons/grenades/frostnova.wav";
new const FROST_FREEZE_SOUND[] = "rezombie/weapons/grenades/impalehit.wav";
new const FROST_BREAK_SOUND[] = "rezombie/weapons/grenades/impalelaunch1.wav";

new const ICECUBE_MODEL[] = "models/w_hegrenade.mdl";
new const ICECUBE_CLASSNAME[] = "ent_icecube";

new g_iIceCubeEntity[MAX_PLAYERS + 1];
new bool:g_bFrostDamage[MAX_PLAYERS + 1];
new Float:g_vecOldVelocity[3];

new g_iModelIndex_GlassGibs;
new g_iModelIndex_LaserBeam;
new g_iModelIndex_ShockWave;

new g_iGrenade_Frost;

enum _:Forwards
{
	Fw_Return,
	Fw_Frost_Grenade_Freeze_Pre,
	Fw_Frost_Grenade_Freeze_Post,

}; new gForwards[Forwards];

public plugin_precache()
{
	register_plugin("[ReZP] Grenade: Frost", REZP_VERSION_STR, "fl0wer");

	precache_sound(FROST_EXPLODE_SOUND);
	precache_sound(FROST_FREEZE_SOUND);
	precache_sound(FROST_BREAK_SOUND);

	precache_model(ICECUBE_MODEL);

	g_iModelIndex_GlassGibs = precache_model("models/glassgibs.mdl");
	g_iModelIndex_LaserBeam = precache_model("sprites/laserbeam.spr");
	g_iModelIndex_ShockWave = precache_model("sprites/shockwave.spr");

	new grenade = g_iGrenade_Frost = rz_grenade_create("grenade_frost", "weapon_flashbang");

	set_grenade_var(grenade, RZ_GRENADE_NAME, "RZ_WPN_FROST_GRENADE");
	set_grenade_var(grenade, RZ_GRENADE_SHORT_NAME, "RZ_WPN_FROST_SHORT");
	set_grenade_var(grenade, RZ_GRENADE_VIEW_MODEL, FROST_VIEW_MODEL);

	set_grenade_var(grenade, RZ_GRENADE_DISTANCE_EFFECT, 350.0);
	set_grenade_var(grenade, RZ_GRENADE_PLAYERS_DAMAGE, 12.0);
}

public plugin_init()
{
	RegisterHookChain(RG_CSGameRules_RestartRound, "@CSGameRules_RestartRound_Post", .post = true);
	//RegisterHookChain(RG_CSGameRules_FPlayerCanTakeDamage, "@CSGameRules_FPlayerCanTakeDamage_Pre", .post = false);

	RegisterHookChain(RH_SV_StartSound, "@SV_StartSound_Pre", .post = false);

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "@CBasePlayer_ResetMaxSpeed_Post", .post = true);

	RegisterHookChain(RG_CBasePlayer_SetAnimation, "@CBasePlayer_SetAnimation_Pre", .post = false);

	gForwards[Fw_Frost_Grenade_Freeze_Pre] = CreateMultiForward("rz_frost_grenade_freeze_pre", ET_CONTINUE, FP_CELL);
	gForwards[Fw_Frost_Grenade_Freeze_Post] = CreateMultiForward("rz_frost_grenade_freeze_post", ET_IGNORE, FP_CELL);
}

public plugin_natives() {
	register_native("rz_grenade_set_user_icer", "@native_grenade_set_user_icer");
}

public rz_grenades_throw_post(id, entity, grenade)
{
	if (grenade != g_iGrenade_Frost)
		return;

	message_begin_f(MSG_ALL, SVC_TEMPENTITY);
	TE_BeamFollow(entity, g_iModelIndex_LaserBeam, 10, 10, { 0, 100, 200 }, 200);
}

public rz_grenades_explode_pre(pEntity, pGrenade)
{
	if (pGrenade != g_iGrenade_Frost)
		return RZ_CONTINUE;

	new Float:vecOrigin[3];
	new Float:vecOrigin2[3];
	new Float:vecAxis[3];

	new pAttacker = get_entvar(pEntity, var_owner);
	get_entvar(pEntity, var_origin, vecOrigin);

	vecAxis = vecOrigin;
	vecAxis[2] += 555.0;

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	TE_BeamCylinder(vecOrigin, vecAxis, g_iModelIndex_ShockWave, 0, 0, 4, 60, 0, { 0, 100, 200 }, 200, 0);

	rh_emit_sound2(pEntity, 0, CHAN_WEAPON, FROST_EXPLODE_SOUND, VOL_NORM, ATTN_NORM);

	for (new pTarget = 1; pTarget <= MaxClients; pTarget++)
	{
		if (!is_user_alive(pTarget))
			continue;

		get_entvar(pTarget, var_origin, vecOrigin2);
		new Float:pGrenadeDistance = get_grenade_var(pGrenade, RZ_GRENADE_DISTANCE_EFFECT);
		if (vector_distance(vecOrigin, vecOrigin2) > pGrenadeDistance)
			continue;

		// Does not work with bots
		/*if (!ExecuteHamB(Ham_FVisible, pTarget, entity))
			continue;*/ // In the future I will replace it with another option

		if (get_member(pTarget, m_iTeam) != TEAM_TERRORIST)
			continue;

		IgnitePlayer(pTarget, pAttacker, 5.0, Float:get_grenade_var(pGrenade, RZ_GRENADE_PLAYERS_DAMAGE));
	}

	return RZ_BREAK;
}

public rz_class_change_pre(id, attacker, class) {
	IceCube_Destroy(id, true);
}

@SV_StartSound_Pre(recipients, entity, channel, sample[], volume, Float:attenuation, flags, pitch) {
	if (!is_user_connected(entity))
		return HC_CONTINUE;

	if (!g_bFrostDamage[entity])
		return HC_CONTINUE;

	return HC_SUPERCEDE;
}

public client_disconnected(id) {
	IceCube_Destroy(id);
}

@CSGameRules_RestartRound_Post() for (new i = 1; i <= MaxClients; i++) {
	IceCube_Destroy(i);
}

/*@CSGameRules_FPlayerCanTakeDamage_Pre(id, attacker)
{
	if (is_nullent(g_iIceCubeEntity[id]))
		return HC_CONTINUE;

	SetHookChainReturn(ATYPE_INTEGER, false);
	return HC_SUPERCEDE;
}*/

@CBasePlayer_TakeDamage_Pre(id, inflictor, attacker, Float:damage, bitsDamageType)
{
	if (is_nullent(g_iIceCubeEntity[id]))
		return;

	get_entvar(id, var_velocity, g_vecOldVelocity);
	SetHookChainArg(4, ATYPE_FLOAT, damage * 0.5);
}

@CBasePlayer_TakeDamage_Post(id, inflictor, attacker, Float:damage, bitsDamageType)
{
	if (is_nullent(g_iIceCubeEntity[id]))
		return;

	set_entvar(id, var_velocity, g_vecOldVelocity);
}

@CBasePlayer_Killed_Pre(pVictim, attacker, gib)
{
	if (is_nullent(g_iIceCubeEntity[pVictim]))
		return;

	g_bFrostDamage[pVictim] = false;

	IceCube_Destroy(pVictim, true);
	SetHookChainArg(3, ATYPE_INTEGER, GIB_ALWAYS);
}

@CBasePlayer_ResetMaxSpeed_Post(id)
{
	if (is_nullent(g_iIceCubeEntity[id]))
		return;

	set_entvar(id, var_maxspeed, 1.0);
}

@CBasePlayer_SetAnimation_Pre(id, PLAYER_ANIM:playerAnim) {
	if (!g_bFrostDamage[id])
		return HC_CONTINUE;

	return HC_SUPERCEDE;
}

@native_grenade_set_user_icer(plugin_id, num_params) {
	enum {
		ArgpTarget = 1,
		ArgpAttacker = 2,
		ArgpDuration = 3,
		ArgpDamage = 4,
	};

	new pTarget = get_param(ArgpTarget);
	new pAttacker = get_param(ArgpAttacker);
	new Float:pDuration = get_param_f(ArgpDuration);
	new Float:pDamage = get_param_f(ArgpDamage);

	if (!is_user_alive(pTarget)) {
		return false;
	}

	IgnitePlayer(pTarget, pAttacker, pDuration, pDamage);
	return true;
}

IgnitePlayer(pTarget, pAttacker, Float:pDuration, Float:pDamage)
{
	ExecuteForward(gForwards[Fw_Frost_Grenade_Freeze_Pre], gForwards[Fw_Return], pTarget);

	if (gForwards[Fw_Return] >= RZ_SUPERCEDE) {
		@UnfreezePlayer_BreakGlass(pTarget);
		return;
	}

	new iceCube = g_iIceCubeEntity[pTarget];

	if (is_nullent(iceCube)) {
		iceCube = IceCube_Create(pTarget, pAttacker, pDuration, pDamage);
	}
	else {
		// refreeze
		IceCube_Destroy(pTarget, true);
		iceCube = IceCube_Create(pTarget, pAttacker, pDuration, pDamage);
	}

	g_iIceCubeEntity[pTarget] = iceCube;

	new Float:vecVelocity[3];
	get_entvar(pTarget, var_velocity, vecVelocity);

	for (new i = 0; i < 3; i++)
		vecVelocity[i] *= 0.5;

	set_entvar(pTarget, var_velocity, vecVelocity);
	set_entvar(pTarget, var_iuser3, get_entvar(pTarget, var_iuser3) | PLAYER_PREVENT_JUMP);
	set_member(pTarget, m_bIsDefusing, true);

	rg_reset_maxspeed(pTarget);

	rh_emit_sound2(pTarget, 0, CHAN_BODY, FROST_FREEZE_SOUND, VOL_NORM, ATTN_NORM);
	
	message_begin(MSG_ONE, gmsgDamage, _, pTarget);
	SendDamage(0, 0, DMG_DROWN);

	ExecuteForward(gForwards[Fw_Frost_Grenade_Freeze_Post], gForwards[Fw_Return], pTarget);
}

IceCube_Create(pTarget, pAttacker, Float:pDuration = 0.0, Float:pDamage = 1.0)
{
	new pFrozen = rg_create_entity("info_target");

	if (is_nullent(pFrozen))
		return 0;

	new Float:pGametime = get_gametime();

	set_entvar(pFrozen, var_classname, ICECUBE_CLASSNAME);
	set_entvar(pFrozen, var_owner, pAttacker);
	set_entvar(pFrozen, var_enemy, pTarget);
	set_entvar(pFrozen, var_dmg_take, pDamage);
	set_entvar(pFrozen, var_nextthink, pGametime);
	set_entvar(pFrozen, var_dmgtime, pGametime + pDuration);

	set_entvar(pFrozen, var_effects, EF_NODRAW);

	engfunc(EngFunc_SetModel, pFrozen, ICECUBE_MODEL);

	SetThink(pFrozen, "@IceCube_Think");

	rz_util_set_rendering(pTarget, kRenderNormal, 25.0, Float:{ 0.0, 100.0, 200.0 }, kRenderFxGlowShell);

	return pFrozen;
}

IceCube_Destroy(pTarget, bool:breakGlass = false)
{
	new pFrozen = g_iIceCubeEntity[pTarget];

	g_iIceCubeEntity[pTarget] = 0;

	if (is_nullent(pFrozen))
		return;

	if (is_user_connected(pTarget))
	{
		rz_util_set_rendering(pTarget);

		if (breakGlass)
			@UnfreezePlayer_BreakGlass(pTarget);
	}

	set_entvar(pFrozen, var_flags, FL_KILLME);
}

@IceCube_Think(const pEntity)
{
	new pTarget = get_entvar(pEntity, var_enemy);
	new Float:pGametime = get_gametime();

	if ((!is_nullent(pTarget) && get_entvar(pTarget, var_flags) & FL_INWATER) || Float:get_entvar(pEntity, var_dmgtime) <= pGametime) 
	{
		IceCube_Destroy(pTarget, true);

		if (is_user_alive(pTarget)) {
			set_entvar(pTarget, var_iuser3, get_entvar(pTarget, var_iuser3) & ~PLAYER_PREVENT_JUMP);
			set_member(pTarget, m_bIsDefusing, false);
			rg_reset_maxspeed(pTarget);
			rz_util_set_rendering(pTarget);
		}

		return;
	}

	if (Float:get_entvar(pEntity, var_pain_finished) <= pGametime)
	{
		set_entvar(pEntity, var_pain_finished, pGametime + 0.2);

		new pAttacker = get_entvar(pEntity, var_owner);
		if (pAttacker && !is_user_connected(pAttacker))
		{
			pAttacker = 0;
			set_entvar(pEntity, var_owner, 0);
		}

		if (rg_is_player_can_takedamage(pTarget, pAttacker))
		{
			g_bFrostDamage[pTarget] = true;
			set_member(pTarget, m_LastHitGroup, HITGROUP_GENERIC);

			rg_multidmg_clear();
			rg_multidmg_add(pEntity, pTarget, Float:get_entvar(pEntity, var_dmg_take), DMG_FREEZE | DMG_NEVERGIB);
			rg_multidmg_apply(pEntity, pAttacker);
	
			g_bFrostDamage[pTarget] = false;
		}
	}

	set_entvar(pEntity, var_nextthink, pGametime + 0.1);
}

@UnfreezePlayer_BreakGlass(const pTarget)
{
	if (!is_user_connected(pTarget))
		return;

	new Float:vecOrigin[3];
	new Float:vecVelocity[3];

	get_entvar(pTarget, var_origin, vecOrigin);

	vecOrigin[2] += 24.0;

	vecVelocity[0] = random_float(-50.0, 50.0);
	vecVelocity[1] = random_float(-50.0, 50.0);
	vecVelocity[2] = 25.0;

	message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
	TE_BreakModel(vecOrigin, Float:{ 16.0, 16.0, 16.0 }, vecVelocity, 10, g_iModelIndex_GlassGibs, 10, 25, BREAK_GLASS);

	rh_emit_sound2(pTarget, 0, CHAN_BODY, FROST_BREAK_SOUND, VOL_NORM, ATTN_NORM);
}
