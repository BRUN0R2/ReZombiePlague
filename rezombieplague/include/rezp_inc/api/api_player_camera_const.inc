#if defined _api_player_camera_const_included
	#endinput
#endif
#define _api_player_camera_const_included

const ENTITY_INTOLERANCE = 100;
const MAX_CAMERA_LENGH = 32;

const Float:MINIMUN_DISTANCE = 60.0;
const Float:MAXIMUM_DISTANCE = 250.0;

#define var_camera_mode var_gamestate

enum _:PlayerZoom
{
	ZOOM_LARGE_AWP		= 10,
	ZOOM_WEAPON_OTHER	= 15,
	ZOOM_WEAPON_SMALL	= 40,
	ZOOM_WEAPON_NO		= 90,
};

enum _:CameraType
{
	CAMERA_NORMAL = 0,
	CAMERA_RIGHT,
	CAMERA_FRONT,
};