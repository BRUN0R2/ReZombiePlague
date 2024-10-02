#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/api/api_player_camera>

new gl_pMenu_Camera

public plugin_precache() {
	register_plugin("[REZP] Camera menu", "1.0", "BRUN0")
	rz_add_translate("menu/camera")
}

public plugin_init()
{
	new const cmds[][] = {
		"camera",
		"say /cam",
		"say .cam",
		"say cam",
		"say_team /cam",
		"say_team .cam",
		"say_team cam",
	};

	for (new i = 0; i < sizeof(cmds); i++) {
		register_clcmd(cmds[i], "@Camera_show_menu")
	}

	gl_pMenu_Camera = register_menuid("camera Menu")
	register_menucmd(gl_pMenu_Camera, 1023, "@Handle_camera_Menu")
}

public client_putinserver(id) {
	pVars[id][CAM_LAST] = 0
	pVars[id][CAM_HAVE] = false
}

@Camera_show_menu(const id) {
	if (!is_user_alive(id)) {
		return
	}

	new keys, len, text[MAX_MENU_LENGTH]

	SetGlobalTransTarget(id)

	// Título do menu
	ADD_FORMATEX("%l^n^n", "RZ_MENU_CAM_TITLE")

	// Se você estiver usando distância, descomente a linha abaixo
	// ADD_FORMATEX("%l \d[\y%0.f\d]^n", "RZ_MENU_CAM_DISTANCE", xDistance[id]);

	pVars[id][CAM_LAST] = get_player_camera_mode(id)

	ADD_FORMATEX("%l %s^n", "RZ_MENU_CAM_ACTIVE", pVars[id][CAM_HAVE] ? "\w[\yON\w]":"\w[\rOFF\w]")
	keys |= MENU_KEY_1;

	ADD_FORMATEX("\d_______________________^n")

	ADD_FORMATEX("%l %s^n", "RZ_MENU_CAM_NORMAL", pVars[id][CAM_LAST] == CAMERA_NORMAL ? "\w[\rX\w]":"")
	keys |= MENU_KEY_2;

	ADD_FORMATEX("%l %s^n", "RZ_MENU_CAM_RIGHT", pVars[id][CAM_LAST] == CAMERA_RIGHT ? "\w[\rX\w]":"")
	keys |= MENU_KEY_3;

	ADD_FORMATEX("%l %s^n", "RZ_MENU_CAM_FRONT", pVars[id][CAM_LAST] == CAMERA_FRONT ? "\w[\rX\w]":"")
	keys |= MENU_KEY_4;

	ADD_FORMATEX("\d_______________________^n")

	ADD_FORMATEX("%l^n", "RZ_MENU_CAM_INCREASE")
	keys |= MENU_KEY_5;

	ADD_FORMATEX("%l^n^n", "RZ_MENU_CAM_DECREASE")
	keys |= MENU_KEY_6;

	ADD_FORMATEX("%l^n", "RZ_MENU_CAM_BACK")
	keys |= MENU_KEY_9;

	ADD_FORMATEX("%l", "RZ_MENU_CAM_CLOSE")
	keys |= MENU_KEY_0;

	show_menu(id, keys, text, -1, "camera Menu")
}

@Handle_camera_Menu(const id, const key) {
	if (key == 9 || !is_user_alive(id)) {
		return PLUGIN_HANDLED
	}

	switch (key)
	{
		case 0:
		{
			if (!pVars[id][CAM_HAVE]) {
				create_player_camera(id)
				pVars[id][CAM_HAVE] = !pVars[id][CAM_HAVE]
			}
			else {
				breaks_player_camera(id)
				pVars[id][CAM_HAVE] = !pVars[id][CAM_HAVE]
			}
		}
		case 1: {
			set_player_camera_mode(id, any:CAMERA_NORMAL)
		}
		case 2: {
			set_player_camera_mode(id, any:CAMERA_RIGHT)
		}
		case 3: {
			set_player_camera_mode(id, any:CAMERA_FRONT)
		}
		case 4: {}
		case 8: {
			amxclient_cmd(id, "options")
		}
	}

	/*if(key == 0 || key == 1) { // Anti bug & Flood de mensagens
		if(++xMsgCount[id] <= 2) rz_print_chat(id, print_team_grey, "%L", id, "RZ_MENU_CAM_ALERT");
	}*/

	if (key != 8) { // Se a key for diferente de 8 @Camera_show_menu(id);
		@Camera_show_menu(id)
	}

	return PLUGIN_HANDLED
}