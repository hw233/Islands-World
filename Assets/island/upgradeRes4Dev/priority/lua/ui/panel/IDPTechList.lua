---@type IDBasePanel
local IDBasePanel = require("ui.panel.IDBasePanel")
---@class IDPTechList:IDBasePanel 邮件列表
local IDPTechList = class("IDPTechList", IDBasePanel)
require "public.IDAttrUtl"
local bio2number = bio2number

local uiobjs = {}
-- 初始化，只会调用一次
function IDPTechList:init(csObj)
    IDPTechList.super.init(self, csObj)
    self:setEventDelegate()
    ---@type DBCFTechData
    self.currTech = nil

    ---@type Coolape.CLUILoopGrid
    uiobjs.grid = getCC(self.transform, "PanelList/Grid", "CLUILoopGrid")
    uiobjs.content = getChild(self.transform, "content")
    uiobjs.SpriteIcon = getCC(uiobjs.content, "SpriteIcon", "UISprite")
    uiobjs.LabelName = getCC(uiobjs.content, "LabelName", "UILabel")
    uiobjs.LabelLev = getCC(uiobjs.content, "LabelLev", "UILabel")
    uiobjs.LabelCostTime = getCC(uiobjs.content, "LabelCostTime", "UILabel")
    uiobjs.LabelNeeds = getCC(uiobjs.content, "LabelNeeds", "UILabel")
    uiobjs.ButtonUpgrade = getChild(uiobjs.content, "ButtonUpgrade")
    uiobjs.LabelCostRes = getCC(uiobjs.ButtonUpgrade, "LabelCostRes", "UILabel")
    uiobjs.ButtonUpgradeImm = getChild(uiobjs.content, "ButtonUpgradeImm")
    uiobjs.LabelCostResImm = getCC(uiobjs.ButtonUpgradeImm, "LabelCostRes", "UILabel")
    uiobjs.gridAttr = getCC(uiobjs.content, "GridAttr", "UIGrid")
    uiobjs.attrPrefab = getChild(uiobjs.gridAttr.transform, "00000").gameObject
end

-- 设置数据
---@param paras _ParamIDPTechList
function IDPTechList:setData(paras)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPTechList:show()
    self:showTechList(false)
end

function IDPTechList:showTechList(isRefresh)
    local cfgData = DBCfg.getData(DBCfg.CfgPath.Tech)
    if isRefresh then
        uiobjs.grid:refreshContentOnly(cfgData.list or {})
    else
        uiobjs.grid:setList(cfgData.list or {}, self:wrapFunc(self.initTechCell))
    end
end

---@param data DBCFTechData
function IDPTechList:initTechCell(cell, data)
    cell:init(data, self:wrapFunc(self.onClickTechCell))
    if self.currTech == nil or bio2number(self.currTech.ID) == bio2number(data.ID) then
        cell.luaTable.setSelect(true)
        self:onClickTechCell(cell, data)
    end
end

---@param data DBCFTechData
function IDPTechList:onClickTechCell(cell, data)
    self.currTech = data
    self:showTechContent(data)
end

---@param data DBCFTechData
function IDPTechList:showTechContent(data)
    local id = bio2number(data.ID)
    local serverData = IDDBCity.curCity:getTechByID(id) or {}
    local lev = IDDBCity.curCity:getTechLev(id)
    local isUnlocked = IDDBCity.curCity:isTechUnlocked(id)
    uiobjs.SpriteIcon.spriteName = data.Icon
    uiobjs.LabelName.text = LGet(data.NameKey)
    uiobjs.LabelLev.text = joinStr(LGet("Level"), ":", lev, "➚", lev + 1)
    local cost =
        DBCfg.getGrowingVal(
        bio2number(data.UpgradeCostGoldMin),
        bio2number(data.UpgradeCostGoldMax),
        bio2number(data.UpgradeCostGoldCurve),
        (lev + 1) / bio2number(data.MaxLev)
    )
    uiobjs.LabelCostRes.text = tostring(cost)

    local mm =
        DBCfg.getGrowingVal(
        bio2number(data.UpgradeTimeMin),
        bio2number(data.UpgradeTimeMax),
        bio2number(data.UpgradeTimeCurve),
        (lev + 1) / bio2number(data.MaxLev)
    )

    -- 先去掉cooldown
    self.csSelf:cancelInvoke4Lua(self.cooldownTime)

    local attrList, calculNextLev
    if isUnlocked then
        uiobjs.LabelNeeds.text = ""
        if IDDBCity.curCity:isTechUpgrading(id) then
            uiobjs.LabelNeeds.text = joinStr("[00ff00]", LGet("Upgrading"), "[-]")
            SetActive(uiobjs.ButtonUpgrade.gameObject, false)
            SetActive(uiobjs.ButtonUpgradeImm.gameObject, true)
            self:cooldownTime()
        else
            uiobjs.LabelCostTime.text =
                joinStr(LGet("UpgradeTime"), ": [ffff00]", DateEx.toStrCn(mm * 60 * 1000), "[-]")
            SetActive(uiobjs.ButtonUpgrade.gameObject, true)
            SetActive(uiobjs.ButtonUpgradeImm.gameObject, false)
        end
        calculNextLev = true
    else
        uiobjs.LabelCostTime.text = joinStr(LGet("UpgradeTime"), ": [ffff00]", DateEx.toStrCn(mm * 60 * 1000), "[-]")
        -- 未解锁
        uiobjs.LabelNeeds.text =
            joinStr("[ff0000]", LGetFmt("TechCenterLev", bio2number(data.NeedTechCenterLev)), "[-]")
        SetActive(uiobjs.ButtonUpgrade.gameObject, false)
        SetActive(uiobjs.ButtonUpgradeImm.gameObject, false)
        calculNextLev = false
    end
    if bio2number(data.GID) == 1 then
        attrList = IDAttrUtl.getUnitAttrs(IDConst.AttrType.ship, bio2number(data.RelationID), serverData, calculNextLev)
    else
        attrList =
            IDAttrUtl.getUnitAttrs(IDConst.AttrType.skill, bio2number(data.RelationID), serverData, calculNextLev)
    end
    CLUIUtl.resetList4Lua(uiobjs.gridAttr, uiobjs.attrPrefab, attrList, self:wrapFunc(self.initAttrCell))
end

function IDPTechList:cooldownTime()
    self.csSelf:cancelInvoke4Lua(self.cooldownTime)
    local diff = bio2number(IDDBCity.curCity.techCenter.endtime) - DateEx.nowMS
    if diff > 0 then
        uiobjs.LabelCostTime.text = joinStr(LGet("UpgradeTime"), ": [ffff00]", DateEx.toStrCn(diff), "[-]")
        uiobjs.LabelCostResImm.text = tostring(IDUtl.minutes2Diam(diff / 60000))
        self.csSelf:invoke4Lua(self.cooldownTime, 1)
    end
end

function IDPTechList:initAttrCell(cell, data)
    cell:init(data, nil)
end

-- 刷新
function IDPTechList:refresh()
end

-- 关闭页面
function IDPTechList:hide()
    self.currTech = nil
    self.csSelf:cancelInvoke4Lua()
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPTechList:procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.onTechChg then
            self:showTechList(true)
        end
    end
end

function IDPTechList:setEventDelegate()
    self.EventDelegate = {
        ButtonUpgrade = function()
            if self.currTech then
                ---@type NetProtoIsland.ST_techInfor
                showHotWheel()
                CLLNet.send(
                    NetProtoIsland.send.upLevTech(
                        bio2number(self.currTech.ID),
                        function()
                            self:showTechList(true)
                            hideHotWheel()
                        end
                    )
                )
            end
        end,
        ButtonUpgradeImm = function()
            if self.currTech then
                ---@type NetProtoIsland.ST_techInfor
                showHotWheel()
                CLLNet.send(
                    NetProtoIsland.send.upLevTechImm(
                        bio2number(self.currTech.ID),
                        function()
                            self:showTechList(true)
                            hideHotWheel()
                        end
                    )
                )
            end
        end
    }
end
-- 处理ui上的事件，例如点击等
function IDPTechList:uiEventDelegate(go)
    local func = self.EventDelegate[go.name]
    if func then
        func()
    end
end

-- 当顶层页面发生变化时回调
function IDPTechList:onTopPanelChange(topPanel)
end

--------------------------------------------
return IDPTechList
