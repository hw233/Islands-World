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
---@class _ParamBattleData 战场数据
---@field public type IDConst.BattleType 类型
---@field public attackPlayer IDDBPlayer 进攻方玩家信息
---@field public targetPlayer IDDBPlayer 被攻击方玩家信息
---@field public targetCity IDDBCity 被攻击方主城信息(舰船数据已经在city结构里)
---@field public fleet NetProtoIsland.ST_fleetinfor 进攻舰队数据
---@field public isReplay boolean 是否回放
---@field public isWatching boolean 是否观看模式
---@field public deployQueue table 投放战斗单元(回放时用)
---@field public endFrames number 结束时的帧数(回放时用)
---@field public result NetProtoIsland.ST_battleresult 结果(回放时用)

---@class IDLBattle  战斗逻辑
IDLBattle = {}
---@type IDPreloadPrefab
local IDPreloadPrefab = require("public.IDPreloadPrefab")
---@type IDLBattleSearcher
local IDLBattleSearcher = require("battle.IDLBattleSearcher")
---@type IDLBattleSearcher
IDLBattle.searcher = IDLBattleSearcher

local lookAtTarget = MyCfg.self.lookAtTarget

---@type _ParamBattleUnitData
IDLBattle.currSelectedUnit = nil
---@type Coolape.CLBaseLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
---@type IDMainCity
local city = nil -- 城池对象
---@type CLGrid
local grid
local Time = Time
---@type _ParamBattleData
IDLBattle.mData = nil -- 战斗方数据
IDLBattle.isFirstDeployRole = true
-- 一次部署的数量
local EachDeployNum = 1
-- 进攻舰船
IDLBattle.offShips = {}
IDLBattle.defShips = {}
IDLBattle.skills = {}
local __isInited = false
IDLBattle.isDebug = false
IDLBattle.isEnterCity = false

--------------------------------------------
function IDLBattle._init()
    if __isInited then
        return
    end
    __isInited = true
    local go = GameObject("battleRoot")
    csSelf = go:AddComponent(typeof(CLBaseLua))
    ---@type Coolape.CLBaseLua
    IDLBattle.csSelf = csSelf
    IDLBattle.csSelf.luaTable = IDLBattle

    IDLBattle.gameObject = csSelf.gameObject
    IDLBattle.transform = csSelf.transform
    transform = IDLBattle.transform
    IDLBattle.transform.parent = MyMain.self.transform
    IDLBattle.transform.localPosition = Vector3.zero
    IDLBattle.transform.localScale = Vector3.one
end

---public 初始化
---@param data _ParamBattleData 进攻方数据
---@param callback 回调
---@param progressCB 进度回调
function IDLBattle.init(data, callback, progressCB)
    IDLBattle._init()
    IDLBattle.isStoped = false
    IDLBattle.isEnterCity = false
    IDLBattle.mData = data
    -- 先暂停资源释放
    CLAssetsManager.self:pause()
    -- IDWorldMap.addFinishEnterCityCallback(IDLBattle.onEnterCity)

    local posindex = bio2number(IDLBattle.mData.targetCity.pos)

    -- 先切到大地图发生战斗的地点
    IDWorldMap.moveToView(posindex, GameModeSub.map, nil)

    -- 加载城
    IDMainCity.init(
        IDLBattle.mData.targetCity,
        function()
            city = IDMainCity
            grid = city.grid
            -- 预加载进攻方兵种
            IDLBattle.prepareSoliders(
                IDLBattle.mData.fleet.units,
                function()
                    IDWorldMap.moveToView(posindex, GameModeSub.city, IDLBattle.onEnterCity)
                    Utl.doCallback(callback)
                end,
                progressCB
            )
        end,
        progressCB,
        true
    )
end

function IDLBattle.onEnterCity()
    IDLBattle.isEnterCity = true
    -- 初始化寻敌器
    IDLBattleSearcher.init(city)
    city.grid:showRect()
    CameraMgr.self.subcamera.enabled = true
    -- 不要雾
    MyCfg.self.fogOfWar.enabled = false

    if IDLBattle.mData.isReplay then
        getPanelAsy(
            "PanelBattleReplay",
            function(p)
                onLoadedPanel(p, IDLBattle.mData)
                -- 回放
                IDLBattle.startReplay()
            end,
            IDLBattle.mData
        )
    elseif IDLBattle.mData.isWatching then
        getPanelAsy(
            "PanelBeingAttacked",
            function(p)
                onLoadedPanel(p, IDLBattle.mData)
                p.luaTable.setCanDragScreem()
            end,
            IDLBattle.mData
        )
    else
        IDMainCity.showDeployRange()
        getPanelAsy("PanelBattle", onLoadedPanel, IDLBattle.mData)
    end
end

---public 预加载进攻方兵种
function IDLBattle.prepareSoliders(data, callback, progressCB)
    IDPreloadPrefab.preloadRoles(data, callback, progressCB)
end

---public 设置当前选择的战斗单元
function IDLBattle.setSelectedUnit(data)
    IDLBattle.currSelectedUnit = data
end

---public 点击了海面
function IDLBattle.onClickOcean()
    if IDLBattle.mData.isReplay or IDLBattle.mData.isWatching then
        return
    end
    local clickPos = MyMainCamera.lastHit.point
    local index = grid.grid:GetCellIndex(clickPos)
    if index < 0 then
        CLAlert.add(LGet("MsgDeployUnitInRange"), Color.yellow, 1)
        -- city.grid:showRect()
        -- csSelf:invoke4Lua(IDLBattle.hideCityRange, 3)
        return
    end
    IDLBattle.deployBattleUnit()
end

-- function IDLBattle.hideCityRange()
-- city.grid:hideRect()
-- end

---public 通知战场，玩家点击了我
function IDLBattle.onClickSomeObj(obj, pos)
    if IDLBattle.mData.isReplay or IDLBattle.mData.isWatching then
        return
    end
    if IDLBattle.isDebug and obj.isBuilding then
        IDLBattleSearcher.debugBuildingAttackRange(obj)
    end
    IDLBattle.deployBattleUnit()
end

---public 开始战斗
function IDLBattle.begain()
    local buildings = city.getBuildings()
    ---@param v IDLBuilding
    for k, v in pairs(buildings) do
        if v.begainAttack then
            v:begainAttack()
        end
    end
end

---public 投放兵
function IDLBattle.deployBattleUnit()
    if IDLBattle.currSelectedUnit == nil then
        CLAlert.add(LGet("MsgSelectBattleUnit"), Color.yellow, 1)
        return
    end
    if bio2Int(IDLBattle.currSelectedUnit.num) <= 0 then
        CLAlert.add(LGet("MsgSelectBattleUnit"), Color.yellow, 1)
        return
    end
    local pos = MyMainCamera.lastHit.point
    pos.y = 0
    -- local grid = grid.grid
    -- local index = grid:GetCellIndex(pos)
    -- local cellPos = grid:GetCellCenter(index)
    if IDMainCity.canDeploy(pos) or IDLBattle.currSelectedUnit.type == IDConst.UnitType.skill then
        IDLBattle.doDeployUnit(pos, IDLBattle.currSelectedUnit)
    else
        CLAlert.add(LGet("MsgCannotPlaceOnthePoint"), Color.red, 1)
        SoundEx.playSound("bad_move_06", 1, 1)
        IDMainCity.showDeployRange()
        csSelf:invoke4Lua(IDMainCity.hideDeployRange, 3)
    end
end

---@param unitData _ParamBattleUnitData
function IDLBattle.doDeployUnit(pos, unitData, fakeRandom, fakeRandom2, fakeRandom3)
    if IDLBattle.isFirstDeployRole then
        -- 首次投放战斗单元，的处理
        IDLBattle.isFirstDeployRole = false
        -- 记录开始投放的帧数
        IDLBattle.startFrame = InvokeEx.self.frameCounter
        if IDLBattle.mData.type == IDConst.BattleType.attackIsland then
            SoundEx.playMainMusic("BattleSound1")
        elseif IDLBattle.mData.type == IDConst.BattleType.attackFleet then
            SoundEx.playMainMusic("npc")
        end
        -- 战斗正式开始
        IDLBattle.csSelf:invoke4Lua(IDLBattle.begain, 1)
    end
    -- 隐藏投兵区域
    IDMainCity.hideDeployRange()

    if unitData.type == IDConst.UnitType.role then
        if (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) then
            fakeRandom = NumEx.NextInt(0, 1001)
            fakeRandom2 = NumEx.NextInt(0, 1001)
            fakeRandom3 = NumEx.NextInt(0, 1001)
            -- 通知服务器
            IDLBattle.sendDeployInfor2Server(
                IDLBattle.currSelectedUnit,
                pos,
                fakeRandom,
                fakeRandom2,
                fakeRandom3,
                true
            )
        end
        -- 投放兵
        IDLBattle.DeployRole(unitData, pos, fakeRandom, fakeRandom2, fakeRandom3, true)
    elseif unitData.type == IDConst.UnitType.skill then
        -- 技能释放
        IDLBattle.DeploySkill(IDLBattle.currSelectedUnit, pos)
    end
end

---@param shipData _ParamBattleUnitData
function IDLBattle.sendDeployInfor2Server(shipData, pos, fakeRandom, fakeRandom2, fakeRandom3, isOffense)
    local id = shipData.id
    ---@type NetProtoIsland.ST_unitInfor
    local unit = {}
    unit.fidx = bio2number(shipData.fidx)
    unit.bidx = bio2number(shipData.bidx)
    unit.id = id
    unit.num = EachDeployNum
    unit.type = shipData.type

    ---@type NetProtoIsland.ST_vector3
    local v3 = {}
    v3.x = NumEx.getIntPart(pos.x * 1000)
    v3.y = NumEx.getIntPart(pos.y * 1000)
    v3.z = NumEx.getIntPart(pos.z * 1000)
    local frame = InvokeEx.self.frameCounter - IDLBattle.startFrame
    CLLNet.send(
        NetProtoIsland.send.onBattleDeployUnit(
            bio2number(IDLBattle.mData.fleet.idx),
            unit,
            frame,
            v3,
            fakeRandom,
            fakeRandom2,
            fakeRandom3,
            isOffense
        )
    )
end

---@param unitInfor _ParamBattleUnitData
function IDLBattle.DeploySkill(unitInfor, pos)
    unitInfor.num = number2bio(bio2number(unitInfor.num) - 1)
    if (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) then
        -- 通知服务器
        IDLBattle.sendDeployInfor2Server(unitInfor, pos, 0, 0, 0, true)
        -- 通知ui
        if IDPBattle then
            IDPBattle.onDeployBattleUnit(unitInfor)
        end
    end
    local index = city.grid.grid:GetCellIndex(pos)
    local offset = city.getPosOffset(index)
    pos = pos + offset

    ---@type DBCFMagicData
    local attr = DBCfg.getDataById(DBCfg.CfgPath.Magic, unitInfor.id)
    -- 播放技能效果
    CLThingsPool.borrowObjAsyn(
        attr.Prefab,
        function(name, go, orgs)
            ---@type MyUnit
            local cell = go:GetComponent("MyUnit")
            cell.transform.localScale = Vector3.one
            cell.transform.eulerAngles = Vector3.zero
            cell.transform.position = pos
            if cell.luaTable == nil then
                ---@type IDLSkillBase
                cell.luaTable = IDUtl.newSkillLua(unitInfor.id)
            end
            SetActive(go, true)
            cell.luaTable:init(cell, unitInfor.id, unitInfor.lev, pos, IDLBattle)
            IDLBattle.skills[cell.instanceID] = cell.luaTable
            cell.luaTable:startAttack()
        end
    )
end

---@param skill IDLSkillBase
function IDLBattle.onFinishSkillAttack(skill)
    skill:clean()
    CLThingsPool.returnObj(skill.csSelf.gameObject)
    SetActive(skill.csSelf.gameObject, false)
    IDLBattle.skills[skill.csSelf.instanceID] = nil
end

---public 部署舰船
---@param shipData _ParamBattleUnitData
---@param pos UnityEngine.Vector3
function IDLBattle.DeployRole(shipData, pos, fakeRandom, fakeRandom2, fakeRandom3, isOffense, needDeployNum)
    if isOffense then
        CLEffect.play("EffectDeploy", pos)
        SoundEx.playSound("water_craft_place_01", 1, 2)
    end

    local id = shipData.id
    local deployNum = 0
    if needDeployNum then
        deployNum = needDeployNum
    else
        local num = bio2Int(shipData.num)
        if num >= EachDeployNum then
            deployNum = EachDeployNum
        else
            deployNum = num
        end
        shipData.num = int2Bio(num - deployNum)

        -- 通知ui
        if (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) and IDPBattle then
            IDPBattle.onDeployBattleUnit(shipData)
        end
    end

    -- 加载舰船
    for i = 1, deployNum do
        CLRolePool.borrowObjAsyn(
            IDUtl.getRolePrefabName(id),
            IDLBattle.onLoadShip,
            {
                serverData = shipData,
                pos = pos,
                fakeRandom = fakeRandom,
                fakeRandom2 = fakeRandom2,
                fakeRandom3 = fakeRandom3,
                isOffense = isOffense
            }
        )
    end
end

---@param ship Coolape.CLUnit
---@param orgs _ParamRoleOtherData
function IDLBattle.onLoadShip(name, ship, orgs)
    local serverData = orgs.serverData
    local pos = orgs.pos
    local isOffense = orgs.isOffense
    orgs.battle = IDLBattle
    ship.transform.parent = transform
    ship.transform.localScale = Vector3.one
    -- ship.transform.localEulerAngles = Vector3.zero
    local headquarters = city.Headquarters
    local dir = headquarters.transform.position - pos
    Utl.RotateTowards(ship.transform, dir)
    if ship.luaTable == nil then
        ---@type IDRoleBase
        ship.luaTable = IDUtl.newRoleLua(serverData.id)
        ship:initGetLuaFunc()
    end
    SetActive(ship.gameObject, true)
    ship:init(serverData.id, 0, 1, true, orgs)
    local hight = bio2number(ship.luaTable.attr.FlyHeigh) / 10
    local offsetx = ship:fakeRandom(-10, 10) / 10
    local offsetz = ship:fakeRandom2(-10, 10) / 10
    pos = Vector3(offsetx + pos.x, hight, offsetz + pos.z)
    ship.transform.position = pos
    IDLBattle.someOneJoin(ship.luaTable)
end

---public 有单位加入战场
---@param unit IDRoleBase
function IDLBattle.someOneJoin(unit)
    if IDLBattle.isStoped then
        return
    end
    if unit.isOffense then
        IDLBattle.offShips[unit.instanceID] = unit
    else
        IDLBattle.defShips[unit.instanceID] = unit
    end
    IDLBattleSearcher.refreshUnit(unit)
    unit:doAttack()
end

---public 有单位死掉了
---@param unit IDLUnitBase
function IDLBattle.someOneDead(unit)
    if IDLBattle.isStoped then
        return
    end
    IDLBattleSearcher.someOneDead(unit)
    -- 应该只需要return移动的战斗单元就可以了,建筑是通过城市来做释放处理的
    if unit.isRole then
        ---@type IDRoleBase
        local role = unit
        ---@type NetProtoIsland.ST_unitInfor
        local unitInfor = {}
        unitInfor.id = role.id
        unitInfor.num = 1
        unitInfor.type = IDConst.UnitType.role
        if role.isOffense then
            unitInfor.fidx = bio2number(role.serverData.fidx)
            IDLBattle.offShips[unit.instanceID] = nil
        else
            unitInfor.bidx = bio2number(role.serverData.bidx)
            IDLBattle.defShips[unit.instanceID] = nil
        end
        unit.csSelf:clean()
        CLRolePool.returnObj(unit.csSelf)
        SetActive(unit.gameObject, false)

        if role.id ~= IDConst.RoleID.Barbarian then
            -- 通知服务器
            -- 陆战兵死亡不用通知服务器
            if (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) then
                CLLNet.send(NetProtoIsland.send.onBattleUnitDie(bio2number(IDLBattle.mData.fleet.idx), unitInfor))
            end
        end
    elseif unit.isBuilding then
        ---@type IDLBuilding
        local b = unit
        -- 刷新a*网格
        city.astar4Tile:scanRange(unit.transform.position, 6)
        city.astar4Ocean:scanRange(unit.transform.position, 6)

        -- 通知服务器
        if (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) then
            CLLNet.send(
                NetProtoIsland.send.onBattleBuildingDie(
                    bio2number(IDLBattle.mData.fleet.idx),
                    bio2number(b.serverData.idx)
                )
            )
        end
    end

    if IDLBattle.needEndBattle() then
        IDLBattle.endBattle()
    end
end

---public 掠夺资源
function IDLBattle.onLootRes(bidx, type, val)
    if IDLBattle.isStoped then
        return
    end
    if val > 0 and (not IDLBattle.mData.isReplay) and (not IDLBattle.mData.isWatching) then
        local fidx = bio2number(IDLBattle.mData.fleet.idx)
        CLLNet.send(NetProtoIsland.send.onBattleLootRes(fidx, bidx, type, val))
    end
end

---public 能否结束战斗
function IDLBattle.needEndBattle()
    if not IDLBattleSearcher.hadBuildingAlive() then
        return true
    end
    --//TODO:进攻方是否已经没有可以投放的单元(目前只处理了舰船，后续还有宠物和技能)
    ---@param v NetProtoIsland.ST_unitInfor
    for k, v in pairs(IDLBattle.mData.fleet.units) do
        if bio2Int(v.num) > 0 then
            return false
        end
    end
    --//TODO:已经投放了的单元是否还有活着的
    return true
end

function IDLBattle.onPressRole(isPress, role, pos)
end

---public 通用子弹击中效果
---@param bullet Coolape.CLBulletBase
function IDLBattle.onBulletHit(bullet)
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
    local pos = bullet.transform.position
    -- 波及范围内单位
    local DamageAffectRang = bio2number(attacker.attr.DamageAffectRang) / 100
    if DamageAffectRang > 0 then
        -- 波及范围内单位
        local list = IDLBattleSearcher.getTargetsInRange(attacker, pos, DamageAffectRang)
        if list and #list > 0 then
            ---@param unit IDLUnitBase
            for i, unit in ipairs(list) do
                local damage = attacker:getDamage(unit)
                unit:onHurt(damage, attacker)
            end
        else
            if target and (not target.isDead) then
                local dis = Vector3.Distance(pos, target.transform.position)
                if dis <= 0.5 then
                    -- 半格范围内都算击中目标
                    local damage = attacker:getDamage(target)
                    target:onHurt(damage, attacker)
                end
            end
        end
    else
        if target and (not target.isDead) then
            local dis = Vector3.Distance(pos, target.transform.position)
            if dis <= 0.6 then
                -- 半格范围内都算击中目标
                local damage = attacker:getDamage(target)
                target:onHurt(damage, attacker)
            end
        end
    end
end

---public 寻敌
---@param targetsNum number 目标数量
function IDLBattle.searchTarget(unit, targetsNum)
    return IDLBattleSearcher.searchTarget(unit, targetsNum)
end

---public 结束战斗
function IDLBattle.endBattle()
    if IDLBattle.isStoped then
        return
    end
    if IDLBattle.mData.isReplay or IDLBattle.mData.isWatching then
        InvokeEx.cancelInvokeByFixedUpdate(IDLBattle.endBattle)
        InvokeEx.cancelInvokeByFixedUpdate(IDLBattle.doplay4Replay)
    end
    IDLBattle.isStoped = true
    --//TODO:end battle
    IDLBattle.clean()
    IDUtl.chgScene(GameMode.map)
end

-- 回放
function IDLBattle.startReplay()
    local panel = CLPanelManager.getPanel("PanelBattleReplay")
    panel.luaTable.startReplay()
    ---@param v NetProtoIsland.ST_deployUnitInfor
    for i, v in ipairs(IDLBattle.mData.deployQueue) do
        local delayTime = bio2number(v.frames) * Time.fixedDeltaTime
        InvokeEx.invokeByFixedUpdate(IDLBattle.doplay4Replay, v, delayTime)
    end
    local endTime = bio2number(IDLBattle.mData.endFrames) * Time.fixedDeltaTime
    InvokeEx.invokeByFixedUpdate(IDLBattle.endBattle, endTime)
end

---@param data NetProtoIsland.ST_deployUnitInfor
function IDLBattle.doplay4Replay(data)
    local pos = Vector3(bio2number(data.pos.x) / 1000, bio2number(data.pos.y) / 1000, bio2number(data.pos.z) / 1000)
    ---@type _ParamBattleUnitData
    local d = {}
    d.type = bio2number(data.unitInfor.type)
    d.id = bio2number(data.unitInfor.id)
    d.num = data.unitInfor.num
    d.lev = data.unitInfor.lev
    if d.type == IDConst.UnitType.role then
        IDLBattle.doDeployUnit(
            pos,
            d,
            bio2number(data.fakeRandom),
            bio2number(data.fakeRandom2),
            bio2number(data.fakeRandom3)
        )
    elseif d.type == IDConst.UnitType.skill then
        IDLBattle.DeploySkill(d, pos)
    end
end

function IDLBattle.clean()
    CameraMgr.self.subcamera.enabled = false
    -- 雾
    MyCfg.self.fogOfWar.enabled = true
    IDLBattle.isFirstDeployRole = true
    IDLBattle.currSelectedUnit = nil
    IDWorldMap.rmFinishEnterCityCallback(IDLBattle.onEnterCity)
    -- 恢复资源释放
    CLAssetsManager.self:regain()

    ---@param v IDRoleBase
    for k, v in pairs(IDLBattle.offShips) do
        v.csSelf:clean() -- 只能过能csSelf调用clean,不然要死循环
        CLRolePool.returnObj(v.csSelf)
        SetActive(v.gameObject, false)
    end
    IDLBattle.offShips = {}

    ---@param v IDRoleBase
    for k, v in pairs(IDLBattle.defShips) do
        v.csSelf:clean() -- 只能过能csSelf调用clean,不然要死循环
        CLRolePool.returnObj(v.csSelf)
        SetActive(v.gameObject, false)
    end
    IDLBattle.defShips = {}

    for k, v in pairs(IDLBattle.skills) do
        v:clean()
        CLThingsPool.returnObj(v.csSelf.gameObject)
        SetActive(v.csSelf.gameObject, false)
    end
    IDLBattle.skills = {}

    -- 城市清理
    if city then
        city.clean()
        city = nil
    end
    if IDLBattleSearcher then
        IDLBattleSearcher.clean()
    end

    if IDLBattle.mData then
        IDLBattle.mData.targetCity = nil
        IDLBattle.mData.targetPlayer = nil
        IDLBattle.mData.attackPlayer = nil
        IDLBattle.mData = nil
    end
end

function IDLBattle.destory()
    IDLBattle.clean()
    GameObject.DestroyImmediate(IDLBattle.gameObject, true)
end

return IDLBattle
