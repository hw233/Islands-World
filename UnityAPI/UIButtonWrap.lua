---@class UIButton : UIButtonColor
---@field public current UIButton
---@field public dragHighlight System.Boolean
---@field public hoverSprite System.String
---@field public pressedSprite System.String
---@field public disabledSprite System.String
---@field public hoverSprite2D UnityEngine.Sprite
---@field public pressedSprite2D UnityEngine.Sprite
---@field public disabledSprite2D UnityEngine.Sprite
---@field public pixelSnap System.Boolean
---@field public onClick System.Collections.Generic.List1EventDelegate
---@field public isEnabled System.Boolean
---@field public normalSprite System.String
---@field public normalSprite2D UnityEngine.Sprite
local m = { }
---public UIButton .ctor()
---@return UIButton
function m.New() end
---public Void OnClick()
function m:OnClick() end
---public Void SetState(State state, Boolean immediate)
---@param optional State state
---@param optional Boolean immediate
function m:SetState(state, immediate) end
UIButton = m
return m
