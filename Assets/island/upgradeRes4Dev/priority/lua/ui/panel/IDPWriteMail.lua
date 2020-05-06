---@class _ParamPWriteMail
---@field public targetPidx number 目标玩家idx
---@field public mail NetProtoIsland.ST_mail 原始邮件

local IDPWriteMail = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
---@type _ParamPWriteMail
local mData

-- 初始化，只会调用一次
function IDPWriteMail.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    local offset = getChild(transform, "offset")
    uiobjs.LabelRecipient = getCC(offset, "LabelRecipient/LabelVal", "UILabel")
    ---@type UIInput
    uiobjs.InputTheme = getCC(offset, "LabelTheme/Input", "UIInput")
    uiobjs.InputThemeCollider = uiobjs.InputTheme:GetComponent("BoxCollider")
    ---@type UIScrollView
    uiobjs.PanelConent = getCC(offset, "LabelContent/PanelContent", "UIScrollView")
    ---@type UIInput
    uiobjs.InputContent = getCC(offset, "LabelContent/PanelContent/Input", "UIInput")

    uiobjs.TableHis = getCC(uiobjs.InputContent.transform, "TableHis", "UITable")
    uiobjs.TableHisPrefab = getChild(uiobjs.TableHis.transform, "00000").gameObject
end

-- 设置数据
function IDPWriteMail.setData(paras)
    mData = paras or {}
end

--当有通用背板显示时的回调
function IDPWriteMail.onShowFrame(cs)
    if cs.frameObj then
        ---@type _ParamFrameData
        local d = {}
        d.title = LGet(cs.titleKeyName)
        d.panel = cs
        cs.frameObj:init(d)
    end
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPWriteMail.show()
    uiobjs.LabelRecipient.text = ""
    if mData.targetPidx and mData.targetPidx ~= 0 then
        IDDBPlayer.getPlayerSimple(mData.targetPidx, IDPWriteMail.onGetPlayerInfor)
    end

    if mData.mail then
        uiobjs.InputTheme.value = joinStr("Re:", LWrap(mData.mail.title, mData.mail.titleParams))
        uiobjs.InputThemeCollider.enabled = false
    else
        uiobjs.InputTheme.value = ""
        uiobjs.InputThemeCollider.enabled = true
    end
    uiobjs.InputContent.value = ""
    uiobjs.InputContent.transform.localPosition = Vector3(40, 0, 0)
    uiobjs.PanelConent:ResetPosition()

    -- 显示历史
    local hisList = nil
    if mData and mData.mail then
		hisList = IDDBMail.getMailHistoryList(bio2number(mData.mail.idx))
        -- table.insert(hisList, 1, mData.mail)
    else
        hisList = {}
    end
    CLUIUtl.resetList4Lua(uiobjs.TableHis, uiobjs.TableHisPrefab, hisList, IDPWriteMail.initCellHis)
end

function IDPWriteMail.initCellHis(cell, data)
    cell:init(data, nil)
end

---@param data NetProtoIsland.ST_chatInfor
function IDPWriteMail.onGetPlayerInfor(data)
    uiobjs.LabelRecipient.text = data.name
end

-- 刷新
function IDPWriteMail.refresh()
end

-- 关闭页面
function IDPWriteMail.hide()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPWriteMail.procNetwork(cmd, succ, msg, paras)
    if succ == NetSuccess then
        if cmd == NetProtoIsland.cmds.sendMail or cmd == NetProtoIsland.cmds.replyMail then
            hideHotWheel()
            CLAlert.add(LGet("Sended"), Color.green, 1)
            hideTopPanel(csSelf)
        end
    end
end

-- 处理ui上的事件，例如点击等
function IDPWriteMail.uiEventDelegate(go)
    local goName = go.name
    if goName == "Bg4Content" then
        -- uiobjs.InputContent:BroadcastMessage("OnClick")
        uiobjs.InputContent:OnClick()
    elseif goName == "ButtonSend" then
        local content = trim(uiobjs.InputContent.value)
        if isNilOrEmpty(content) then
            CLAlert.add(LGet("InputContentIsNil"), Color.yellow, 1)
            return
        end

        local title = trim(uiobjs.InputTheme.value)
        if isNilOrEmpty(title) then
            CLAlert.add(LGet("InputThemeIsNil"), Color.yellow, 1)
            return
        end
        if mData.targetPidx == nil or mData.targetPidx == 0 then
            CLAlert.add(LGet("PleaseSelectPlayer"), Color.yellow, 1)
            return
        end

        showHotWheel()
        if mData.mail then
            -- 回复邮件
            CLLNet.send(NetProtoIsland.send.replyMail(bio2number(mData.mail.idx), content))
        else
            -- 新邮件
            CLLNet.send(NetProtoIsland.send.sendMail(mData.targetPidx, title, content, IDConst.MailType.private))
        end
    end
end

-- 当顶层页面发生变化时回调
function IDPWriteMail.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPWriteMail.hideSelfOnKeyBack()
    return true
end

--------------------------------------------
return IDPWriteMail
