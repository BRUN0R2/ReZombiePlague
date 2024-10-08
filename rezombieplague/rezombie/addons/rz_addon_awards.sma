#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <rezp_inc/rezp_main>

const AWARD_TEAM_WIN = 3;
const AWARD_TEAM_LOSER = 1;
const AWARD_TEAM_DRAW = 0;

new Float:g_flDamageDealt[MAX_PLAYERS + 1];

new g_pClass_Human;

public plugin_precache()
{
	register_plugin("[ReZP] Addon: Awards", REZP_VERSION_STR, "fl0wer");

	RZ_CHECK_CLASS_EXISTS(g_pClass_Human, "class_human");
}

public plugin_init() {
	RegisterHookChain(RG_RoundEnd, "@RoundEnd_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_AddAccount, "@CBasePlayer_AddAccount_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Pre", .post = false);
}

public client_putinserver(id) {
	g_flDamageDealt[id] = 0.0;
}

public rz_class_change_post(id, attacker)
{
	if (!rz_main_get(RZ_MAIN_CREDITS_ENABLED) || id == attacker || !attacker)
		return;

	new bonus = rz_main_get(RZ_MAIN_CREDITS_PER_INFECT);
	if (!bonus) return;
	rg_add_account(attacker, bonus);
}

@RoundEnd_Post(WinStatus:status, ScenarioEventEndRound:event, Float:delay)
{
	if (status == WINSTATUS_NONE)
		return;

	if (rz_game_is_warmup())
		return;

	if (!rz_main_get(RZ_MAIN_CREDITS_ENABLED))
		return;

	new TeamName:winTeam = TEAM_UNASSIGNED;
	new TeamName:team;

	switch (status)
	{
		case WINSTATUS_TERRORISTS: winTeam = TEAM_TERRORIST;
		case WINSTATUS_CTS: winTeam = TEAM_CT;
	}

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_connected(i)) {
			continue;
		}

		team = get_member(i, m_iTeam);

		if (team != TEAM_TERRORIST && team != TEAM_CT)
			continue;

		if (get_member(i, m_iNumSpawns) < 1) {
			continue;
		}

		if (winTeam == TEAM_UNASSIGNED) {
			rg_add_account(i, rz_main_get(RZ_MAIN_CREDITS_TEAM_DRAW));
		} else if (winTeam == team) {
			rg_add_account(i, rz_main_get(RZ_MAIN_CREDITS_TEAM_WIN));
		} else {
			rg_add_account(i, rz_main_get(RZ_MAIN_CREDITS_TEAM_LOSER));
		}
	}
}

@CBasePlayer_AddAccount_Pre(id, amount, RewardType:type, bool:trackChange)
{
	if (type != RT_ENEMY_KILLED)
		return;

	if (!rz_main_get(RZ_MAIN_CREDITS_ENABLED))
		return;

	SetHookChainArg(2, ATYPE_INTEGER, rz_main_get(RZ_MAIN_CREDITS_PER_KILLED));
}

@CBasePlayer_TakeDamage_Pre(const victim, const inflictor, const attacker, const Float:xDamage, const bitsDamageType) {
	if (!rz_main_get(RZ_MAIN_CREDITS_ENABLED) || victim == attacker || !is_user_connected(attacker)) {
		return HC_CONTINUE;
	}
	if (!rg_is_player_can_takedamage(victim, attacker)) {
		return HC_CONTINUE;
	}
	if (rz_player_get(attacker, RZ_PLAYER_CLASS) != g_pClass_Human) {
		return HC_CONTINUE;
	}

	new Float:pNeedDamage = Float:rz_main_get(RZ_MAIN_CREDITS_NEED_DAMAGE);

	g_flDamageDealt[attacker] += xDamage;
	new pCredits = 0;
	while(g_flDamageDealt[attacker] > pNeedDamage)
	{
		g_flDamageDealt[attacker] -= pNeedDamage;
		pCredits += rz_main_get(RZ_MAIN_CREDITS_PER_DAMAGE);
	}

	if(pCredits)rg_add_account(attacker, pCredits);
	return HC_CONTINUE;
}