using System.Collections;
using System.Collections.Generic;
using UnityEditor;

public class EIslandMenus
{

    [MenuItem("Islands/Generate worldmap data", false, 1)]
    public static void showGenerateWorldmapDataWind()
    {
        EditorWindow.GetWindow<EWorldmapCfgDataGneratorWind>(false, "Generate worldmap data", true);
    }

    [MenuItem("Assets/Create/Lua Script/New Class Lua Panel", false, 81)]
    public static void CreatNewLuaPanel()
    {
        ECLCreateFile.PubCreatNewFile("Assets/island/Templates/Lua/NewClassLuaPanel.lua", ECLCreateFile.GetSelectedPathOrFallback() + "/NewLuaPanel.lua");
    }
}
