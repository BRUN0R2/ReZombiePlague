#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <rezp_inc/rezp_main>

new g_iGameMode_Sniper;
new g_iClass_Sniper;
new g_iClass_Zombie;

public plugin_precache()
{
	register_plugin("[ReZP] Game Mode: Sniper", REZP_VERSION_STR, "fl0wer");

	RZ_CHECK_CLASS_EXISTS(g_iClass_Sniper, "class_sniper");
	RZ_CHECK_CLASS_EXISTS(g_iClass_Zombie, "class_zombie");

	new gameMode = g_iGameMode_Sniper = rz_gamemode_create("gamemode_sniper");

	rz_gamemode_set(gameMode, RZ_GAMEMODE_NAME, "RZ_GAMEMODE_SNIPER");
	rz_gamemode_set(gameMode, RZ_GAMEMODE_NOTICE, "RZ_GAMEMODE_NOTICE_SNIPER");
	rz_gamemode_set(gameMode, RZ_GAMEMODE_HUD_COLOR, { 0, 250, 250 });
	rz_gamemode_set(gameMode, RZ_GAMEMODE_CHANCE, 20);
}

public rz_gamemodes_change_post(GameMode)
{
    if (GameMode != g_iGameMode_Sniper)
        return;

    new Array:humansArray = ArrayCreate(1, 0);
    new Array:botsArray = ArrayCreate(1, 0);

    for (new i = 1; i <= MaxClients; i++)
    {
        if (!is_user_alive(i))
            continue;

        if (is_user_bot(i)) {
            ArrayPushCell(botsArray, i);
        } else {
            ArrayPushCell(humansArray, i);
        }
    }

    if (ArraySize(humansArray) > 0)
    {
        new item = random_num(0, ArraySize(humansArray) - 1);
        new sniper = ArrayGetCell(humansArray, item);

        // Torna o jogador selecionado um sniper
        rz_class_player_change(sniper, 0, g_iClass_Sniper);
        ArrayDeleteItem(humansArray, item);
    }

    // Torna todos os bots e humanos restantes zumbis
    for (new idl = 0; idl < ArraySize(humansArray); idl++)
    {
        new player = ArrayGetCell(humansArray, idl);
        rz_class_player_change(player, 0, g_iClass_Zombie);
    }

    for (new idl = 0; idl < ArraySize(botsArray); idl++)
    {
        new bot = ArrayGetCell(botsArray, idl);
        rz_class_player_change(bot, 0, g_iClass_Zombie);
    }

    rz_class_override_default(TEAM_CT, g_iClass_Sniper);
    rz_class_override_default(TEAM_TERRORIST, g_iClass_Zombie);

    // Destruir os arrays
    ArrayDestroy(humansArray);
    ArrayDestroy(botsArray);
}