---public 魔法技能
require("public.class")
---@class IDLSkillWild:IDLSkillBase
IDLSkillWild = class("IDLSkillWild", IDLSkillBase)

---public 可以重载这个方法以达到不同的效果
function IDLSkillWild:doTargetsHurt()
    -- 取得范围内的目标
    local list = self.battle.searcher.getTargetsInRange(self, self.position, self.effectRange)
    ---@param v IDRoleBase
    for i, v in ipairs(list) do
        v:setWild(self.stayTime)
    end
end

return IDLSkillWild
