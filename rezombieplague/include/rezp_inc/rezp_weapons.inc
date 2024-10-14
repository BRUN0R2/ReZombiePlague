#if defined _rezp_weapons_included
	#endinput
#endif

#define _rezp_weapons_included

#define var_weapon_handle var_noise

/**
 * Default weapon properties.
 */
enum RZDefaultWeaponProp
{
	RZ_DEFAULT_WEAPON_HANDLE, // [RZ_MAX_HANDLE_LENGTH]
	RZ_DEFAULT_WEAPON_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_DEFAULT_WEAPON_SHORT_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_DEFAULT_WEAPON_KNOCKBACK_POWER, // Float
};

native any:rz_weapon_default_get(WeaponIdType:weaponId, RZDefaultWeaponProp:prop, any:...);

native rz_weapon_default_set(WeaponIdType:weaponId, RZDefaultWeaponProp:prop, any:...);

native rz_weapons_default_find(const hanlde[]);

/**
 * Weapon properties.
 */
enum RZWeaponProp
{
	RZ_WEAPON_HANDLE,				// [RZ_MAX_HANDLE_LENGTH]
	RZ_WEAPON_REFERENCE,			// [RZ_MAX_REFERENCE_LENGTH]
	RZ_WEAPON_NAME,					// [RZ_MAX_LANGKEY_LENGTH]
	RZ_WEAPON_SHORT_NAME,			// [RZ_MAX_LANGKEY_LENGTH]
	RZ_WEAPON_VIEW_MODEL,			// [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_PLAYER_MODEL,			// [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_WORLD_MODEL,			// [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_WEAPONLIST,			// [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_BASE_DAMAGE1,			// Float
	RZ_WEAPON_BASE_DAMAGE2,			// Float
	RZ_WEAPON_GENERIC_DAMAGE,		// Float
	RZ_WEAPON_HEAD_DAMAGE,			// Float
	RZ_WEAPON_CHEST_DAMAGE,			// Float
	RZ_WEAPON_STOMACH_DAMAGE,		// Float
	RZ_WEAPON_ARMS_DAMAGE,			// Float
	RZ_WEAPON_LEGS_DAMAGE,			// Float
	RZ_WEAPON_KNOCKBACK_POWER,		// Float
	RZ_WEAPON_BEAM_CYLINDER,		// Bool
	RZ_WEAPON_BEAM_POINTER,			// Bool
	RZ_WEAPON_BEAM_CYLINDER_COLOR,	// [4]
	RZ_WEAPON_BEAM_POINTER_COLOR,	// [4]
};

/**
 * Creates a custom weapon.
 *
 * @param handle	Name to handle
 * @param reference	Weapon classname such as "weapon_*"
 *
 * @return			Weapon index
 * @error			If an invalid reference is provided an error will be thrown.
 */
native rz_weapon_create(const handle[], const reference[]);

/**
 * Returns a weapon's property.
 *
 * @param weapon	Weapon index
 * @param prop		Weapon property. See RZWeaponProp enum
 *
 * @return          Value or array passed via the 3rd argument and more
 */
native any:get_weapon_var(weapon, RZWeaponProp:prop, any:...);

/**
 * Sets a weapon's property.
 *
 * @param weapon	Weapon index
 * @param prop		Weapon property. See RZWeaponProp enum
 *
 * @return			true on success, 0 otherwise
 */
native set_weapon_var(weapon, RZWeaponProp:prop, any:...);

native rz_weapons_start();

/**
 * Searches through the array and returns the index of the first occurrence.
 *
 * @param handle		Handle name to search for
 *
 * @return			Weapon index on success, 0 if the handle can't be found
 */
native rz_weapons_find(const handle[]);

native rz_weapons_size();

native rz_weapons_valid(weapon);


/**
 * Knife properties.
 */
enum RZKnifeProp
{
	RZ_KNIFE_HANDLE, // [RZ_MAX_HANDLE_LENGTH]
	RZ_KNIFE_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_KNIFE_SHORT_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_KNIFE_VIEW_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_PLAYER_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_WEAPONLIST, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_STAB_BASE_DAMAGE, // Float
	RZ_KNIFE_SWING_BASE_DAMAGE, // Float
	RZ_KNIFE_STAB_DISTANCE, // Float
	RZ_KNIFE_SWING_DISTANCE, // Float
	RZ_KNIFE_KNOCKBACK_POWER, // Float
	RZ_KNIFE_SOUNDS_BANK, // [RZ_MAX_KNIFE_SOUNDS], Array
};

enum RZKnifeSound
{
	RZ_KNIFE_SOUND_NONE = -1,
	RZ_KNIFE_SOUND_DEPLOY, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_SOUND_HIT, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_SOUND_SLASH, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_SOUND_STAB, // [RZ_MAX_RESOURCE_PATH]
	RZ_KNIFE_SOUND_HITWALL, // [RZ_MAX_RESOURCE_PATH]
	RZ_MAX_KNIFE_SOUNDS,
};

native rz_knife_create(const handle[]);

native any:get_knife_var(knife, RZKnifeProp:prop, any:...);

native set_knife_var(knife, RZKnifeProp:prop, any:...);

native rz_knife_sound_add(knife, RZKnifeSound:knifeSound, const sample[]);

native rz_knifes_start();

native rz_knifes_find(const handle[]);

native rz_knifes_size();

native rz_knifes_valid(knife);

/**
 * Grenade properties.
 */
enum RZGrenadeProp
{
	RZ_GRENADE_HANDLE,			// [RZ_MAX_HANDLE_LENGTH]
	RZ_GRENADE_REFERENCE,		// [RZ_MAX_REFERENCE_LENGTH]
	RZ_GRENADE_NAME,			// [RZ_MAX_LANGKEY_LENGTH]
	RZ_GRENADE_SHORT_NAME,		// [RZ_MAX_LANGKEY_LENGTH]
	RZ_GRENADE_VIEW_MODEL,		// [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_PLAYER_MODEL,	// [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_WORLD_MODEL,		// [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_WEAPONLIST,		// [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_DISTANCE_EFFECT,	// Float
	RZ_GRENADE_PLAYERS_DAMAGE,	// Float
};

native rz_grenade_create(const handle[], const reference[]);

native any:get_grenade_var(grenade, RZGrenadeProp:prop, any:...);

native set_grenade_var(grenade, RZGrenadeProp:prop, any:...);

native rz_grenades_start();

native rz_grenades_find(const handle[]);

native rz_grenades_size();

native rz_grenades_valid(grenade);

/**
 * Sets a fire property.
 *
 * @param target	Player index
 * @param attacker	Player Attacker index
 * @param duration	The time the player will stay on fire
 * @param damage	Flame damage
 */
native rz_grenade_set_user_fire(const target, const attacker, Float:duration = 0.0, Float:damage = 1.0);

/**
 * Sets a icer property.
 *
 * @param target	Player index
 * @param attacker	Player Attacker index
 * @param duration	The time the player will stay on frozen
 * @param damage	Freeze damage
 */
native rz_grenade_set_user_icer(const target, const attacker, Float:duration = 0.0, Float:damage = 1.0);

/**
 * Called before a player throws a grenade.
 *
 * @param id			Player index
 * @param entity		Grenade entity index
 * @param grenade		Grenade index
 */
forward rz_grenades_throw_pre(id, entity, grenade);

/**
 * Called after a player throws a grenade.
 *
 * @param id			Player index
 * @param entity		Grenade entity index
 * @param grenade		Grenade index
 */
forward rz_grenades_throw_post(id, entity, grenade);

/**
 * Called before a grenade explodes.
 *
 * Possible return values are:
 *	- RZ_CONTINUE (default behavior)
 *	- RZ_SUPERCEDE (block explosion)
 *	- RZ_BREAK (block explosion, sets FL_KILLME flag to id)
 *
 * @param id		Grenade entity index
 * @param grenade	Grenade index
 */
forward rz_grenades_explode_pre(id, grenade);

/**
 * Called after a grenade explodes.
 *
 * @param id		Grenade entity index
 * @param grenade	Grenade index
 */
forward rz_grenades_explode_post(id, grenade);

/**
 * Checks if the weapon is valid
 */
stock bool:rz_is_weapon_valid(pWeapon, impulse = 0) {
	if (is_nullent(pWeapon)) return false;
	if (get_entvar(pWeapon, var_impulse) == impulse) return true;
	return false;
}

/**
 * Find weapons by Handler
 */
stock bool:rz_find_weapon_by_handler(const id, const handler[]) {
    for (new InventorySlotType:iSlot = PRIMARY_WEAPON_SLOT, pItem; iSlot <= C4_SLOT; iSlot++) {
        pItem = get_member(id, m_rgpPlayerItems, iSlot);

        while (!is_nullent(pItem)) {
            new pHandler[RZ_MAX_HANDLE_LENGTH];
            get_entvar(pItem, var_weapon_handle, pHandler, charsmax(pHandler));

            if (equali(pHandler, handler)) {
                return true;
            }

            pItem = get_member(pItem, m_pNext);
        }
    }

    return false;
}

stock rz_send_weapon_animation(const pWeapon, const pPlayer, const pAnim = 0)
{
	new pBody = get_entvar(pWeapon, var_body);
	set_entvar(pPlayer, var_weaponanim, pAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, {0,0,0}, pPlayer);
	write_byte(pAnim);
	write_byte(pBody);
	message_end();

	for (new pObserver = 1; pObserver <= MaxClients; pObserver++)
	{
		if (pObserver == pPlayer || !is_user_connected(pObserver) || is_user_alive(pObserver) || is_nullent(pObserver) 
	 	|| get_entvar(pObserver, var_iuser1) != OBS_IN_EYE || get_entvar(pObserver, var_iuser2) != pPlayer)
			continue;

		set_entvar(pObserver, var_weaponanim, pAnim);

		message_begin(MSG_ONE, SVC_WEAPONANIM, {0,0,0}, pObserver);
		write_byte(pAnim);
		write_byte(pBody);
		message_end();
	}
}

stock Float:playerVelocityLength2d(const player) {
	new Float:velocity[3]
	get_entvar(player, var_velocity, velocity)
	velocity[2] = 0.0
	return vector_length(velocity)
}

stock getAimingAngle(const player, Float:aimingAngle[3]) {
	new Float:viewAngle[3]
	new Float:punchAngle[3]
	get_entvar(player, var_v_angle, viewAngle)
	get_entvar(player, var_punchangle, punchAngle)
	for (new i = 0; i < sizeof(viewAngle); ++i) {
		aimingAngle[i] = viewAngle[i] + punchAngle[i]
	}
}

stock getGunPositionAndAiming(const player, Float:src[3], Float:aiming[3]) {
	new Float:viewAngle[3]
	getAimingAngle(player, viewAngle)
	engfunc(EngFunc_MakeVectors, viewAngle)
	ExecuteHamB(Ham_Player_GetGunPosition, player, src)
	global_get(glb_v_forward, aiming)
}