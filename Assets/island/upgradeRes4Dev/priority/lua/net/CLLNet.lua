--- 网络下行数据调度器
require("bio.BioUtl")
require("net.NetProtoUsermgrClient")
require("net.NetProtoIslandClient")

CLLNet = {}
local onReceiveCmdCallback = nil
local PanelListener = {}
---@type CLLQueue
local ListenerQueue = CLLQueue.new()
local strLen = string.len
local strSub = string.sub
local strPack = string.pack
--local strbyte = string.byte
--local maxPackSize = 64 * 1024 - 1
--local subPackSize = 64 * 1024 - 1 - 50
---@type Coolape.Net
local csSelf = Net.self
--local __maxLen = 1024 * 1024
local timeOutSec = 30 -- 超时秒
local NetSuccess = NetSuccess
local __httpBaseUrl = PStr.b():a("http://"):a(Net.self.gateHost):a(":"):a(tostring(Net.self.gatePort)):e()
local baseUrlUsermgr = joinStr(__httpBaseUrl, "/usermgr/postbio")

function CLLNet.refreshBaseUrl(host)
    __httpBaseUrl = PStr.b():a("http://"):a(host):a(":"):a(tostring(Net.self.gatePort)):e()
    baseUrlUsermgr = joinStr(__httpBaseUrl, "/usermgr/postbio")
end

--function CLLNet.init()
--    csSelf = Net.self
--end

local httpPostBio = function(url, postData, callback, orgs)
    WWWEx.postBytes(Utl.urlAddTimes(url), postData, CLAssetType.bytes, callback, CLLNet.httpError, orgs, true, 3)
end

function CLLNet.httpPostUsermgr(data, callback)
    local postData = BioUtl.writeObject(data)
    httpPostBio(baseUrlUsermgr, postData, CLLNet.onResponsedUsermgr, {callback = callback, data = data})
end

function CLLNet.onResponsedUsermgr(content, orgs)
    local callback = orgs.callback
    local map = nil
    if content then
        map = BioUtl.readObject(content)
    end
    if map then
        local cmd = map[0]
        local dispatchInfor = NetProtoUsermgr.dispatch[cmd]
        if dispatchInfor then
            local data = dispatchInfor.onReceive(map)
            if callback then
                callback(data)
            else
                -- 因为账号服务器返回的数据中int没有转成bio，为了兼容，在这里转
                data.retInfor.code = number2bio(data.retInfor.code)
                CLLNet.dispatch(data)
            end
        end
    end
end

function CLLNet.httpError(content, orgs)
    local callback = orgs.callback
    local data = orgs.data
    local map = {}
    local ret = {}
    local cmd = data[0]
    ret.code = number2bio(2)
    ret.msg = "http error"
    map.retInfor = ret
    map.cmd = cmd
    if callback then
        callback(map, data)
    else
        CLLNet.dispatch(map)
    end
end

--============================================================

function CLLNet.dispatchGame(map)
    if (map == nil) then
        return
    end
    if type(map) == "string" then
        if map == "connectCallback" then
            if CLPanelManager.topPanel then
                CLPanelManager.topPanel:procNetwork("connectCallback", 1, "connectCallback", nil)
            end
            InvokeEx.invoke(CLLNet.heart, timeOutSec)
        elseif map == "outofNetConnect" then
            CLLNet.onOffline()
        end
    elseif type(map) == "table" then
        local dispatchInfor = NetProtoIsland.dispatch[map[0]]
        if dispatchInfor then
            local data = dispatchInfor.onReceive(map)
            CLLNet.dispatch(data)
        end
    else
        printw("get some error data")
    end
end

function CLLNet.onOffline()
    CLLNet.cancelHeart()
    if CLPanelManager.topPanel then
        CLPanelManager.topPanel:procNetwork("outofNetConnect", -9999, "outofNetConnect", nil)
    end

    -- 处理断线处理
    if GameMode.none ~= MyCfg.mode then
        local ok, result = pcall(procOffLine)
        if not ok then
            printe(result)
        end
    end
end

function CLLNet.dispatch(map)
    local cmd = map.cmd -- 接口名
    if cmd == NetProtoIsland.cmds.heart then
        -- 心跳不处理
        return
    end
    local retInfor = map.retInfor
    -- 解密bio
    retInfor.code = BioUtl.bio2int(retInfor.code)
    local succ = retInfor.code
    local msg = retInfor.msg

    if MyCfg.self.isEditMode then
        print(joinStr("cmd:[", cmd, "]succ:[", succ, "]msg:", msg))
    end

    if (succ ~= NetSuccess) then
        printe(joinStr("cmd:[", cmd, "]succ:[", succ, "]msg:", msg))
        retInfor.msg = Localization.Get(joinStr("Error_", succ))
        CLAlert.add(retInfor.msg, Color.red, 1)
        hideHotWheel()
    else
        -- success
        CLLNet.onReceiveCMD(cmd, map)
    end

    -- 通知所有显示的页面
    -- local panels4Retain = CLPanelManager.panels4Retain
    -- if (panels4Retain ~= nil and panels4Retain.Length > 0) then
    --     for i = 0, panels4Retain.Length - 1 do
    --         panels4Retain[i]:procNetwork(cmd, succ, msg, map)
    --     end
    -- else
    --     if (CLPanelManager.topPanel ~= nil) then
    --         CLPanelManager.topPanel:procNetwork(cmd, succ, msg, map)
    --     end
    -- end

    -- 线程安全考虑，先把要处理的panle放到quque中
    for k, p in pairs(PanelListener) do
        ListenerQueue:enQueue(p)
    end
    local p
    while(ListenerQueue:size() > 0)  do
        ---@type coolape.Coolape.CLPanelBase
        p = ListenerQueue:deQueue()
        if p then
            p:procNetwork(cmd, succ, msg, map)
        end
    end
end

---@param p Coolape.CLPanelBase
function CLLNet.addPanelListener(p)
    if p then
        PanelListener[p] = p
    end
end

---@param p Coolape.CLPanelBase
function CLLNet.removePanelListener(p)
    if p then
        PanelListener[p] = nil
    end
end

function CLLNet.cleanPanelListeners()
    PanelListener = {}
end

function CLLNet.setReceiveCMDCallback(cb)
    onReceiveCmdCallback = cb
end

---public 缓存数据
function CLLNet.onReceiveCMD(cmd, data)
    if onReceiveCmdCallback then
        onReceiveCmdCallback(cmd, data)
    end
end

-- 心跳
function CLLNet.heart()
    CLLNet.send(NetProtoIsland.send.heart())
    InvokeEx.invoke(CLLNet.heart, timeOutSec)
end

function CLLNet.cancelHeart()
    InvokeEx.cancelInvoke(CLLNet.heart)
end

---public 发送网络数据
function CLLNet.send(package)
    if not csSelf:send(package) then
        pcall(procOffLine)
    end
end

function CLLNet.stop()
    if csSelf.connected then
        csSelf:stop()
        CLLNet.onOffline()
    end
    PanelListener = {}
end

return CLLNet
