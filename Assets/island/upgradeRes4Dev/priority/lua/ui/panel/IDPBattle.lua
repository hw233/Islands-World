﻿-- xx界面
local IDPBattle = {}

local csSelf = nil
local transform = nil
---@type BattleData
local mData

-- 初始化，只会调用一次
function IDPBattle.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    --[[
    上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider");
    --]]
end

-- 设置数据
function IDPBattle.setData(paras)
    mData = paras
    --mData.defData
    --mData.offData 进攻方的舰船数据
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPBattle.show()
    CLUIDrag4World.setCanClickPanel(csSelf.name)
end

-- 刷新
function IDPBattle.refresh()
    IDPBattle.shwoShips()
end

function IDPBattle.shwoShips()
    -- wrap mData
    local shipMap = mData.offShips
    ---@param v NetProtoIsland.ST_dockyardShips
    for k, v in pairs(shipMap) do
        for shipId, num in pairs(v.shipsMap or {}) do
          
        end
    end
end

-- 关闭页面
function IDPBattle.hide()
    CLUIDrag4World.removeCanClickPanel(csSelf.name)
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPBattle.procNetwork(cmd, succ, msg, paras)
    --[[
    if(succ == NetSuccess) then
      if(cmd == "xxx") then
        -- TODO:
      end
    end
    --]]
end

-- 处理ui上的事件，例如点击等
function IDPBattle.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonQuit" then
        IDLBattle.clean()
        --//TODO:强制退出战斗时，通知服务器
        -- net:send(NetProtoIsland.send.stopAttack)
        IDUtl.chgScene(GameMode.map)
    end
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPBattle.hideSelfOnKeyBack()
    return false
end

--------------------------------------------
return IDPBattle