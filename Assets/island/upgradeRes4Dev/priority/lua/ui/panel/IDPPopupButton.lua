---@class _ParamPPopupButton
---@field public target UnityEngine.Transform
---@field public buttons {_ParamCellPopupButton,_ParamCellPopupButton}

-- xx界面
local IDPPopupButton = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
---@type _ParamPPopupButton
local mData
local mOffsetX = 160
local mOffsetY = 60
local mOffsetPos = {
    [Pivot.Center] = Vector3(mOffsetX, 0, 0),
    [Pivot.Left] = Vector3(mOffsetX, 0, 0),
    [Pivot.Top] = Vector3(mOffsetX, -mOffsetY, 0),
    [Pivot.Right] = Vector3(-mOffsetX, 0, 0),
    [Pivot.Bottom] = Vector3(mOffsetX, mOffsetY, 0),
    [Pivot.TopLeft] = Vector3(mOffsetX, -mOffsetY, 0),
    [Pivot.BottomLeft] = Vector3(mOffsetX, mOffsetY, 0),
    [Pivot.TopRight] = Vector3(-mOffsetX, -mOffsetY, 0),
    [Pivot.BottomRight] = Vector3(-mOffsetX, mOffsetY, 0)
}

-- 初始化，只会调用一次
function IDPPopupButton.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    uiobjs.BottonRoot = getChild(transform, "Buttons")
    ---@type Coolape.CLUILoopGrid
    uiobjs.Grid = getCC(uiobjs.BottonRoot, "Grid", "CLUILoopGrid")
end

-- 设置数据
function IDPPopupButton.setData(paras)
    mData = paras
end

--当有通用背板显示时的回调
function IDPPopupButton.onShowFrame()
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPPopupButton.show()
    if #mData.buttons > 10 then
        printe("Max count of popup buttons is 10, now is [" .. #mData.buttons, "]")
    end
    local clickPos = UICamera.lastWorldPosition
    uiobjs.BottonRoot.position = clickPos
    local viewPos = MyCfg.self.uiCamera:WorldToViewportPoint(clickPos)
    local diffx = viewPos.x - 0.5
    local diffy = viewPos.y - 0.5
    local threshold = 0.1
    local pivot
    if math.abs(diffx) <= threshold and math.abs(diffy) <= threshold then
        pivot = Pivot.Center
    elseif diffx < -threshold and math.abs(diffy) <= threshold then
        pivot = Pivot.Left
    elseif diffx > threshold and math.abs(diffy) <= threshold then
        pivot = Pivot.Right
    elseif math.abs(diffx) <= threshold and diffy < -threshold then
        pivot = Pivot.Bottom
    elseif math.abs(diffx) <= threshold and diffy > threshold then
        pivot = Pivot.Top
    elseif diffx < -threshold and diffy < -threshold then
        pivot = Pivot.BottomLeft
    elseif diffx < -threshold and diffy > threshold then
        pivot = Pivot.TopLeft
    elseif diffx > threshold and diffy < -threshold then
        pivot = Pivot.BottomRight
    elseif diffx > threshold and diffy > threshold then
        pivot = Pivot.TopRight
    end
    uiobjs.BottonRoot.localPosition = uiobjs.BottonRoot.localPosition + mOffsetPos[pivot]
    uiobjs.Grid.grid.pivot = pivot
    uiobjs.Grid:setList(mData.buttons or {}, IDPPopupButton.initCell)
end

function IDPPopupButton.initCell(cell, data)
    cell:init(data, IDPPopupButton.onClickButton)
end

function IDPPopupButton.onClickButton(cell)
    ---@type _ParamCellPopupButton
    local data = cell.luaTable.getData()
    hideTopPanel(csSelf)
    Utl.doCallback(data.callback, data.paras)
end

-- 刷新
function IDPPopupButton.refresh()
end

-- 关闭页面
function IDPPopupButton.hide()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPPopupButton.procNetwork(cmd, succ, msg, paras)
    --[[
    if(succ == NetSuccess) then
      if(cmd == "xxx") then
        -- TODO:
      end
    end
    --]]
end

-- 处理ui上的事件，例如点击等
function IDPPopupButton.uiEventDelegate(go)
    local goName = go.name
    if goName == "Bg" then
        hideTopPanel(csSelf)
        -- 把事件传给下层ui
        local uicamera = MyCfg.self.uiCamera:GetComponent("UICamera")
        uicamera:ProcessRelease()
        uicamera:Update()
        uicamera:LateUpdate()
    end
end

-- 当顶层页面发生变化时回调
function IDPPopupButton.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPPopupButton.hideSelfOnKeyBack()
    return true
end

--------------------------------------------
return IDPPopupButton
