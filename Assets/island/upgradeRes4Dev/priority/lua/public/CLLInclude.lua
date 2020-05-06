-- 需要先加载的部分
-------------------------------------------------------
require "public.CLLIncludeBase"
-------------------------------------------------------
-- 重新命名
---@type UnityEngine.Vector2
Vector2 = CS.UnityEngine.Vector2
---@type UnityEngine.Vector4
Vector4 = CS.UnityEngine.Vector4
---@type UnityEngine.Ray
Ray = CS.UnityEngine.Ray
---@type UnityEngine.Ray2D
Ray2D = CS.UnityEngine.Ray2D
---@type UnityEngine.Bounds
Bounds = CS.UnityEngine.Bounds
---@type UnityEngine.Resources
Resources = CS.UnityEngine.Resources
---@type UnityEngine.TextAsset
TextAsset = CS.UnityEngine.TextAsset
---@type UnityEngine.AnimationCurve
AnimationCurve = CS.UnityEngine.AnimationCurve
---@type UnityEngine.AnimationClip
AnimationClip = CS.UnityEngine.AnimationClip
---@type UnityEngine.MonoBehaviour
MonoBehaviour = CS.UnityEngine.MonoBehaviour
---@type UnityEngine.ParticleSystem
ParticleSystem = CS.UnityEngine.ParticleSystem
---@type UnityEngine.SkinnedMeshRenderer
SkinnedMeshRenderer = CS.UnityEngine.SkinnedMeshRenderer
---@type UnityEngine.MeshRenderer
MeshRenderer = CS.UnityEngine.MeshRenderer
---@type UnityEngine.Renderer
Renderer = CS.UnityEngine.Renderer
---@type UnityEngine.Screen
Screen = CS.UnityEngine.Screen
---@type UnityEngine.RaycastHit
RaycastHit = CS.UnityEngine.RaycastHit
---@type UnityEngine.Shader
Shader = CS.UnityEngine.Shader
---@type UnityEngine.LayerMask
LayerMask = CS.UnityEngine.LayerMask
---@type UnityEngine.BoxCollider
BoxCollider = CS.UnityEngine.LayerMask
---@type UnityEngine.AudioSource
AudioSource = CS.UnityEngine.AudioSource
---@type UnityEngine.Physics
Physics = CS.UnityEngine.Physics

---@type UIRoot
UIRoot = CS.UIRoot
---@type UICamera
UICamera = CS.UICamera
---@type UIRect
UIRect = CS.UIRect
---@type UIWidget
UIWidget = CS.UIWidget
---@type UIWidget+Pivot
Pivot = CS.UIWidget.Pivot
---@type UIWidgetContainer
UIWidgetContainer = CS.UIWidgetContainer
---@type UILabel
UILabel = CS.UILabel
---@type UIToggle
UIToggle = CS.UIToggle
---@type UIBasicSprite
UIBasicSprite = CS.UIBasicSprite
---@type UITexture
UITexture = CS.UITexture
---@type UISprite
UISprite = CS.UISprite
---@type UIProgressBar
UIProgressBar = CS.UIProgressBar
---@type UISlider
UISlider = CS.UISlider
---@type UIGrid
UIGrid = CS.UIGrid
---@type UITable
UITable = CS.UITable
---@type UIInput
UIInput = CS.UIInput
---@type UIButton
UIButton = CS.UIButton
---@type UIScrollView
UIScrollView = CS.UIScrollView
---@type UITweener
UITweener = CS.UITweener
---@type TweenWidth
TweenWidth = CS.TweenWidth
---@type TweenRotation
TweenRotation = CS.TweenRotation
---@type TweenPosition
TweenPosition = CS.TweenPosition
---@type TweenScale
TweenScale = CS.TweenScale
---@type TweenAlpha
TweenAlpha = CS.TweenAlpha
---@type UICenterOnChild
UICenterOnChild = CS.UICenterOnChild
---@type UIAtlas
UIAtlas = CS.UIAtlas
---@type UILocalize
UILocalize = CS.UILocalize
---@type UIPlayTween
UIPlayTween = CS.UIPlayTween
---@type UIFollowTarget
UIFollowTarget = CS.UIFollowTarget
---@type UIFollowTarget
HUDRoot = CS.HUDRoot
---@type UIRichText4Chat
UIRichText4Chat = CS.UIRichText4Chat
---@type UIAnchor
UIAnchor = CS.UIAnchor
---@type UIPanel
UIPanel = CS.UIPanel

---@type Coolape.CLAssetsManager
CLAssetsManager = CS.Coolape.CLAssetsManager
---@type Coolape.CLAssetsPoolBase
CLAssetsPoolBase = CS.Coolape.CLAssetsPoolBase
---@type Coolape.CLBulletBase
CLBulletBase = CS.Coolape.CLBulletBase
---@type Coolape.CLBulletPool
CLBulletPool = CS.Coolape.CLBulletPool
---@type Coolape.CLEffect
CLEffect = CS.Coolape.CLEffect
---@type Coolape.CLEffectPool
CLEffectPool = CS.Coolape.CLEffectPool
---@type Coolape.CLMaterialPool
CLMaterialPool = CS.Coolape.CLMaterialPool
---@type Coolape.CLRolePool
CLRolePool = CS.Coolape.CLRolePool
---@type Coolape.CLSoundPool
CLSoundPool = CS.Coolape.CLSoundPool
---@type Coolape.CLSharedAssets
CLSharedAssets = CS.Coolape.CLSharedAssets
---@type Coolape.CLSharedAssets.CLMaterialInfor
CLMaterialInfor = CS.Coolape.CLSharedAssets.CLMaterialInfor
---@type Coolape.CLTexturePool
CLTexturePool = CS.Coolape.CLTexturePool
---@type Coolape.CLThingsPool
CLThingsPool = CS.Coolape.CLThingsPool
---@type Coolape.CLThings4LuaPool
CLThings4LuaPool = CS.Coolape.CLThings4LuaPool
---@type Coolape.CLBaseLua
CLBaseLua = CS.Coolape.CLBaseLua
---@type Coolape.CLBehaviour4Lua
CLBehaviour4Lua = CS.Coolape.CLBehaviour4Lua
---@type Coolape.CLUtlLua
CLUtlLua = CS.Coolape.CLUtlLua
---@type Coolape.CLRoleAction
CLRoleAction = CS.Coolape.CLRoleAction
---@type Coolape.CLRoleAvata
CLRoleAvata = CS.Coolape.CLRoleAvata
---@type Coolape.CLUnit
CLUnit = CS.Coolape.CLUnit
---@type Coolape.BlockWordsTrie
BlockWordsTrie = CS.Coolape.BlockWordsTrie
---@type Coolape.ColorEx
ColorEx = CS.Coolape.ColorEx
---@type Coolape.DateEx
DateEx = CS.Coolape.DateEx
---@type Coolape.ListEx
ListEx = CS.Coolape.ListEx
---@type Coolape.MyMainCamera
MyMainCamera = CS.Coolape.MyMainCamera
---@type Coolape.MyTween
MyTween = CS.Coolape.MyTween
---@type Coolape.NewList
NewList = CS.Coolape.NewList
---@type Coolape.NewMap
NewMap = CS.Coolape.NewMap
---@type Coolape.NumEx
NumEx = CS.Coolape.NumEx
---@type Coolape.ObjPool
ObjPool = CS.Coolape.ObjPool
---@type Coolape.SScreenShakes
SScreenShakes = CS.Coolape.SScreenShakes
---@type Coolape.ZipEx
ZipEx = CS.Coolape.ZipEx
---@type Coolape.XXTEA
XXTEA = CS.Coolape.XXTEA
---@type Coolape.CLButtonMsgLua
CLButtonMsgLua = CS.Coolape.CLButtonMsgLua
---@type Coolape.CLJoystick
CLJoystick = CS.Coolape.CLJoystick
---@type Coolape.CLUIDrag4World
CLUIDrag4World = CS.Coolape.CLUIDrag4World
---@type Coolape.CLUILoopGrid
CLUILoopGrid = CS.Coolape.CLUILoopGrid
---@type Coolape.CLUILoopTable
CLUILoopTable = CS.Coolape.CLUILoopTable
---@type Coolape.TweenSpriteFill
TweenSpriteFill = CS.Coolape.TweenSpriteFill
---@type Coolape.UIDragPage4Lua
UIDragPage4Lua = CS.Coolape.UIDragPage4Lua
---@type Coolape.UIDragPageContents
UIDragPageContents = CS.Coolape.UIDragPageContents
---@type Coolape.UIGridPage
UIGridPage = CS.Coolape.UIGridPage
---@type Coolape.UIMoveToCell
UIMoveToCell = CS.Coolape.UIMoveToCell
---@type Coolape.UISlicedSprite
UISlicedSprite = CS.Coolape.UISlicedSprite
---@type Coolape.CLCellBase
CLCellBase = CS.Coolape.CLCellBase
---@type Coolape.CLCellLua
CLCellLua = CS.Coolape.CLCellLua
---@type Coolape.CLPanelBase
CLPanelBase = CS.Coolape.CLPanelBase
---@type Coolape.CLPanelLua
CLPanelLua = CS.Coolape.CLPanelLua
---@type Coolape.CLUIRenderQueue
CLUIRenderQueue = CS.Coolape.CLUIRenderQueue
---@type Coolape.EffectNum
EffectNum = CS.Coolape.EffectNum
---@type Coolape.TweenProgress
TweenProgress = CS.Coolape.TweenProgress
---@type Coolape.B2Int
B2Int = CS.Coolape.B2Int
---@type Coolape.AngleEx
AngleEx = CS.Coolape.AngleEx
---@type Coolape.CLGridPoints
CLGridPoints = CS.Coolape.CLGridPoints
---@type Coolape.CLTweenColor
CLTweenColor = CS.Coolape.CLTweenColor
---@type Coolape.CLAStarPathSearch
CLAStarPathSearch = CS.Coolape.CLAStarPathSearch
---@type Coolape.CLSeeker
CLSeeker = CS.Coolape.CLSeeker
---@type Coolape.CLSeekerByRay
CLSeekerByRay = CS.Coolape.CLSeekerByRay
---@type Coolape.CLSmoothFollow
CLSmoothFollow = CS.Coolape.CLSmoothFollow
---@type Coolape.uvAn
uvAn = CS.Coolape.uvAn
---@type Coolape.CLEjector
CLEjector = CS.Coolape.CLEjector
-------------------------------------------------------
--
---@type MirrorReflection
MirrorReflection = CS.MirrorReflection

---@type CLGrid
CLGrid = CS.CLGrid
---@type Coolape.GridBase
GridBase = CS.Coolape.GridBase

---@type MyUnit
MyUnit = CS.MyUnit
---@type SFourWayArrow
SFourWayArrow = CS.SFourWayArrow
---@type MyUtl
MyUtl = CS.MyUtl

---@type CameraMgr
CameraMgr = CS.CameraMgr
ScriptableObject = CS.UnityEngine.ScriptableObject
--PostProcessingBehaviour = CS.UnityEngine.PostProcessing.PostProcessingBehaviour
PostProcessVolume = CS.UnityEngine.Rendering.PostProcessing.PostProcessingProfile

---@type MyUIPanel
MyUIPanel = CS.MyUIPanel

---@type FogOfWarSystem
FogOfWarSystem = CS.SimpleFogOfWar.FogOfWarSystem
---@type SimpleFogOfWar.FogOfWarInfluence
FogOfWarInfluence = CS.SimpleFogOfWar.FogOfWarInfluence

---@type ShipTrail
ShipTrail = CS.ShipTrail
---@type HUDText
HUDText = CS.HUDText
---@type MyBoundsPool
MyBoundsPool = CS.MyBoundsPool
-------------------------------------------------------
-- require
require("public.class")
json = require("json.json")
---@type CLQuickSort
CLQuickSort = require("toolkit.CLQuickSort")
-------------------------------------------------------
-- 子模式
GameModeSub = {
    none = 0,
    map = 1,
    city = 2,
    mapBtwncity = 4, -- 地图与主城之前切换
    fleet = 5 -- 舰队模式
}

-- 重载pcall，以便可以自动print error msg
local _pcall = pcall
function pcall(func, ...)
    local ret, result = _pcall(func, ...)
    if not ret then
        printe(result)
    end
    return ret, result
end
-------------------------------------------------------
