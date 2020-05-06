---@class _ParamCellPopupButton
---@field public label string
---@field public background string
---@field public callback function
---@field public paras object 回调参数

-- xx单元
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type _ParamCellPopupButton
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.background = csSelf:GetComponent("UISprite")
    uiobjs.Label = getCC(transform, "Label", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    uiobjs.Label.text = mData.label
    uiobjs.background.spriteName = mData.background and  mData.background or "public_common_bt_blue_l3" --//TODO:先使用这个图片
 end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
