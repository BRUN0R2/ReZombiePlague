#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/api/api_player_camera_const>
#pragma compress 1

#define PLUGIN  "[API] Camera"
#define VERSION "1.0"
#define AUTHOR  "BRUN0"

new gl_pMaxEntities
new gl_pModelIndex
new gl_pCameraMode
new gl_pClassName

enum _:PlayerVars
{
	CAM_ENT,
	CAM_LAST,
	bool:CAM_HAVE,
	Float:CAM_DIST,
};

new pVars[MAX_PLAYERS+1][PlayerVars];

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	gl_pMaxEntities = global_get(glb_maxEntities)
	gl_pModelIndex = precache_model("models/rpgrocket.mdl")

	gl_pClassName = engfunc(EngFunc_AllocString, "info_target")
}

public plugin_init()
{
	register_message(get_user_msgid("SetFOV"), "@Message_Set_User_Camera_Fov")
	RegisterHookChain(RG_CBasePlayer_Spawn, "@CBasePlayer_Spawn_Post", .post = true)
}

public plugin_natives()
{
	register_library("api_player_camera")

	register_native("create_player_camera", "@native_create_player_camera")
	register_native("breaks_player_camera", "@native_breaks_player_camera")

	register_native("set_camera_mode", "@native_set_camera_mode")
	register_native("get_camera_mode", "@native_get_camera_mode")

	register_native("set_camera_distance", "@native_set_camera_distance")
	register_native("get_camera_distance", "@native_get_camera_distance")

	register_native("set_camera_have", "@native_set_camera_have")
	register_native("get_camera_have", "@native_get_camera_have")
}

public client_putinserver(pPlayer) {
	pVars[pPlayer][CAM_ENT] = NULLENT
	pVars[pPlayer][CAM_HAVE] = false
	pVars[pPlayer][CAM_DIST] = 0.0
}

@CBasePlayer_Spawn_Post(const pPlayer) {
	if (!is_user_alive(pPlayer))
		return

	if (!pVars[pPlayer][CAM_HAVE]) {
		return
	}

	@Create_Player_Camera(pPlayer)
}

@Create_Player_Camera(const pPlayer)
{
	if (gl_pMaxEntities - engfunc(EngFunc_NumberOfEntities) <= ENTITY_INTOLERANCE)
		return NULLENT

	@Check_PlayerCam_Entity(pPlayer)

	if (is_nullent(pVars[pPlayer][CAM_LAST])) {
		pVars[pPlayer][CAM_LAST] = CAMERA_NORMAL
	}

	gl_pCameraMode = pVars[pPlayer][CAM_LAST]

	if ((pVars[pPlayer][CAM_ENT] = engfunc(EngFunc_CreateNamedEntity, gl_pClassName)))
	{
		if (is_nullent(pVars[pPlayer][CAM_ENT]))
			return NULLENT

		set_entvar(pVars[pPlayer][CAM_ENT], var_classname, "ent_cam2")
		set_entvar(pVars[pPlayer][CAM_ENT], var_modelindex, gl_pModelIndex)

		set_entvar(pVars[pPlayer][CAM_ENT], var_owner, pPlayer)
		set_entvar(pVars[pPlayer][CAM_ENT], var_solid, SOLID_NOT)
		set_entvar(pVars[pPlayer][CAM_ENT], var_movetype, MOVETYPE_FLY)

		set_entvar(pPlayer, var_camera_mode, gl_pCameraMode)

		set_entvar(pVars[pPlayer][CAM_ENT], var_rendermode, kRenderTransTexture)

		engset_view(pPlayer, pVars[pPlayer][CAM_ENT])

		pVars[pPlayer][CAM_HAVE] = true

		SetThink(pVars[pPlayer][CAM_ENT], "@Player_Camera_Think")

		set_entvar(pVars[pPlayer][CAM_ENT], var_nextthink, get_gametime())
	}

	return pVars[pPlayer][CAM_ENT]
}

@Player_Camera_Think(const pCamera)
{
	if (is_nullent(pCamera)) {
		SetThink(pCamera, NULL_STRING)
		return
	}

	static pOwner; pOwner = get_entvar(pCamera, var_owner)
	if (!is_user_alive(pOwner))
	{
		@Check_PlayerCam_Entity(pOwner)
		return
	}

	static Float:cOrigin[3], Float:vback[3], Float:vright[3]
	static Float:pOrigin[3]; get_entvar(pOwner, var_origin, pOrigin)
	static Float:vangles[3]; get_entvar(pOwner, var_view_ofs, vangles)

	pOrigin[2] += vangles[2];

	switch (CameraType:get_entvar(pOwner, var_camera_mode))
	{
		case CAMERA_NORMAL:
		{
			get_entvar(pOwner, var_v_angle, vangles)
			angle_vector(vangles, ANGLEVECTOR_FORWARD, vback)
	
			cOrigin[0] = pOrigin[0] + (-vback[0] * pVars[pOwner][CAM_DIST])
			cOrigin[1] = pOrigin[1] + (-vback[1] * pVars[pOwner][CAM_DIST])
			cOrigin[2] = pOrigin[2] + (-vback[2] * pVars[pOwner][CAM_DIST])

		}
		case CAMERA_RIGHT:
		{
			get_entvar(pOwner, var_v_angle, vangles)
			angle_vector(vangles, ANGLEVECTOR_FORWARD, vback)
			angle_vector(vangles, ANGLEVECTOR_RIGHT, vright)

			cOrigin[0] = pOrigin[0] + (-vback[0] * 45.0) + (vright[0] * 24.0)
			cOrigin[1] = pOrigin[1] + (-vback[1] * 45.0) + (vright[1] * 24.0)
			cOrigin[2] = pOrigin[2] + (-vback[2] * 45.0) + (vright[2] * 24.0)
		}
		case CAMERA_FRONT:
		{
			get_entvar(pOwner, var_v_angle, vangles)
			vangles[1] += vangles[1] > 180.0 ? -180.0 : 180.0

			angle_vector(vangles, ANGLEVECTOR_FORWARD, vback)
				
			cOrigin[0] = pOrigin[0] + (-vback[0] * pVars[pOwner][CAM_DIST])
			cOrigin[1] = pOrigin[1] + (-vback[1] * pVars[pOwner][CAM_DIST])
			cOrigin[2] = pOrigin[2] + (-vback[2] * pVars[pOwner][CAM_DIST])
		}
	}

	engfunc(EngFunc_TraceLine, pOrigin, cOrigin, IGNORE_MONSTERS, pOwner, 0)
	static Float:flFraction; get_tr2(0, TR_flFraction, flFraction)

	if (flFraction != 1.0)
	{
		flFraction *= pVars[pOwner][CAM_DIST]
	
		cOrigin[0] = pOrigin[0] + (-vback[0] * flFraction)
		cOrigin[1] = pOrigin[1] + (-vback[1] * flFraction)
		cOrigin[2] = pOrigin[2] + (-vback[2] * flFraction)
	}

	engfunc(EngFunc_SetOrigin, pCamera, cOrigin)
	set_entvar(pCamera, var_angles, vangles)
	set_entvar(pCamera, var_nextthink, get_gametime() + 0.001)
}

@Message_Set_User_Camera_Fov(const iMsgID, const iMsgDest, const pPlayer)
{
	if (is_nullent(pVars[pPlayer][CAM_ENT]))
		return

	if (!is_user_alive(pPlayer))
		return

	switch (PlayerZoom:get_msg_arg_int(1))
	{
		case ZOOM_LARGE_AWP, ZOOM_WEAPON_OTHER, ZOOM_WEAPON_SMALL: engset_view(pPlayer, pPlayer)
		case ZOOM_WEAPON_NO: engset_view(pPlayer, pVars[pPlayer][CAM_ENT])
	}
}

@native_create_player_camera(plugin_id, num_params) {
	enum { ArgpTarget = 1 }

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	if (!is_nullent(pVars[pTarget][CAM_ENT])) {
		return false
	}

	@Create_Player_Camera(pTarget)
	return true
}

@native_breaks_player_camera(plugin_id, num_params) {
	enum { ArgpTarget = 1 }

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	engset_view(pTarget, pTarget)
	@Check_PlayerCam_Entity(pTarget)
	
	return true
}

@native_set_camera_mode(plugin_id, num_params) {
	enum { ArgpTarget = 1, ArgpMode = 2 }

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	pVars[pTarget][CAM_LAST] = get_param(ArgpMode)
	@Player_Set_Camera_Mode(pTarget, CameraType:pVars[pTarget][CAM_LAST])
	return true
}

@native_get_camera_mode(plugin_id, num_params) {
	enum { ArgpTarget = 1 }

	new pTarget = get_param(ArgpTarget)

	if (!is_user_alive(pTarget)) {
		return false
	}

	return any:pVars[pTarget][CAM_LAST]
}

@native_set_camera_distance(plugin_id, num_params) {
	enum { ArgpTarget = 1, ArgpDistance = 2 }

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	pVars[pTarget][CAM_DIST] = floatclamp(
		get_param_f(ArgpDistance),
		MINIMUN_DISTANCE,
		MAXIMUM_DISTANCE
	)

	return true
}

@native_get_camera_distance(plugin_id, num_params) {
	enum { ArgpTarget = 1 }

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	return any:pVars[pTarget][CAM_DIST]
}

@native_set_camera_have(plugin_id, num_params)
{
	enum { ArgpTarget = 1, ArgpCamHave = 2 }

	new pTarget = get_param(ArgpTarget)
	new pCamHave = get_param(ArgpCamHave)

	if (!is_user_connected(pTarget)) {
		return false
	}

	pVars[pTarget][CAM_HAVE] = any:pCamHave
	return true
}

@native_get_camera_have(plugin_id, num_params)
{
	enum { ArgpTarget = 1 }

	new pTarget = get_param(ArgpTarget)

	if (!is_user_connected(pTarget)) {
		return false
	}

	return bool:pVars[pTarget][CAM_HAVE]
}

@Player_Set_Camera_Mode(const pTarget, CameraType:cameraMode) {
	if (cameraMode == CameraType:pVars[pTarget][CAM_LAST]) {
		if (pVars[pTarget][CAM_LAST]) {
			gl_pCameraMode = pVars[pTarget][CAM_LAST]
		} else {
			gl_pCameraMode = CAMERA_NORMAL
		}
	} else {
		pVars[pTarget][CAM_LAST] = gl_pCameraMode
		gl_pCameraMode = _:cameraMode
	}

	set_entvar(pTarget, var_camera_mode, gl_pCameraMode)
	return true
}

@Check_PlayerCam_Entity(const id)
{
	if (pVars[id][CAM_ENT] && !is_nullent(pVars[id][CAM_ENT]))
	{
		SetThink(pVars[id][CAM_ENT], NULL_STRING)
		rg_remove_entity(pVars[id][CAM_ENT])
		pVars[id][CAM_ENT] = NULLENT
	}
}