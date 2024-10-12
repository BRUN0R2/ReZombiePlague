#if defined _api_smoke_wallpuff_included
	#endinput
#endif
#define _api_smoke_wallpuff_included

#pragma reqlib api_smoke_wallpuff
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib api_smoke_wallpuff
#endif

// I did it in the simplest way possible :D

/**
 * Create Smoke Wall Puff.
 *
 * @param pVecEnd   Final position of the smoke effect
 * @param pPlane    Direction vector for the smoke movement
 * @param pColor    Color of the smoke puff
 * @param pScale    Size of the smoke puff
 */
native create_smoke_wallpuff(
    const Float:pVecEnd[3],
    const Float:pPlane[3],
    const Float:pColor[3] = {60.0, 60.0, 60.0}, 
    const Float:pScale = 0.5
);