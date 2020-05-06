---@class _ParamIDPMails
---@field public isReceive boolean 显示收件箱(可为空)
---@field public type IDConst.MailType 默认显示的类型（可为空）

---@type CLQuickSort
local Sort = require "toolkit.CLQuickSort"
---@type IDBasePanel
local IDBasePanel = require("ui.panel.IDBasePanel")
---@class IDPMails:IDBasePanel 邮件列表
local IDPMails = class("IDPMails", IDBasePanel)
local TypeToggleName = {
    [IDConst.MailType.all] = "ToggleAll",
    [IDConst.MailType.system] = "ToggleSys",
    [IDConst.MailType.report] = "ToggleReport",
    [IDConst.MailType.private] = "ToggleOther"
}
local uiobjs = {}
-- 初始化，只会调用一次
function IDPMails:init(csObj)
    IDPMails.super.init(self, csObj)
    uiobjs.Types = {}

    ---@type UIToggle
    uiobjs.ToggleReceive = getCC(self.transform, "ToggleReceive", "UIToggle")
    ---@type UIToggle
    uiobjs.ToggleSended = getCC(self.transform, "ToggleSended", "UIToggle")

    uiobjs.Types = {}
    uiobjs.Types.root = getChild(self.transform, "Types")
    uiobjs.Types.ToggleAll = {}
    uiobjs.Types.ToggleAll.Toggle = getCC(uiobjs.Types.root, "ToggleAll", "UIToggle")
    uiobjs.Types.ToggleAll.LabelUnread = getCC(uiobjs.Types.ToggleAll.Toggle.transform, "LabelUnread", "UILabel")
    uiobjs.Types.ToggleSys = {}
    uiobjs.Types.ToggleSys.Toggle = getCC(uiobjs.Types.root, "ToggleSys", "UIToggle")
    uiobjs.Types.ToggleSys.LabelUnread = getCC(uiobjs.Types.ToggleSys.Toggle.transform, "LabelUnread", "UILabel")
    uiobjs.Types.ToggleReport = {}
    uiobjs.Types.ToggleReport.Toggle = getCC(uiobjs.Types.root, "ToggleReport", "UIToggle")
    uiobjs.Types.ToggleReport.LabelUnread = getCC(uiobjs.Types.ToggleReport.Toggle.transform, "LabelUnread", "UILabel")
    uiobjs.Types.ToggleOther = {}
    uiobjs.Types.ToggleOther.Toggle = getCC(uiobjs.Types.root, "ToggleOther", "UIToggle")
    uiobjs.Types.ToggleOther.LabelUnread = getCC(uiobjs.Types.ToggleOther.Toggle.transform, "LabelUnread", "UILabel")

    ---@type Coolape.CLUILoopGrid
    uiobjs.gridList = getCC(self.transform, "PanelList/Grid", "CLUILoopGrid")
    ---@type UIButton
    uiobjs.ButtonOneKey = getCC(self.transform, "ButtonOneKey", "UIButton")
    uiobjs.Content = getChild(self.transform, "Content")
    ---@type UIScrollView
    uiobjs.PanelContent = getCC(uiobjs.Content, "PanelContent", "UIScrollView")
    uiobjs.TableCom = getCC(uiobjs.PanelContent.transform, "TableCom", "UITable")
    uiobjs.TableComPrefab = getChild(uiobjs.TableCom.transform, "00000").gameObject

    ---@type Coolape.CLCellLua
    uiobjs.ReportInfor = getCC(uiobjs.PanelContent.transform, "TableReport", "CLCellLua")
    ---@type UITable
    uiobjs.TableReport = getCC(uiobjs.PanelContent.transform, "TableReport", "UITable")
    uiobjs.LabelTitle = getCC(uiobjs.Content, "LabelTitle", "UILabel")
    uiobjs.LabelType = getCC(uiobjs.Content, "LabelType", "UILabel")

    uiobjs.GridAttachment = getCC(uiobjs.Content, "Attachment/GridAttachment", "UIGrid")
    uiobjs.ButtonReward = getCC(uiobjs.Content, "Attachment/ButtonReward", "UIButton")
    uiobjs.ButtonReplay = getCC(uiobjs.Content, "Attachment/ButtonReplay", "UIButton")
    uiobjs.ButtonReply = getCC(uiobjs.Content, "Attachment/ButtonReply", "UIButton")
    uiobjs.ButtonOneKey = getChild(self.transform, "ButtonOneKey")
    uiobjs.ButtonGM = getChild(self.transform, "ButtonGM")
    -- 设置ui事件代理
    self:setEventDelegate()
end

-- 设置数据
---@param paras _ParamIDPMails
function IDPMails:setData(paras)
    self.currType = paras and paras.type or 0
    if paras and paras.isReceive then
        uiobjs.ToggleReceive.value = paras.isReceive
    end
    self.selectedIdx = 0 -- 当前选中的邮件
end

---public 当有通用背板显示时的回调
---@param cs Coolape.CLPanelLua
function IDPMails:onShowFrame(cs)
	if cs.frameObj then
		---@type _ParamFrameData
		local d = {}
        d.title = LGet(cs.titleKeyName)
        d.hideContentBg = true
		d.panel = cs
		cs.frameObj:init(d)
	end
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPMails:show()
    if uiobjs.ToggleReceive.value then
        -- 显示收件箱
        self:showReceives(false)
    else
        -- 显示已发送
        self:showSendeds(false)
    end
end

-- 刷新
function IDPMails:refresh()
end

---public 显示收件箱
function IDPMails:showReceives(isRefresh)
    SetActive(uiobjs.Types.root.gameObject, true)
    SetActive(uiobjs.ButtonOneKey.gameObject, true)
    SetActive(uiobjs.ButtonGM.gameObject, false)
    local typeName = TypeToggleName[self.currType]
    uiobjs.Types[typeName].Toggle.value = true

    -- 设置未读邮件数量
    for type, Tname in pairs(TypeToggleName) do
        local num = IDDBMail.getUnreadNum(type)
        if num > 0 then
            uiobjs.Types[Tname].LabelUnread.text = num
            SetActive(uiobjs.Types[Tname].LabelUnread.gameObject, true)
        else
            SetActive(uiobjs.Types[Tname].LabelUnread.gameObject, false)
        end
    end

    -- 邮件列表
    self:setMailList(isRefresh)
end

-- IDPMails.sortMail = function(a, b)
--     local mail1 = IDDBMail.getMailByIndex(a)
--     local mail2 = IDDBMail.getMailByIndex(b)
--     return bio2number(mail1.date) > bio2number(mail2.date)
-- end

---public 邮件列表
function IDPMails:setMailList(isRefresh)
    local mails = IDDBMail.getMailsByType(self.currType)
    -- 邮件要倒序显示
    -- Sort.quickSort(mails, IDPMails.sortMail)

    -- 设置初始选中邮件
    if #mails > 0 then
        ---@type NetProtoIsland.ST_mail
        local mail = nil
        if self.selectedIdx <= 0 then
            self.selectedIdx = mails[1]
            mail = IDDBMail.getMailByIndex(mails[1])
        else
            mail = IDDBMail.getMailByIdx(self.selectedIdx)
        end
        if mail then
            mail.isSelected = true
        end
        self.selectedIdx = bio2number(mail.idx)
    end

    if isRefresh then
        uiobjs.gridList:refreshContentOnly(mails)
    else
        uiobjs.gridList:setList(mails, self:wrapFunc(self.initMailCell))
    end
    if #mails == 0 then
        -- //TODO:显示没有邮件的
        self:showMailContent(nil)
    end
end

function IDPMails:releaseSelected()
    ---@type NetProtoIsland.ST_mail
    local mail = nil
    if self.selectedIdx > 0 then
        local count = uiobjs.gridList.transform.childCount
        local child, cell, celldata
        for i = 0, count - 1 do
            child = uiobjs.gridList.transform:GetChild(i)
            cell = child.gameObject:GetComponent("CLCellLua")
            if cell.luaTable then
                celldata = cell.luaTable.getData()
                if celldata and bio2number(celldata.idx) == self.selectedIdx then
                    cell.luaTable.selected(false)
                    break
                end
            end
        end
        mail = IDDBMail.getMailByIdx(self.selectedIdx)
    end
    if mail then
        mail.isSelected = false
    end
    self.selectedIdx = 0
end

---@param cell Coolape.CLCellLua
function IDPMails:initMailCell(cell, index)
    local data = IDDBMail.getMailByIndex(index)
    cell:init(data, self:wrapFunc(self.onClickMailCell))
    if data.isSelected then
        self:onClickMailCell(cell)
    end
end

---@param cell CLCellLua
function IDPMails:onClickMailCell(cell)
    self:releaseSelected()
    ---@type IDCellMail
    local cellLua = cell.luaTable
    local mail = cellLua.getData()
    cellLua.selected(true)
    mail.isSelected = true
    self.selectedIdx = bio2number(mail.idx)

    self:showMailContent(mail)
    if bio2number(mail.state) == IDConst.MailState.unread and bio2number(mail.rewardIdx) <= 0 then
        CLLNet.send(NetProtoIsland.send.readMail(bio2number(mail.idx)))
    end
end

---public 显示已发送
function IDPMails:showSendeds(isRefresh)
    SetActive(uiobjs.Types.root.gameObject, false)
    SetActive(uiobjs.ButtonOneKey.gameObject, false)
    SetActive(uiobjs.ButtonGM.gameObject, true)

    local mails = IDDBMail.getSendedMails()
    if isRefresh then
        uiobjs.gridList:refreshContentOnly(mails)
    else
        uiobjs.gridList:setList(mails, self:wrapFunc(self.initMailCell))
    end
    if #mails == 0 then
        -- //TODO:显示没有邮件的
        self:showMailContent(nil)
    end
end

---@param mail NetProtoIsland.ST_mail
function IDPMails:showMailContent(mail)
    if mail == nil then
        --//TODO:显示没有邮件的
        SetActive(uiobjs.Content.gameObject, false)
        return
    end
    SetActive(uiobjs.Content.gameObject, true)

    local type = bio2number(mail.type)
    local title = LWrap(mail.title, mail.titleParams)
    if #(mail.historyList) > 1 then
        uiobjs.LabelTitle.text = joinStr("Re:", title)
    else
        uiobjs.LabelTitle.text = title
    end
    uiobjs.LabelType.text = LGet(IDConst.MailTypeName[type])
    if type == IDConst.MailType.report then
        self:showBattleReport(mail)
    else
        self:showComContent(mail)
    end
    -- 显示附件
    self:showAttachment(mail)
    uiobjs.PanelContent:ResetPosition()
end

---@param mail NetProtoIsland.ST_mail
function IDPMails:showComContent(mail)
    SetActive(uiobjs.TableCom.gameObject, true)
    SetActive(uiobjs.TableReport.gameObject, false)
    local list = IDDBMail.getMailHistoryList(bio2number(mail.idx))
    local i = 0
    CLUIUtl.resetList4Lua(
        uiobjs.TableCom,
        uiobjs.TableComPrefab,
        list,
        function(cell, data)
            if i > 0 then
                data.lineSize = #list - i
            else
                data.lineSize = 0
            end
            i = i + 1
            cell:init(data, nil)
        end
        -- self:wrapFunc(self.intCellComContent)
    )
end

function IDPMails:intCellComContent(cell, data)
    cell:init(data, nil)
end

---@param mail NetProtoIsland.ST_mail
function IDPMails:showBattleReport(mail)
    SetActive(uiobjs.TableCom.gameObject, false)
    SetActive(uiobjs.TableReport.gameObject, true)
end

---@param mail NetProtoIsland.ST_mail
function IDPMails:showAttachment(mail)
    --//TODO:
    local type = bio2number(mail.type)
    if type == IDConst.MailType.private then
        SetActive(uiobjs.ButtonReward.gameObject, false)
        SetActive(uiobjs.ButtonReplay.gameObject, false)
        SetActive(uiobjs.ButtonReply.gameObject, true)
    else
        SetActive(uiobjs.ButtonReply.gameObject, false)
        local comIdx = bio2number(mail.comIdx)
        if comIdx > 0 then
            if type == IDConst.MailType.report then
                SetActive(uiobjs.ButtonReward.gameObject, false)
                SetActive(uiobjs.ButtonReplay.gameObject, true)
            else
                SetActive(uiobjs.ButtonReplay.gameObject, false)
            end
        else
            -- 没有附件
            SetActive(uiobjs.ButtonReward.gameObject, false)
            SetActive(uiobjs.ButtonReplay.gameObject, false)
        end
    end
end

---@param data NetProtoIsland.RC_getReportDetail
function IDPMails:replayBattleFleet(data)
    ---@type _ParamBattleFleetData
    local battleData = {}
    battleData.type = IDConst.BattleType.attackFleet
    battleData.battleData = data.battleFleetDetail
    battleData.result = data.battleresult

    hideTopPanel(self.csSelf)
    IDUtl.chgScene(GameMode.battleFleet, battleData, nil)
end

---@param data NetProtoIsland.RC_getReportDetail
function IDPMails:replayBattle(data)
    ---@type NetProtoIsland.ST_battleDetail
    local report = data.battleDetail
    ---@type IDDBPlayer
    local targetPlayer = IDDBPlayer.new(report.target)
    ---@type IDDBCity
    local targetCity = IDDBCity.new(report.targetCity)
    local cellIndex = bio2number(targetCity.pos)
    targetCity:setAllUnits2Buildings(report.targetUnits)

    ---@type _ParamBattleData
    local battleData = {}
    battleData.type = IDConst.BattleType.attackIsland
    battleData.attackPlayer = report.attacker
    battleData.targetPlayer = targetPlayer
    battleData.targetCity = targetCity
    battleData.fleet = report.fleet
    battleData.isReplay = true
    battleData.deployQueue = report.deployQueue
    battleData.endFrames = report.endFrames
    battleData.result = data.battleresult

    hideTopPanel(self.csSelf)
    IDUtl.chgScene(GameMode.battle, battleData, nil)
end

-- 关闭页面
function IDPMails:hide()
    self:releaseSelected()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPMails:procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.onMailChg then
            if uiobjs.ToggleReceive.value then
                -- 显示收件箱
                self:showReceives(true)
            else
                -- 显示已发送
                self:showSendeds()
            end
        end
    end
end

function IDPMails:setEventDelegate()
    self.EventDelegate = {
        ["ToggleReceive"] = function()
            self:show()
        end,
        ["ToggleSended"] = function()
            self:show()
        end,
        ["ToggleAll"] = function()
            self:releaseSelected()
            self.currType = IDConst.MailType.all
            self:showReceives(false)
        end,
        ["ToggleReport"] = function()
            self:releaseSelected()
            self.currType = IDConst.MailType.report
            self:showReceives(false)
        end,
        ["ToggleSys"] = function()
            self:releaseSelected()
            self.currType = IDConst.MailType.system
            self:showReceives(false)
        end,
        ["ToggleOther"] = function()
            self:releaseSelected()
            self.currType = IDConst.MailType.private
            self:showReceives(false)
        end,
        ["ButtonReplay"] = function()
            -- 重播
            local mail = IDDBMail.getMailByIdx(self.selectedIdx)
            if mail then
                showHotWheel()
                CLLNet.send(
                    NetProtoIsland.send.getReportDetail(
                        bio2number(mail.comIdx),
                        ---@param result NetProtoIsland.RC_getReportDetail
                        function(org, result)
                            if bio2Int(result.battleType) == IDConst.BattleType.attackIsland then
                                -- 攻岛战
                                self:replayBattle(result)
                            else
                                -- 舰队对战
                                self:replayBattleFleet(result)
                            end
                            hideHotWheel()
                        end,
                        mail
                    )
                )
            else
                printe("取得邮件失败！！")
            end
        end,
        ["ButtonOneKey"] = function()
        end,
        ["ButtonReply"] = function()
            -- 回复
            if self.selectedIdx == nil or self.selectedIdx <= 0 then
                --//TODO:
                return
            end
            ---@type NetProtoIsland.ST_mail
            local mail = IDDBMail.getMailByIdx(self.selectedIdx)
            ---@type _ParamPWriteMail
            local d = {}
            d.mail = mail
            d.targetPidx = bio2number(mail.fromPidx)
            getPanelAsy("PanelWriteMail", onLoadedPanelTT, d)
        end,
        ["ButtonGM"] = function()
        end
    }
end
-- 处理ui上的事件，例如点击等
function IDPMails:uiEventDelegate(go)
    local func = self.EventDelegate[go.name]
    if func then
        func()
    end
end

-- 当顶层页面发生变化时回调
function IDPMails:onTopPanelChange(topPanel)
end

--------------------------------------------
return IDPMails
