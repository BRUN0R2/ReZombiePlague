#if defined _rezp_trie_included
	#endinput
#endif

#define _rezp_trie_included

new Trie:g_tData = Invalid_Trie;

// Function to create the Trie (initialization)
stock rz_trie_create()
{
    if (g_tData == Invalid_Trie) {
        g_tData = TrieCreate();
    }
}

// Function to destroy the Trie and free memory
stock rz_trie_destroy()
{
    if (g_tData != Invalid_Trie) {
        TrieDestroy(g_tData);
        g_tData = Invalid_Trie;
    }
}

stock rz_set_tdata_int(pEntity, const szMember[], iValue) {
    if (g_tData != Invalid_Trie) {
        TrieSetCell(g_tData, fmt("%i:%s", pEntity, szMember), iValue);
    }
}

stock rz_get_tdata_int(pEntity, const szMember[]) {
    if (g_tData != Invalid_Trie) {
        new iValue;
        TrieGetCell(g_tData, fmt("%i:%s", pEntity, szMember), iValue);
        return iValue;
    }
    return -1;
}

stock rz_set_tdata_float(pEntity, const szMember[], Float:flValue) {
    if (g_tData != Invalid_Trie) {
        new Float:aValue[1]; 
        aValue[0] = flValue;
        TrieSetArray(g_tData, fmt("%i:%s", pEntity, szMember), aValue, 1);
    }
}

stock Float:rz_get_tdata_float(pEntity, const szMember[]) {
    if (g_tData != Invalid_Trie) {
        new Float:aValue[1];
        TrieGetArray(g_tData, fmt("%i:%s", pEntity, szMember), aValue, 1);
        return aValue[0];
    }
    return 0.0;
}

stock rz_set_tdata_array(pEntity, const szMember[], any:array[], iSize) {
    if (g_tData != Invalid_Trie) {
        TrieSetArray(g_tData, fmt("%i:%s", pEntity, szMember), array, iSize);
    }
}

stock rz_get_tdata_array(pEntity, const szMember[], any:array[], iSize) {
    if (g_tData != Invalid_Trie) {
        TrieGetArray(g_tData, fmt("%i:%s", pEntity, szMember), array, iSize);
    }
}

stock rz_remove_tdata(pEntity, szMember[]) {
    if (g_tData != Invalid_Trie) {
        TrieDelete(g_tData, fmt("%i:%s", pEntity, szMember));
    }
}

// Function to delete all data associated with an entity
stock rz_remove_entity_tdata(pEntity) {
    if (g_tData != Invalid_Trie) {
        new Handle:hIter;
        new szKey[64];

        // Iterate and find all keys that belong to the entity
        while ((hIter = TrieFind(g_tData, fmt("%i:", pEntity), szKey, charsmax(szKey))) != 0) {
            TrieDelete(g_tData, szKey);// Remove each entry associated with the entity
        }
    }
}