#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iClass_Survivor;

public plugin_precache()
{
	register_plugin("[ReZP] Class: Survivor", REZP_VERSION_STR, "fl0wer");

	new class = g_iClass_Survivor = rz_class_create("class_survivor", TEAM_CT);
	new props = rz_class_get(class, RZ_CLASS_PROPS);
	new model = rz_class_get(class, RZ_CLASS_MODEL);
	new nightVision = rz_class_get(class, RZ_CLASS_NIGHTVISION);
	new knife = rz_knife_create("knife_survivor");

	rz_class_set(class, RZ_CLASS_NAME, "RZ_SURVIVOR");
	rz_class_set(class, RZ_CLASS_HUD_COLOR, { 0, 180, 225 });
	rz_class_set(class, RZ_CLASS_KNIFE, knife);

	rz_class_set(class, RZ_CLASS_FOG_COLOR, { 10, 10, 20 });
	rz_class_set(class, RZ_CLASS_FOG_DISTANCE, 800.0);

	rz_playerprops_set(props, RZ_PLAYER_PROPS_BASE_HEALTH, 200.0);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_GRAVITY, 1.25);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_NO_IMPACT, false);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_INTERACT, false);
	rz_playerprops_set(props, RZ_PLAYER_PROPS_WEAPON_CANDROP, false);

	rz_playermodel_add(model, "leet", .defaultHitboxes = false);

	rz_nightvision_set(nightVision, RZ_NIGHTVISION_EQUIP, RZ_NVG_EQUIP_APPEND_AND_ENABLE);
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_COLOR, { 25, 70, 255 });
	rz_nightvision_set(nightVision, RZ_NIGHTVISION_ALPHA, 180);
	
	//rz_knife_set(knife, RZ_KNIFE_DAMAGE_MULTI, 2.0);
}

public plugin_init()
{
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Post", true);
}

public rz_class_change_post(id, attacker, class, bool:preSpawn) {
	if (class != g_iClass_Survivor || !is_user_alive(id))
		return;
	rz_longjump_player_give(id, true, 560.0, 300.0, 2.0);
	rz_nightvision_player_change(id, rz_player_get(id, RZ_PLAYER_NIGHTVISION), true);
}

@CBasePlayer_GiveDefaultItems_Post(id)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Survivor)
		return;

	new item = rg_give_item(id, "weapon_m249", GT_APPEND);

	if (!is_nullent(item))
	{
		new WeaponIdType:weaponId = get_member(item, m_iId);

		set_member(id, m_rgAmmo, rg_get_weapon_info(weaponId, WI_MAX_ROUNDS), rg_get_weapon_info(weaponId, WI_AMMO_TYPE));
	}
}
