#include <amxmodx>
#include <rezp_inc/rezp_main>

#define PLUGIN "[API] Player Fog"
#define VERSION "1.0.0"
#define AUTHOR "BRUN0"

enum _:PlayerFogData
{
	PlayerFog_Handle[RZ_MAX_HANDLE_LENGTH],
	PlayerFog_Color[3],
	Float:PlayerFog_distance,
}; new pPlayerFogData[PlayerFogData]

new gl_pMessageFog,
	Array:
	gl_pPlayerFog,
	gl_pModule;

public plugin_precache() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	gl_pMessageFog = get_user_msgid("Fog")

	gl_pPlayerFog = ArrayCreate(PlayerFogData, 0);
	gl_pModule = rz_module_create("player_fog", gl_pPlayerFog)
}

public plugin_init() {
	register_message(gl_pMessageFog, "@Message_Fog")
}

@Message_Fog(iMsgId, iMsgDest, ePlayer) {
	return PLUGIN_HANDLED
}

public plugin_natives()
{
	register_library("api_player_fog")

	register_native("rz_player_fog_create", "@native_player_fog_create")

	register_native("rz_player_fog_get", "@native_player_fog_get")
	register_native("rz_player_fog_set", "@native_player_fog_set")

	register_native("rz_player_fog_find", "@native_player_fog_find")
	register_native("rz_player_fog_reset", "@native_player_fog_reset")
}

@native_player_fog_create(plugin, argc)
{
	enum { arg_handle = 1 }

	new data[PlayerFogData]

	get_string(arg_handle, data[PlayerFog_Handle], charsmax(data[PlayerFog_Handle]))

	data[PlayerFog_distance] = 1200.0

	new pFogColor[3]

	pFogColor[0] = clamp(100, 0, 255)
	pFogColor[1] = clamp(100, 0, 255)
	pFogColor[2] = clamp(100, 0, 255)

	data[PlayerFog_Color] = pFogColor
	
	return ArrayPushArray(gl_pPlayerFog, data) + rz_module_get_offset(gl_pModule)
}

@native_player_fog_get(plugin, argc)
{
	enum { arg_player_fog = 1, arg_prop, arg_3, arg_4 }

	new pFog = get_param(arg_player_fog)
	new index = rz_module_get_valid_index(gl_pModule, pFog)

	RZ_CHECK_MODULE_VALID_INDEX(index, false)
	
	ArrayGetArray(gl_pPlayerFog, index, pPlayerFogData)

	new prop = get_param(arg_prop)

	switch (prop)
	{
		case RZ_PLAYER_FOG_HANDLE:
		{
			set_string(arg_3, pPlayerFogData[PlayerFog_Handle], get_param_byref(arg_4))
		}
		case RZ_PLAYER_FOG_COLOR:
		{
			set_array(arg_3, pPlayerFogData[PlayerFog_Color], sizeof(pPlayerFogData[PlayerFog_Color]))
		}
		case RZ_PLAYER_FOG_DISTANCE:
		{
			return any:pPlayerFogData[PlayerFog_distance]
		}
		default:
		{
			rz_log(true, "Player fog property '%d' not found for '%s'", prop, pPlayerFogData[PlayerFog_Handle])
			return false
		}
	}

	return true
}

@native_player_fog_set(plugin, argc)
{
	enum { arg_player_fog = 1, arg_prop, arg_3 }

	new pFog = get_param(arg_player_fog)
	new index = rz_module_get_valid_index(gl_pModule, pFog)

	RZ_CHECK_MODULE_VALID_INDEX(index, false)
	
	ArrayGetArray(gl_pPlayerFog, index, pPlayerFogData)

	new prop = get_param(arg_prop)

	switch (prop)
	{
		case RZ_PLAYER_FOG_HANDLE:
		{
			get_string(arg_3, pPlayerFogData[PlayerFog_Handle], charsmax(pPlayerFogData[PlayerFog_Handle]))
		}
		case RZ_PLAYER_FOG_COLOR:
		{
			get_array(arg_3, pPlayerFogData[PlayerFog_Color], sizeof(pPlayerFogData[PlayerFog_Color]))
		}
		case RZ_PLAYER_FOG_DISTANCE:
		{
			pPlayerFogData[PlayerFog_distance] = get_float_byref(arg_3)
		}
		default:
		{
			rz_log(true, "Player fog property '%d' not found for '%s'", prop, pPlayerFogData[PlayerFog_Handle])
			return false
		}
	}

	ArraySetArray(gl_pPlayerFog, index, pPlayerFogData)
	return true
}

@native_player_fog_find(plugin, argc)
{
	enum { arg_handle = 1 }

	new handle[RZ_MAX_HANDLE_LENGTH]
	get_string(arg_handle, handle, charsmax(handle))

	new i = ArrayFindString(gl_pPlayerFog, handle)

	if (i != -1) {
		return i + rz_module_get_offset(gl_pModule)
	}

	return 0
}

@native_player_fog_reset(iPluginId, iArgc) {
	enum { 
		arg_pPlayer = 1,
	};

	new pPlayer = get_param(arg_pPlayer)

	if (!is_user_connected(pPlayer))
	{
		log_error(AMX_ERR_NATIVE, "[Api Player Fog] Invalid Player (%d)", pPlayer)
		return false
	}

	rz_util_send_player_fog(pPlayer, {0,0,0}, -1.0)
	return true
}