#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iClass_Sniper;
new g_iWeapon_SniperAWP;

public plugin_precache()
{
	register_plugin("[ReZP] Class: Sniper", REZP_VERSION_STR, "fl0wer");

	new class = g_iClass_Sniper = rz_class_create("class_sniper", TEAM_CT);
	new props = rz_class_get(class, RZ_CLASS_PROPS);
	new model = rz_class_get(class, RZ_CLASS_MODEL);
	new nightVision = rz_class_get(class, RZ_CLASS_NIGHTVISION);

	rz_class_set(class, RZ_CLASS_NAME, "RZ_SNIPER");
	rz_class_set(class, RZ_CLASS_HUD_COLOR, { 0, 180, 225 });

	rz_class_set(class, RZ_CLASS_FOG_COLOR, { 10, 20, 10 });
	rz_class_set(class, RZ_CLASS_FOG_DISTANCE, 800.0);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_BASE_HEALTH, 50.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 0.75);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_NO_IMPACT, false);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_INTERACT, false);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_CANDROP, false);

	rz_playermodel_add(model, "gign", .defaultHitboxes = false);
	rz_playermodel_add(model, "leet", .defaultHitboxes = false);

	rz_nightvision_set(nightVision, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_COLOR, { 25, 255, 70 });
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_ALPHA, 180);
}

public plugin_init()
{
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Post", true);
	
	g_iWeapon_SniperAWP = rz_weapons_find("weapon_sniperawp");
}

public rz_class_change_post(id, attacker, class, bool:preSpawn) {
	if (class != g_iClass_Sniper || !is_user_alive(id))
		return;
	rz_longjump_player_give(id, true, 560.0, 300.0, 2.0);
	rz_nightvision_player_change(id, rz_player_get(id, RZ_PLAYER_NIGHTVISION), true);
}

@CBasePlayer_GiveDefaultItems_Post(id)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Sniper)
		return;

	if (g_iWeapon_SniperAWP)
	{
		new reference[RZ_MAX_REFERENCE_LENGTH];
		get_weapon_var(g_iWeapon_SniperAWP, RZ_WEAPON_REFERENCE, reference, charsmax(reference));

		new item = rg_give_custom_item(id, reference, GT_APPEND, g_iWeapon_SniperAWP);

		if (!is_nullent(item))
		{
			new WeaponIdType:weaponId = get_member(item, m_iId);

			set_member(id, m_rgAmmo, rg_get_weapon_info(weaponId, WI_MAX_ROUNDS), rg_get_weapon_info(weaponId, WI_AMMO_TYPE));
		}
	}
}
