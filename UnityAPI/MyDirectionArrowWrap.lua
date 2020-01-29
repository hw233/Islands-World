---@class MyDirectionArrow : UnityEngine.MonoBehaviour
---@field public isSharedMaterial System.Boolean
---@field public line UnityEngine.LineRenderer
---@field public arrow UnityEngine.Transform
---@field public lineMaterail UnityEngine.Material
local m = { }
---public MyDirectionArrow .ctor()
---@return MyDirectionArrow
function m.New() end
---public Void setMaterailScale(Single dis)
---@param optional Single dis
function m:setMaterailScale(dis) end
---public Void init(Single startWidth, Single endWidth, Color startColor, Color endColor, Single dottedSpacing)
---@param optional Single startWidth
---@param optional Single endWidth
---@param optional Color startColor
---@param optional Color endColor
---@param optional Single dottedSpacing
function m:init(startWidth, endWidth, startColor, endColor, dottedSpacing) end
---public Void SetPosition(Vector3 startPos, Vector3 endPos)
---@param optional Vector3 startPos
---@param optional Vector3 endPos
function m:SetPosition(startPos, endPos) end
---public Void SetEndPosition(Vector3 endPos)
---@param optional Vector3 endPos
function m:SetEndPosition(endPos) end
---public Void SetStartPosition(Vector3 startPos)
---@param optional Vector3 startPos
function m:SetStartPosition(startPos) end
---public Void SetPositions(List`1 path, Vector3 startPos, Int32 startIndex)
---@param optional List`1 path
---@param optional Vector3 startPos
---@param optional Int32 startIndex
function m:SetPositions(path, startPos, startIndex) end
MyDirectionArrow = m
return m
