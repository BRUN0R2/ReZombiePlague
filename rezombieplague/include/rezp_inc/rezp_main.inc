#if defined _rezp_included
	#endinput
#endif

#define _rezp_included

#define rz_is_null_string(%0) bool:(%0[0] == EOS)

/**
 * Constants.
 */
const RZ_MAX_COLOR_LENGTH = 3;
const RZ_MAX_HANDLE_LENGTH = 64;
const RZ_MAX_LANGKEY_LENGTH = 64;
const RZ_MAX_REFERENCE_LENGTH = 64;
const RZ_MAX_PLAYER_MODEL_LENGTH = 64;
const RZ_MAX_RESOURCE_PATH = 64;
const WEAPON_DATA_MAX_LENGTH = 256;

#include <rezp_inc/rezp_trie>
#include <rezp_inc/rezp_gamemodes>
#include <rezp_inc/rezp_weapons>
#include <rezp_inc/rezp_items>
#include <rezp_inc/rezp_player>
#include <rezp_inc/rezp_util>
#include <rezp_inc/rezp_version>

/**
 * Forward return types.
 */
enum
{
	RZ_CONTINUE,
	RZ_SUPERCEDE,
	RZ_BREAK,
};

enum RZMainProp
{
	RZ_MAIN_GAME_DESC,				// [64]
	RZ_MAIN_SKY_NAME,				// [32]
	RZ_MAIN_GLOBAL_LIGHTING,		// [2]
	RZ_MAIN_NVG_LIGHTING,			// [2]
	RZ_MAIN_ROUNDOVER_CT_WIN,		// bool
	RZ_MAIN_AWARD_NOTICE,			// bool
	RZ_MAIN_CHAT_PREFIX,			// [32]
	RZ_MAIN_PREPARE_TIME,			// cell
	RZ_MAIN_ROUND_TIME,				// cell
	RZ_MAIN_WARMUP_TIME,			// cell
	RZ_MAIN_CREDITS_ENABLED,		// bool
	RZ_MAIN_CREDITS_JOIN_AMOUNT,	// cell
	RZ_MAIN_CREDITS_PER_KILLED,		// cell
	RZ_MAIN_CREDITS_PER_INFECT,		// cell
	RZ_MAIN_CREDITS_TEAM_WIN,		// cell
	RZ_MAIN_CREDITS_TEAM_LOSER,		// cell
	RZ_MAIN_CREDITS_TEAM_DRAW,		// cell
	RZ_MAIN_CREDITS_PER_DAMAGE,		// cell
	RZ_MAIN_CREDITS_NEED_DAMAGE,	// float
};

/**
 * Retrieves the path to the MOD configs directory.
 *
 * @param buffer Buffer to copy path to.
 * @param len Maximum buffer size.
 *
 * @noreturn
 */
native rz_get_configsdir(buffer[], len);

// The old method will be removed and we will only use the new one
native rz_load_langs(const name[]);
native rz_add_translate(const name[]);

native rz_print(text[], any:...);
native rz_log(bool:isError, text[], any:...);
native rz_sys_error(const error[], any:...);

native rz_print_chat(id, sender = print_team_grey, text[], any:...);

native any:rz_main_get(RZMainProp:prop, any:...);
native rz_main_set(RZMainProp:prop, any:...);

native rz_main_lighting_global_get();
native rz_main_lighting_global_set(const character[]);
native rz_main_lighting_global_reset();
native rz_main_lighting_nvg_get();
native rz_main_lighting_nvg_set(const character[]);
native rz_main_lighting_nvg_reset();

native rz_module_create(const name[], Array:handle);
native rz_module_get_offset(module);
native rz_module_get_valid_index(module, index);
native rz_module_find(const name[]);

native bool:rz_game_is_warmup();
native rz_game_get_playersnum(TeamName:team);
native rz_game_get_alivesnum();
native rz_game_get_random_player();

forward rz_fire_grenade_burn_pre(id);
forward rz_fire_grenade_burn_post(id);

forward rz_frost_grenade_freeze_pre(id);
forward rz_frost_grenade_freeze_post(id);

native rz_multi_mother_player_get(id);

native rz_longjump_player_get(id);
native rz_longjump_player_give(id, bool:enabled = true, Float:force = 560.0, Float:height = 300.0, Float:cooldown = 0.0);

#define RZ_CHECK_MOD_EXISTS(%0,%1) \
	(%0 = (%0 = rz_gamemodes_find(%1)) != 0 ? %0 : set_fail_state("Mod '%s' not found", %1))

#define RZ_CHECK_CLASS_EXISTS(%0,%1) \
	(%0 = (%0 = rz_class_find(%1)) != 0 ? %0 : set_fail_state("Class '%s' not found", %1))

#define RZ_CHECK_WEAPON_EXISTS(%0,%1) \
	(%0 = (%0 = rz_weapons_find(%1)) != 0 ? %0 : set_fail_state("Weapon '%s' not found", %1))

#define RZ_CHECK_NATIVE_ARGS_NUM(%0,%1,%2) \
	if (%0 < %1) { \
		log_error(AMX_ERR_NATIVE, "Invalid num of arguments %d. Expected %d", %0, %1); \
		return %2; \
	}

#define RZ_CHECK_CONNECTED(%0,%1) \
	if (!is_user_connected(%0)) \
	{ \
		log_error(AMX_ERR_NATIVE, "Player %d is not connected", %0); \
		return %1; \
	}

#define RZ_CHECK_ALIVE(%0,%1) \
	if (!is_user_alive(%0)) \
	{ \
		log_error(AMX_ERR_NATIVE, "Player %d is not alive", %0); \
		return %1; \
	}

#define RZ_CHECK_PLAYABLE_TEAM(%0,%1) \
	if (%0 != TEAM_TERRORIST && %0 != TEAM_CT) \
	{ \
		log_error(AMX_ERR_NATIVE, "Invalid playable team (%d)", %0); \
		return %1; \
	}

#define RZ_CHECK_MODULE_VALID_INDEX(%0,%1) \
	if (%0 == -1) \
	{ \
		log_error(AMX_ERR_NATIVE, "Invalid index (%d)", %0); \
		return %1; \
	}

/**
 * This is the callback from the main plugin that gives major/minor versions
 * for verifying compatibility for ReZombiePlague versions.
 * If an AMXX plugin gets a failure, then you do need to upgrade to the latest
 * version of the ReZP plugins or update the files included for AMXX plugins.
 * Do not modify this!
 */
public __rezp_version_check(const majorVersion[], const minorVersion[])
{
	if (strcmp(majorVersion, REZP_VERSION_MAJOR) != 0)
	{
		set_fail_state("[ReZP]: Api major version mismatch; expected %s, real %s",
			REZP_VERSION_MAJOR, majorVersion);
		return;
	}

	if (strcmp(minorVersion, REZP_VERSION_MINOR) != 0)
	{
		set_fail_state("[ReZP]: Api minor version mismatch; expected at least %s, real %s",
			REZP_VERSION_MINOR, minorVersion);
		return;
	}
}