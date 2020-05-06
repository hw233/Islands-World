-- xx界面
local IDPFleetBattle = {}

---@type Coolape.CLPanelLua
local csSelf = nil
---@type UnityEngine.Transform
local transform = nil
local uiobjs = {}

-- 初始化，只会调用一次
function IDPFleetBattle.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    --[[
    上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider");
    --]]
end

-- 设置数据
function IDPFleetBattle.setData(paras)
end

--当有通用背板显示时的回调
function IDPFleetBattle.onShowFrame()
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPFleetBattle.show()
	CLUIDrag4World.setCanClickPanel(csSelf.name)
	IDLFleetBattle.start()
end

-- 刷新
function IDPFleetBattle.refresh()
end

-- 关闭页面
function IDPFleetBattle.hide()
    CLUIDrag4World.removeCanClickPanel(csSelf.name)
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPFleetBattle.procNetwork(cmd, succ, msg, paras)
    --[[
    if(succ == NetSuccess) then
      if(cmd == "xxx") then
        -- TODO:
      end
    end
    --]]
end

-- 处理ui上的事件，例如点击等
function IDPFleetBattle.uiEventDelegate(go)
    local goName = go.name
    if goName == "ButtonQuit" then
        IDUtl.chgScene(GameMode.map)
    end
end

-- 当顶层页面发生变化时回调
function IDPFleetBattle.onTopPanelChange(topPanel)
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPFleetBattle.hideSelfOnKeyBack()
    return false
end

--------------------------------------------
return IDPFleetBattle
