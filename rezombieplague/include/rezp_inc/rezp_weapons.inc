#if defined _rezp_weapons_included
	#endinput
#endif

#define _rezp_weapons_included

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
	RZ_WEAPON_HANDLE, // [RZ_MAX_HANDLE_LENGTH]
	RZ_WEAPON_REFERENCE, // [RZ_MAX_REFERENCE_LENGTH]
	RZ_WEAPON_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_WEAPON_SHORT_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_WEAPON_VIEW_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_PLAYER_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_WORLD_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_WEAPONLIST, // [RZ_MAX_RESOURCE_PATH]
	RZ_WEAPON_BASE_DAMAGE, // Float
	RZ_WEAPON_BASE_DAMAGE2, // Float
	RZ_WEAPON_KNOCKBACK_POWER, // Float
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
native any:rz_weapon_get(weapon, RZWeaponProp:prop, any:...);

/**
 * Sets a weapon's property.
 *
 * @param weapon	Weapon index
 * @param prop		Weapon property. See RZWeaponProp enum
 *
 * @return			true on success, 0 otherwise
 */
native rz_weapon_set(weapon, RZWeaponProp:prop, any:...);

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

native any:rz_knife_get(knife, RZKnifeProp:prop, any:...);

native rz_knife_set(knife, RZKnifeProp:prop, any:...);

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
	RZ_GRENADE_HANDLE, // [RZ_MAX_HANDLE_LENGTH]
	RZ_GRENADE_REFERENCE, // [RZ_MAX_REFERENCE_LENGTH]
	RZ_GRENADE_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_GRENADE_SHORT_NAME, // [RZ_MAX_LANGKEY_LENGTH]
	RZ_GRENADE_VIEW_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_PLAYER_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_WORLD_MODEL, // [RZ_MAX_RESOURCE_PATH]
	RZ_GRENADE_WEAPONLIST, // [RZ_MAX_RESOURCE_PATH]
};

native rz_grenade_create(const handle[], const reference[]);

native any:rz_grenade_get(grenade, RZGrenadeProp:prop, any:...);

native rz_grenade_set(grenade, RZGrenadeProp:prop, any:...);

native rz_grenades_start();

native rz_grenades_find(const handle[]);

native rz_grenades_size();

native rz_grenades_valid(grenade);

/**
 * Sets a fire property.
 *
 * @param id		Player index
 * @param attacker	Player Attacker index
 * @param time		The time the player will stay on fire
 */
native rz_grenade_set_user_fire(const id, const attacker, Float:time = 1.0);

/**
 * Sets a icer property.
 *
 * @param id		Player index
 * @param attacker	Player Attacker index
 * @param time		The time the player will stay on frozen
 */
native rz_grenade_set_user_icer(const id, const attacker, Float:time = 1.0);

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
 * Find weapons by name
 */
stock bool:rz_find_weapon_by_classname(const this, const classname[]) {
	for (new InventorySlotType:iSlot = PRIMARY_WEAPON_SLOT, pItem; iSlot <= C4_SLOT; iSlot++) {
		pItem = get_member(this, m_rgpPlayerItems, iSlot);

		while (!is_nullent(pItem))
		{
			if (FClassnameIs(pItem, classname))
				return true;
	
			pItem = get_member(pItem, m_pNext);
		}
	}

	return false;
}