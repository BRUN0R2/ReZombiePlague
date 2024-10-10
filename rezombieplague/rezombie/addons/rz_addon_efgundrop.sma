#include <amxmodx>
#include <reapi>
#include <fakemeta>
#include <xs>

#define PLUGIN  "[REAPI] Drop effect"
#define VERSION "1.0"
#define AUTHOR  "BRUN0"

new const EFFECT_MODEL[] = "models/rezombie/dropeffect.mdl"

new gl_pMaxEntities
new gl_pClassName

const ENTITY_INTOLERANCE = 100

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	precache_model(EFFECT_MODEL)
	gl_pMaxEntities = global_get(glb_maxEntities)
	gl_pClassName = engfunc(EngFunc_AllocString, "info_target")
}

public plugin_init() {
	RegisterHookChain(RG_CWeaponBox_SetModel, "@CWeaponBox_SetModel_Pre", .post = false)
}

@CWeaponBox_SetModel_Pre(const pEntity) {
	if (is_nullent(pEntity))
		return

	@Create_weapon_effect(pEntity)
}

@Create_weapon_effect(const pEntity)
{
	if (gl_pMaxEntities - engfunc(EngFunc_NumberOfEntities) <= ENTITY_INTOLERANCE)
		return

	new pEffect = engfunc(EngFunc_CreateNamedEntity, gl_pClassName)

	if (is_nullent(pEffect))
		return

	set_entvar(pEffect, var_classname, "effect_drop")
	set_entvar(pEffect, var_owner, pEntity)
	set_entvar(pEffect, var_framerate, 1.0)
	set_entvar(pEffect, var_animtime, get_gametime())
	set_entvar(pEffect, var_movetype, MOVETYPE_FOLLOW)
	set_entvar(pEffect, var_aiment, pEntity)

	engfunc(EngFunc_SetModel, pEffect, EFFECT_MODEL)
	SetThink(pEffect, "@Think_weapon_effect")
	set_entvar(pEffect, var_nextthink, get_gametime())
}

@Think_weapon_effect(const pEffect) {
	if (is_nullent(pEffect))
		return
	if (is_nullent(get_entvar(pEffect, var_owner))) {
		rg_remove_entity(pEffect)
		return
	}
	set_entvar(pEffect, var_nextthink, get_gametime())
}