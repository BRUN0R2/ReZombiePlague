#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new Float:rz_gamemode_notice_hud_pos[2];
new Array:gamemodesArray;

public plugin_precache() {
    register_plugin("[ReZP] Game Modes", REZP_VERSION_STR, "fl0wer");
}

public plugin_init() {
    RegisterHookChain(RG_CSGameRules_RestartRound, "@CSGameRules_RestartRound_Pre", false);
    RegisterHookChain(RG_CSGameRules_OnRoundFreezeEnd, "@CSGameRules_OnRoundFreezeEnd_Pre", false);

    bind_pcvar_float(create_cvar("rz_gamemode_notice_hud_x", "-1.0", _, "", true, -1.0, true, 1.0), rz_gamemode_notice_hud_pos[0]);
    bind_pcvar_float(create_cvar("rz_gamemode_notice_hud_y", "0.17", _, "", true, -1.0, true, 1.0), rz_gamemode_notice_hud_pos[1]);

    // Initialize gamemodesArray
    gamemodesArray = ArrayCreate(1, 0);
    loadGamemodes();

    rz_load_langs("gamemodes");
}

public plugin_cfg() {
    if (!rz_gamemodes_size()) {
        rz_sys_error("No loaded game modes");
    }
}

public loadGamemodes() {
    new totalMods = rz_gamemodes_size();
    for (new i = 0; i < totalMods; i++) {
        new mode = i + rz_gamemodes_start();
        ArrayPushCell(gamemodesArray, mode);
    }
}

public rz_gamemodes_change_post(gameMode) {
    rz_gamemodes_set(RZ_GAMEMODES_CURRENT, gameMode);
    rz_gamemodes_set(RZ_GAMEMODES_LAST, gameMode);

    new roundTime = rz_gamemode_get(gameMode, RZ_GAMEMODE_ROUND_TIME);
    new hudColor[3], notice[RZ_MAX_LANGKEY_LENGTH];

    rz_gamemode_get(gameMode, RZ_GAMEMODE_HUD_COLOR, hudColor);
    rz_gamemode_get(gameMode, RZ_GAMEMODE_NOTICE, notice, charsmax(notice));

    set_dhudmessage(
        hudColor[0],
        hudColor[1],
        hudColor[2],
        rz_gamemode_notice_hud_pos[0], 
        rz_gamemode_notice_hud_pos[1],
        0, 0.0, 5.0, 1.0, 1.0
    );

    show_dhudmessage(0, "~ %L ~", LANG_PLAYER, notice);

    if (roundTime) {
        set_member_game(m_iRoundTime, roundTime);
    }
}

@CSGameRules_RestartRound_Pre() {
    rz_main_lighting_global_reset();
    rz_main_lighting_nvg_reset();

    set_member_game(m_bCompleteReset, false);
    rz_gamemodes_set(RZ_GAMEMODES_CURRENT, 0);
    rz_gamemodes_set(RZ_GAMEMODES_FORCE, 0);

    rz_class_override_default(TEAM_TERRORIST, 0);
    rz_class_override_default(TEAM_CT, 0);
}

new lastChanceMod = 0;

@CSGameRules_OnRoundFreezeEnd_Pre() {
    if (!get_member_game(m_bGameStarted) || get_member_game(m_bCompleteReset)) {
        return;
    }

    new modSortIndex = xRandomMod();
    new alivesNum = rz_game_get_alivesnum();

    if (xUserChance(lastChanceMod) && alivesNum >= rz_gamemode_get(modSortIndex, RZ_GAMEMODE_MIN_ALIVES)) {}
    else modSortIndex = rz_gamemodes_get(RZ_GAMEMODES_DEFAULT);

    rz_gamemodes_change(modSortIndex);
    set_member_game(m_bCompleteReset, true);
}

public xRandomMod() {
    new chance, modSortIndex;
    new Array:modsChancesArray = ArrayCreate(1, 0);

    for (new i = 0; i < ArraySize(gamemodesArray); i++) {
        chance = rz_gamemode_get(ArrayGetCell(gamemodesArray, i), RZ_GAMEMODE_CHANCE);
        ArrayPushCell(modsChancesArray, chance);
    }

    new chanceSortIndex = random(ArraySize(modsChancesArray));
    new chanceRandom = ArrayGetCell(modsChancesArray, chanceSortIndex);
    modSortIndex = ArrayGetCell(gamemodesArray, chanceSortIndex);

    lastChanceMod = chanceRandom;

    ArrayDestroy(modsChancesArray);

    return modSortIndex;
}

stock xUserChance(chance) {
    return random(100) < chance;
}