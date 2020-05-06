-- xx单元
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type DBCFTechData
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    ---@type UIToggle
    uiobjs.toggle = csSelf:GetComponent("UIToggle")
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    uiobjs.LabelName = getCC(transform, "LabelName", "UILabel")
    uiobjs.LabelLev = getCC(transform, "LabelLev", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    local id = bio2number(mData.ID)
    local lev = IDDBCity.curCity:getTechLev(id)
    local isupgrading = IDDBCity.curCity:isTechUpgrading(id)
    uiobjs.SpriteIcon.spriteName = mData.Icon
    uiobjs.LabelName.text = LGet(mData.NameKey)
    if IDDBCity.curCity:isTechUnlocked(id) then
        CLUIUtl.setAllSpriteGray(csSelf.gameObject, false)
        if isupgrading then
            uiobjs.LabelLev.text = joinStr(LGet("Level"), ":", lev, "  [00ff00]", LGet("Upgrading"), "[-]")
        else
            uiobjs.LabelLev.text = joinStr(LGet("Level"), ":", lev)
        end
    else
        CLUIUtl.setAllSpriteGray(csSelf.gameObject, true)
        uiobjs.LabelLev.text = joinStr("[ff0000]", LGet("Locked"), "[-]")
    end
end

function _cell.setSelect(val)
    uiobjs.toggle.value = val
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
