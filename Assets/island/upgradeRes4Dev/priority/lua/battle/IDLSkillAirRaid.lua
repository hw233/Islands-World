---public 魔法技能
require("public.class")
---@class IDLSkillAirRaid:IDLSkillBase
IDLSkillAirRaid = class("IDLSkillAirRaid", IDLSkillBase)

function IDLSkillAirRaid:_init(csObj)
    if not IDLSkillAirRaid.super._init(self, csObj) then
        return false
    end

    return true
end

function IDLSkillAirRaid:init(csObj, id, lev, pos, battle)
    IDLSkillAirRaid.super.init(self, csObj, id, lev, pos, battle)
    self.bulletAttr = DBCfg.getBulletByID(bio2number(self.attr.Bullets))
end

---public 可以重载这个方法以达到不同的效果
function IDLSkillAirRaid:doTargetsHurt()
    local orgPos = self.position + Vector3.up * bio2number(self.bulletAttr.Range)/10
    orgPos.x = orgPos.x + NumEx.NextInt(-self.effectRange * 10, self.effectRange * 10) * 0.9 / 10
    orgPos.z = orgPos.z + NumEx.NextInt(-self.effectRange * 10, self.effectRange * 10) * 0.9 / 10
    CLBulletBase.fire(self.csSelf, nil, orgPos, -Vector3.up, self.bulletAttr, nil, self:wrapFunc(self.onBulletHit))
end

function IDLSkillAirRaid:onBulletHit(bullet)
    ---@type DBCFBulletData
    local bulletAttr = bullet.attr
    CLEffect.play(bulletAttr.HitEffect, bullet.hitPoint)
    SoundEx.playSound(bulletAttr.HitSFX, 1, 2)
    if bulletAttr.IsScreenShake then
        -- 震屏
        SScreenShakes.play(nil, 0)
    end

    IDLSkillAirRaid.super.doTargetsHurt(self)
end

return IDLSkillAirRaid
