---public 魔法技能
require("public.class")
---@class IDLSkillBase:IDLUnitBase
IDLSkillBase = class("IDLSkillBase")

function IDLSkillBase:_init(csObj)
    if self.isFinitInit then
        return false
    end

    self.isFinitInit = true
    return true
end

function IDLSkillBase:init(csObj, id, lev, pos, battle)
    self:_init(csObj)
    self.csSelf = csObj
    self.transform = csObj.transform
    self.isSkill = true
    ---@type IDLBattle
    self.battle = battle
    self.position = pos
    self.isOffense = true
    self.attackTimes = 0

    ---@type DBCFMagicData
    self.attr = DBCfg.getDataById(DBCfg.CfgPath.Magic, id)
    self.damage =
        DBCfg.getGrowingVal(
        bio2number(self.attr.DamageMin),
        bio2number(self.attr.DamageMax),
        bio2number(self.attr.DamageCurve),
        bio2number(lev) / bio2number(self.attr.MaxLev)
    )
    self.stayTime =
        DBCfg.getGrowingVal(
        bio2number(self.attr.StateMsMin),
        bio2number(self.attr.StateMsMax),
        bio2number(self.attr.StateMsCurve),
        bio2number(lev) / bio2number(self.attr.MaxLev)
    ) / 1000

    self.effectRange =
        DBCfg.getGrowingVal(
        bio2number(self.attr.RangeMin),
        bio2number(self.attr.RangeMax),
        bio2number(self.attr.RangeCurve),
        bio2number(lev) / bio2number(self.attr.MaxLev),
        2
    )
    self.attackSpeed = bio2number(self.attr.AttackSpeedMs) / 1000

    self:setEffectRange()
end

---public 设置魔法技能的范围
function IDLSkillBase:setEffectRange()
    self.transform.localScale = Vector3.one * self.effectRange * 2
end

function IDLSkillBase:startAttack()
    self:attack()
    if self.stayTime > 0 then
        InvokeEx.invokeByFixedUpdate(self:wrapFunc(self.finishAttack), self.stayTime)
    end
end

function IDLSkillBase:attack()
    SoundEx.playSound(self.attr.Sound, 1, 1)

    self:doTargetsHurt()

    if bio2number(self.attr.DamageTimes) > 0 then
        self.attackTimes = self.attackTimes + 1
        if self.attackTimes > bio2number(self.attr.DamageTimes) then
            -- 攻击完成
            self:finishAttack()
            return
        end
    end
    InvokeEx.invokeByFixedUpdate(self:wrapFunc(self.attack), self.attackSpeed)
end

---public 可以重载这个方法以达到不同的效果
function IDLSkillBase:doTargetsHurt()
    -- 取得范围内的目标
    local list = self.battle.searcher.getTargetsInRange(self, self.position, self.effectRange)
    ---@param v IDLUnitBase
    for i, v in ipairs(list) do
        v:onHurt(self.damage, self)
    end
end

function IDLSkillBase:finishAttack()
    self:clean()
    self.battle.onFinishSkillAttack(self)
end

function IDLSkillBase:clean()
    InvokeEx.cancelInvokeByFixedUpdate(self:wrapFunc(self.finishAttack))
    InvokeEx.cancelInvokeByFixedUpdate(self:wrapFunc(self.attack))
end

return IDLSkillBase
