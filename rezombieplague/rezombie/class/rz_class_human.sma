#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iClass_Human;

public plugin_precache()
{
	register_plugin("[ReZP] Class: Human", REZP_VERSION_STR, "fl0wer");

	new class = g_iClass_Human = rz_class_create("class_human", TEAM_CT);
	new model = rz_class_get(class, RZ_CLASS_MODEL);

	rz_class_set(class, RZ_CLASS_NAME, "RZ_HUMAN");
	rz_class_set(class, RZ_CLASS_HUD_COLOR, { 0, 180, 225 });

	rz_playermodel_add(model, "urban", .defaultHitboxes = false);
	rz_playermodel_add(model, "gsg9", .defaultHitboxes = false);
	rz_playermodel_add(model, "sas", .defaultHitboxes = false);
	rz_playermodel_add(model, "gign", .defaultHitboxes = false);
}

public plugin_init() {
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "@CBasePlayer_GiveDefaultItems_Post", true);
}

@CBasePlayer_GiveDefaultItems_Post(id)
{
	if (rz_player_get(id, RZ_PLAYER_CLASS) != g_iClass_Human)
		return;

	rg_give_item(id, "weapon_usp");
	set_member(id, m_rgAmmo, 24, rg_get_weapon_info(WEAPON_USP, WI_AMMO_TYPE));
}
