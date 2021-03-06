﻿-- xx界面
local IDPBattlePrepare = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
---@type NetProtoIsland.RC_sendPrepareAttackIsland
local mData

-- 初始化，只会调用一次
function IDPBattlePrepare.init(csObj)
    csSelf = csObj
	transform = csObj.transform
	uiobjs.LabelCooldown = getCC(transform, "LabelCooldown", "UILabel")
	local TargetInfor = getChild(transform, "TargetInfor")
	uiobjs.LabelPlayerTarget = getCC(TargetInfor, "LabelPlayer", "UILabel")
	uiobjs.LabelPosTarget = getCC(TargetInfor, "LabelPos", "UILabel")
end

-- 设置数据
function IDPBattlePrepare.setData(paras)
    mData = paras
end

--当有通用背板显示时的回调
function IDPBattlePrepare.onShowFrame(cs)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPBattlePrepare.show()
    csSelf.panel.depth = CLPanelManager.self.depth + 500
	uiobjs.LabelPlayerTarget.text = mData.player.name
	uiobjs.LabelPosTarget.text = bio2number(mData.city.pos)
	csSelf:cancelInvoke4Lua(IDPBattlePrepare.cooldown)
	IDPBattlePrepare.cooldown()
end

function IDPBattlePrepare.cooldown()
	local diff = bio2number(mData.fleetinfor.arrivetime) - DateEx.nowMS
	if diff > 0 then
		uiobjs.LabelCooldown.text = DateEx.toStrCn(diff)
		csSelf:invoke4Lua(IDPBattlePrepare.cooldown, 1)
	else
		uiobjs.LabelCooldown.text = ""
	end
end

-- 刷新
function IDPBattlePrepare.refresh()
end

-- 关闭页面
function IDPBattlePrepare.hide()
	csSelf:cancelInvoke4Lua(IDPBattlePrepare.cooldown)
end

---@param data NetProtoIsland.RC_sendStartAttackIsland
function IDPBattlePrepare.startBattle(data)
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
	doHidePanel(csSelf)
    IDUtl.chgScene(
        GameMode.battle,
        battleData,
        nil
    )
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPBattlePrepare.procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.sendStartAttackIsland then
            IDPBattlePrepare.startBattle(paras)
        end
    end
end

-- 处理ui上的事件，例如点击等
function IDPBattlePrepare.uiEventDelegate(go)
    local goName = go.name
    --[[
    if(goName == "xxx") then
      --TODO:
    end
    --]]
end

-- 当顶层页面发生变化时回调
function IDPBattlePrepare.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPBattlePrepare.hideSelfOnKeyBack()
    return true
end

--------------------------------------------
return IDPBattlePrepare
