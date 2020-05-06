---@type IDBasePanel
local IDBasePanel = require("ui.panel.IDBasePanel")
---@class IDPMagics:IDBasePanel 邮件列表
local IDPMagics = class("IDPMagics", IDBasePanel)

local uiobjs = {}
-- 初始化，只会调用一次
function IDPMagics:init(csObj)
    IDPMagics.super.init(self, csObj)
    ---@type Coolape.CLUILoopGrid
    uiobjs.grid = getCC(self.transform, "PanelList/Grid", "CLUILoopGrid")
    self:setEventDelegate()
end

-- 设置数据
---@param paras _ParamIDPMagics
function IDPMagics:setData(paras)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPMagics:show()
    self:showList(false)
end

function IDPMagics:showList(isRefresh)
    local list = DBCfg.getData(DBCfg.CfgPath.Magic)
    if isRefresh then
        uiobjs.grid:refreshContentOnly(list)
    else
        uiobjs.grid:setList(list.list, self:wrapFunc(self.initCell))
    end
end

function IDPMagics:initCell(cell, data)
    cell:init(data, nil)
end

-- 刷新
function IDPMagics:refresh()
end

-- 关闭页面
function IDPMagics:hide()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPMagics:procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.onBuildingChg then
            ---@type NetProtoIsland.RC_onBuildingChg
            local d = paras
            if bio2number(d.building.attrid) == IDConst.BuildingID.MagicAltar then
                self:showList(false)
            end
        elseif cmd == NetProtoIsland.cmds.summonMagic or cmd == NetProtoIsland.cmds.summonMagicSpeedUp then
            self:showList(false)
            hideHotWheel()
        end
    end
end

function IDPMagics:setEventDelegate()
    self.EventDelegate = {}
end
-- 处理ui上的事件，例如点击等
function IDPMagics:uiEventDelegate(go)
    local func = self.EventDelegate[go.name]
    if func then
        func()
    end
end

-- 当顶层页面发生变化时回调
function IDPMagics:onTopPanelChange(topPanel)
end

--------------------------------------------
return IDPMagics
