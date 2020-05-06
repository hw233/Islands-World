--[[
-- //                    ooOoo
-- //                   8888888
-- //                  88" . "88
-- //                  (| -_- |)
-- //                  O\  =  /O
-- //               ____/`---'\____
-- //             .'  \\|     |//  `.
-- //            /  \\|||  :  |||//  \
-- //           /  _||||| -:- |||||-  \
-- //           |   | \\\  -  /// |   |
-- //           | \_|  ''\---/''  |_/ |
-- //            \ .-\__  `-`  ___/-. /
-- //         ___`. .'  /--.--\  `. . ___
-- //      ."" '<  `.___\_<|>_/___.'  >' "".
-- //     | | : ` - \`.` \ _ / `.`/- ` : | |
-- //     \ \ `-.    \_ __\ /__ _/   .-` / /
-- //======`-.____`-.___\_____/___.-`____.-'======
-- //                   `=---='
-- //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- //           佛祖保佑       永无BUG
-- //           游戏大卖       经济自由
-- //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--]]
---@class _ParamBattleFleetData 战场数据
---@field public type IDConst.BattleType 类型
---@field public battleData NetProtoIsland.ST_battleFleetDetail 战斗数据
---@field public result NetProtoIsland.ST_battleresult 结果(回放时用)

---@class _UnitAction
local _UnitAction = {
    attack = 1,
    move = 2,
    onHurt = 3,
    dead = 4
}

local lookAtTarget = MyCfg.self.lookAtTarget

---@class IDLFleetBattle  舰队vs舰队战斗逻辑
IDLFleetBattle = {}
IDLFleetBattle.unitsMap = {}
IDLFleetBattle.offUnitCount = 0
IDLFleetBattle.defUnitCount = 0
local isInited = false
---@type Coolape.GridBase
local gridLeft
---@type Coolape.GridBase
local gridRight
local gridSize = 10
---@type _ParamBattleFleetData
local mData

function IDLFleetBattle._init()
    if isInited then
        return
    end
    isInited = true
    gridLeft = GridBase()
    gridLeft:init(Vector3.zero, gridSize, gridSize, 1)

    gridRight = GridBase()
    gridRight:init(Vector3(10, 0, 0), gridSize, gridSize, 1)
end

function IDLFleetBattle.init(data, callback, progress)
    IDLFleetBattle.initCallback = callback
    IDLFleetBattle.onLoaedProgress = progress
    IDLFleetBattle._init()
    mData = data
    IDLFleetBattle.offUnitCount = 0
    IDLFleetBattle.defUnitCount = 0

    if IDWorldMap and IDWorldMap.oceanTransform then
        IDWorldMap.oceanTransform.position = Vector3.zero
    end
    SetActive(IDWorldMap.oceanTransform.gameObject, true)
    -- TODO:加载左右双方舰队
    IDLFleetBattle.totalUnits = #(mData.battleData.attackFleet.formations) + #(mData.battleData.defenseFleet.formations)
    IDLFleetBattle.loadedUnits = 0
    IDLFleetBattle.loadFleetUnits(true)
    IDLFleetBattle.loadFleetUnits(false)
end

function IDLFleetBattle.loadFleetUnits(isLeft)
    ---@type Coolape.GridBase
    local grid
    local formation
    if isLeft then
        grid = gridLeft
        formation = mData.battleData.attackFleet.formations
    else
        grid = gridRight
        formation = mData.battleData.defenseFleet.formations
    end

    ---@type _ParamBattleUnitData
    local unitData
    local pos
    ---@param v NetProtoIsland.ST_unitFormation
    for i, v in ipairs(formation) do
        pos = grid:GetCellCenter(bio2number(v.pos))
        CLRolePool.borrowObjAsyn(
            IDUtl.getRolePrefabName(bio2number(v.id)),
            IDLFleetBattle.onLoadUnit,
            {
                serverData = v,
                pos = pos,
                isOffense = isLeft,
                idx = bio2number(v.idx)
            }
        )
    end
end

function IDLFleetBattle.onLoadUnit(name, unit, orgs)
    local serverData = orgs.serverData
    local pos = orgs.pos
    local isOffense = orgs.isOffense
    local idx = orgs.idx
    orgs.battle = IDLFleetBattle
    local id = bio2number(serverData.id)

    unit.transform.parent = MyMain.self.transform
    unit.transform.localScale = Vector3.one
    if isOffense then
        unit.transform.localEulerAngles = Vector3(0, 45, 0)
    else
        unit.transform.localEulerAngles = Vector3(0, -90, 0)
    end
    if unit.luaTable == nil then
        ---@type IDRoleBase
        unit.luaTable = IDUtl.newRoleLua(id)
        unit:initGetLuaFunc()
    end
    SetActive(unit.gameObject, true)
    unit:init(id, 0, 1, true, orgs)
    local hight = bio2number(unit.luaTable.attr.FlyHeigh) / 10
    local offsetx = unit:fakeRandom(-10, 10) / 40
    local offsetz = unit:fakeRandom2(-10, 10) / 40
    pos = Vector3(offsetx + pos.x, hight, offsetz + pos.z)
    unit.transform.position = pos

    IDLFleetBattle.unitsMap[idx] = unit.luaTable
    if isOffense then
        IDLFleetBattle.offUnitCount = IDLFleetBattle.offUnitCount + 1
    else
        IDLFleetBattle.defUnitCount = IDLFleetBattle.defUnitCount + 1
    end
    IDLFleetBattle.loadedUnits = IDLFleetBattle.loadedUnits + 1
    Utl.doCallback(IDLFleetBattle.onLoaedProgress, IDLFleetBattle.totalUnits, IDLFleetBattle.loadedUnits)
    if IDLFleetBattle.loadedUnits >= IDLFleetBattle.totalUnits then
        -- finish
        IDLFleetBattle.finishLoadBattle()
    end
end

function IDLFleetBattle.finishLoadBattle()
    CameraMgr.self.subcamera.enabled = true
    -- 不要雾
    MyCfg.self.fogOfWar.enabled = false
    lookAtTarget.position = Vector3(5, 0, 5)
    lookAtTarget.localEulerAngles = Vector3.zero

    Utl.doCallback(IDLFleetBattle.initCallback)
end

function IDLFleetBattle.start()
    ---@param v NetProtoIsland.ST_unitAction
    for i, v in ipairs(mData.battleData.actionQueue) do
        InvokeEx.invokeByUpdate(IDLFleetBattle.doUnitAction, v, bio2number(v.timeMs) / 1000)
    end
end
---@param actionInfor NetProtoIsland.ST_unitAction
function IDLFleetBattle.doUnitAction(actionInfor)
    local type = bio2number(actionInfor.action)
    local idx = bio2number(actionInfor.idx)
    ---@type IDRoleBase
    local unit = IDLFleetBattle.unitsMap[idx]
    if unit == nil then
        return
    end
    if type == _UnitAction.attack then
        local taget = IDLFleetBattle.unitsMap[bio2number(actionInfor.targetVal)]
        if unit.id == 8 then
            -- 自爆
            unit:startFire(taget)
        else
            unit:fire(taget)
        end
    elseif type == _UnitAction.move then
        local target = IDLFleetBattle.unitsMap[bio2number(actionInfor.targetVal)]
        if target then
            ---@type UnityEngine.Vector3
            local diff = target.transform.position - unit.transform.position
            local toPos = unit.transform.position + diff.normalized * (unit.MaxAttackRange + 0.5)
            unit:moveTo4FleetBattle(toPos, target)
        end
    elseif type == _UnitAction.onHurt then
        local damage = bio2number(actionInfor.targetVal)
        unit:onHurt(damage, nil)
    elseif type == _UnitAction.dead then
        -- IDLFleetBattle.someOneDead(unit)
    end
end

function IDLFleetBattle.onBulletHit(bullet)
    ---@type DBCFBulletData
    local bulletAttr = bullet.attr
    ---@type IDLUnitBase
    local attacker = bullet.attacker.luaTable
    --//TODO:有一种可能就是当子弹击中目标时，发射子弹的对象已经死掉并且又被从对象池时取出来重新使用。不过好像这种情况在这个游戏里不太可能出理，先不考虑
    ---@type IDRoleBase
    local target = bullet.target and bullet.target.luaTable or nil
    CLEffect.play(bulletAttr.HitEffect, bullet.hitPoint)
    SoundEx.playSound(bulletAttr.HitSFX, 1, 2)
    if bulletAttr.IsScreenShake then
        -- 震屏
        SScreenShakes.play(nil, 0)
    end

end

---@param unit IDLUnitBase
function IDLFleetBattle.someOneDead(unit)
    unit:clean()
    unit.csSelf:clean()
    SetActive(unit.gameObject, false)

    if unit.isOffense then
        IDLFleetBattle.offUnitCount = IDLFleetBattle.offUnitCount - 1
    else
        IDLFleetBattle.defUnitCount = IDLFleetBattle.defUnitCount - 1
    end
    if IDLFleetBattle.offUnitCount <= 0 or IDLFleetBattle.defUnitCount <= 0 then
        IDLFleetBattle.stop()
    end
end

function IDLFleetBattle.stop()
    --//TODO:
end

function IDLFleetBattle.clean()
    InvokeEx.cancelInvokeByUpdate(IDLFleetBattle.doUnitAction)

    ---@param v IDRoleBase
    for k, v in pairs(IDLFleetBattle.unitsMap) do
        v.csSelf:clean() -- 只能过能csSelf调用clean,不然要死循环
        CLRolePool.returnObj(v.csSelf)
        SetActive(v.gameObject, false)
    end
    IDLFleetBattle.unitsMap = {}

    CameraMgr.self.subcamera.enabled = false
    -- 雾
    MyCfg.self.fogOfWar.enabled = true
end

function IDLFleetBattle.destory()
    IDLFleetBattle.clean()
    gridLeft = nil
    gridRight = nil
    IDLFleetBattle.isInited = false
end

return IDLFleetBattle
