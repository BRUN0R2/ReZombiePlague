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

stock bool:rz_util_is_steam(const id)
{
	static auth[64]; get_user_authid(id, auth, charsmax(auth))
	return (strfind(auth, "STEAM", true) != -1)
}

stock rz_util_send_screenfade(const id, color[3] = {255, 255, 255}, Float:fadeTime = 1.0, Float:fadeHold = 0.0, alpha = 0, fadeFlags = 0)
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

stock rz_util_send_player_fog(const id, color[3] = {255, 255, 255}, Float:pRange = 0.0)
{
	if (pRange >= 0.0)
	{
		new Float:flDensity = pRange < 0 ? 0.0 : (1.0 / pRange);

		message_begin(MSG_ONE, get_user_msgid("Fog"), {0, 0, 0}, id);
		write_byte(clamp(color[0], 0, 255));
		write_byte(clamp(color[1], 0, 255));
		write_byte(clamp(color[2], 0, 255));
		write_long(_:flDensity);
		message_end();
	} else {
		new Float:flDensity = 0.0;
		message_begin(MSG_ONE, get_user_msgid("Fog"), {0, 0, 0}, id);
		write_byte(color[0]);
		write_byte(color[1]);
		write_byte(color[2]);
		write_long(_:flDensity);
		message_end();
	}
}

stock rz_util_find_target(const pEntity, const pPlayer, const Float:pRange = 8162.0)
{
	new Float:closestDistance = pRange;
	new pClosestEnemy = NULLENT;

	for (new pTarget = 1; pTarget <= engfunc(EngFunc_NumberOfEntities); pTarget++)
	{
		if (get_entvar(pTarget, var_takedamage) == DAMAGE_NO)
			continue;

		if (!rz_util_entity_visible(pEntity, pTarget))
			continue;

		new Float:pDistance = rz_util_entity_range(pEntity, pTarget);

		if (!is_user_alive(pTarget))
			continue;

		if (!rz_util_valid_enemy(pTarget, pPlayer))
			continue;

		if (pDistance < closestDistance) {
			closestDistance = pDistance;
			pClosestEnemy = pTarget;
		}
	}

	return pClosestEnemy;
}

stock Float:rz_util_entity_range(const pEntityA, const pEntityB)
{
    static Float:originA[3]; rz_util_get_entity_center(pEntityA, originA);
    static Float:originB[3]; rz_util_get_entity_center(pEntityB, originB);
    static Float:delta[3]; xs_vec_sub(originA, originB, delta);

    return xs_vec_len(delta);
}
/**
 * Getting the center of the entities :)
 */
stock rz_util_get_entity_center(const this, Float:output[3])
{
    if (this >= 1 && this <= MaxClients) {
        get_entvar(this, var_origin, output);
    }
    else if (this > MaxClients && this <= 2265)
    {
        static Float:absmin[3]; get_entvar(this, var_absmin, absmin);
        static Float:absmax[3]; get_entvar(this, var_absmax, absmax);

        output[0] = (absmin[0] + absmax[0]) * 0.5;
        output[1] = (absmin[1] + absmax[1]) * 0.5;
        output[2] = (absmin[2] + absmax[2]) * 0.5;
    }
}

stock bool:rz_util_valid_enemy(const pTarget, const pPlayer)
{
	if (GetProtectionState(pTarget))
		return false

	if (rz_util_similar_team(pTarget, pPlayer))
		return false

	if (!rg_is_player_can_takedamage(pTarget, pPlayer))
		return false

	return true
}

stock bool:rz_util_similar_team(const pPlayer, const pTarget)
{
	if (get_member(pPlayer, m_iTeam) == get_member(pTarget, m_iTeam)) {
		return true;
	}

	return false;
}

// Function for linear interpolation between two values
stock Float:rz_util_floatlerp(Float:start, Float:end, Float:percent) {
	return start + (end - start) * percent
}

stock rz_util_entity_animation(const pEntity, const iSequence = 0, const Float:Frame = 0.0, const Float:FrameRate = 1.0)
{
	set_entvar(pEntity, var_frame, Frame);
	set_entvar(pEntity, var_framerate, FrameRate);
	set_entvar(pEntity, var_animtime, get_gametime());
	set_entvar(pEntity, var_sequence, iSequence);
}

stock rz_util_get_vector_aiming(const ePlayer, Float:vecAiming[3]) {
	static Float:vecViewAngle[3]; get_entvar(ePlayer, var_v_angle, vecViewAngle);
	angle_vector(vecViewAngle, ANGLEVECTOR_FORWARD, vecAiming);
}

/**
 * Checking for entities behind walls :)
 */
stock bool:rz_util_entity_visible(const pEntity, const pTarget)
{
    if (is_nullent(pEntity) || is_nullent(pTarget))
        return false;

    static Float:vecStart[3], Float:vecEnd[3];
    rz_util_get_entity_center(pEntity, vecStart);
    rz_util_get_entity_center(pTarget, vecEnd);

    new pTrace = create_tr2();
    engfunc(EngFunc_TraceLine, vecStart, vecEnd, IGNORE_MONSTERS, pEntity, pTrace);

    static Float:vecEndPos[3]; 
    get_tr2(pTrace, TR_vecEndPos, vecEndPos);
    free_tr2(pTrace);

    if (!xs_vec_equal(vecEnd, vecEndPos)) {
        return false;
    }

    return true;
}

stock bool:rz_util_play_timing_sound(const pThis, const pEntity, const pChannel = CHAN_WEAPON, const pSound[], const Float:pTime)
{
	static Float:flGameTime; flGameTime = get_gametime();
	static Float:flNextSound; get_entvar(pEntity, var_impacttime, flNextSound);
	if (flNextSound > flGameTime) {
		return false;
	}

	rh_emit_sound2(pThis, 0, pChannel, pSound);
	set_entvar(pEntity, var_impacttime, flGameTime + pTime);
	return true;
}

stock rz_util_reset_timing_sound(const pThis, const pEntity, const pChannel = CHAN_WEAPON, const pSound[] = "common/null.wav")
{
	set_entvar(pEntity, var_impacttime, get_gametime());
	rh_emit_sound2(pThis, 0, pChannel, pSound);
}

stock rz_util_precache_sprites_from_txt(const szTextFile[])
{
	new szTxtDir[64], szSprDir[64]; 
	new szFileData[128], szSprName[48], temp[1];

	format(szTxtDir, charsmax(szTxtDir), "sprites/%s.txt", szTextFile);
	precache_generic(szTxtDir);

	new iFile = fopen(szTxtDir, "rb");
	while(iFile && !feof(iFile)) 
	{
		fgets(iFile, szFileData, charsmax(szFileData));
		trim(szFileData);

		if(!strlen(szFileData)) 
			continue;

		new pos = containi(szFileData, "640");	
				
		if (pos == -1) {
			continue;
		}

		format(szFileData, charsmax(szFileData), "%s", szFileData[pos+3]);		
		trim(szFileData);

		strtok(szFileData, szSprName, charsmax(szSprName), temp, charsmax(temp), ' ', 1);
		trim(szSprName);
			
		format(szSprDir, charsmax(szSprDir), "sprites/%s.spr", szSprName);
		precache_generic(szSprDir);
	}

	if (iFile) fclose(iFile);
}

// All stocks are from tempentities.inc and messages.inc
// I just did it to make things easier

stock rz_util_te_worlddecal(Float:position[3] = NULL_VECTOR, textureIndex)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	write_coord_f(position[0]);	// position.x
	write_coord_f(position[1]);	// position.y
	write_coord_f(position[2]);	// position.z
	write_byte(textureIndex);	// texture index of precached decal texture name
	message_end();
}

stock rz_util_te_dlight(Float:position[3] = NULL_VECTOR, radius, color[3], life, decayRate)
{
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, position);
	write_byte(TE_DLIGHT);
	write_coord_f(position[0]);	// position.x
	write_coord_f(position[1]);	// position.y
	write_coord_f(position[2]);	// position.z
	write_byte(radius);			// radius in 10's
	write_byte(color[0]);		// red
	write_byte(color[1]);		// green
	write_byte(color[2]);		// blue
	write_byte(life);			// life in 10's
	write_byte(decayRate);		// decay rate in 10's
	message_end();
}

stock rz_util_te_beamentoint(startEntity, Float:end[3] = NULL_VECTOR, spriteIndex = 0, startingFrame = 0, frameRate = 0, life = 1, lineWidth = 1, noiseAmplitude = 0, RGBA[4] = {255, 255, 255, 255}, scrollSpeed = 0)
{
	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(startEntity);	// start entity
	write_coord_f(end[0]);		// endposition.x
	write_coord_f(end[1]);		// endposition.y
	write_coord_f(end[2]);		// endposition.z
	write_short(spriteIndex);	// sprite index
	write_byte(startingFrame);	// starting frame
	write_byte(frameRate);		// frame rate in 0.1's
	write_byte(life);			// life in 0.1's
	write_byte(lineWidth);		// line width in 0.1's
	write_byte(noiseAmplitude);	// noise amplitude in 0.01's
	write_byte(RGBA[0]);		// red
	write_byte(RGBA[1]);		// green
	write_byte(RGBA[2]);		// blue
	write_byte(RGBA[3]);		// brightness
	write_byte(scrollSpeed);	// scroll speed in 0.1's
	message_end();
}

stock rz_util_beaments(const iDest, const startEntity, const endEntity, const spriteIndex, const iStartFrame = 0, const iFrameRate = 1, const iLife = 1, const iWidth = 1, const iNoise = 0, const RGBA[4] = { 255, 255, 255, 255 }, const iScroll = 0)
{
	message_begin_f(iDest, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTS);
	write_short(startEntity);	// start entity
	write_short(endEntity);		// end entity
	write_short(spriteIndex);	// sprite index
	write_byte(iStartFrame);	// Start Frame
	write_byte(iFrameRate);		// FrameRate
	write_byte(iLife);			// Life in 0.1's
	write_byte(iWidth);			// Width
	write_byte(iNoise);			// Noise
	write_byte(RGBA[0]);		// Red
	write_byte(RGBA[1]);		// Green
	write_byte(RGBA[2]);		// Blue
	write_byte(RGBA[3]);		// Brightness
	write_byte(iScroll);		// Scroll speed in 0.1's
	message_end();
}

stock rz_util_te_beamcylinder(Float:position[3] = NULL_VECTOR, Float:axis[3] = NULL_VECTOR, spriteIndex = 0, startingFrame = 0, frameRate = 0, life = 1, lineWidth = 3, noiseAmplitude = 0, RGBA[4] = {255, 255, 255, 255}, scrollSpeed = 0)
{
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, position);
	write_byte(TE_BEAMCYLINDER);
	write_coord_f(position[0]);	// position.x
	write_coord_f(position[1]);	// position.y
	write_coord_f(position[2]);	// position.z
	write_coord_f(axis[0]);		// axis.x
	write_coord_f(axis[1]);		// axis.y
	write_coord_f(axis[2]);		// axis.z
	write_short(spriteIndex);	// sprite index
	write_byte(startingFrame);	// starting frame
	write_byte(frameRate);		// frame rate in 0.1's
	write_byte(life);			// life in 0.1's
	write_byte(lineWidth);		// line width in 0.1's
	write_byte(noiseAmplitude);	// noise amplitude in 0.01's
	write_byte(RGBA[0]);		// red
	write_byte(RGBA[1]);		// green
	write_byte(RGBA[2]);		// blue
	write_byte(RGBA[3]);		// brightness
	write_byte(scrollSpeed);	// scroll speed in 0.1's
	message_end();
}

stock rz_util_te_explosion(Float:position[3] = NULL_VECTOR, spriteIndex, scale, frameRate, const flags = TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES)
{
	message_begin_f(MSG_PAS, SVC_TEMPENTITY, position);
	write_byte(TE_EXPLOSION);
	write_coord_f(position[0]);	// position.x
	write_coord_f(position[1]);	// position.y
	write_coord_f(position[2]);	// position.z
	write_short(spriteIndex);	// sprite index
	write_byte(scale);			// scale in 0.1's
	write_byte(frameRate);		// framerate
	write_byte(flags);			// flags
	message_end();
}

stock rz_util_te_smoke(Float:position[3] = NULL_VECTOR, spriteIndex, scale, frameRate)
{
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, position);
	write_byte(TE_SMOKE);
	write_coord_f(position[0]);	// position.x
	write_coord_f(position[1]);	// position.y
	write_coord_f(position[2]); // position.z
	write_short(spriteIndex);	// sprite index
	write_byte(scale);			// scale in 0.1's
	write_byte(frameRate);		// framerate
	message_end();
}

stock rz_util_te_beamfollow(const entity, const spriteIndex, const life, const width, const RGBA[4] = {255, 255, 255, 255})
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(entity);		// entity:attachment to follow
	write_short(spriteIndex);	// sprite index
	write_byte(life);			// life in 0.1's
	write_byte(width);			// line width in 0.1's
	write_byte(RGBA[0]);		// red
	write_byte(RGBA[1]);		// green
	write_byte(RGBA[2]);		// blue
	write_byte(RGBA[3]);		// brightness
	message_end();
}

stock rz_util_te_tracer(const Float:start[3] = NULL_VECTOR, const Float:end[3] = NULL_VECTOR) {
	message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_TRACER);
	write_coord_f(start[0]);	// startposition.x
	write_coord_f(start[1]);	// startposition.y
	write_coord_f(start[2]);	// startposition.z
	write_coord_f(end[0]);		// endposition.x
	write_coord_f(end[1]);		// endposition.y
	write_coord_f(end[2]);		// endposition.z
	message_end();
}