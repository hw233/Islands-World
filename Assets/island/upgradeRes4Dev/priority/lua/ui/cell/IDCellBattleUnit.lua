-- xx单元
local _cell = {}
local csSelf = nil
local transform = nil
---@type _ParamBattleUnitData
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.toggle = csSelf:GetComponent("UIToggle")
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    uiobjs.LabelName = getCC(transform, "LabelName", "UILabel")
    uiobjs.LabelNum = getCC(transform, "LabelNum", "UILabel")
    uiobjs.LabelLev = getCC(transform, "LabelLev", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
	mData = data
    uiobjs.SpriteIcon.spriteName = mData.icon
    uiobjs.LabelName.text = mData.name
    uiobjs.LabelNum.text = joinStr(bio2number(mData.num), "")
    uiobjs.LabelLev.text = LGetFmt("LevelWithNum", bio2number(mData.lev))
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
