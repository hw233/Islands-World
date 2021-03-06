﻿-- xx单元
local _cell = {}
local csSelf = nil
local transform = nil
local mData = nil --[[
    mData.target : gameobject
    mData.data:数据
    mData.offset:位置偏移
    --]]
local uiobjs = {}
local iconSize = 55

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    --[[
        上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider");
        --]]
    uiobjs.table = csSelf:GetComponent("UITable")
    ---@type UIFollowTarget
    uiobjs.followTarget = csSelf:GetComponent("UIFollowTarget")
    uiobjs.followTarget:setCamera(MyCfg.self.mainCamera, MyCfg.self.uiCamera)

    uiobjs.spriteIcon = getCC(transform, "00SpriteIcon", "UISprite")
    uiobjs.Progress = getCC(transform, "01Progress Bar", "UISlider")
    uiobjs.Label = getCC(uiobjs.Progress.transform, "Label", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    ---@type NetProtoIsland.ST_building
    local serverData = mData.data
    mData.starttime = bio2number(serverData.starttime)
    mData.endtime = bio2number(serverData.endtime)
    mData.diff = mData.endtime - mData.starttime
    uiobjs.followTarget:setTarget(mData.target.transform, mData.offset or Vector3.zero)
    if bio2number(serverData.state) == IDConst.BuildingState.upgrade then
        CLUIUtl.setSpriteFit(uiobjs.spriteIcon, "icon_build", iconSize)
    elseif bio2number(serverData.state) == IDConst.BuildingState.working then
        if bio2number(serverData.attrid) == IDConst.BuildingID.dockyardBuildingID then
            local shipID = bio2number(serverData.val)
            CLUIUtl.setSpriteFit(uiobjs.spriteIcon, joinStr("roleIcon_", shipID), iconSize)
        elseif bio2number(serverData.attrid) == IDConst.BuildingID.TechCenter then
            -- 科技中心
            local techIdx = bio2number(serverData.val)
            local tech = IDDBCity.curCity:getTechByIdx(techIdx)
            if tech then
                ---@type DBCFTechData
                local attr = DBCfg.getDataById(DBCfg.CfgPath.Tech, bio2number(tech.id))
                if attr then
                    CLUIUtl.setSpriteFit(uiobjs.spriteIcon, attr.Icon, iconSize)
                else
                    printe("get tech attr is nil!!")
                end
            end
        elseif bio2number(serverData.attrid) == IDConst.BuildingID.MagicAltar then
            -- 魔法坛
            local magicId = bio2number(serverData.val)
            ---@type DBCFMagicData
            local attr = DBCfg.getDataById(DBCfg.CfgPath.Magic, magicId)
            if attr then
                CLUIUtl.setSpriteFit(uiobjs.spriteIcon, attr.Icon, iconSize)
            else
                printe("get tech attr is nil!!")
            end
        end
    end

    if mData.diff > 0 then
        _cell.cooldown()
    else
        uiobjs.Label.text = ""
        uiobjs.Progress.value = 0
        InvokeEx.cancelInvokeByUpdate(_cell.cooldown)
    end
    uiobjs.table.repositionNow = true
end

function _cell.cooldown()
    if not csSelf.gameObject.activeInHierarchy then
        return
    end
    local lefttime = mData.endtime - DateEx.nowMS
    if lefttime > 0 then
        uiobjs.Label.text = DateEx.toStrCn(lefttime)
        uiobjs.Progress.value = lefttime / mData.diff
        if lefttime > 10000 then
            InvokeEx.invokeByUpdate(_cell.cooldown, 1)
        else
            InvokeEx.invokeByUpdate(_cell.cooldown, 0.2)
        end
    end
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
