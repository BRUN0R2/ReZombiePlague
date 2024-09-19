#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/util_messages>

new Float:g_nextHudInfoTime[MAX_PLAYERS + 1];

new g_iHudSync_Info;

new Float:rz_playerinfo_hud_pos[2];

public plugin_init()
{
	register_plugin("[ReZP] Addon: Player Info", REZP_VERSION_STR, "fl0wer");

	rz_add_translate("hud");

	register_message(get_user_msgid("Money"), "@MSG_Money");
	register_message(get_user_msgid("SpecHealth"), "@MSG_SpecHealth1");
	register_message(get_user_msgid("SpecHealth2"), "@MSG_SpecHealth2");
	register_message(get_user_msgid("Health"), "@MSG_Health");

	RegisterHookChain(RG_CBasePlayer_Spawn, "@CBasePlayer_Spawn_Post", true);
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Post", true);
	RegisterHookChain(RG_CBasePlayer_UpdateClientData, "@CBasePlayer_UpdateClientData_Post", true);
	RegisterHookChain(RG_CBasePlayer_AddAccount, "@CBasePlayer_AddAccount_Post", true);

	bind_pcvar_float(create_cvar("rz_playerinfo_hud_x", "0.02", _, "", true, -1.0, true, 1.0), rz_playerinfo_hud_pos[0]);
	bind_pcvar_float(create_cvar("rz_playerinfo_hud_y", "0.2", _, "", true, -1.0, true, 1.0), rz_playerinfo_hud_pos[1]);

	g_iHudSync_Info = CreateHudSyncObj();
}

public client_putinserver(id) {
	g_nextHudInfoTime[id] = 0.0;
}

@MSG_Money(id, dest, player)
{
	if (get_msg_arg_int(2) == 0)
		return PLUGIN_CONTINUE;

	return PLUGIN_HANDLED;
}

@MSG_SpecHealth1(id, dest, player)
{
	new observerTarget = get_member(player, m_hObserverTarget);
	new Float:health = get_entvar(observerTarget, var_health);
	new Float:maxHealth = get_entvar(observerTarget, var_max_health);

	if (health < 0.0)
		health = 0.0;

	set_msg_arg_int(1, ARG_BYTE, floatround((health / maxHealth) * 100.0));
}

@MSG_SpecHealth2(id, dest, player)
{
	new observerTarget = get_msg_arg_int(2);
	new Float:health = get_entvar(observerTarget, var_health);
	new Float:maxHealth = get_entvar(observerTarget, var_max_health);

	set_msg_arg_int(1, ARG_BYTE, floatround((health / maxHealth) * 100.0));
}

@MSG_Health(id, dest, player)
{
	if (!is_user_alive(player)) {
		return;
	}

	new Float:health = get_entvar(player, var_health);
	new Float:maxHealth = get_entvar(player, var_max_health);

	set_msg_arg_int(1, ARG_BYTE, clamp(floatround((health / maxHealth) * 100.0), 1, 255));
}

@CBasePlayer_Spawn_Post(id) {
	if (!is_user_alive(id))
		return;

	g_nextHudInfoTime[id] = get_gametime() + 0.2;
}

@CBasePlayer_Killed_Post(id, attacker, gib)
{
	ClearSyncHud(id, g_iHudSync_Info);
}

@CBasePlayer_AddAccount_Post(id, amount, RewardType:type, bool:trackChange)
{
	if (!rz_main_get(RZ_MAIN_AMMOPACKS_ENABLED))
		return;

	message_begin(MSG_ONE, gmsgMoney, _, id);
	SendMoney(get_member(id, m_iAccount), true);
}

@CBasePlayer_UpdateClientData_Post(const id) {
	if (!g_nextHudInfoTime[id] || !is_user_connected(id) || is_user_bot(id))
		return;

	static Float:Gametime; Gametime = get_gametime();

	if (g_nextHudInfoTime[id] > Gametime)
		return;

	g_nextHudInfoTime[id] = Gametime + 0.1;

	static class, subclass, color[3], Float:xSpeed, Float:velocity[3];
	class = rz_player_get(id, RZ_PLAYER_CLASS);

	if (!class) return;

	SetGlobalTransTarget(id);

	get_entvar(id, var_velocity, velocity);
	xSpeed = floatsqroot(floatpower(velocity[0], 2.0) + floatpower(velocity[1], 2.0));

	subclass = rz_player_get(id, RZ_PLAYER_SUBCLASS);

	static name[RZ_MAX_LANGKEY_LENGTH];
	rz_class_get(class, RZ_CLASS_HUD_COLOR, color);
	rz_class_get(class, RZ_CLASS_NAME, name, charsmax(name));

	new len; static text[512];

	if (subclass) {
		static subclassName[RZ_MAX_LANGKEY_LENGTH];
		rz_subclass_get(subclass, RZ_SUBCLASS_NAME, subclassName, charsmax(subclassName));
		ADD_FORMATEX("^n» %l: %l", name, subclassName);
	}
	else if (class) {
		static className[RZ_MAX_LANGKEY_LENGTH];
		rz_class_get(class, RZ_CLASS_NAME, className, charsmax(className));
		ADD_FORMATEX("^n» %l: %l", "RZ_HUD_CLASS", className);
	}

	ADD_FORMATEX("^n» %l: %.1f", "RZ_HUD_SPEED", xSpeed);

	set_hudmessage(color[0], color[1], color[2], rz_playerinfo_hud_pos[0], rz_playerinfo_hud_pos[1], 0, 0.0, 0.30, 0.0, 0.0);
	ShowSyncHudMsg(id, g_iHudSync_Info, text);
}
