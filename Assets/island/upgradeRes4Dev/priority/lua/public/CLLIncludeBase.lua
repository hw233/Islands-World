-- 需要先加载的部分
-------------------------------------------------------
---@type UnityEngine.Application
Application = CS.UnityEngine.Application
---@type UnityEngine.SystemInfo
SystemInfo = CS.UnityEngine.SystemInfo
---@type UnityEngine.QualitySettings
QualitySettings = CS.UnityEngine.QualitySettings
---@type UnityEngine.Time
Time = CS.UnityEngine.Time
---@type UnityEngine.GameObject
GameObject = CS.UnityEngine.GameObject
---@type UnityEngine.Component
Component = CS.UnityEngine.Component
---@type UnityEngine.Behaviour
Behaviour = CS.UnityEngine.Behaviour
---@type UnityEngine.Transform
Transform = CS.UnityEngine.Transform
---@type UnityEngine.Vector3
Vector3 = CS.UnityEngine.Vector3
---@type UnityEngine.Rect
Rect = CS.UnityEngine.Rect
---@type System.Collections.Queue
Queue = CS.System.Collections.Queue
---@type System.Collections.Stack
Stack = CS.System.Collections.Stack
---@type System.Collections.Hashtable
Hashtable = CS.System.Collections.Hashtable
---@type System.Collections.ArrayList
ArrayList = CS.System.Collections.ArrayList
---@type UnityEngine.PlayerPrefs
PlayerPrefs = CS.UnityEngine.PlayerPrefs
---@type System.IO.File
File = CS.System.IO.File
---@type System.IO.Path
Path = CS.System.IO.Path
---@type System.IO.Directory
Directory = CS.System.IO.Directory
---@type System.IO.MemoryStream
MemoryStream = CS.System.IO.MemoryStream
---@type UnityEngine.Color
Color = CS.UnityEngine.Color
---@type System.GC
GC = CS.System.GC

---NGUI
---@type Localization
Localization = CS.Localization
---@type NGUITools
NGUITools = CS.NGUITools

---@type Coolape.ReporterMessageReceiver
ReporterMessageReceiver = CS.ReporterMessageReceiver

----Coolape
---@type Coolape.JSON
JSON = CS.Coolape.JSON
---@type Coolape.CLCfgBase
CLCfgBase = CS.Coolape.CLCfgBase
---@type Coolape.WWWEx
WWWEx = CS.Coolape.WWWEx
---@type Coolape.CLAssetType
CLAssetType = CS.Coolape.CLAssetType
---@type Coolape.StrEx
StrEx = CS.Coolape.StrEx
---@type Coolape.Utl
Utl = CS.Coolape.Utl
---@type Coolape.CLPanelManager
CLPanelManager = CS.Coolape.CLPanelManager
---@type Coolape.Net
Net = CS.Coolape.Net
---@type Coolape.Net.NetWorkType
NetWorkType = CS.Coolape.Net.NetWorkType
---@type Coolape.PStr
PStr = CS.Coolape.PStr
---@type Coolape.MapEx
MapEx = CS.Coolape.MapEx
---@type Coolape.CLUIOtherObjPool
CLUIOtherObjPool = CS.Coolape.CLUIOtherObjPool
---@type Coolape.CLUIInit
CLUIInit = CS.Coolape.CLUIInit
---@type Coolape.InvokeEx
InvokeEx = CS.Coolape.InvokeEx
---@type Coolape.CLPathCfg
CLPathCfg = CS.Coolape.CLPathCfg
---@type Coolape.CLVerManager
CLVerManager = CS.Coolape.CLVerManager
---@type Coolape.CLUIUtl
CLUIUtl = CS.Coolape.CLUIUtl
---@type Coolape.CLMainBase
CLMainBase = CS.Coolape.CLMainBase
---@type Coolape.SoundEx
SoundEx = CS.Coolape.SoundEx
---@type Coolape.FileEx
FileEx = CS.Coolape.FileEx
---@type Coolape.B2InputStream
B2InputStream = CS.Coolape.B2InputStream
---@type Coolape.B2OutputStream
B2OutputStream = CS.Coolape.B2OutputStream
---@type Coolape.CLAlert
CLAlert = CS.Coolape.CLAlert

---other
---@type MyMain
MyMain = CS.MyMain
---@type MyCfg
MyCfg = CS.MyCfg
-------------------------------------------------------
require "toolkit.CLLPrintEx"
---public 重写require
local localReq = require
function require(path)
    local ret, result = pcall(localReq, path)
    --("toolkit.KKWhiteList")
    if not ret then
        printe("Err:" .. result)
        return nil
    end
    return result
end
-------------------------------------------------------
-- require
require("bio.BioUtl")
require("toolkit.LuaUtl")
require("public.CLLPrefs")
require("toolkit.CLLUpdateUpgrader")
require("toolkit.CLLVerManager")
-------------------------------------------------------
-- 全局变量
__version__ = Application.version -- "1.0"
__UUID__ = ""
-------------------------------------------------------
bio2Int = BioUtl.bio2int
int2Bio = BioUtl.int2bio
bio2Long = BioUtl.bio2long
long2Bio = BioUtl.long2bio
bio2number = BioUtl.bio2number
number2bio = BioUtl.number2bio
net = Net.self
NetSuccess = Net.SuccessCode

LGet = Localization.Get
function LGetFmt(key, ...)
    return string.format(LGet(key), ...)
end

---public 异步加载panel
---@param panelName string 页面名
---@param callback function 取得页面的回调(panel, orgs)
---@param paras object 回调的透传参数
---@param luaClass ClassBase lua类可为空
function getPanelAsy(panelName, callback, paras, luaClass)
    if luaTable then
        CLPanelManager.getPanelAsy(
            panelName,
            ---@param p Coolape.CLPanelLua
            function(p, orgs)
                if p.luaTable == nil then
                    p.luaTable = luaClass.new()
                end
                callback(p, orgs)
            end,
            paras
        )
    else
        CLPanelManager.getPanelAsy(panelName, callback, paras)
    end
end
-------------------------------------------------------
-- 模式
GameMode = {
    none = 0,
    city = 1,
    map = 2,
    battle = 3,
    battleFleet = 4,
}
-------------------------------------------------------
local chnCfg  -- 安装包配置
function getChlCfg()
    if chnCfg ~= nil then
        return chnCfg
    end
    if not CLCfgBase.self.isEditMode then
        local fpath = "chnCfg.json" -- 该文在打包时会自动放在streamingAssetsPath目录下，详细参见打包工具
        local content = FileEx.readNewAllText(fpath)
        if (content ~= nil) then
            chnCfg = JSON.DecodeMap(content)
        end
    end
    return chnCfg
end

-- 取得渠道代码
function getChlCode()
    if chnCfg ~= nil then
        return MapEx.getString(chnCfg, "SubChannel")
    end
    local chlCode = "0000"
    chnCfg = getChlCfg()
    if (chnCfg ~= nil) then
        chlCode = MapEx.getString(chnCfg, "SubChannel")
    end
    return chlCode
end
-------------------------------------------------------
