local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type DBCFMagicData
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    uiobjs.LabelNum = getCC(transform, "LabelNum", "UILabel")
    uiobjs.LabelState = getCC(transform, "LabelState", "UILabel")
    local Table = getChild(transform, "Table")
    uiobjs.LabelName = getCC(Table, "LabelName", "UILabel")
    uiobjs.LabelCostTime = getCC(Table, "LabelCostTime", "UILabel")
    uiobjs.LabelCondition = getCC(Table, "LabelCondition", "UILabel")
    uiobjs.ButtonSummon = getChild(transform, "ButtonSummon")
    uiobjs.LabelCostRes = getCC(uiobjs.ButtonSummon, "LabelCostRes", "UILabel")
    uiobjs.ButtonSpeedup = getChild(transform, "ButtonSpeedup")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    local id = bio2number(mData.ID)
    ---@type NetProtoIsland.ST_unitInfor
    local serverData = IDDBCity.curCity:getMagicById(id) or {}
    local lev = IDDBCity.curCity:getMagicLev(id)
    uiobjs.SpriteIcon.spriteName = mData.Icon
    uiobjs.LabelName.text = joinStr(LGet(mData.NameKey), "  ", LGetFmt("LevelWithNum", lev))
    local costMs =
        DBCfg.getGrowingVal(
        bio2number(mData.BuildTimeMin),
        bio2number(mData.BuildTimeMax),
        bio2number(mData.BuildTimeCurve),
        lev / bio2number(mData.MaxLev)
    )
    costMs = costMs * 60 * 1000
    uiobjs.LabelCostTime.text = joinStr(LGet("CostTime"), ":", DateEx.toStrCn(costMs))

    csSelf:cancelInvoke4Lua(_cell.cooldown)
    local maxNum, openDesc = IDUtl.getCurrMagicMaxNum(id)
    if maxNum <= 0 then
        -- 说明还没有解锁
        uiobjs.LabelNum.text = ""
        uiobjs.LabelState.text = joinStr("[ff0000]", LGet("Locked"), "[-]")
        uiobjs.LabelCondition.text = joinStr("[ff0000]", openDesc, "[-]")
        SetActive(uiobjs.ButtonSummon.gameObject, false)
        SetActive(uiobjs.ButtonSpeedup.gameObject, false)
    else
        uiobjs.LabelNum.text = joinStr(bio2number(serverData.num), "/", maxNum)
        uiobjs.LabelCondition.text = ""
        if bio2number(serverData.num) >= maxNum then
            -- 数量已满
            uiobjs.LabelState.text = LGet("MaximumLimitReached")
            SetActive(uiobjs.ButtonSummon.gameObject, false)
            SetActive(uiobjs.ButtonSpeedup.gameObject, false)
        else
            uiobjs.LabelState.text = ""
            -- 如果正在升级
            local isMagicSummoning, endTime = IDDBCity.curCity:isMagicSummoning(id)
            if isMagicSummoning then
                SetActive(uiobjs.ButtonSummon.gameObject, false)
                SetActive(uiobjs.ButtonSpeedup.gameObject, true)
                _cell.cooldown(endTime)
            else
                local costRes =
                    DBCfg.getGrowingVal(
                    bio2number(mData.BuildCostOilMin),
                    bio2number(mData.BuildCostOilMax),
                    bio2number(mData.BuildCostOilCurve),
                    lev / bio2number(mData.MaxLev)
                )
                uiobjs.LabelCostRes.text = tostring(costRes)
                SetActive(uiobjs.ButtonSummon.gameObject, true)
                SetActive(uiobjs.ButtonSpeedup.gameObject, false)
            end
        end
    end
end

function _cell.cooldown(endTime)
    local diff = endTime - DateEx.nowMS
    if diff > 0 then
        uiobjs.LabelCostTime.text = joinStr(LGet("CostTime"), ":", DateEx.toStrCn(diff))
        csSelf:invoke4Lua(_cell.cooldown, endTime, 1)
    end
end

-- 取得数据
function _cell.getData()
    return mData
end

function _cell.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonSummon" then
        showHotWheel()
        CLLNet.send(NetProtoIsland.send.summonMagic(bio2number(mData.ID)))
    elseif goName == "ButtonSpeedup" then
        showHotWheel()
        CLLNet.send(NetProtoIsland.send.summonMagicSpeedUp(bio2number(mData.ID)))
    end
end

--------------------------------------------
return _cell
