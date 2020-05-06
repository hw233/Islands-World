-- xx界面
local IDPBattleReplay = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}
---@type _ParamBattleData
local mData
local endTime

-- 初始化，只会调用一次
function IDPBattleReplay.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    uiobjs.LabelTime = getCC(transform, "LabelTime", "UILabel")
end

-- 设置数据
function IDPBattleReplay.setData(paras)
    mData = paras
end

--当有通用背板显示时的回调
function IDPBattleReplay.onShowFrame()
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPBattleReplay.show()
    CLUIDrag4World.setCanClickPanel(csSelf.name)
end

function IDPBattleReplay.startReplay()
    endTime = DateEx.nowMS + NumEx.getIntPart(bio2number(mData.endFrames) * Time.fixedDeltaTime * 1000)
    IDPBattleReplay.cooldown()
end

function IDPBattleReplay.cooldown()
	local diff = endTime - DateEx.nowMS
    if diff > 0 then
        uiobjs.LabelTime.text = DateEx.toStrCn(diff)
		csSelf:invoke4Lua(IDPBattleReplay.cooldown, 1)
    end
end

-- 刷新
function IDPBattleReplay.refresh()
end

-- 关闭页面
function IDPBattleReplay.hide()
    csSelf:cancelInvoke4Lua()
    CLUIDrag4World.removeCanClickPanel(csSelf.name)
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPBattleReplay.procNetwork(cmd, succ, msg, paras)
    --[[
    if(succ == NetSuccess) then
      if(cmd == "xxx") then
        -- TODO:
      end
    end
    --]]
end

-- 处理ui上的事件，例如点击等
function IDPBattleReplay.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonQuit" then
        IDLBattle.endBattle()
    end
end

-- 当顶层页面发生变化时回调
function IDPBattleReplay.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPBattleReplay.hideSelfOnKeyBack()
    return false
end

--------------------------------------------
return IDPBattleReplay
