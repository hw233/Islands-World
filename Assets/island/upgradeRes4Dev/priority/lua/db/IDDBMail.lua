---@class IDDBMail 邮件缓存
IDDBMail = {}
IDDBMail.mails = {} -- 总邮件列表
IDDBMail.mailsIndexMap = {} -- 邮件idx->邮件的索引index
IDDBMail.mailsReceive = {} -- 收件箱
IDDBMail.mailsSend = {} -- 发件箱
IDDBMail.mailsType = {} -- 邮件类型列表
IDDBMail.mailsUnreadNum = {} -- 发件箱
IDDBMail.reports = {} -- 战报记录

---@public 初始化
IDDBMail.init = function()
    IDDBMail.clean()
    -- 取是全部邮件
    CLLNet.send(NetProtoIsland.send.getMails())
end

---@public 当取得所有邮件时
IDDBMail.onGetMails = function(mails)
    IDDBMail.mails = mails
    ---@param m NetProtoIsland.ST_mail
    for i, m in ipairs(mails) do
        IDDBMail.mailsIndexMap[bio2number(m.idx)] = i
        -- 记录分类数据
        IDDBMail.wrapData(m)
    end
end

---@public 当有邮件推送时
IDDBMail.onMailsChg = function(mails)
    ---@param m NetProtoIsland.ST_mail
    local index = 0
    for i, m in ipairs(mails) do
        index = IDDBMail.mailsIndexMap[bio2number(m.idx)]
        if index == nil then
            -- 新邮件
            table.insert(IDDBMail.mails, m)
            index = #(IDDBMail.mails)
            IDDBMail.mailsIndexMap[bio2number(m.idx)] = index
            -- 记录分类数据
            IDDBMail.wrapData(m)
        else
            ---@type NetProtoIsland.ST_mail
            local oldMail = IDDBMail.getMailByIndex(index)
            if bio2number(oldMail.state) == IDConst.MailState.unread 
                and bio2number(m.state) ~= IDConst.MailState.unread then
                IDDBMail.onReadMail(m)
            end
            -- 刷新数据
            IDDBMail.mails[index] = m
        end
    end
end

---@public 包装邮件列表
---@param mail NetProtoIsland.ST_mail
IDDBMail.wrapData = function(mail)
    -- 邮件的索引
    local index = IDDBMail.mailsIndexMap[bio2number(mail.idx)]

    local fromPidx = mail.fromPidx
    if bio2number(fromPidx) == bio2number(IDDBPlayer.myself.idx) then
        -- 说明是自己的发的邮件,记录到已发送
        table.insert(IDDBMail.mailsSend, index)
    else
        -- 记录到收件箱
        table.insert(IDDBMail.mailsReceive, index)
        -- 记录分类数据
        local list = IDDBMail.mailsType[IDConst.MailType.all] or {}
        table.insert(list, index)
        IDDBMail.mailsType[IDConst.MailType.all] = list

        list = IDDBMail.mailsType[bio2number(mail.type)] or {}
        table.insert(list, index)
        IDDBMail.mailsType[bio2number(mail.type)] = list
        -- 未读邮件计数
        if
            bio2number(mail.state) == IDConst.MailState.unread or
                bio2number(mail.state) == IDConst.MailState.readNotRewared
         then
            IDDBMail.mailsUnreadNum[IDConst.MailType.all] = (IDDBMail.mailsUnreadNum[IDConst.MailType.all] or 0) + 1
            local type = bio2number(mail.type)
            IDDBMail.mailsUnreadNum[type] = (IDDBMail.mailsUnreadNum[type] or 0) + 1
        end
    end
end

---@param mail NetProtoIsland.ST_mail
IDDBMail.onReadMail = function(mail)
    IDDBMail.mailsUnreadNum[IDConst.MailType.all] = (IDDBMail.mailsUnreadNum[IDConst.MailType.all] or 0) - 1
    local type = bio2number(mail.type)
    IDDBMail.mailsUnreadNum[type] = (IDDBMail.mailsUnreadNum[type] or 0) - 1
end

---@public 取得已发送邮件
IDDBMail.getSendedMails = function()
    return IDDBMail.mailsSend
end

---@public 根据类型得邮件列表
IDDBMail.getMailsByType = function(type)
    local ret = {}
    return IDDBMail.mailsType[type] or {}
end

---@public 通过索引取得邮件，注意不是邮件的idx
IDDBMail.getMailByIndex = function(index)
    return IDDBMail.mails[index]
end

---@public 通过邮件的idx取得邮件
IDDBMail.getMailByIdx = function(idx)
    local index = IDDBMail.mailsIndexMap[idx]
    if index == nil then
        return nil
    end
    return IDDBMail.mails[index]
end

---@public 取得邮件的历史记录列表
IDDBMail.getMailHistoryList = function(idx)
    ---@type NetProtoIsland.ST_mail
    local mail = IDDBMail.getMailByIdx(idx)
    if mail == nil then
        return nil
    end
    local hList = {}
    if mail.historyList then
        for i, _idx in ipairs(mail.historyList) do
            table.insert(hList, IDDBMail.getMailByIdx(bio2number(_idx)))
        end
    end
    return hList
end

---@public 取得未读邮件数量
IDDBMail.getUnreadNum = function(type)
    return IDDBMail.mailsUnreadNum[type] or 0
end

IDDBMail.clean = function()
    IDDBMail.mails = {}
    IDDBMail.mailsIndexMap = {}
    IDDBMail.mailsType = {}
    IDDBMail.reports = {}
    IDDBMail.mailsReceive = {} -- 收件箱
    IDDBMail.mailsSend = {} -- 发件箱
    IDDBMail.mailsUnreadNum = {} -- 发件箱
end

return IDDBMail
