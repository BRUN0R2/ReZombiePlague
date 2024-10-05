#if defined _api_player_camera_included
	#endinput
#endif
#define _api_player_camera_included

#include <rezp_inc/api/api_player_camera_const>

#pragma reqlib api_player_camera
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib api_player_camera
#endif

/**
 * Sets a player camera.
 *
 * @param target	Player index
 */
native create_player_camera(const target);

/**
 * Destroy a player camera.
 *
 * @param target	Player index
 */
native breaks_player_camera(const target);

/**
 * Set camera mode.
 *
 * @param target	Player index
 * @param type		Camera mode: normal, right, front and last! Located in: api_player_camera_const
 */
native set_camera_mode(const target, const CameraType:type);

/**
 * Get camera mode.
 *
 * @param target	Player index
 * @return			Camera type
 */
native get_camera_mode(const target);

/**
 * Set camera Distance.
 *
 * @param target	Player index
 * @param distance	Camera distance
 */
native set_camera_distance(const target, const Float:distance = 90.0);

/**
 * Get camera Distance.
 *
 * @param target	Player index
 * @return			Camera distance
 */
native Float:get_camera_distance(const target);

/**
 * Set camera have.
 *
 * @param target	Player index
 * @param have		Camera have
 */
native set_camera_have(const target, const bool:have = true);

/**
 * Get camera have.
 *
 * @param target	Player index
 * @return			Have true or false
 */
native get_camera_have(const target);