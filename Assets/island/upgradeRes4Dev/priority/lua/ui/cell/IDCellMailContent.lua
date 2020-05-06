-- xx单元
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type NetProtoIsland.ST_mail
local mData = nil
local uiobjs = {}
local table = table

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    ---@type UITable
    uiobjs.table = csSelf:GetComponent("UITable")
    uiobjs.LabelLine = getCC(transform, "LabelLine", "UILabel")
    uiobjs.LabelSender = getCC(transform, "LabelSender", "UILabel")
    uiobjs.LabelTime = getCC(uiobjs.LabelSender.transform, "LabelTime", "UILabel")
    uiobjs.LabelContent = getCC(transform, "LabelContent", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    local lines = {}
    for i = 1, mData.lineSize do
        table.insert(lines, "=>")
    end
    uiobjs.LabelLine.text = table.concat(lines, "")
    uiobjs.LabelSender.text = joinStr(LGet("Sender"), ":", mData.fromName)
    uiobjs.LabelTime.text = DateEx.formatByMs(bio2number(mData.date))
    uiobjs.LabelContent.text = LWrap(mData.content, mData.contentParams)
    uiobjs.table:Reposition()
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
