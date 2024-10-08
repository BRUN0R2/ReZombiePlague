#include <amxmodx>
#include <fakemeta>
#include <reapi>

#define PLUGIN  "[API] MuzzleFlash"
#define VERSION "1.0"
#define AUTHOR  "BRUN0"

new gl_pMaxEntities
new gl_pClassName

const ENTITY_INTOLERANCE = 100

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	gl_pMaxEntities = global_get(glb_maxEntities)

	gl_pClassName = engfunc(EngFunc_AllocString, "env_sprite")
}

public plugin_natives()
{
	register_library("api_muzzleflash")

	register_native("create_muzzleflash", "@native_create_muzzleflash")
	register_native("destroy_muzzleflash", "@native_destroy_muzzleflash")
}

@native_create_muzzleflash(plugin_id, num_params)
{
	enum {
		ArgpTarget = 1,
		ArgpLife,
		ArgpAttachment,
		ArgpColor,
		ArgpRenderamt,
		ArgpScale,
		ArgpModel,
	};

	new pTarget = get_param(ArgpTarget)
	if (!is_user_alive(pTarget)) {
		return false
	}

	// Pega os parâmetros opcionais
	new Float:life = get_param_f(ArgpLife);
	new attachment = get_param(ArgpAttachment);

	new Float:color[3]
	get_array_f(ArgpColor, color, 3)

	new Float:renderamt = get_param_f(ArgpRenderamt)
	new Float:scale = get_param_f(ArgpScale)
	new pMuzzleModel[64]
	get_string(ArgpModel, pMuzzleModel, charsmax(pMuzzleModel))

	Create_weapon_muzzleflash(
		.pPlayer = pTarget, 
		.life = life, 
		.attachment = attachment, 
		.color = color, 
		.renderamt = renderamt, 
		.scale = scale,
		.model = pMuzzleModel
	)

	return true
}

@native_destroy_muzzleflash(plugin_id, num_params)
{

}

stock Create_weapon_muzzleflash(const pPlayer, const Float:life = 0.1, const attachment = 1, Float:color[3] = {255.0, 255.0, 255.0}, Float:renderamt = 255.0, Float:scale = 0.1, const model[]) {
	if (gl_pMaxEntities - engfunc(EngFunc_NumberOfEntities) <= ENTITY_INTOLERANCE) {
		return
	}

	new pEntity = engfunc(EngFunc_CreateNamedEntity, gl_pClassName)
	if (is_nullent(pEntity))
		return

	set_entvar(pEntity, var_classname, "ent_muzzleflash2")
	set_entvar(pEntity, var_owner, pPlayer)
	set_entvar(pEntity, var_pitch_speed, life)
	set_entvar(pEntity, var_iuser1, 0)
	set_entvar(pEntity, var_aiment, pPlayer)
	set_entvar(pEntity, var_body, attachment)
	set_entvar(pEntity, var_spawnflags, SF_SPRITE_ONCE)
	set_entvar(pEntity, var_rendermode, kRenderTransAdd)
	set_entvar(pEntity, var_rendercolor, color)
	set_entvar(pEntity, var_renderamt, renderamt)
	set_entvar(pEntity, var_scale, scale)

	set_entvar(pEntity, var_nextthink, get_gametime() + 0.1)

	engfunc(EngFunc_SetModel, pEntity, model)
	dllfunc(DLLFunc_Spawn, pEntity)

	SetThink(pEntity, "@Weapon_muzzleflash_think")
}

@Weapon_muzzleflash_think(const pEntity)
{
	if (is_nullent(pEntity)) return

	new Float:flFrame; get_entvar(pEntity, var_frame, flFrame)
	new Float:flNextThink; get_entvar(pEntity, var_pitch_speed, flNextThink)

	static Float:pGameTime; pGameTime = get_gametime()

	if (flFrame < get_ent_data_float(pEntity, "CSprite", "m_maxFrame"))
	{
		flFrame++
		set_entvar(pEntity, var_frame, flFrame)
		set_entvar(pEntity, var_nextthink, pGameTime + flNextThink)
		return
	}
	else if (get_entvar(pEntity, var_iuser1)) {
		flFrame = 0.0
		set_entvar(pEntity, var_frame, flFrame)
		set_entvar(pEntity, var_nextthink, pGameTime + flNextThink)
		return
	}

	rg_remove_entity(pEntity)
}

public bool:@Destroy_MuzzleFlash(const pPlayer)
{

}