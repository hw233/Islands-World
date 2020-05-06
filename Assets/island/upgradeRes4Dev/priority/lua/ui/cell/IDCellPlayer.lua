-- xx单元
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.toggle = csSelf:GetComponent("UIToggle")
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    uiobjs.LabelName = getCC(transform, "LabelName", "UILabel")
    uiobjs.SpriteReddot = getChild(transform, "SpriteReddot")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    local pidx = mData
    SetActive(uiobjs.SpriteReddot.gameObject, IDDBChat.hadReddotByPidx(pidx))
    IDDBPlayer.getPlayerSimple(pidx, _cell.setPlayerInfor)
end

---@param data NetProtoIsland.ST_playerSimple
function _cell.setPlayerInfor(data)
    uiobjs.LabelName.text = data.name
    uiobjs.SpriteIcon.spriteName = joinStr("playerIcon_", bio2number(data.icon))
end

function _cell.setSelected(val)
    uiobjs.toggle.value = val
end

function _cell.refreshReddot()
    SetActive(uiobjs.SpriteReddot.gameObject, IDDBChat.hadReddotByPidx(mData))
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
