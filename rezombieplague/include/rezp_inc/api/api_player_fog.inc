#if defined _api_player_fog_included
	#endinput
#endif
#define _api_player_fog_included

#pragma reqlib api_player_fog
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib api_player_fog
#endif

enum RZPlayerFogProp
{
	RZ_PLAYER_FOG_HANDLE,		// [RZ_MAX_HANDLE_LENGTH]
	RZ_PLAYER_FOG_COLOR,		// [3]
	RZ_PLAYER_FOG_DISTANCE,		// Float
};

native any:rz_player_fog_get(id, RZPlayerFogProp:prop, any:...);
native rz_player_fog_set(id, RZPlayerFogProp:prop, any:...);
native rz_player_fog_reset(id);