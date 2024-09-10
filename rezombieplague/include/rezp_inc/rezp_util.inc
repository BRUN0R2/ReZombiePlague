#if defined _rezp_util_included
	#endinput
#endif

#define _rezp_util_included

/**
 * You have to create len and text[] variables before call add_formatex.
 */
#define ADD_FORMATEX(%0)			len += formatex(text[len], charsmax(text) - len, %0)

#define MENU_CLOSER(%0)				(show_menu(%0, 0, "", 0))

#define FixedUnsigned16(%0,%1)		clamp(floatround(%0 * %1), 0, 0xFFFF)

#define FFADE_IN					0x0000 // Just here so we don't pass 0 into the function
#define FFADE_OUT					0x0001 // Fade out (not in)
#define FFADE_MODULATE				0x0002 // Modulate (don't blend)
#define FFADE_STAYOUT				0x0004 // ignores the duration, stays faded out until new ScreenFade message received

stock rz_util_set_rendering(id, mode = kRenderNormal, Float:amount = 0.0, Float:color[3] = NULL_VECTOR, fx = kRenderFxNone)
{
	set_entvar(id, var_rendermode, mode);
	set_entvar(id, var_renderamt, amount);
	set_entvar(id, var_rendercolor, color);
	set_entvar(id, var_renderfx, fx);
}

stock rz_util_send_lightstyle(id, index, const style[])
{
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id);
	write_byte(index);
	write_string(style);
	message_end();
}

stock rz_util_send_weaponanim(id, anim, body = 0)
{
	set_entvar(id, var_weaponanim, anim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, id);
	write_byte(anim);
	write_byte(body);
	message_end();
}

stock rz_util_send_screenfade(id, color[3], Float:fadeTime, Float:fadeHold = 0.0, alpha = 0, fadeFlags = 0)
{
	static pMsg;

	if (!pMsg) pMsg = get_user_msgid("ScreenFade");

	new duration = FixedUnsigned16(fadeTime, (1<<12));
	new holdTime = FixedUnsigned16(fadeHold, (1<<12));

	message_begin(MSG_ONE, pMsg, _, id);
	write_short(duration);
	write_short(holdTime);
	write_short(fadeFlags);
	write_byte(color[0]);
	write_byte(color[1]);
	write_byte(color[2]);
	write_byte(alpha);
	message_end();
}

// All stocks are from tempentities.inc and messages.inc
// I just did it to make things easier

stock rz_util_te_worlddecal(Float:position[3], textureIndex)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	write_coord_f(position[0]); // position.x
	write_coord_f(position[1]); // position.y
	write_coord_f(position[2]); // position.z
	write_byte(textureIndex); // texture index of precached decal texture name
	message_end();
}