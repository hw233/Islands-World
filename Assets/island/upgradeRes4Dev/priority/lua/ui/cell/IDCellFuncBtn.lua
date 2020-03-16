---@class _ParamCellFuncBtn
---@field public label string
---@field public icon string
---@field public showReddot boolean 显示红点
---@field public onClick function 点击的回调
---@field public params object 回调参数

local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type _ParamCellFuncBtn
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.Label = getCC(transform, "Label", "UILabel")
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    uiobjs.SpriteReddot = getCC(transform, "SpriteReddot", "UISprite")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    uiobjs.Label.text = LGet(mData.label)
    uiobjs.SpriteIcon.spriteName = mData.icon
    SetActive(uiobjs.SpriteReddot.gameObject, mData.showReddot or false)
end

-- 取得数据
function _cell.getData()
    return mData
end

function _cell.uiEventDelegate(go)
    if mData.onClick then
        mData.onClick(mData.params)
    end
end

--------------------------------------------
return _cell
