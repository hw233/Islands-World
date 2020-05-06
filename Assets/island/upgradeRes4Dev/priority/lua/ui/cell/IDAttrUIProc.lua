-- 建筑属性通用处理
require "public.IDAttrUtl"
local _cell = {}
local csSelf = nil
local transform = nil
local mData = nil
local uiobjs = {}
local attr
---@type NetProtoIsland.ST_building
local serverData

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    --[[
        上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider");
        --]]
    uiobjs.table = csSelf:GetComponent("UITable")
    uiobjs.cellPrefab = getChild(transform, "00000").gameObject
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    attr = mData.attr
    serverData = mData.serverData

    local list = IDAttrUtl.getUnitAttrs(mData.type, bio2number(attr.ID), serverData)
    if mData.maxRow and mData.maxRow > 0 and #list > mData.maxRow then
        uiobjs.table.columns = 2
    else
        uiobjs.table.columns = 1
    end
    CLUIUtl.resetList4Lua(uiobjs.table, uiobjs.cellPrefab, list, _cell.initCell)
end

function _cell.initCell(cell, data)
    cell:init(data, nil)
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
