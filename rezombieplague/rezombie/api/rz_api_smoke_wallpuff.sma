#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <reapi>

#define PLUGIN  "[API] Smoke WallPuff"
#define VERSION "1.0"
#define AUTHOR  "BRUN0"

new const SPRITES[][] =
{
	"sprites/wall_puff1.spr",
	"sprites/wall_puff2.spr",
	"sprites/wall_puff3.spr",
	"sprites/wall_puff4.spr",
};

new gl_pMaxEntities
new gl_pAllocString

const ENTITY_INTOLERANCE = 100

public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	gl_pMaxEntities = global_get(glb_maxEntities)
	gl_pAllocString = engfunc(EngFunc_AllocString, "env_sprite")

	for (new IND = 0; IND < sizeof(SPRITES); IND++) { 
		precache_model(SPRITES[IND])
	}
}

public plugin_natives()
{
	register_library("api_smoke_wallpuff")
	register_native("create_smoke_wallpuff", "@native_create_smoke_wallpuff")
}

@native_create_smoke_wallpuff(plugin_id, num_params)
{
	enum {
		ArgpVecEnd = 1,
		ArgpPlane,
		ArgpColor,
		ArgpScale,
	};

	new Float:pVecEnd[3];get_array_f(ArgpVecEnd,pVecEnd,3)
	new Float:pPlane[3]; get_array_f(ArgpPlane, pPlane, 3)
	new Float:pColor[3]; get_array_f(ArgpColor, pColor, 3)

	Create_Smoke_WallPuff(
		.pVecEnd = pVecEnd, 
		.pPlane = pPlane, 
		.pColor = pColor,
		.pScale = get_param_f(ArgpScale)
	)
}

stock Create_Smoke_WallPuff(const Float:pVecEnd[3], const Float:pPlane[3], const Float:pColor[3] = {60.0, 60.0, 60.0}, const Float:pScale = 0.5) {
	if (gl_pMaxEntities - engfunc(EngFunc_NumberOfEntities) <= ENTITY_INTOLERANCE) {
		return NULLENT
	}

	static pEntity; pEntity = engfunc(EngFunc_CreateNamedEntity, gl_pAllocString)
	if (is_nullent(pEntity))
		return NULLENT

	static Float:pGameTime; pGameTime = get_gametime()
	static Float:pEndPosition[3], Float:pDirectory[3]

	xs_vec_add_scaled(pVecEnd, pPlane, 3.0, pEndPosition)
	xs_vec_mul_scalar(pPlane, random_float(25.0, 30.0), pDirectory)

	set_entvar(pEntity, var_classname, "ent_smokepuff")

	set_entvar(pEntity, var_movetype, MOVETYPE_NOCLIP)
	set_entvar(pEntity, var_spawnflags, SF_SPRITE_ONCE)

	set_entvar(pEntity, var_framerate, 30.0)

	set_entvar(pEntity, var_rendermode, kRenderTransAdd)
	set_entvar(pEntity, var_rendercolor, pColor)
	set_entvar(pEntity, var_renderamt, random_float(150.0, 200.0))
	set_entvar(pEntity, var_scale, pScale)

	set_entvar(pEntity, var_velocity, pDirectory)
	set_entvar(pEntity, var_origin, pEndPosition)

	set_entvar(pEntity, var_pitch_speed, pGameTime)
	set_entvar(pEntity, var_nextthink, pGameTime)

	new pSpriteIndex = random_num(0, sizeof(SPRITES) - 1)
	engfunc(EngFunc_SetModel, pEntity, SPRITES[pSpriteIndex])

	SetThink(pEntity, "@Smoke_WallPuff_think")

	return pEntity
}

@Smoke_WallPuff_think(const pEntity)
{
    if (is_nullent(pEntity)) {
        SetThink(pEntity, NULL_STRING)
        return
    }

    static Float:pGameTime; pGameTime = get_gametime()
    static Float:pFrame; pFrame = get_entvar(pEntity, var_frame)
    static Float:pFrameRate; pFrameRate = get_entvar(pEntity, var_framerate)
    static Float:pLastTime; pLastTime = get_entvar(pEntity, var_pitch_speed)

    pFrame += pFrameRate * (pGameTime - pLastTime)
    set_entvar(pEntity, var_frame, pFrame)

    if (pFrame >= pFrameRate) {
        SetThink(pEntity, NULL_STRING)
        rg_remove_entity(pEntity)
        return
    }

    static Float:pVelocity[3]
    get_entvar(pEntity, var_velocity, pVelocity)

    if (pFrame > 7.0) {
        xs_vec_mul_scalar(pVelocity, 0.97, pVelocity)
        pVelocity[2] = floatmin(pVelocity[2] + 0.7, 70.0)
    }

    if (pFrame > 6.0) {
        static Float:magnitude[2]
        static bool:direction[2] = { true, true }

        for (new i = 0; i < 2; i++) {
            magnitude[i] = floatmin(magnitude[i] + 0.075, 5.0)
            pVelocity[i] += direction[i] ? magnitude[i] : -magnitude[i]

            if (!random(10) && magnitude[i] > 3.0) {
                magnitude[i] = 0.0
                direction[i] = !direction[i]
            }
        }
    }

    set_entvar(pEntity, var_velocity, pVelocity)
    set_entvar(pEntity, var_pitch_speed, pGameTime)
    set_entvar(pEntity, var_nextthink, pGameTime + 0.05)
}