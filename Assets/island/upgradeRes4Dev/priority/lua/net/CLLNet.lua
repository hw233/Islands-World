﻿--- 网络下行数据调度器
require("bio.BioUtl")
require("net.NetProtoUsermgrClient")
require("net.NetProtoIslandClient")
require("db.IDDBPlayer")
require("db.IDDBCity")
require("db.IDDBWorldMap")
CLLNet = {}
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
    WWWEx.postBytes(Utl.urlAddTimes(url), postData, CLAssetType.bytes, callback, CLLNet.httpError, orgs, true)
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
    else
        local dispatchInfor = NetProtoIsland.dispatch[map[0]]
        if dispatchInfor then
            local data = dispatchInfor.onReceive(map)
            CLLNet.dispatch(data)
        end
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

---@public 缓存数据
function CLLNet.onReceiveCMD(cmd, data)
    local func = CLLNet.receiveCMDFunc[cmd]
    if func then
        func(cmd, data)
    end
end

---@public 缓存数据的方法
CLLNet.receiveCMDFunc = {
    ---@param data NetProtoIsland.RC_login
    [NetProtoIsland.cmds.login] = function(cmd, data)
        NetProtoIsland.__sessionID = bio2number(data.session)
        ---@type NetProtoIsland.ST_player
        local player = data.player
        local p = IDDBPlayer.new(player)

        -- 切换账号时的情况
        if IDDBPlayer.myself and bio2number(IDDBPlayer.myself.idx) ~= bio2number(p.idx) then
            IDUtl.onSwitchPlayer()
        end

        IDDBPlayer.myself = p
        ---@type NetProtoIsland.ST_city
        local city = data.city
        local curCity = IDDBCity.new(city)
        curCity:initDockyardShips()

        IDDBCity.curCity = curCity
        -- 初始化时间
        local systime = bio2number(data.systime)
        DateEx.init(systime)

        -- 取得舰队列表
        CLLNet.send(NetProtoIsland.send.getAllFleets(bio2number(city.idx)))
    end,
    ---@param data NetProtoIsland.RC_getAllFleets
    [NetProtoIsland.cmds.getAllFleets] = function(cmd, data)
        IDDBCity.curCity:setFleets(data.fleetinfors)
    end,
    ---@param data NetProtoIsland.RC_saveFleet
    [NetProtoIsland.cmds.saveFleet] = function(cmd, data)
        IDDBCity.curCity:onFleetChg(data.fleetinfor, false)
    end,
    ---@param data NetProtoIsland.RC_getFleet
    [NetProtoIsland.cmds.getFleet] = function(cmd, data)
        IDDBCity.curCity:onFleetChg(data.fleetinfor, false)
    end,
    ---@param data NetProtoIsland.RC_sendFleet
    [NetProtoIsland.cmds.sendFleet] = function(cmd, data)
        IDDBCity.curCity:onFleetChg(data.fleetinfor, data.isRemove)
        IDDBWorldMap.onGetFleet(data.fleetinfor, data.isRemove)
    end,
    ---@param data NetProtoIsland.RC_onPlayerChg
    [NetProtoIsland.cmds.onPlayerChg] = function(cmd, data)
        IDDBPlayer.myself = IDDBPlayer.new(data.player)
    end,
    [NetProtoIsland.cmds.newBuilding] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onBuildingChg(data.building)
        end
    end,
    [NetProtoIsland.cmds.newTile] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onTileChg(data.tile)
        end
    end,
    [NetProtoIsland.cmds.moveTile] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onTileChg(data.tile)
        end
    end,
    [NetProtoIsland.cmds.onBuildingChg] = function(cmd, data)
        -- 当有建筑变化
        if IDDBCity.curCity then
            IDDBCity.curCity:onBuildingChg(data.building)
        end
    end,
    [NetProtoIsland.cmds.rmTile] = function(cmd, data)
        if IDDBCity.curCity then
            local idx = bio2number(data.idx)
            IDDBCity.curCity.tiles[idx] = nil
        end
    end,
    [NetProtoIsland.cmds.rmBuilding] = function(cmd, data)
        if IDDBCity.curCity then
            local idx = bio2number(data.idx)
            IDDBCity.curCity.buildings[idx] = nil
        end
    end,
    ---@param data NetProtoIsland.RC_getMapDataByPageIdx
    [NetProtoIsland.cmds.getMapDataByPageIdx] = function(cmd, data)
        if IDDBWorldMap then
            IDDBWorldMap.onGetMapPageData(data.mapPage)
            IDDBWorldMap.onGetFleets4Page(data.fleetinfors)
        end
    end,
    [NetProtoIsland.cmds.getShipsByBuildingIdx] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onGetUnits4Building(data.dockyardShips)
        end
    end,
    ---@param data NetProtoIsland.RC_onFinishBuildOneShip
    [NetProtoIsland.cmds.onFinishBuildOneShip] = function(cmd, data)
        --//TODO:当完成一个舰船时，
    end,
    [NetProtoIsland.cmds.sendNetCfg] = function(cmd, data)
        -- 初始化时间
        local systime = bio2number(data.systime)
        DateEx.init(systime)
        ---@type CLLNetSerialize
        local netSerialize = csSelf.luaTable
        if netSerialize then
            netSerialize.setCfg(data.netCfg)
        end
    end,
    ---@param data NetProtoIsland.RC_onMapCellChg
    [NetProtoIsland.cmds.onMapCellChg] = function(cmd, data)
        IDDBWorldMap.onMapCellChg(data.mapCell, data.isRemove)
    end,
    [NetProtoIsland.cmds.onMyselfCityChg] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onMyselfCityChg(data.city)
        end
    end,
    ---@param data NetProtoIsland.RC_sendPrepareAttackIsland
    [NetProtoIsland.cmds.sendPrepareAttackIsland] = function(cmd, data)
        if IDDBPlayer.myself:equal(data.player) then
            -- 防守方
            if IDDBPlayer.myself.attacking then
                -- 当我正在攻击其它玩家时，突然又有玩家来攻击我，但是你已经在攻击状态，所以不能退出，只能简单提示下
                CLAlert.add(LGetFmt("MsgSomebodyAttackYou", data.player2.name), Color.red, 5)
            else
                getPanelAsy("PanelBeingAttacked", doShowPanel, data)
            end
        else
            if IDDBPlayer.myself:equal(data.player2) then
                -- 进攻方
                IDWorldMap.selectFleet(bio2number(data.fleetinfor.idx))
                getPanelAsy("PanelBattlePrepare", doShowPanel, data)
            else
                -- 数据错误
            end
        end
    end
}

-- 心跳
function CLLNet.heart()
    CLLNet.send(NetProtoIsland.send.heart())
    InvokeEx.invoke(CLLNet.heart, timeOutSec)
end

function CLLNet.cancelHeart()
    InvokeEx.cancelInvoke(CLLNet.heart)
end

---@public 发送网络数据
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
