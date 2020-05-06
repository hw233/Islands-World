---@class UIRoot : UnityEngine.MonoBehaviour
---@field public list System.Collections.Generic.List1UIRoot
---@field public scalingStyle UIRoot.Scaling
---@field public manualWidth System.Int32
---@field public manualHeight System.Int32
---@field public minimumHeight System.Int32
---@field public maximumHeight System.Int32
---@field public fitWidth System.Boolean
---@field public fitHeight System.Boolean
---@field public adjustByDPI System.Boolean
---@field public shrinkPortraitUI System.Boolean
---@field public constraint UIRoot.Constraint
---@field public activeScaling UIRoot.Scaling
---@field public activeHeight System.Int32
---@field public pixelSizeAdjustment System.Single
local m = { }
---public UIRoot .ctor()
---@return UIRoot
function m.New() end
---public Single GetPixelSizeAdjustment(GameObject go)
---public Single GetPixelSizeAdjustment(Int32 height)
---@return number
---@param optional Int32 height
function m.GetPixelSizeAdjustment(height) end
---public Void UpdateScale(Boolean updateAnchors)
---@param optional Boolean updateAnchors
function m:UpdateScale(updateAnchors) end
---public Void Broadcast(String funcName)
---public Void Broadcast(String funcName, Object param)
---@param String funcName
---@param optional Object param
function m.Broadcast(funcName, param) end
UIRoot = m
return m
