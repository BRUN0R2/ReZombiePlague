#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <rezp_inc/rezp_main>

const ADMINMENU_FLAGS = ADMIN_MENU;

new g_iMenu_Game;

new const GAME_MENU_ID[] = "RZ_GameMenu";

public plugin_init()
{
	register_plugin("[ReZP] Menu: Game", REZP_VERSION_STR, "fl0wer");

	new const cmds[][] = { "chooseteam", "gamemenu", "say /menu" };

	for (new i = 0; i < sizeof(cmds); i++)
		register_clcmd(cmds[i], "@Command_GameMenu");

	g_iMenu_Game = register_menuid(GAME_MENU_ID);
	register_menucmd(g_iMenu_Game, 1023, "@HandleMenu_Game");
}

@Command_GameMenu(id)
{
	if (is_nullent(id))
		return PLUGIN_CONTINUE;
	
	if (get_member(id, m_iJoiningState) != JOINED)
		return PLUGIN_CONTINUE;

	new menu, keys;
	get_user_menu(id, menu, keys);

	if (menu != g_iMenu_Game)
		GameMenu_Show(id);
	else
		MENU_CLOSER(id);

	return PLUGIN_HANDLED;
}

GameMenu_Show(id)
{
	new bool:warmup = rz_game_is_warmup();
	new isAlive = is_user_alive(id);
	new keys;
	new len;
	new text[MAX_MENU_LENGTH];

	SetGlobalTransTarget(id);

	ADD_FORMATEX("\yRe Zombie Plague^n");
	ADD_FORMATEX("\y%l^n^n", "RZ_MENU_GAME_TITLE");

	ADD_FORMATEX("\r1. \w%l^n", "RZ_MENU_GAME_SELECT_WPNS");
	keys |= MENU_KEY_1;

	if (!warmup && isAlive)
	{
		ADD_FORMATEX("\r2. \w%l^n", "RZ_MENU_GAME_BUY_EXTRA");
		keys |= MENU_KEY_2;
	}
	else
		ADD_FORMATEX("\d2. %l^n", "RZ_MENU_GAME_BUY_EXTRA");

	new defaultTrClass = rz_class_get_default(TEAM_TERRORIST, false);
	new name[32];

	rz_class_get(defaultTrClass, RZ_CLASS_NAME, name, charsmax(name));

	ADD_FORMATEX("\r3. \w%l^n", "RZ_MENU_GAME_CHOOSE_SUBCLASS", name);
	keys |= MENU_KEY_3;

	// check last
	if (get_member(id, m_iTeam) == TEAM_SPECTATOR)
		ADD_FORMATEX("\r4. \w%l^n", "RZ_MENU_GAME_JOIN_GAME");
	else
		ADD_FORMATEX("\r4. \w%l^n", "RZ_MENU_GAME_JOIN_SPECS");

	keys |= MENU_KEY_4;

	ADD_FORMATEX("^n");
	ADD_FORMATEX("^n");
	ADD_FORMATEX("^n");
	ADD_FORMATEX("^n");

	if (get_user_flags(id) & ADMINMENU_FLAGS)
	{
		ADD_FORMATEX("\r9. \w%l^n", "RZ_MENU_GAME_ADMIN");
		keys |= MENU_KEY_9;
	}
	else
		ADD_FORMATEX("\d9. %l^n", "RZ_MENU_GAME_ADMIN");

	ADD_FORMATEX("\r0. \w%l", "RZ_CLOSE");
	keys |= MENU_KEY_0;

	show_menu(id, keys, text, -1, GAME_MENU_ID);
}

@HandleMenu_Game(id, key)
{
	if (key == 9)
		return PLUGIN_HANDLED;
	
	switch (key)
	{
		case 0:
		{
			amxclient_cmd(id, "guns");
		}
		case 1:
		{
			amxclient_cmd(id, "items");
		}
		case 2:
		{
			amxclient_cmd(id, "zombie");
		}
		case 3:
		{
			if (get_member(id, m_iTeam) == TEAM_SPECTATOR)
			{
				rg_set_user_team(id, TEAM_CT, MODEL_UNASSIGNED, .check_win_conditions = true);
			}
			else
			{
				if (is_user_alive(id))
				{
					new Float:frags = get_entvar(id, var_frags);
					
					ExecuteHamB(Ham_Killed, id, id, GIB_NEVER);
					set_entvar(id, var_frags, frags);
				}

				rg_set_user_team(id, TEAM_SPECTATOR, MODEL_UNASSIGNED, .check_win_conditions = true);
			}
		}
		case 8:
		{
			amxclient_cmd(id, "adminmenu");
		}
	}
	
	return PLUGIN_HANDLED;
}
