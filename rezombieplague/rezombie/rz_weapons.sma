#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <rezp_inc/rezp_main>
#include <rezp_inc/util_messages>

new gl_iLaserSprite;
new gl_iShockSprite;

public plugin_precache()
{
	register_plugin("[ReZP] Weapons", REZP_VERSION_STR, "fl0wer");

	rz_trie_create();

	gl_iLaserSprite = precache_model("sprites/dot.spr");
	gl_iShockSprite = precache_model("sprites/shockwave.spr");
}

public plugin_init()
{
	RegisterHookChain(RG_CBasePlayer_AddPlayerItem, "@CBasePlayer_AddPlayerItem_Post", true);
	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "@CBasePlayerWeapon_DefaultDeploy_Pre", false);
	RegisterHookChain(RG_CWeaponBox_SetModel, "@CWeaponBox_SetModel_Pre", false);

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "@CBasePlayer_TakeDamage_Pre", .post = false);
	RegisterHookChain(RG_IsPenetrableEntity, "@RG_IsPenetrableEntity_Post", .post = true);

	new weaponName[RZ_MAX_REFERENCE_LENGTH];

	for (new i = 1; i < MAX_WEAPONS - 1; i++)
	{
		if ((1<<i) & ((1<<CSW_GLOCK) | (1<<CSW_C4)))
			continue;

		rg_get_weapon_info(WeaponIdType:i, WI_NAME, weaponName, charsmax(weaponName));

		RegisterHam(Ham_Spawn, weaponName, "@CBasePlayerWeapon_Spawn_Post", true);
	}

	rz_load_langs("weapons");
}

public plugin_end() {
	rz_trie_destroy();
}

@SV_StartSound_Pre(recipients, entity, channel, sample[], volume, Float:attenuation, flags, pitch)	
{
	if (sample[8] != 'k' || sample[9] != 'n' || sample[10] != 'i')
		return;

	if (!is_user_connected(entity))
		return;

	new activeItem = get_member(entity, m_pActiveItem);

	if (is_nullent(activeItem))
		return;

	new impulse = get_entvar(activeItem, var_impulse);

	if (rz_knifes_valid(impulse))
	{
		new RZKnifeSound:knifeSound = RZ_KNIFE_SOUND_NONE;

		if (sample[14] == 'd' && sample[15] == 'e' && sample[16] == 'p')
		{
			knifeSound = RZ_KNIFE_SOUND_DEPLOY;
		}
		else if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a')
		{
			knifeSound = RZ_KNIFE_SOUND_SLASH;
		}
		else if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't')
		{
			knifeSound = (sample[17] == 'w') ? RZ_KNIFE_SOUND_HITWALL : RZ_KNIFE_SOUND_HIT;
		}
		else if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')
		{
			knifeSound = RZ_KNIFE_SOUND_STAB;
		}

		if (knifeSound != RZ_KNIFE_SOUND_NONE)
		{
			new Array:sounds = rz_knife_get(impulse, RZ_KNIFE_SOUNDS_BANK, knifeSound);
			new soundsNum = ArraySize(sounds);

			if (soundsNum)
			{
				new sound[RZ_MAX_RESOURCE_PATH];
				ArrayGetString(sounds, random_num(0, soundsNum - 1), sound, charsmax(sound));

				SetHookChainArg(4, ATYPE_STRING, sound);
			}
		}
	}
}

@CBasePlayer_AddPlayerItem_Post(id, item)
{
	if (!GetHookChainReturn(ATYPE_INTEGER))
		return;

	new impulse = get_entvar(item, var_impulse);
	new name[RZ_MAX_RESOURCE_PATH];

	if (impulse)
	{
		switch (get_member(item, m_iId))
		{
			case WEAPON_KNIFE:
			{
				if (rz_knifes_valid(impulse)) {
					rz_knife_get(impulse, RZ_KNIFE_WEAPONLIST, name, charsmax(name));
				}
			}
			case WEAPON_HEGRENADE, WEAPON_FLASHBANG, WEAPON_SMOKEGRENADE:
			{
				if (rz_grenades_valid(impulse)) {
					rz_grenade_get(impulse, RZ_GRENADE_WEAPONLIST, name, charsmax(name));
				}
			}
			default:
			{
				if (rz_weapons_valid(impulse)) {
					rz_weapon_get(impulse, RZ_WEAPON_WEAPONLIST, name, charsmax(name));
				}
			}
		}
	}

	if (!name[0])
		rg_get_iteminfo(item, ItemInfo_pszName, name, charsmax(name));

	message_begin(MSG_ONE, gmsgWeaponList, _, id);
	SendWeaponList
	(
		name,
		get_member(item, m_Weapon_iPrimaryAmmoType),
		rg_get_iteminfo(item, ItemInfo_iMaxAmmo1),
		get_member(item, m_Weapon_iSecondaryAmmoType),
		rg_get_iteminfo(item, ItemInfo_iMaxAmmo2),
		rg_get_iteminfo(item, ItemInfo_iSlot),
		rg_get_iteminfo(item, ItemInfo_iPosition),
		rg_get_iteminfo(item, ItemInfo_iId),
		rg_get_iteminfo(item, ItemInfo_iFlags)
	);
}

@CBasePlayerWeapon_DefaultDeploy_Pre(id, viewModel[], weaponModel[], anim, animExt[], skiplocal)
{
	new impulse = get_entvar(id, var_impulse);

	if (!impulse)
		return;

	new newViewModel[RZ_MAX_RESOURCE_PATH];
	new newPlayerModel[RZ_MAX_RESOURCE_PATH];

	switch (get_member(id, m_iId))
	{
		case WEAPON_KNIFE:
		{
			if (rz_knifes_valid(impulse))
			{
				rz_knife_get(impulse, RZ_KNIFE_VIEW_MODEL, newViewModel, charsmax(newViewModel));
				rz_knife_get(impulse, RZ_KNIFE_PLAYER_MODEL, newPlayerModel, charsmax(newPlayerModel));
			}
			else
				return;
		}
		case WEAPON_HEGRENADE, WEAPON_FLASHBANG, WEAPON_SMOKEGRENADE:
		{
			if (rz_grenades_valid(impulse))
			{
				rz_grenade_get(impulse, RZ_GRENADE_VIEW_MODEL, newViewModel, charsmax(newViewModel));
				rz_grenade_get(impulse, RZ_GRENADE_PLAYER_MODEL, newPlayerModel, charsmax(newPlayerModel));
			}
			else
				return;
		}
		default:
		{
			if (rz_weapons_valid(impulse))
			{
				rz_weapon_get(impulse, RZ_WEAPON_VIEW_MODEL, newViewModel, charsmax(newViewModel));
				rz_weapon_get(impulse, RZ_WEAPON_PLAYER_MODEL, newPlayerModel, charsmax(newPlayerModel));
			}
			else
				return;
		}
	}

	if (newViewModel[0])
		SetHookChainArg(2, ATYPE_STRING, newViewModel);

	if (equal(newPlayerModel, "hide"))
		SetHookChainArg(3, ATYPE_STRING, "");
	else if (newPlayerModel[0])
		SetHookChainArg(3, ATYPE_STRING, newPlayerModel);
}

@CWeaponBox_SetModel_Pre(id, model[])
{
	new item;
	new impulse;
	new worldModel[RZ_MAX_RESOURCE_PATH];

	for (new InventorySlotType:i = PRIMARY_WEAPON_SLOT; i <= PISTOL_SLOT; i++)
	{
		item = get_member(id, m_WeaponBox_rgpPlayerItems, i);

		if (is_nullent(item))
			continue;

		impulse = get_entvar(item, var_impulse);

		if (!impulse)
			continue;

		if (rz_weapons_valid(impulse))
		{
			rz_weapon_get(impulse, RZ_WEAPON_WORLD_MODEL, worldModel, charsmax(worldModel));

			if (worldModel[0])
				SetHookChainArg(2, ATYPE_STRING, worldModel);

			break;
		}
	}
}

@CBasePlayerWeapon_Spawn_Post(const pWeapon)
{
	new impulse = get_entvar(pWeapon, var_impulse);

	if (!impulse)
		return;

	new WeaponIdType:weaponId = get_member(pWeapon, m_iId);

	new handle[RZ_MAX_HANDLE_LENGTH];

	switch (weaponId)
	{
		case WEAPON_KNIFE:
		{
			if (rz_knifes_valid(impulse))
			{
				SetMemberByProp(pWeapon, m_Knife_flStabBaseDamage, rz_knife_get(impulse, RZ_KNIFE_STAB_BASE_DAMAGE));
				SetMemberByProp(pWeapon, m_Knife_flSwingBaseDamage, rz_knife_get(impulse, RZ_KNIFE_SWING_BASE_DAMAGE));
				SetMemberByProp(pWeapon, m_Knife_flStabDistance, rz_knife_get(impulse, RZ_KNIFE_STAB_DISTANCE));
				SetMemberByProp(pWeapon, m_Knife_flSwingDistance, rz_knife_get(impulse, RZ_KNIFE_SWING_DISTANCE));
			}

			rz_knife_get(impulse, RZ_KNIFE_HANDLE, handle, charsmax(handle));
			set_entvar(pWeapon, var_classname, handle);
		}
		case WEAPON_HEGRENADE, WEAPON_FLASHBANG, WEAPON_SMOKEGRENADE:
		{
			if (rz_grenades_valid(impulse))
			{
				rz_grenade_get(impulse, RZ_GRENADE_HANDLE, handle, charsmax(handle));
				set_entvar(pWeapon, var_classname, handle);
			}
		}
		default:
		{
			if (rz_weapons_valid(impulse))
			{
				SetMemberByProp(pWeapon, m_Weapon_flBaseDamage, rz_weapon_get(impulse, RZ_WEAPON_BASE_DAMAGE1));

				switch (weaponId)
				{
					case WEAPON_FAMAS: SetMemberByProp(pWeapon, m_Famas_flBaseDamageBurst, rz_weapon_get(impulse, RZ_WEAPON_BASE_DAMAGE2));
					case WEAPON_USP: SetMemberByProp(pWeapon, m_USP_flBaseDamageSil, rz_weapon_get(impulse, RZ_WEAPON_BASE_DAMAGE2));
					case WEAPON_M4A1: SetMemberByProp(pWeapon, m_M4A1_flBaseDamageSil, rz_weapon_get(impulse, RZ_WEAPON_BASE_DAMAGE2));
				}

				rz_weapon_get(impulse, RZ_WEAPON_HANDLE, handle, charsmax(handle));
				set_entvar(pWeapon, var_classname, handle);
			}
		}
	}
}

@CBasePlayer_TakeDamage_Pre(const pVictim, const inflictor, const pAttacker, Float:pDamage, const bitsDamageType) {
	if (pDamage <= 0.0 || !(bitsDamageType & DMG_BULLET) || pVictim == pAttacker) {
		return HC_CONTINUE;
	}

	if (!is_user_connected(pAttacker) || !is_user_alive(pVictim)) {
        return HC_CONTINUE;
    }

	if (!rg_is_player_can_takedamage(pVictim, pAttacker)) {
		return HC_CONTINUE;
	}

	new pActiveItem = get_member(pAttacker, m_pActiveItem);
	if (is_nullent(pActiveItem)) {
		return HC_CONTINUE;
	}

	static impulse; impulse = get_entvar(pActiveItem, var_impulse);
	if (!impulse || !rz_weapons_valid(impulse)) {
		return HC_CONTINUE;
	}

	/*switch (get_member(pVictim, m_LastHitGroup))
	{
		case HITGROUP_GENERIC:	pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_GENERIC_DAMAGE);
		case HITGROUP_HEAD:		pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_HEAD_DAMAGE);
		case HITGROUP_CHEST:	pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_CHEST_DAMAGE);
		case HITGROUP_STOMACH:	pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_STOMACH_DAMAGE);
		case HITGROUP_LEFTARM,
		HITGROUP_RIGHTARM:		pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_ARMS_DAMAGE);
		case HITGROUP_LEFTLEG,
		HITGROUP_RIGHTLEG:		pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_LEGS_DAMAGE);

		default: pDamage = Float:rz_weapon_get(impulse, RZ_WEAPON_ARMS_DAMAGE);
	}

	SetHookChainArg(4, ATYPE_FLOAT, pDamage);*/

	if (bool:rz_weapon_get(impulse, RZ_WEAPON_BEAM_CYLINDER))
	{
		static Float:pVictimOrigin[3], Float:pVecAxis[3];
		get_entvar(pVictim, var_origin, pVictimOrigin);
		pVecAxis = pVictimOrigin;

		if (get_entvar(pVictim, var_flags) & FL_DUCKING)
			pVictimOrigin[2] -= 15.0;
		else 
			pVictimOrigin[2] -= 34.0;

		pVecAxis[2] += 200.0;

		static CylinderColor[4];
		rz_weapon_get(impulse, RZ_WEAPON_BEAM_CYLINDER_COLOR, CylinderColor);

		CylinderColor[0] = clamp(CylinderColor[0], 0, 255); // Red
		CylinderColor[1] = clamp(CylinderColor[1], 0, 255); // Green
		CylinderColor[2] = clamp(CylinderColor[2], 0, 255); // Blue
		CylinderColor[3] = clamp(CylinderColor[3], 0, 255); // Brightness

		// noiseAmplitude = random_num(0, 30) = min and max shock effect

		rz_util_te_beamcylinder(
			.position = pVictimOrigin,
			.axis = pVecAxis,
			.spriteIndex = gl_iShockSprite,
			.startingFrame = 0,
			.frameRate = 0,
			.life = 1,
			.lineWidth = 5,
			.noiseAmplitude = random_num(0, 30),
			.RGBA = CylinderColor,
			.scrollSpeed = 0
		);
	}

	return HC_CONTINUE;
}

@RG_IsPenetrableEntity_Post(const Float:vecSrc[3], Float:vecEnd[3], const pAttacker, const pHit) {
	if (!is_user_alive(pAttacker)) {
		return;
	}

	new pActiveItem = get_member(pAttacker, m_pActiveItem);
	if (is_nullent(pActiveItem)) {
		return;
	}
	static pImpulse; pImpulse = get_entvar(pActiveItem, var_impulse);
	if (!pImpulse || !rz_weapons_valid(pImpulse)) {
		return;
	}

	if (bool:rz_weapon_get(pImpulse, RZ_WEAPON_BEAM_POINTER))
	{
		static BeamPointerColor[4];

		rz_weapon_get(pImpulse, RZ_WEAPON_BEAM_POINTER_COLOR, BeamPointerColor);

		BeamPointerColor[0] = clamp(BeamPointerColor[0], 0, 255); // Red
		BeamPointerColor[1] = clamp(BeamPointerColor[1], 0, 255); // Green
		BeamPointerColor[2] = clamp(BeamPointerColor[2], 0, 255); // Blue
		BeamPointerColor[3] = clamp(BeamPointerColor[3], 0, 255); // Brightness

		// noiseAmplitude = random_num(0, 30) = min and max shock effect

		rz_util_te_beamentoint(
			.startEntity = pAttacker|0x1000, // The effect comes out of the gun barrel 0x1000
			.end = vecEnd,
			.spriteIndex = gl_iLaserSprite,
			.startingFrame = 0,
			.frameRate = 0,
			.life = 1,
			.lineWidth = 5,
			.noiseAmplitude = 0,
			.RGBA = BeamPointerColor,
			.scrollSpeed = 0
		);
	}
}

SetMemberByProp(id, any:member, Float:value)
{
	if (!value)
		return;

	set_member(id, member, value);
}
