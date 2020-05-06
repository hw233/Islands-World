---@class _ParamsIDPChats
---@field public type IDConst.ChatType
---@field public targetPidx number 私聊的玩家idx

-- 聊天界面
local IDPChats = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
local currType = nil
---@type _ParamsIDPChats
local mParmas
local selectedPidx = nil
local isInitedFaces = false
local isShowFaces = false

-- 初始化，只会调用一次
function IDPChats.init(csObj)
    csSelf = csObj
    transform = csObj.transform

    ---@type UnityEngine.Vector4
    local contentRect = GetUIContentRect(csSelf, 20, 165)
    local offset = getChild(transform, "AnchorLeft/offset")
    uiobjs.bg = getChild(transform, "Bg")
    ---@type TweenPosition
    uiobjs.ChatRoot = getCC(offset, "ChatRoot", "TweenPosition")
    uiobjs.ChatRoot:ResetToBeginning()
    uiobjs.Content = getCC(uiobjs.ChatRoot.transform, "PanelContent", "UIPanel")
    uiobjs.Content.transform.localPosition = Vector3.zero
    uiobjs.Content.clipOffset = Vector2.zero
    local region = uiobjs.Content.baseClipRegion
    region.w = contentRect.w
    uiobjs.Content.baseClipRegion = region

    ---@type Coolape.CLUILoopTable
    uiobjs.Table = getCC(uiobjs.Content.transform, "Table", "CLUILoopTable")
    ---@type UIInput
    uiobjs.Input = getCC(uiobjs.ChatRoot.transform, "Input", "UIInput")
    uiobjs.ButtonCloseTw = getCC(uiobjs.ChatRoot.transform, "ButtonClose", "TweenPosition")
    uiobjs.ButtonCloseTw:ResetToBeginning()
    uiobjs.ChatFaces = getCC(uiobjs.ChatRoot.transform, "ChatFaces", "TweenScale")
    uiobjs.ChatFaces:ResetToBeginning()
    uiobjs.ChatFacesTw2 = uiobjs.ChatFaces:GetComponent("TweenAlpha")
    uiobjs.ChatFacesTw2:ResetToBeginning()
    uiobjs.GridFace = getCC(uiobjs.ChatFaces.transform, "Grid", "UIGrid")
    uiobjs.GridFacePrefab = getChild(uiobjs.GridFace.transform, "00000").gameObject

    uiobjs.PlayersRoot = getChild(offset, "PlayersRoot")
    ---@type Coolape.CLUILoopGrid
    uiobjs.Grid4Players = getCC(uiobjs.PlayersRoot, "PanelPlayers/Grid", "CLUILoopGrid")
    uiobjs.LabelNoPlayers = getChild(uiobjs.PlayersRoot, "LabelNoPlayers").gameObject

    uiobjs.PlayersRoot = uiobjs.PlayersRoot:GetComponent("TweenScale")
    uiobjs.PlayersRoot:ResetToBeginning()
    uiobjs.PlayersRootTw2 = uiobjs.PlayersRoot:GetComponent("TweenAlpha")
    uiobjs.PlayersRootTw2:ResetToBeginning()

    local type = getChild(offset, "Types")
    uiobjs.ToggleWorld = getCC(type, "ToggleWorld", "UIToggle")
    uiobjs.ToggleUnion = getCC(type, "ToggleUnion", "UIToggle")
    uiobjs.ToggleUnionReddot = getChild(uiobjs.ToggleUnion.transform, "SpriteReddot")
    uiobjs.TogglePrivate = getCC(type, "TogglePrivate", "UIToggle")
    uiobjs.TogglePrivateReddot = getChild(uiobjs.TogglePrivate.transform, "SpriteReddot")
end

-- 设置数据
function IDPChats.setData(paras)
    mParmas = paras or {}
end

function IDPChats.initFaces()
    isInitedFaces = true
    local faces = {}
    for i = 1, 24 do
        faces[i] = i
    end
    CLUIUtl.resetList4Lua(
        uiobjs.GridFace,
        uiobjs.GridFacePrefab,
        faces,
        function(cell, data)
            local sprite = cell:GetComponent("UISprite")
            sprite.spriteName = joinStr("chatFace_", data)
            cell:init(
                nil,
                function(cell)
                    uiobjs.Input:Insert(joinStr("#", data, "#"))
                end
            )
        end
    )
end

--当有通用背板显示时的回调
function IDPChats.onShowFrame()
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPChats.show()
    if not isInitedFaces then
        csSelf:invoke4Lua(IDPChats.initFaces, 0.5)
    end
    local type = mParmas and mParmas.type or (currType and currType or IDConst.ChatType.world)
    IDPChats.chgType(type, (mParmas and mParmas.targetPidx or nil))
end

function IDPChats.chgType(type, targetPidx)
    if currType == type then
        -- 直刷新数据
        IDPChats.setPlayers(targetPidx, true)
        IDPChats.setChatList(true)
    else
        local oldType = currType
        currType = type
        if currType == IDConst.ChatType.private then
            uiobjs.TogglePrivate.value = true
            uiobjs.ChatRoot:Play(true)
            IDPChats.showPlayers(targetPidx)
        else
            if oldType == IDConst.ChatType.private then
                uiobjs.ChatRoot:Play(false)
                IDPChats.hidePlayers()
            end
            if currType == IDConst.ChatType.world then
                uiobjs.ToggleWorld.value = true
            elseif currType == IDConst.ChatType.union then
                uiobjs.ToggleUnion.value = true
                IDDBChat.clearReddot(IDConst.ChatType.union)
            end
        end
        IDPChats.setChatList(false)
    end
end

function IDPChats.refreshReddot()
    SetActive(uiobjs.ToggleUnionReddot.gameObject, IDDBChat.hadReddotByType(IDConst.ChatType.union))
    SetActive(uiobjs.TogglePrivateReddot.gameObject, IDDBChat.hadReddotByType(IDConst.ChatType.private))
end

function IDPChats.setChatList(refreshContent)
    IDPChats.refreshReddot()

    local list
    if currType == IDConst.ChatType.private then
        -- 是私聊
        if selectedPidx then
            list = IDDBChat.getPrivateChatsByPidx(selectedPidx)
        else
            list = {}
        end
    else
        list = IDDBChat.getChatsByType(currType)
    end

    if refreshContent then
        uiobjs.Table:refreshContentOnly(list, true)
    else
        uiobjs.Table:setList(list, IDPChats.initCellChat)
    end
end

function IDPChats.initCellChat(cell, data)
    cell:init(data, IDPChats.onClickCellChat)
end

function IDPChats.onClickCellChat(cell)
    if currType == IDConst.ChatType.private then
        return
    end
    ---@type NetProtoIsland.ST_chatInfor
    local data = cell.luaTable.getData()
    local fromPidx = bio2number(data.fromPidx)
    if fromPidx ~= IDConst.sysPidx and fromPidx ~= bio2number(IDDBPlayer.myself.idx) then
        local buttons = {}
        ---@type _ParamCellPopupButton
        local b
        if currType ~= IDConst.ChatType.private then
            b = {}
            b.label = LGet("Contact") -- 联系他
            b.callback = IDPChats.contactWith
            b.paras = fromPidx
            table.insert(buttons, b)

            b = {}
            b.label = LGet("WriteMail") -- 联系他
            b.callback = IDPChats.writeMail
            b.paras = fromPidx
            table.insert(buttons, b)
        end
        if fromPidx ~= IDConst.gmPidx then
            b = {}
            b.label = LGet("TipOff") -- 举报
            b.callback = IDPChats.tipoffPlayer
            b.paras = fromPidx
            table.insert(buttons, b)
        end
        ---@type _ParamPPopupButton
        local param = {}
        param.buttons = buttons
        param.target = cell.transform
        IDUtl.showPopupButtons(param)
    end
end

---public 联系wb
function IDPChats.contactWith(pidx)
    IDPChats.chgType(IDConst.ChatType.private, pidx)
end

---public 写邮件
function IDPChats.writeMail(pidx)
    ---@type _ParamPWriteMail
    local d = {}
    d.targetPidx = pidx
    getPanelAsy("PanelWriteMail", onLoadedPanelTT, d)
end

function IDPChats.tipoffPlayer(pidx)
    --//TODO:
    CLAlert.add("暂未开放")
end

function IDPChats.hidePlayers()
    uiobjs.PlayersRoot:Play(false)
    uiobjs.PlayersRootTw2:Play(false)
    csSelf:invoke4Lua(IDPChats._doHidePlayers, 0.5)
end

function IDPChats._doHidePlayers()
    SetActive(uiobjs.PlayersRoot.gameObject, false)
end

function IDPChats.showPlayers(targetPidx, isRefresh)
    csSelf:cancelInvoke4Lua(IDPChats._doHidePlayers)
    SetActive(uiobjs.PlayersRoot.gameObject, true)
    uiobjs.PlayersRoot:Play(true)
    uiobjs.PlayersRootTw2:Play(true)
    IDPChats.setPlayers(targetPidx, isRefresh)
end

function IDPChats.setPlayers(targetPidx, isRefresh)
    if currType ~= IDConst.ChatType.private then
        return
    end
    -- 取得已经有聊过天的玩家
    local players = IDDBChat.getPlayers() or {}

    if targetPidx then
        selectedPidx = targetPidx
        if not IDDBChat.hadChatwith(selectedPidx) then
            -- 之前没有聊过，直接插入列表
            table.insert(players, 1, targetPidx)
        end
        SetActive(uiobjs.LabelNoPlayers, false)
    else
        if #players <= 0 then
            SetActive(uiobjs.LabelNoPlayers, true)
            IDPChats.setChatList(false)
        else
            if selectedPidx == nil then
                selectedPidx = players[1]
            end
            SetActive(uiobjs.LabelNoPlayers, false)
        end
    end

    uiobjs.Grid4Players:setList(players, IDPChats.initCellPlayer)
end

function IDPChats.initCellPlayer(cell, data)
    cell:init(data, IDPChats.onClickCellPlayer)
    if selectedPidx and selectedPidx == data then
        IDPChats.onClickCellPlayer(cell)
    end
end

function IDPChats.onClickCellPlayer(cell)
    cell.luaTable.setSelected(true)
    local pidx = cell.luaTable.getData()
    selectedPidx = pidx
    -- 先清除红点
    if IDDBChat.hadReddotByPidx(pidx) then
        IDDBChat.clearReddot(IDConst.ChatType.private, pidx)
        cell.luaTable.refreshReddot()
    end
    IDPChats.setChatList(false)
end

-- 刷新
function IDPChats.refresh()
end

-- 关闭页面
function IDPChats.hide()
    IDUtl.hidePopupButtons()
    selectedPidx = nil
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPChats.procNetwork(cmd, succ, msg, paras)
    if succ == NetSuccess then
        if cmd == NetProtoIsland.cmds.sendChat then
            uiobjs.Input.value = ""
            hideHotWheel()
        elseif cmd == NetProtoIsland.cmds.onChatChg then
            if currType == IDConst.ChatType.private then
                if selectedPidx then
                    IDDBChat.clearReddot(IDConst.ChatType.private, selectedPidx)
                end
            end
            IDPChats.setChatList(true)
        end
    end
end

-- 处理ui上的事件，例如点击等
function IDPChats.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonClose" then
        hideTopPanel(csSelf)
    elseif goName == "ButtonSend" then
        local content = uiobjs.Input.value
        if isNilOrEmpty(content) then
            CLAlert.add(LGet("InputContentIsNil"), Color.yellow, 1)
            return
        end
        local toPidx = 0
        if currType == IDConst.ChatType.private then
            if selectedPidx == nil or selectedPidx == 0 then
                CLAlert.add(LGet("PleaseSelectPlayer"), Color.yellow, 1)
                return
            end
            showHotWheel()
            CLLNet.send(NetProtoIsland.send.sendChat(content, currType, selectedPidx))
        else
            showHotWheel()
            CLLNet.send(NetProtoIsland.send.sendChat(content, currType, 0))
        end
    elseif goName == "ToggleWorld" then
        IDPChats.chgType(IDConst.ChatType.world)
    elseif goName == "ToggleUnion" then
        IDPChats.chgType(IDConst.ChatType.union)
    elseif goName == "TogglePrivate" then
        IDPChats.chgType(IDConst.ChatType.private)
    elseif goName == "Bg" then
        -- 把事件传给下层ui
        -- local uicamera = MyCfg.self.uiCamera:GetComponent("UICamera")
        -- uicamera:ProcessRelease()
        -- uicamera:Update()
        -- uicamera:LateUpdate()
        hideTopPanel(csSelf)
    elseif goName == "ButtonFace" then
        isShowFaces = not isShowFaces
        uiobjs.ButtonCloseTw:Play(isShowFaces)
        uiobjs.ChatFaces:Play(isShowFaces)
        uiobjs.ChatFacesTw2:Play(isShowFaces)
    end
end

-- 当顶层页面发生变化时回调
function IDPChats.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPChats.hideSelfOnKeyBack()
    return true
end

--------------------------------------------
return IDPChats
