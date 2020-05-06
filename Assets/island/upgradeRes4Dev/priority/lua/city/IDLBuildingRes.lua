---public 资源建筑
require("city.IDLBuilding")

---@class IDLBuildingRes:IDLBuilding
IDLBuildingRes = class("IDLBuildingRes", IDLBuilding)

function IDLBuildingRes:init(selfObj, id, star, lev, _isOffense, other)
    -- 通过这种模式把self传过去，不能 self.super:init()
    IDLBuildingRes.super.init(self, selfObj, id, star, lev, _isOffense, other)

    -- 设置建筑的资源类型
    self.resType = IDUtl.getResTypeByBuildingID(self.id)

    if
        GameMode.map == MyCfg.mode and self.serverData and
            bio2number(self.serverData.state) == IDConst.BuildingState.normal
     then
        self:showCollect()
    end
end

---public 收集资源
function IDLBuildingRes:showCollect()
    if (not self.serverData) or GameMode.map ~= MyCfg.mode then
        return
    end
    if bio2number(self.serverData.state) == IDConst.BuildingState.normal then
        local passTime = DateEx.nowMS - bio2number(self.serverData.starttime)
        if passTime >= 60000 * 3 then
            -- 大于3分钟可以显示收集资源图标
            self:showCollectHud()
        else
            self:hideCollectHud()
            self.csSelf:invoke4Lua(self.showCollect, 60)
        end
    else
        self:hideCollectHud()
        printe("当前建筑不可收集资源！state==" .. bio2number(self.serverData.state))
    end
end

function IDLBuildingRes:showCollectHud()
    if self.tipHud == nil then
        CLUIOtherObjPool.borrowObjAsyn(
            "TipHud",
            function(name, obj, orgs)
                if (not self.gameObject.activeInHierarchy) or self.tipHud ~= nil then
                    CLUIOtherObjPool.returnObj(obj)
                    SetActive(obj, false)
                    return
                end
                self.tipHud = obj:GetComponent("CLCellLua")
                self.tipHud.transform.parent = MyCfg.self.hud3dRoot
                self.tipHud.transform.localScale = Vector3.one
                self.tipHud.transform.localEulerAngles = Vector3.zero
                SetActive(self.tipHud.gameObject, true)
                local color = Color.white
                if not self:canCollect() then
                    color = Color.yellow
                end
                self.tipHud:init(
                    {
                        target = self.csSelf,
                        data = self.serverData,
                        offset = Vector3(0, 2, 0),
                        icon = IDUtl.getResIcon(self.resType),
                        bgColor = color,
                        onClick = self.collectRes
                    }
                )
            end
        )
    else
        SetActive(self.tipHud.gameObject, true)
        self.tipHud:init({target = self.csSelf, data = self.serverData, offset = Vector3(0, 2, 0)})
    end
end

function IDLBuildingRes:hideCollectHud()
    if self.tipHud then
        CLUIOtherObjPool.returnObj(self.tipHud.gameObject)
        SetActive(self.tipHud.gameObject, false)
        self.tipHud = nil
    end
end

function IDLBuildingRes:OnClick()
    IDLBuildingRes.super.OnClick(self)
    self:collectRes()
end

function IDLBuildingRes:collectRes()
    if self.tipHud then
        if self:canCollect() then
            -- showHotWheel()
            self:hideCollectHud()
            CLLNet.send(NetProtoIsland.send.collectRes(bio2number(self.serverData.idx)))
        else
            CLAlert.add(LGet("MsgCollectResIsFull"), Color.yellow, 1)
        end
    end
end

---public 播放收集资源图标飞的效果
function IDLBuildingRes:playCollectResEffect()
    local to = nil
    if IDPMain then
        to = IDPMain.getResIconObj(self.resType)
    end
    if to then
        local pos = MyCfg.self.mainCamera:WorldToViewportPoint(self.transform.position)
        pos = MyCfg.self.uiCamera:ViewportToWorldPoint(pos)
        pos.z = 0
        IDUtl.playFlyPics(pos, nil, to.transform, IDUtl.getResIcon(self.resType), self.attr.CollectEffect, 12)
    end
end

---public 预估产量
function IDLBuildingRes:estimateYield()
    local proTime = DateEx.nowMS - bio2number(self.serverData.starttime)
    proTime = NumEx.getIntPart(proTime / 60000)
    if proTime > bio2number(DBCfg.getConstCfg().MaxTimeLen4ResYields) then
        proTime = bio2number(DBCfg.getConstCfg().MaxTimeLen4ResYields)
    end

    local attr = DBCfg.getBuildingByID(self.id)
    local maxLev = bio2number(attr.MaxLev)
    local persent = bio2number(self.serverData.lev) / maxLev
    -- 每分钟产量
    local yieldsPerMinutes =
        DBCfg.getGrowingVal(
        bio2number(attr.ComVal1Min),
        bio2number(attr.ComVal1Max),
        bio2number(attr.ComVal1Curve),
        persent
    )
    return yieldsPerMinutes * proTime
end

---public 是否可以收集
function IDLBuildingRes:canCollect()
    -- 状态必须是空间
    if bio2number(self.serverData.state) == IDConst.BuildingState.normal then
        -- 至少要1分钟
        local passTime = DateEx.nowMS - bio2number(self.serverData.starttime)
        if passTime >= 60000 then
            local yields = self:estimateYield()
            if yields == 0 then
                return false
            end
            -- 判断空间是否够用
            local freeSpace = 0
            local resInfor = IDDBCity.curCity:getRes()
            if self.resType == IDConst.ResType.food then
                freeSpace = resInfor.maxfood - resInfor.food
            elseif self.resType == IDConst.ResType.oil then
                freeSpace = resInfor.maxoil - resInfor.oil
            elseif self.resType == IDConst.ResType.gold then
                freeSpace = resInfor.maxgold - resInfor.gold
            end
            if freeSpace > 0 then
                local outPrent = (yields - freeSpace) / yields
                if outPrent <= 0.2 then
                    return true
                end
            end
        end
    end
    return false
end

function IDLBuildingRes:onHurt(damage, attacker)
    if not self.isDead then
        -- 处理扣除资源
        if damage > 0 then
            local _damage = damage
            if _damage > bio2number(self.data.curHP) then
                _damage = bio2number(self.data.curHP)
            end
            local resType = IDUtl.getResTypeByBuildingID(bio2number(self.attr.ID))
            local persent = _damage / bio2number(self.data.HP)
            -- 只计算分钟数
            local passTime = DateEx.nowMS - bio2number(self.serverData.starttime)
            passTime = NumEx.getIntPart(passTime / 60000)
            local constcfg = DBCfg.getConstCfg()
            local MaxTimeLen4ResYields = bio2number(constcfg.MaxTimeLen4ResYields)
            -- 判断时长是否超过最大生产时长(目前配置的时最大只可生产8小时产量)
            if passTime > MaxTimeLen4ResYields then
                passTime = MaxTimeLen4ResYields
            end
            -- 此处计算的是分钟数，相当于掠夺了xx分钟的产量
            self.data.lootRes[resType] = persent * passTime + self.data.lootRes[resType]
            self:showBeLootResEffect()
        end
    end
    IDLBuildingRes.super.onHurt(self, damage, attacker)
end

function IDLBuildingRes:SetActive(active)
    IDLBuildingRes.super.SetActive(self, active)
    if active then
        if self.serverData and bio2number(self.serverData.state) == IDConst.BuildingState.normal then
            self:showCollect()
        end
    else
        self:hideCollectHud()
    end
end

function IDLBuildingRes:clean()
    self.csSelf:cancelInvoke4Lua()
    IDLBuildingRes.super.clean(self)
    self:hideCollectHud()
end

--------------------------------------------
return IDLBuildingRes
