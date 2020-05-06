---@class IDCellMail
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type NetProtoIsland.ST_mail
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.Selected = getChild(transform, "Selected").gameObject
    uiobjs.LabelTitle = getCC(transform, "LabelTitle", "UILabel")
    uiobjs.LabelType = getCC(transform, "LabelType", "UILabel")
    uiobjs.LabelTime = getCC(transform, "LabelTime", "UILabel")
    uiobjs.SpriteState = getCC(transform, "SpriteState", "UISprite")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
---@param data NetProtoIsland.ST_mail
function _cell.show(go, data)
    mData = data
    local title = LWrap(mData.title, mData.titleParams)
    if #(mData.historyList) > 1 then
        uiobjs.LabelTitle.text = joinStr("Re:", title)
    else
        uiobjs.LabelTitle.text = title
    end
    uiobjs.LabelTime.text = IDUtl.timeCost(DateEx.nowMS - bio2number(mData.date))
    uiobjs.LabelType.text = LGet(IDConst.MailTypeName[bio2number(data.type)])
    if bio2number(mData.fromPidx) == bio2number(IDDBPlayer.myself.idx) then
        -- 说明是自己发的邮件
        CLUIUtl.setSpriteFit(uiobjs.SpriteState, "mail_Icon_Yj_yidu")
    else
        if bio2number(mData.state) == IDConst.MailState.readRewared then
            CLUIUtl.setSpriteFit(uiobjs.SpriteState, "mail_Icon_Yj_yidu")
        else
            CLUIUtl.setSpriteFit(uiobjs.SpriteState, "mail_Icon_Yj_weidu")
        end
    end
    _cell.selected(mData.isSelected or false)
end

function _cell.selected(val)
    SetActive(uiobjs.Selected, val)
end

-- 取得数据
---@return NetProtoIsland.ST_mail
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
