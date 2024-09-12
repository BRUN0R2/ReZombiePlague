#pragma semicolon 1

#include <amxmodx>
#include <json>
#include <rezp_inc/rezp_main>

new const SUBCLASS_DIRECTORY[] = "subclass";

new bool:g_bCreating;
new JSON:g_iJsonHandle;
new JSON:g_iJsonHandleCopy;
new g_sBaseDirPath[PLATFORM_MAX_PATH];
new g_sSubclassDirPath[PLATFORM_MAX_PATH];
new g_sHandle[RZ_MAX_HANDLE_LENGTH];

new g_iTemp;
new g_sTemp[RZ_MAX_RESOURCE_PATH];

public plugin_precache()
{
	register_plugin("[ReZP] Config: Subclass", REZP_VERSION_STR, "fl0wer");

	rz_get_configsdir(g_sBaseDirPath, charsmax(g_sBaseDirPath));
	formatex(g_sSubclassDirPath, charsmax(g_sSubclassDirPath), "%s/%s", g_sBaseDirPath, SUBCLASS_DIRECTORY);

	if (!dir_exists(g_sSubclassDirPath))
	{
		if (mkdir(g_sSubclassDirPath) != 0)
		{
			rz_log(true, "Cannot create subclass directory '%s'", g_sSubclassDirPath);
			return;
		}

		rz_print("Subclass directory '%s' was created", g_sSubclassDirPath);
	}

	SubClassConfigs();
}

SubClassConfigs()
{
	new size = rz_subclass_size();

	if (!size)
		return;

	new start = rz_subclass_start();
	new end = start + size;
	new failedCount;
	new filePath[PLATFORM_MAX_PATH];

	for (new i = start; i < end; i++)
	{
		rz_subclass_get(i, RZ_SUBCLASS_HANDLE, g_sHandle, charsmax(g_sHandle));
		formatex(filePath, charsmax(filePath), "%s/%s.json", g_sSubclassDirPath, g_sHandle);

		if (file_exists(filePath))
		{
			g_iJsonHandle = json_parse(filePath, true);

			if (g_iJsonHandle == Invalid_JSON)
			{
				failedCount++;
				rz_log(true, "Error parsing class file '%s/%s.json'", SUBCLASS_DIRECTORY, g_sHandle);
				continue;
			}

			g_bCreating = false;
			g_iJsonHandleCopy = json_deep_copy(g_iJsonHandle);
		}
		else
		{
			g_bCreating = true;
			g_iJsonHandle = json_init_object();

			rz_print("SubClass file '%s/%s.json' was created", SUBCLASS_DIRECTORY, g_sHandle);
		}

		SubClassPropField("name", i, RZ_SUBCLASS_NAME, RZ_MAX_LANGKEY_LENGTH);
		//SubClassPropField("team", i, RZ_CLASS_TEAM); // will break classes by default
		SubClassPropField("hud_color", i, RZ_SUBCLASS_HUD_COLOR);
		SubClassPropField("properties", i, RZ_SUBCLASS_PROPS);
		SubClassPropField("Subclass_models", i, RZ_SUBCLASS_MODEL);
		SubClassPropField("Subclass_sounds", i, RZ_SUBCLASS_SOUND);
		SubClassPropField_Knife("knife", i, RZ_MAX_HANDLE_LENGTH, "weapon_knife");
		SubClassPropField("nightvision", i, RZ_SUBCLASS_NIGHTVISION);

		if (g_bCreating)
		{
			json_serial_to_file(g_iJsonHandle, filePath, true);
		}
		else if (!json_equals(g_iJsonHandle, g_iJsonHandleCopy))
		{
			json_serial_to_file(g_iJsonHandle, filePath, true);
			json_free(g_iJsonHandleCopy);
		}

		json_free(g_iJsonHandle);
	}

	if (failedCount)
		rz_print("Loaded %d subclasses (%d failed)", size, failedCount);
	else
		rz_print("Loaded %d subclasses", size);
}

SubClassPropField(value[], subclass, RZSubclassProp:prop, length = 0)
{
	switch (prop)
	{
		case RZ_SUBCLASS_HUD_COLOR:
		{
			new colorInt[3];

			if (!g_bCreating && json_object_has_value(g_iJsonHandle, value, JSONString))
			{
				new color[3][4];

				json_object_get_string(g_iJsonHandle, value, g_sTemp, length - 1);

				if (parse(g_sTemp, color[0], charsmax(color[]), color[1], charsmax(color[]), color[2], charsmax(color[])) == 3)
				{
					colorInt[0] = str_to_num(color[0]);
					colorInt[1] = str_to_num(color[1]);
					colorInt[2] = str_to_num(color[2]);

					rz_subclass_set(subclass, prop, colorInt);
				}
				else
				{
					rz_subclass_get(subclass, RZ_SUBCLASS_HANDLE, g_sHandle, charsmax(g_sHandle));
					rz_log(true, "Error parsing property '%s' for subclass '%s'", value, g_sHandle);
				}
			}
			else
			{
				rz_subclass_get(subclass, prop, colorInt);
				json_object_set_string(g_iJsonHandle, value, fmt("%d %d %d", colorInt[0], colorInt[1], colorInt[2]));
			}
		}
		case RZ_SUBCLASS_PROPS, RZ_SUBCLASS_MODEL, RZ_SUBCLASS_SOUND, RZ_SUBCLASS_NIGHTVISION:
		{
			if (!g_bCreating && json_object_has_value(g_iJsonHandle, value, JSONNumber))
			{
				g_iTemp = json_object_get_number(g_iJsonHandle, value);
				rz_subclass_set(subclass, prop, g_iTemp);
			}
			else
			{
				g_iTemp = rz_subclass_get(subclass, prop);
				json_object_set_number(g_iJsonHandle, value, g_iTemp);
			}
		}
		default:
		{
			if (!g_bCreating && json_object_has_value(g_iJsonHandle, value, JSONString))
			{
				json_object_get_string(g_iJsonHandle, value, g_sTemp, length - 1);
				rz_subclass_set(subclass, prop, g_sTemp);
			}
			else
			{
				rz_subclass_get(subclass, prop, g_sTemp, length - 1);
				json_object_set_string(g_iJsonHandle, value, g_sTemp);
			}
		}
	}
}

SubClassPropField_Knife(value[], subclass, length, defValue[])
{
	if (!g_bCreating && json_object_has_value(g_iJsonHandle, value, JSONString))
	{
		json_object_get_string(g_iJsonHandle, value, g_sTemp, length - 1);

		if (g_sTemp[0] && !equal(g_sTemp, defValue))
		{
			new knife = rz_knifes_find(g_sTemp);

			if (knife)
			{
				rz_subclass_set(subclass, RZ_SUBCLASS_KNIFE, knife);
			}
			else
			{
				rz_subclass_get(subclass, RZ_SUBCLASS_HANDLE, g_sHandle, charsmax(g_sHandle));
				rz_log(true, "Error searching knife '%s' for class '%s'", value, g_sHandle);
			}
		}
		else
		{
			rz_subclass_set(subclass, RZ_SUBCLASS_KNIFE, 0);
		}
	}
	else
	{
		new knife = rz_subclass_get(subclass, RZ_SUBCLASS_KNIFE);

		if (knife)
		{
			rz_knife_get(knife, RZ_KNIFE_HANDLE, g_sHandle, charsmax(g_sHandle));
			json_object_set_string(g_iJsonHandle, value, g_sHandle);
		}
		else
			json_object_set_string(g_iJsonHandle, value, defValue);
	}
}