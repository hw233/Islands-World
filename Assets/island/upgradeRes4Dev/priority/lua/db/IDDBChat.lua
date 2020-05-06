---@class IDDBChat 聊天缓存
IDDBChat = {}

local table = table
local _chats4types = {} -- 根据类型缓存聊天
local _chats4Private = {} -- 私聊，根据聊天对象做了分类
local _players4Private = {} -- 私信相关的玩家
local _players4PrivateMap = {} -- 私信相关的玩家Map

local _reddot4types = {} -- 红点信息
local _reddot4Private = {} -- 红点信息
local oldPidx = 0

IDDBChat.init = function(pidx)
    IDDBChat.clean(oldPidx ~= pidx)
    oldPidx = pidx
    CLLNet.send(NetProtoIsland.send.getChats(IDDBChat.onGetAllChats))
end

---@param data NetProtoIsland.RC_getChats
IDDBChat.onGetAllChats = function(orgs, data)
    _chats4types[IDConst.ChatType.world] = data.chatInfors
    _chats4types[IDConst.ChatType.union] = data.chatInfors3
    if data.chatInfors3 and #(data.chatInfors3) > 0 then
        IDDBChat.refreshReddot(data.chatInfors3[#(data.chatInfors3)])
    end
    -- 私聊要包装成根据聊天对象分出来
    IDDBChat.onChatChg(data.chatInfors2)
end

IDDBChat.onChatChg = function(chats)
    local type, list
    ---@type NetProtoIsland.ST_chatInfor
    local chat
    local count = #(chats or {})
    for i = count, 1, -1 do
        chat = chats[i]
        type = bio2number(chat.type)
        if type == IDConst.ChatType.world or type == IDConst.ChatType.union then
            list = _chats4types[type] or {}
            table.insert(list, 1, chat)
            _chats4types[type] = list
        elseif type == IDConst.ChatType.private then
            -- 私聊：把数据按照聊天对象区分出来
            local targetPidx =
                bio2number(IDDBPlayer.myself.idx) == bio2number(chat.fromPidx) and bio2number(chat.toPidx) or
                bio2number(chat.fromPidx)
            list = _chats4Private[targetPidx] or {}
            table.insert(list, 1, chat)
            _chats4Private[targetPidx] = list
            if #list == 1 then
                -- 说明是第一次取得该玩家的聊天
                table.insert(_players4Private, targetPidx)
                _players4PrivateMap[targetPidx] = targetPidx
            end
        end

        IDDBChat.refreshReddot(chat)
    end

    if IDPMain and #chats > 0 then
        IDPMain.onGetChat(chats[1])
    end
end

IDDBChat.getNestChat = function()
    local chat1, chat2 = nil
    local list = _chats4types[IDConst.ChatType.world] or {}
    if #list > 0 then
        chat1 = list[1]
    end

    list = _chats4types[IDConst.ChatType.union] or {}
    if #list > 0 then
        chat2 = list[1]
    end
    if chat1 and chat2 then
        if bio2number(chat1.time) >= bio2number(chat2.time) then
            return chat1
        else
            return chat2
        end
    elseif chat1 then
        return chat1
    elseif chat2 then
        return chat2
    else
        return nil
    end
end

---public 刷新红点信息
---@param chat NetProtoIsland.ST_chatInfor
IDDBChat.refreshReddot = function(chat)
    local type = bio2Int(chat.type)
    if type == IDConst.ChatType.world then
        return
    elseif type == IDConst.ChatType.union then
        local oldlastTime = Prefs.getLastUnionChatTime()
        oldlastTime = tonumber(oldlastTime) or 0
        if bio2number(chat.time) > oldlastTime then
            _reddot4types[IDConst.ChatType.union] = true
            Prefs.setLastUnionChatTime(bio2number(chat.time))
        end
    elseif type == IDConst.ChatType.private then
        local targetPidx =
            bio2number(IDDBPlayer.myself.idx) == bio2number(chat.fromPidx) and bio2number(chat.toPidx) or
            bio2number(chat.fromPidx)
        local key = joinStr("pchat_", targetPidx)
        local oldlastTime = Prefs.getLastPrivateChatTime(key)
        if bio2number(chat.time) > oldlastTime then
            _reddot4Private[targetPidx] = true
            Prefs.setLastPrivateChatTime(key, bio2number(chat.time))
        end
    end
end

IDDBChat.hadReddotByType = function(type)
    if type == IDConst.ChatType.union then
        return _reddot4types[type] or false
    elseif type == IDConst.ChatType.private then
        for k, v in pairs(_reddot4Private) do
            if v then
                return true
            end
        end
    end
    return false
end

---public 是否有红点
IDDBChat.hadReddotByPidx = function(pidx)
    return _reddot4Private[pidx] or false
end

---public 清除红点
IDDBChat.clearReddot = function(type, pidx)
    if type == IDConst.ChatType.private then
        _reddot4Private[pidx] = nil
    else
        _reddot4types[type] = false
    end
end

IDDBChat.getChatsByType = function(type)
    return _chats4types[type] or {}
end

IDDBChat.getWorldChats = function()
    return _chats4types[IDConst.ChatType.world] or {}
end

IDDBChat.getUnionChats = function()
    return _chats4types[IDConst.ChatType.union] or {}
end

---public 取得和某个玩家的私聊信息
IDDBChat.getPrivateChatsByPidx = function(targtPidx)
    return _chats4Private[targtPidx] or {}
end

IDDBChat._sorPlayers = function(a, b)
    local redDot1 = IDDBChat.hadReddotByPidx(a)
    local redDot2 = IDDBChat.hadReddotByPidx(b)
    if redDot1 then
        return true
    elseif redDot2 then
        return false
    else
        return false
    end
end

---public 取得私聊的所有玩家
IDDBChat.getPlayers = function()
    table.sort(_players4Private, IDDBChat._sorPlayers)
    return _players4Private
end

---public 是否和xx聊过天
IDDBChat.hadChatwith = function(targetPidx)
    if targetPidx and _players4PrivateMap[targetPidx] then
        return true
    end
    return false
end

IDDBChat.clean = function(all)
    _chats4types = {}
    _chats4Private = {} -- 私聊，根据聊天对象做了分类
    _players4Private = {}
    _players4PrivateMap = {}
    if all then
        _reddot4types = {} -- 红点信息
        _reddot4Private = {} -- 红点信息
    end
end

return IDDBChat
