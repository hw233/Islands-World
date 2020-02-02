---@class UIPanel : UIRect
---@field public list System.Collections.Generic.List1UIPanel
---@field public onGeometryUpdated UIPanel.OnGeometryUpdated
---@field public showInPanelTool System.Boolean
---@field public generateNormals System.Boolean
---@field public widgetsAreStatic System.Boolean
---@field public cullWhileDragging System.Boolean
---@field public alwaysOnScreen System.Boolean
---@field public anchorOffset System.Boolean
---@field public softBorderPadding System.Boolean
---@field public renderQueue UIPanel.RenderQueue
---@field public startingRenderQueue System.Int32
---@field public widgets System.Collections.Generic.List1UIWidget
---@field public drawCalls System.Collections.Generic.List1UIDrawCall
---@field public worldToLocal UnityEngine.Matrix4x4
---@field public drawCallClipRange UnityEngine.Vector4
---@field public onClipMove UIPanel.OnClippingMoved
---@field public nextUnusedDepth System.Int32
---@field public canBeAnchored System.Boolean
---@field public alpha System.Single
---@field public depth System.Int32
---@field public sortingOrder System.Int32
---@field public width System.Single
---@field public height System.Single
---@field public halfPixelOffset System.Boolean
---@field public usedForUI System.Boolean
---@field public drawCallOffset UnityEngine.Vector3
---@field public clipping UIDrawCall.Clipping
---@field public parentPanel UIPanel
---@field public clipCount System.Int32
---@field public hasClipping System.Boolean
---@field public hasCumulativeClipping System.Boolean
---@field public clipOffset UnityEngine.Vector2
---@field public clipTexture UnityEngine.Texture2D
---@field public baseClipRegion UnityEngine.Vector4
---@field public finalClipRegion UnityEngine.Vector4
---@field public clipSoftness UnityEngine.Vector2
---@field public localCorners UnityEngine.Vector3
---@field public worldCorners UnityEngine.Vector3
local m = { }
---public UIPanel .ctor()
---@return UIPanel
function m.New() end
---public Int32 CompareFunc(UIPanel a, UIPanel b)
---@return number
---@param optional UIPanel a
---@param optional UIPanel b
function m.CompareFunc(a, b) end
---public Vector3[] GetSides(Transform relativeTo)
---@return table
---@param optional Transform relativeTo
function m:GetSides(relativeTo) end
---public Void Invalidate(Boolean includeChildren)
---@param optional Boolean includeChildren
function m:Invalidate(includeChildren) end
---public Single CalculateFinalAlpha(Int32 frameID)
---@return number
---@param optional Int32 frameID
function m:CalculateFinalAlpha(frameID) end
---public Void SetRect(Single x, Single y, Single width, Single height)
---@param optional Single x
---@param optional Single y
---@param optional Single width
---@param optional Single height
function m:SetRect(x, y, width, height) end
---public Boolean IsVisible(Vector3 worldPos)
---public Boolean IsVisible(UIWidget w)
---public Boolean IsVisible(Vector3 a, Vector3 b, Vector3 c, Vector3 d)
---@return bool
---@param Vector3 a
---@param Vector3 b
---@param Vector3 c
---@param optional Vector3 d
function m:IsVisible(a, b, c, d) end
---public Boolean Affects(UIWidget w)
---@return bool
---@param optional UIWidget w
function m:Affects(w) end
---public Void RebuildAllDrawCalls()
function m:RebuildAllDrawCalls() end
---public Void SetDirty()
function m:SetDirty() end
---public Void ParentHasChanged()
function m:ParentHasChanged() end
---public Void SortWidgets()
function m:SortWidgets() end
---public UIDrawCall FindDrawCall(UIWidget w)
---@return UIDrawCall
---@param optional UIWidget w
function m:FindDrawCall(w) end
---public Void AddWidget(UIWidget w)
---@param optional UIWidget w
function m:AddWidget(w) end
---public Void RemoveWidget(UIWidget w)
---@param optional UIWidget w
function m:RemoveWidget(w) end
---public Void Refresh()
function m:Refresh() end
---public Vector3 CalculateConstrainOffset(Vector2 min, Vector2 max)
---@return Vector3
---@param optional Vector2 min
---@param optional Vector2 max
function m:CalculateConstrainOffset(min, max) end
---public Boolean ConstrainTargetToBounds(Transform target, Boolean immediate)
---public Boolean ConstrainTargetToBounds(Transform target, Bounds& targetBounds, Boolean immediate)
---@return bool
---@param Transform target
---@param optional Bounds& targetBounds
---@param optional Boolean immediate
function m:ConstrainTargetToBounds(target, targetBounds, immediate) end
---public UIPanel Find(Transform trans)
---public UIPanel Find(Transform trans, Boolean createIfMissing)
---public UIPanel Find(Transform trans, Boolean createIfMissing, Int32 layer)
---@return UIPanel
---@param Transform trans
---@param Boolean createIfMissing
---@param optional Int32 layer
function m.Find(trans, createIfMissing, layer) end
---public Vector2 GetWindowSize()
---@return Vector2
function m:GetWindowSize() end
---public Vector2 GetViewSize()
---@return Vector2
function m:GetViewSize() end
UIPanel = m
return m
