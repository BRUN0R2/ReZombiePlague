#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/util_messages>

new const SOUND_FLASHLIGHT_ON[] = "items/flashlight1.wav";
new const SOUND_FLASHLIGHT_OFF[] = "items/flashlight1.wav";

new bool:g_bHasFlashLight[MAX_PLAYERS + 1];
new bool:g_bFlashLightOn[MAX_PLAYERS + 1];
new Float:g_flNextFlashLightTime[MAX_PLAYERS + 1];

new g_iClass_Human;

new Float:rz_flashlight_drain_time;
new Float:rz_flashlight_charge_time;
new Float:rz_flashlight_distance;
new rz_flashlight_radius;
new rz_flashlight_color[3];

public plugin_precache()
{
	register_plugin("[ReZP] Addon: Humam Flashlight", REZP_VERSION_STR, "fl0wer");

	RZ_CHECK_CLASS_EXISTS(g_iClass_Human, "class_human");

	precache_sound(SOUND_FLASHLIGHT_ON);
	precache_sound(SOUND_FLASHLIGHT_OFF);

	bind_pcvar_float(create_cvar("rz_flashlight_drain_time", "1.2", FCVAR_NONE, "", true, 0.0, false), rz_flashlight_drain_time);
	bind_pcvar_float(create_cvar("rz_flashlight_charge_time", "0.2", FCVAR_NONE, "", true, 0.0, false), rz_flashlight_charge_time);
	bind_pcvar_float(create_cvar("rz_flashlight_distance", "1024", FCVAR_NONE, "", true, 0.0, false), rz_flashlight_distance);
	bind_pcvar_num(create_cvar("rz_flashlight_radius", "7", FCVAR_NONE, "", true, 0.0, true, 255.0), rz_flashlight_radius);
	bind_pcvar_num(create_cvar("rz_flashlight_color_red", "255", FCVAR_NONE, "", true, 0.0, true, 255.0), rz_flashlight_color[0]);
	bind_pcvar_num(create_cvar("rz_flashlight_color_green", "255", FCVAR_NONE, "", true, 0.0, true, 255.0), rz_flashlight_color[1]);
	bind_pcvar_num(create_cvar("rz_flashlight_color_blue", "255", FCVAR_NONE, "", true, 0.0, true, 255.0), rz_flashlight_color[2]);
}

public plugin_init()
{
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@CBasePlayer_UpdateClientData_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@CBasePlayer_UpdateClientData_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_ImpulseCommands, "@CBasePlayer_ImpulseCommands_Pre", .post = false);
}

public client_putinserver(id)
{
	g_flNextFlashLightTime[id] = 0.0;
}

public rz_class_change_post(id, attacker, class)
{
	if (class == g_iClass_Human) {
		g_bHasFlashLight[id] = true;
		set_member(id, m_iFlashBattery, 100);
	} else {
		g_bHasFlashLight[id] = false;
	}

	SetFlashlightEnabled(id, .enabled = false);
}

@CBasePlayer_UpdateClientData_Pre(const id)
{
	if (!g_bHasFlashLight[id] || !is_user_connected(id))
		return;

	new Float:time = get_gametime();

	if (Float:get_member(id, m_flFlashLightTime) > time)
		return;

	new flashBattery = get_member(id, m_iFlashBattery);

	if (g_bFlashLightOn[id])
	{
		if (flashBattery)
		{
			set_member(id, m_flFlashLightTime, time + rz_flashlight_drain_time);

			if (--flashBattery <= 0)
				SetFlashlightEnabled(id, .enabled = false);
		}
	}
	else
	{
		if (flashBattery < 100)
		{
			set_member(id, m_flFlashLightTime, time + rz_flashlight_charge_time);
			flashBattery++;
		}
		else
			set_member(id, m_flFlashLightTime, 0.0);
	}

	set_member(id, m_iFlashBattery, flashBattery);
	
	message_begin(MSG_ONE, gmsgFlashBat, _, id);
	SendFlashBat(flashBattery);
}

@CBasePlayer_UpdateClientData_Post(const id)
{
	if (!g_flNextFlashLightTime[id] || !is_user_alive(id))
		return;

	static Float:pGameTime; pGameTime = get_gametime();

	if (g_flNextFlashLightTime[id] > pGameTime)
		return;

	g_flNextFlashLightTime[id] = pGameTime + 0.1;

	new Float:fraction;
	new Float:vecSrc[3];
	new Float:vecViewAngle[3];
	new Float:vecViewForward[3];
	new Float:vecEnd[3];

	ExecuteHam(Ham_Player_GetGunPosition, id, vecSrc);
	get_entvar(id, var_v_angle, vecViewAngle);
	
	angle_vector(vecViewAngle, ANGLEVECTOR_FORWARD, vecViewForward);

	for (new i = 0; i < 3; i++)
		vecEnd[i] = vecSrc[i] + vecViewForward[i] * rz_flashlight_distance;

	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, 0);
	get_tr2(0, TR_flFraction, fraction);

	if (fraction >= 1.0)
		return;

	get_tr2(0, TR_vecEndPos, vecEnd);

	rz_util_te_dlight(vecEnd, rz_flashlight_radius, rz_flashlight_color, 3, 0);
}

@CBasePlayer_ImpulseCommands_Pre(id)
{
	if (get_entvar(id, var_impulse) == 100)
	{
		if (g_bHasFlashLight[id])
			SetFlashlightEnabled(id, !g_bFlashLightOn[id]);

		set_entvar(id, var_impulse, 0);
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

SetFlashlightEnabled(const id, bool:enabled = false)
{
	if (!is_user_connected(id))
		return;

	// In this part a bug occurs when the human becomes a zombie
	// a deactivated flashlight sound comes out

	new Float:GameTime = get_gametime();

	g_bFlashLightOn[id] = enabled;

	if (enabled) {
		rh_emit_sound2(id, 0, CHAN_ITEM, SOUND_FLASHLIGHT_ON, VOL_NORM, ATTN_NORM);
		set_member(id, m_flFlashLightTime, GameTime + rz_flashlight_drain_time);
		g_flNextFlashLightTime[id] = GameTime;
	} else {
		rh_emit_sound2(id, 0, CHAN_ITEM, SOUND_FLASHLIGHT_OFF, VOL_NORM, ATTN_NORM);
		set_member(id, m_flFlashLightTime, GameTime + rz_flashlight_charge_time);
		g_flNextFlashLightTime[id] = 0.0;
	}

	message_begin(MSG_ONE, gmsgFlashlight, _, id);
	SendFlashlight(enabled, get_member(id, m_iFlashBattery));
}
