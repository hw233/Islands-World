-- xx单元
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type NetProtoIsland.ST_chatInfor
local mData = nil
local uiobjs = {}
local NGUIMath = CS.NGUIMath

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    ---@type UIWidget
    uiobjs.rootWidget = csSelf:GetComponent("UIWidget")
    ---@type UnityEngine.BoxCollider
    uiobjs.rootCollider = csSelf:GetComponent("BoxCollider")
    ---@type UISprite
    uiobjs.Background = getCC(transform, "Background", "UISprite")
    ---@type UIRichText4Chat
    uiobjs.LabelContent = getCC(transform, "LabelContent", "UIRichText4Chat")
    ---@type UISprite
    uiobjs.SpriteIcon = getCC(transform, "SpriteIcon", "UISprite")
    ---@type UILabel
    uiobjs.LabelName = getCC(transform, "LabelName", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    if bio2number(mData.fromPidx) == bio2number(IDDBPlayer.myself.idx) then
        -- 说明是自己发的
        uiobjs.SpriteIcon.transform.localPosition = Vector3(380, 0, 0)
        uiobjs.LabelContent.label.pivot = Pivot.TopRight
        uiobjs.LabelContent.transform.localPosition = Vector3(307, -10, 0)
        uiobjs.LabelName.pivot = Pivot.Right
        uiobjs.LabelName.transform.localPosition = Vector3(307, 30, 0)
        uiobjs.Background.color = ColorEx.getColor(110, 255, 110)
    else
        uiobjs.SpriteIcon.transform.localPosition = Vector3(-380, 0, 0)
        uiobjs.LabelContent.label.pivot = Pivot.TopLeft
        uiobjs.LabelContent.transform.localPosition = Vector3(-307, -10, 0)
        uiobjs.LabelName.pivot = Pivot.Left
        uiobjs.LabelName.transform.localPosition = Vector3(-307, 30, 0)
        uiobjs.Background.color = Color.white
    end
    uiobjs.LabelContent.label.width = 600
    uiobjs.LabelContent.value = mData.content
    local realWithd = NumEx.getIntPart(uiobjs.LabelContent.label.printedSize.x)
    if realWithd < 500 then
        realWithd = realWithd + 15
        uiobjs.LabelContent.label.width = realWithd
    else
        uiobjs.LabelContent.label.width = 600
    end
    uiobjs.Background:UpdateAnchors()

    uiobjs.LabelName.text = ""
    uiobjs.SpriteIcon.spriteName = ""
    IDDBPlayer.getPlayerSimple(bio2number(mData.fromPidx), _cell.setPlayerInfor)

    -- 要在下一帧更新才准确
    InvokeEx.invokeByUpdate(_cell.refreshColliderSize, 0.1)
end

function _cell.refreshColliderSize()
    ---@type UnityEngine.Bounds
    local bounds = NGUIMath.CalculateRelativeWidgetBounds(transform, false)
    uiobjs.rootCollider.center = bounds.center
    uiobjs.rootCollider.size = bounds.size
    -- 重新刷新一次数据
    uiobjs.LabelContent:onTextChanged(uiobjs.LabelContent.gameObject)
end

---@param data NetProtoIsland.ST_playerSimple
function _cell.setPlayerInfor(data)
    local diff = DateEx.nowMS - bio2number(mData.time)
    if bio2number(mData.fromPidx) == bio2number(IDDBPlayer.myself.idx) then
        uiobjs.LabelName.text =
            joinStr("[sub][C8C8C8]", IDUtl.timeCost(diff), "[-][/sub]  ", data.name)
    else
        uiobjs.LabelName.text =
            joinStr(data.name, "  [sub][C8C8C8]", IDUtl.timeCost(diff), "[-][/sub]")
    end
    uiobjs.SpriteIcon.spriteName = joinStr("playerIcon_", bio2number(data.icon))
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
