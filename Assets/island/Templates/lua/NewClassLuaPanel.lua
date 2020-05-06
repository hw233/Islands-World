
---@type IDBasePanel
local IDBasePanel = require("ui.panel.IDBasePanel")
---@class #SCRIPTNAME#:IDBasePanel 邮件列表
local #SCRIPTNAME# = class("#SCRIPTNAME#", IDBasePanel)

local uiobjs = {}
-- 初始化，只会调用一次
function #SCRIPTNAME#:init(csObj)
    #SCRIPTNAME#.super.init(self, csObj)

    self:setEventDelegate()
end

-- 设置数据
---@param paras _Param#SCRIPTNAME#
function #SCRIPTNAME#:setData(paras)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function #SCRIPTNAME#:show()
end

-- 刷新
function #SCRIPTNAME#:refresh()
end

-- 关闭页面
function #SCRIPTNAME#:hide()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function #SCRIPTNAME#:procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        --[[
        if cmd == xx then
        end
        ]]
    end
end

function #SCRIPTNAME#:setEventDelegate()
    self.EventDelegate = {
    }
end
-- 处理ui上的事件，例如点击等
function #SCRIPTNAME#:uiEventDelegate(go)
    local func = self.EventDelegate[go.name]
    if func then
        func()
    end
end

-- 当顶层页面发生变化时回调
function #SCRIPTNAME#:onTopPanelChange(topPanel)
end

--------------------------------------------
return #SCRIPTNAME#
