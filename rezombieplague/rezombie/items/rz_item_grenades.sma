#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iItem_Infect;
new g_iItem_Fire;
new g_iItem_Frost;
new g_iItem_Flare;

new g_iGrenade_Infect;
new g_iGrenade_Fire;
new g_iGrenade_Frost;
new g_iGrenade_Flare;

new g_iClass_Zombie;
new g_iClass_Human;

new const AMMO_PICKUP_SOUND[] = "items/9mmclip1.wav";

public plugin_precache()
{
	register_plugin("[ReZP] Item: Grenades", REZP_VERSION_STR, "fl0wer");

	precache_sound(AMMO_PICKUP_SOUND);

	g_iGrenade_Infect = rz_grenades_find("grenade_infect");

	if (g_iGrenade_Infect)
	{
		new item = g_iItem_Infect = rz_item_create("zombie_infectgrenade");

		rz_item_set(item, RZ_ITEM_NAME, "RZ_ITEM_NADE_INFECTION");
		rz_item_set(item, RZ_ITEM_COST, 20);
	}

	g_iGrenade_Fire = rz_grenades_find("grenade_fire");

	if (g_iGrenade_Fire)
	{
		new item = g_iItem_Fire = rz_item_create("human_firegrenade");

		rz_item_set(item, RZ_ITEM_NAME, "RZ_ITEM_NADE_FIRE");
		rz_item_set(item, RZ_ITEM_COST, 6);
	}

	g_iGrenade_Frost = rz_grenades_find("grenade_frost");

	if (g_iGrenade_Frost)
	{
		new item = g_iItem_Frost = rz_item_create("human_frostgrenade");

		rz_item_set(item, RZ_ITEM_NAME, "RZ_ITEM_NADE_FROST");
		rz_item_set(item, RZ_ITEM_COST, 6);
	}

	g_iGrenade_Flare = rz_grenades_find("grenade_flare");

	if (g_iGrenade_Flare)
	{
		new item = g_iItem_Flare = rz_item_create("human_flaregrenade");

		rz_item_set(item, RZ_ITEM_NAME, "RZ_ITEM_NADE_FLARE");
		rz_item_set(item, RZ_ITEM_COST, 6);
	}
}

public plugin_init()
{
	g_iClass_Zombie = rz_class_find("class_zombie");
	g_iClass_Human = rz_class_find("class_human");
}

public rz_items_select_pre(id, item)
{
	if (item == g_iItem_Infect)
	{
		if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Zombie)
			return RZ_BREAK;
	}
	else if (item == g_iItem_Fire || item == g_iItem_Frost || item == g_iItem_Flare)
	{
		if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Human)
			return RZ_BREAK;
	}

	return RZ_CONTINUE;
}

public rz_items_select_post(id, item)
{
	new pGrenade;

	if (item == g_iItem_Infect) {
		pGrenade = g_iItem_Infect;
	}
	else if (item == g_iItem_Fire) {
		pGrenade = g_iGrenade_Fire;
	}
	else if (item == g_iItem_Frost) {
		pGrenade = g_iGrenade_Frost;
	}
	else if (item == g_iItem_Flare) {
		pGrenade = g_iGrenade_Flare;
	}
	else return;

	new reference[RZ_MAX_REFERENCE_LENGTH];
	get_grenade_var(pGrenade, RZ_GRENADE_REFERENCE, reference, charsmax(reference));

	if (!rg_has_item_by_name(id, reference)) {
		rg_give_custom_item(id, reference, GT_APPEND, pGrenade);
	}
	else
	{
		new WeaponIdType:gtype = rg_get_weapon_info(reference, WI_ID);
		rg_set_user_bpammo(id, gtype, rg_get_user_bpammo(id, gtype) + 1);
		rh_emit_sound2(id, 0, CHAN_ITEM, AMMO_PICKUP_SOUND, VOL_NORM, ATTN_NORM);
	}
}
