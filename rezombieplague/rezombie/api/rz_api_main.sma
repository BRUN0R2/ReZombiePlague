#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <rezp_inc/rezp_main>

new const MOD_DIRECTORY[] = "rezombie";

enum MainData
{
	Main_GameDesc[64],
	Main_SkyName[32],
	Main_GlobalLighting[2],
	Main_NvgLighting[2],
	bool:Main_RoundOverCTWin,
	bool:Main_AwardNotice,
	Main_ChatPrefix[32],
	Main_PrepareTime,
	Main_RoundTime,
	Main_WarmupTime,
	bool:Main_CreditsEnabled,
	Main_CreditsJoinAmount,
	Main_AwardPer_Killed,
	Main_AwardPer_Infect,
	Main_Award_Team_Win,
	Main_Award_Team_Loser,
	Main_Award_Team_Draw,
	Main_AwardPer_Damage,
	Float:Main_AwardNeed_Damage,

}; new gMainData[MainData];

enum _:ModuleData
{
	Module_Name[32],
	Module_Offset,
	Array:Module_Handle,

}; new Array:g_aModules;

new g_sConfigDirPath[PLATFORM_MAX_PATH];
new g_sLogDirPath[PLATFORM_MAX_PATH];
new g_sLogFilePath[PLATFORM_MAX_PATH];
new g_sLangDirPath[PLATFORM_MAX_PATH];

new g_sGlobalLightingTemp[2];
new g_sNVGLightingTemp[2];

public plugin_precache()
{
	register_plugin("[ReZP] API: Main", REZP_VERSION_STR, "fl0wer");

	get_localinfo("amxx_configsdir", g_sConfigDirPath, charsmax(g_sConfigDirPath));
	format(g_sConfigDirPath, charsmax(g_sConfigDirPath), "%s/%s", g_sConfigDirPath, MOD_DIRECTORY);

	get_localinfo("amxx_logs", g_sLogDirPath, charsmax(g_sLogDirPath));
	format(g_sLogDirPath, charsmax(g_sLogDirPath), "%s/%s", g_sLogDirPath, MOD_DIRECTORY);

	get_localinfo("amxx_datadir", g_sLangDirPath, charsmax(g_sLangDirPath));
	format(g_sLangDirPath, charsmax(g_sLangDirPath), "%s/lang/%s", g_sLangDirPath, MOD_DIRECTORY);
	
	g_aModules = ArrayCreate(ModuleData, 0);
}

public plugin_natives()
{
	ExecuteForward(CreateMultiForward("__rezp_version_check", ET_IGNORE, FP_STRING, FP_STRING), _, REZP_VERSION_MAJOR, REZP_VERSION_MINOR);

	register_native("rz_get_configsdir", "@native_get_configsdir");
	register_native("rz_print", "@native_print");
	register_native("rz_log", "@native_log");
	register_native("rz_sys_error", "@native_sys_error");

	register_native("rz_print_chat", "@native_print_chat");

	register_native("rz_main_get", "@native_main_get");
	register_native("rz_main_set", "@native_main_set");

	register_native("rz_main_lighting_global_get", "@native_main_lighting_global_get");
	register_native("rz_main_lighting_global_set", "@native_main_lighting_global_set");
	register_native("rz_main_lighting_global_reset", "@native_main_lighting_global_reset");
	register_native("rz_main_lighting_nvg_get", "@native_main_lighting_nvg_get");
	register_native("rz_main_lighting_nvg_set", "@native_main_lighting_nvg_set");
	register_native("rz_main_lighting_nvg_reset", "@native_main_lighting_nvg_reset");

	register_native("rz_module_create", "@native_module_create");
	register_native("rz_module_get_offset", "@native_module_get_offset");
	register_native("rz_module_get_valid_index", "@native_module_get_valid_index");
	register_native("rz_module_find", "@native_module_find");
}

@native_get_configsdir(plugin, argc)
{
	enum { arg_buffer = 1, arg_len };

	set_string(arg_buffer, g_sConfigDirPath, get_param(arg_len));
}

@native_print(plugin, argc)
{
	enum { arg_text = 1, arg_arguments };

	new buffer[190];

	vdformat(buffer, charsmax(buffer), arg_text, arg_arguments);
	server_print("[REZP] %s", buffer);
}

@native_log(plugin, argc)
{
	enum { arg_is_error = 1, arg_text, arg_arguments };

	if (!dir_exists(g_sLogDirPath))
	{
		if (mkdir(g_sLogDirPath) != 0)
		{
			log_amx("Cannot create logs directory '%s'", g_sLogDirPath);
			return;
		}

		rz_print("Logs directory '%s' was created", g_sLogDirPath);
	}

	new bool:isError = bool:get_param(arg_is_error);
	new time[12];
	new buffer[1024];

	get_time("%Y%m%d", time, charsmax(time));
	formatex(g_sLogFilePath, charsmax(g_sLogFilePath), "%s/%s%s.log", g_sLogDirPath, isError ? "error_" : "L", time);
	vdformat(buffer, charsmax(buffer), arg_text, arg_arguments);
	log_to_file(g_sLogFilePath, buffer);
}

@native_sys_error(plugin, argc)
{
	enum { arg_text = 1, arg_arguments };

	new buffer[256];
	
	vdformat(buffer, charsmax(buffer), arg_text, arg_arguments);
	dllfunc(DLLFunc_Sys_Error, fmt("[REZP] %s", buffer));
}

@native_print_chat(plugin, argc)
{
	enum { arg_player = 1, arg_sender, arg_text, arg_arguments };

	new player = get_param(arg_player);
	new sender = get_param(arg_sender);
	new buffer[190];

	vdformat(buffer, charsmax(buffer), arg_text, arg_arguments);
	client_print_color(player, sender, "%s%s", gMainData[Main_ChatPrefix], buffer);
}

@native_main_get(plugin, argc)
{
	enum { arg_prop = 1, arg_2, arg_3 };

	new prop = get_param(arg_prop);

	switch (prop)
	{
		case RZ_MAIN_GAME_DESC:
		{
			set_string(arg_2, gMainData[Main_GameDesc], get_param_byref(arg_3));
		}
		case RZ_MAIN_SKY_NAME:
		{
			set_string(arg_2, gMainData[Main_SkyName], get_param_byref(arg_3));
		}
		case RZ_MAIN_GLOBAL_LIGHTING:
		{
			set_string(arg_2, gMainData[Main_GlobalLighting], get_param_byref(arg_3));
		}
		case RZ_MAIN_NVG_LIGHTING:
		{
			set_string(arg_2, gMainData[Main_NvgLighting], get_param_byref(arg_3));
		}
		case RZ_MAIN_ROUNDOVER_CT_WIN:
		{
			return gMainData[Main_RoundOverCTWin];
		}
		case RZ_MAIN_AWARD_NOTICE:
		{
			return gMainData[Main_AwardNotice];
		}
		case RZ_MAIN_CHAT_PREFIX:
		{
			set_string(arg_2, gMainData[Main_ChatPrefix], get_param_byref(arg_3));
		}
		case RZ_MAIN_PREPARE_TIME:
		{
			return gMainData[Main_PrepareTime];
		}
		case RZ_MAIN_ROUND_TIME:
		{
			return gMainData[Main_RoundTime];
		}
		case RZ_MAIN_WARMUP_TIME:
		{
			return gMainData[Main_WarmupTime];
		}
		case RZ_MAIN_CREDITS_ENABLED:
		{
			return gMainData[Main_CreditsEnabled];
		}
		case RZ_MAIN_CREDITS_JOIN_AMOUNT:
		{
			return gMainData[Main_CreditsJoinAmount];
		}
		case RZ_MAIN_CREDITS_PER_KILLED:
		{
			return gMainData[Main_AwardPer_Killed];
		}
		case RZ_MAIN_CREDITS_PER_INFECT:
		{
			return gMainData[Main_AwardPer_Infect];
		}
		case RZ_MAIN_CREDITS_TEAM_WIN:
		{
			return gMainData[Main_Award_Team_Win];
		}
		case RZ_MAIN_CREDITS_TEAM_LOSER:
		{
			return gMainData[Main_Award_Team_Loser];
		}
		case RZ_MAIN_CREDITS_TEAM_DRAW:
		{
			return gMainData[Main_Award_Team_Draw];
		}
		case RZ_MAIN_CREDITS_PER_DAMAGE:
		{
			return gMainData[Main_AwardPer_Damage];
		}
		case RZ_MAIN_CREDITS_NEED_DAMAGE:
		{
			return any:gMainData[Main_AwardNeed_Damage];
		}
		default:
		{
			rz_log(true, "Config property '%d' not found", prop);
			return false;
		}
	}

	return true;
}

@native_main_set(plugin, argc)
{
	enum { arg_prop = 1, arg_2 };

	new prop = get_param(arg_prop);

	switch (prop)
	{
		case RZ_MAIN_GAME_DESC:
		{
			get_string(arg_2, gMainData[Main_GameDesc], charsmax(gMainData[Main_GameDesc]));
		}
		case RZ_MAIN_SKY_NAME:
		{
			get_string(arg_2, gMainData[Main_SkyName], charsmax(gMainData[Main_SkyName]));
		}
		case RZ_MAIN_GLOBAL_LIGHTING:
		{
			get_string(arg_2, gMainData[Main_GlobalLighting], charsmax(gMainData[Main_GlobalLighting]));
		}
		case RZ_MAIN_NVG_LIGHTING:
		{
			get_string(arg_2, gMainData[Main_NvgLighting], charsmax(gMainData[Main_NvgLighting]));
		}
		case RZ_MAIN_ROUNDOVER_CT_WIN:
		{
			gMainData[Main_RoundOverCTWin] = any:get_param_byref(arg_2);
		}
		case RZ_MAIN_AWARD_NOTICE:
		{
			gMainData[Main_AwardNotice] = any:get_param_byref(arg_2);
		}
		case RZ_MAIN_CHAT_PREFIX:
		{
			get_string(arg_2, gMainData[Main_ChatPrefix], charsmax(gMainData[Main_ChatPrefix]));
		}
		case RZ_MAIN_PREPARE_TIME:
		{
			gMainData[Main_PrepareTime] = get_param_byref(arg_2);
		}
		case RZ_MAIN_ROUND_TIME:
		{
			gMainData[Main_RoundTime] = get_param_byref(arg_2);
		}
		case RZ_MAIN_WARMUP_TIME:
		{
			gMainData[Main_WarmupTime] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_ENABLED:
		{
			gMainData[Main_CreditsEnabled] = any:get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_JOIN_AMOUNT:
		{
			gMainData[Main_CreditsJoinAmount] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_PER_KILLED:
		{
			gMainData[Main_AwardPer_Killed] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_PER_INFECT:
		{
			gMainData[Main_AwardPer_Infect] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_TEAM_WIN:
		{
			gMainData[Main_Award_Team_Win] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_TEAM_LOSER:
		{
			gMainData[Main_Award_Team_Loser] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_TEAM_DRAW:
		{
			gMainData[Main_Award_Team_Draw] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_PER_DAMAGE:
		{
			gMainData[Main_AwardPer_Damage] = get_param_byref(arg_2);
		}
		case RZ_MAIN_CREDITS_NEED_DAMAGE:
		{
			gMainData[Main_AwardNeed_Damage] = get_float_byref(arg_2);
		}
		default:
		{
			rz_log(true, "Config property '%d' not found", prop);
			return false;
		}
	}

	return true;
}

@native_main_lighting_global_get(plugin, argc)
{
	return (g_sGlobalLightingTemp[0] ? g_sGlobalLightingTemp[0] : gMainData[Main_GlobalLighting][0]);
}

@native_main_lighting_global_set(plugin, argc)
{
	enum { arg_lighting = 1 };

	get_string(arg_lighting, g_sGlobalLightingTemp, charsmax(g_sGlobalLightingTemp));

	//rz_nightvision_player_update();
	return true;
}

@native_main_lighting_global_reset(plugin, argc)
{
	g_sGlobalLightingTemp[0] = EOS;

	//rz_nightvision_player_update();
	return true;
}

@native_main_lighting_nvg_get(plugin, argc)
{
	return (g_sNVGLightingTemp[0] ? g_sNVGLightingTemp[0] : gMainData[Main_NvgLighting][0]);
}

@native_main_lighting_nvg_set(plugin, argc)
{
	enum { arg_lighting = 1 };

	get_string(arg_lighting, g_sNVGLightingTemp, charsmax(g_sNVGLightingTemp));

	//rz_nightvision_player_update();
	return true;
}

@native_main_lighting_nvg_reset(plugin, argc)
{
	g_sNVGLightingTemp[0] = EOS;

	//rz_nightvision_player_update();
	return true;
}

@native_module_create(plugin, argc)
{
	enum { arg_name = 1, arg_array_handle };

	new data[ModuleData];

	get_string(arg_name, data[Module_Name], charsmax(data[Module_Name]));
	data[Module_Handle] = Array:get_param(arg_array_handle);

	if (ArrayFindString(g_aModules, data[Module_Name]) != -1)
	{
		rz_sys_error("Module '%s' already defined", data[Module_Name]);
		return 0;
	}

	data[Module_Offset] = (ArraySize(g_aModules) + 1) * 1000;

	return ArrayPushArray(g_aModules, data);
}

@native_module_get_valid_index(plugin, argc)
{
	enum { arg_module = 1, arg_index };

	new module = get_param(arg_module);
	new index = get_param(arg_index);
	
	new data[ModuleData];
	ArrayGetArray(g_aModules, module, data);

	index -= data[Module_Offset];

	if (index < 0 || index >= ArraySize(data[Module_Handle]))
		return -1;

	return index;
}

@native_module_get_offset(plugin, argc)
{
	enum { arg_module = 1 };

	new module = get_param(arg_module);

	// safecheck
	
	new data[ModuleData];
	ArrayGetArray(g_aModules, module, data);

	return data[Module_Offset];
}

@native_module_find(plugin, argc)
{
	enum { arg_name = 1 };

	new data[ModuleData];
	get_string(arg_name, data[Module_Name], charsmax(data[Module_Name]));

	new index = ArrayFindString(g_aModules, data[Module_Name]);

	if (index == -1)
	{
		log_error(AMX_ERR_NATIVE, "Invalid module name (%s)", index, data[Module_Name]);
		return -1;
	}

	ArrayGetArray(g_aModules, index, data);

	return data[Module_Offset];
}
