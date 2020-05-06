require("db.IDDBPlayer")
require("db.IDDBCity")
require("db.IDDBWorldMap")
require("db.IDDBMail")
require("db.IDDBChat")

IDDBRoot = {}
IDDBRoot.init = function()
    CLLNet.setReceiveCMDCallback(IDDBRoot.onReceiveCMD)
end

IDDBRoot.clean = function()
    if IDDBPlayer then
        IDDBPlayer.clean()
    end
    if IDDBMail then
        IDDBMail.clean()
    end
    if IDDBChat then
        IDDBChat.clean()
    end
    if IDDBWorldMap then
        IDDBWorldMap.clean()
    end
end

---public 当接口数据返回（都是成功的情况）
IDDBRoot.onReceiveCMD = function(cmd, data)
    local func = IDDBRoot.receiveCMDFunc[cmd]
    if func then
        func(cmd, data)
    end
end

---public 缓存数据的方法
IDDBRoot.receiveCMDFunc = {
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
        IDDBCity.curCity = curCity
        curCity:initUnitsInBuildings()
        IDDBCity.curCity:onGetTechs(city.techs)
        
        -- 初始化时间
        local systime = bio2number(data.systime)
        DateEx.init(systime)

        -- 初始化邮件
        IDDBMail.init()
        -- 初始化聊天
        IDDBChat.init(bio2number(IDDBPlayer.myself.idx))
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
    ---@param data NetProtoIsland.RC_onBuildingChg
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
    ---@param data NetProtoIsland.RC_getUnitsInBuilding
    [NetProtoIsland.cmds.getUnitsInBuilding] = function(cmd, data)
        if IDDBCity.curCity then
            IDDBCity.curCity:onGetUnits4Building(data.unitsInBuilding)
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
        local netSerialize = net.luaTable
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
                CLLNet.cleanPanelListeners()
                CLPanelManager.hideAllPanel()
                getPanelAsy("PanelBeingAttacked", onLoadedPanelTT, data)
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
    end,
    ---@param data NetProtoIsland.RC_getMails
    [NetProtoIsland.cmds.getMails] = function(cmd, data)
        IDDBMail.onGetMails(data.mails)
    end,
    ---@param data NetProtoIsland.RC_onMailChg
    [NetProtoIsland.cmds.onMailChg] = function(cmd, data)
        IDDBMail.onMailsChg(data.mails)
    end,
    ---@param data NetProtoIsland.RC_onChatChg
    [NetProtoIsland.cmds.onChatChg] = function(cmd, data)
        IDDBChat.onChatChg(data.chatInfors)
    end,
    ---@param data NetProtoIsland.RC_getTechs
    [NetProtoIsland.cmds.getTechs] = function(cmd, data)
        IDDBCity.curCity:onGetTechs(data.techInfors)
    end,
    ---@param data NetProtoIsland.RC_onTechChg
    [NetProtoIsland.cmds.onTechChg] = function(cmd, data)
        IDDBCity.curCity:onTechChg(data.techInfor)
    end
}

return IDDBRoot
