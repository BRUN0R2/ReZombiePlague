#if defined _api_muzzleflash_included
	#endinput
#endif
#define _api_muzzleflash_included

#pragma reqlib api_muzzleflash
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib api_muzzleflash
#endif
// I did it in the simplest way possible :D
/**
 * Create muzzleflash.
 *
 * @param target	Player index
 */
native create_muzzleflash(
    const target,
    const Float:life = 0.1,
    const attachment = 1,
    const Float:color[3] = {255.0, 255.0, 255.0},
    const Float:renderamt = 255.0,
    const Float:scale = 0.1,
    const model[]
);

/**
 * Destroy muzzleflash.
 *
 * @param target	Player index
 */
native breaks_muzzleflash(const target);