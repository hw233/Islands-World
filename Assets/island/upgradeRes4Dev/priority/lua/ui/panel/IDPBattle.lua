---@class _ParamBattleUnitData 战斗单元的数据包装
---@field public type IDConst.UnitType
---@field public id System.Int32
---@field public name String
---@field public icon String
---@field public num bio
---@field public lev bio
---@field public fidx bio 所属舰队idx
---@field public bidx bio 所属建筑idx

-- xx界面
IDPBattle = {}

local csSelf = nil
local transform = nil
---@type _ParamBattleData
local mData
local uiobjs = {}

-- 初始化，只会调用一次
function IDPBattle.init(csObj)
    ---@type Coolape.CLPanelLua
    IDPBattle.csSelf = csObj
    csSelf = csObj
    transform = csObj.transform
    --[[
    上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider");
	--]]
    uiobjs.unitGrid = getCC(transform, "AnchorBottom/Scroll View/Grid", "UIGrid")
    uiobjs.unitGridPrefab = getChild(uiobjs.unitGrid.transform, "00000").gameObject
end

-- 设置数据
function IDPBattle.setData(paras)
    mData = paras
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPBattle.show()
    CLUIDrag4World.setCanClickPanel(csSelf.name)
end

-- 刷新
function IDPBattle.refresh()
    IDPBattle.showUnits()
end

function IDPBattle.showUnits()
    -- wrap mData
    local list = {}
    local units = {}
    ---@type _ParamBattleUnitData
    local cellData
    ---@param v NetProtoIsland.ST_unitInfor
    for k, v in pairs(mData.fleet.units) do
        local shipId = bio2number(v.id)
        local attr = DBCfg.getRoleByID(shipId)
        cellData = {}
        cellData.type = IDConst.UnitType.role
        cellData.id = shipId
        cellData.num = v.num
        cellData.name = LGet(attr.NameKey)
        cellData.icon = IDUtl.getRoleIcon(shipId)
        cellData.fidx = mData.fleet.idx
        if bio2number(attr.GID) ~= IDConst.RoleGID.pet then
            -- 需要根据科技来设置等级
            local techId = bio2number(attr.TechID)
            cellData.lev = number2bio(IDDBCity.curCity:getTechLev(techId))
        else
            --//TODO: 海怪的等级不是通过科技
        end
        table.insert(units, cellData)
    end

    -- 设置魔法
    if IDDBCity.curCity.magicAltar then
        local list = IDDBCity.curCity:getUnitsByBIdx(bio2number(IDDBCity.curCity.magicAltar.idx))
        ---@param v NetProtoIsland.ST_unitInfor
        for i, v in pairs(list) do
            local id = bio2number(v.id)
            ---@type DBCFMagicData
            local attr = DBCfg.getDataById(DBCfg.CfgPath.Magic, id)
            cellData = {}
            cellData.type = IDConst.UnitType.skill
            cellData.id = id
            cellData.num = v.num
            cellData.name = LGet(attr.NameKey)
            cellData.icon = attr.Icon
            cellData.bidx = IDDBCity.curCity.magicAltar.idx
            cellData.lev = number2bio(IDDBCity.curCity:getMagicLev(id))
            table.insert(units, cellData)
        end
    end

    CLUIUtl.resetList4Lua(uiobjs.unitGrid, uiobjs.unitGridPrefab, units, IDPBattle.initUnitCell)
end

function IDPBattle.initUnitCell(cell, data)
    cell:init(data, IDPBattle.onClickUnitCell)
end

---@param cell Coolape.CLCellLua
function IDPBattle.onClickUnitCell(cell)
    local data = cell.luaTable.getData()
    IDPBattle.selectedUnit = cell
    IDLBattle.setSelectedUnit(data)
end

-- 关闭页面
function IDPBattle.hide()
    IDPBattle.selectedUnit = nil
    CLUIDrag4World.removeCanClickPanel(csSelf.name)
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPBattle.procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.sendEndAttackIsland then
            hideHotWheel()
            IDLBattle.endBattle()
        end
    end
end

-- 处理ui上的事件，例如点击等
function IDPBattle.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonQuit" then
        --//强制退出战斗时，通知服务器
        showHotWheel()
        CLLNet.send(NetProtoIsland.send.quitIslandBattle(bio2number(mData.fleet.idx)))
    end
end

function IDPBattle.onDeployBattleUnit(data)
    IDPBattle.selectedUnit.luaTable.show(nil, data)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPBattle.hideSelfOnKeyBack()
    return false
end

--------------------------------------------
return IDPBattle
