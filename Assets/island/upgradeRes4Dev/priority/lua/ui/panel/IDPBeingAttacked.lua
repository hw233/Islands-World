-- xx界面
local IDPBeingAttacked = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
---@type NetProtoIsland.RC_sendPrepareAttackIsland
local mdata

-- 初始化，只会调用一次
function IDPBeingAttacked.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    uiobjs.LabelTitle = getCC(transform, "LabelTitle", "UILabel")
    uiobjs.SpriteBG = getCC(transform, "SpriteBG", "UISprite")
end

-- 设置数据
function IDPBeingAttacked.setData(paras)
    mdata = paras
end

--当有通用背板显示时的回调
function IDPBeingAttacked.onShowFrame(cs)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPBeingAttacked.show()
    SetActive(uiobjs.SpriteBG.gameObject, true)
    -- csSelf.panel.depth = CLPanelManager.self.depth + 500
    uiobjs.LabelTitle.text = "你的岛屿正在被攻击..."
end

function IDPBeingAttacked.setCanDragScreem()
    SetActive(uiobjs.SpriteBG.gameObject, false)
end

-- 刷新
function IDPBeingAttacked.refresh()
end

-- 关闭页面
function IDPBeingAttacked.hide()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPBeingAttacked.procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.sendEndAttackIsland then
            hideTopPanel(csSelf)
            IDUtl.chgScene(GameMode.map)
        elseif cmd == NetProtoIsland.cmds.sendStartAttackIsland then
            IDPBeingAttacked.startBattle(paras)
        elseif cmd == NetProtoIsland.cmds.sendBattleDeployUnit then
            if IDLBattle and IDLBattle.isEnterCity then
                IDLBattle.doplay4Replay(paras.deployUnitInfor)
            end
        end
    end
end

---@param data NetProtoIsland.RC_sendStartAttackIsland
function IDPBeingAttacked.startBattle(data)
    if IDWorldMap then
        IDWorldMap.unselectFleet()
    end

    ---@type IDDBPlayer
    local targetPlayer = IDDBPlayer.new(data.player)
    ---@type IDDBCity
    local targetCity = IDDBCity.new(data.city)
    local cellIndex = bio2number(targetCity.pos)
    targetCity:setAllUnits2Buildings(data.unitsInBuildings)

    ---@type _ParamBattleData
    local battleData = {}
    battleData.type = IDConst.BattleType.attackIsland
    battleData.attackPlayer = data.player2
    battleData.targetPlayer = targetPlayer
    battleData.targetCity = targetCity
    battleData.fleet = data.fleetinfor
    battleData.isWatching = true
    IDUtl.chgScene(GameMode.battle, battleData, nil)
end

-- 处理ui上的事件，例如点击等
function IDPBeingAttacked.uiEventDelegate(go)
    local goName = go.name
    --[[
    if(goName == "xxx") then
      --TODO:
    end
    --]]
end

-- 当顶层页面发生变化时回调
function IDPBeingAttacked.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPBeingAttacked.hideSelfOnKeyBack()
    return true
end

--------------------------------------------
return IDPBeingAttacked
