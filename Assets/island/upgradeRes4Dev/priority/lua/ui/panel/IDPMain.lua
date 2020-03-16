-- 主界面
IDPMain = {}

local csSelf = nil
local transform = nil
local uiobjs = {}
local funcBtnList = {}
local FuncBtnsMapCfg = {}
local FuncBtnsList4City = {}
local FuncBtnsList4Map = {}
local eventDelegateMap
local IDWorldMap = IDWorldMap
local currCenterIndex = 0
local isShowFuncBtns = true

-- 初始化，只会调用一次
function IDPMain.init(csObj)
    csSelf = csObj
    transform = csObj.transform

    IDPMain.initBtnsMap()

    uiobjs.publicRoot = getChild(transform, "public")
    local TableRes = getChild(uiobjs.publicRoot, "AnchorTopLeft/TableRes")
    -- 资源相关
    uiobjs.resObjs = {}
    uiobjs.resObjs.ProgressBarFood = getCC(TableRes, "ProgressBarFood", "UISlider")
    uiobjs.resObjs.LabelFood = getCC(uiobjs.resObjs.ProgressBarFood.transform, "Label", "UILabel")
    uiobjs.resObjs.spriteFood = getCC(uiobjs.resObjs.ProgressBarFood.transform, "SpriteIcon", "UISprite")
    uiobjs.resObjs.ProgressBarGold = getCC(TableRes, "ProgressBarGold", "UISlider")
    uiobjs.resObjs.LabelGold = getCC(uiobjs.resObjs.ProgressBarGold.transform, "Label", "UILabel")
    uiobjs.resObjs.spriteGold = getCC(uiobjs.resObjs.ProgressBarGold.transform, "SpriteIcon", "UISprite")
    uiobjs.resObjs.ProgressBarOil = getCC(TableRes, "ProgressBarOil", "UISlider")
    uiobjs.resObjs.LabelOil = getCC(uiobjs.resObjs.ProgressBarOil.transform, "Label", "UILabel")
    uiobjs.resObjs.spriteOil = getCC(uiobjs.resObjs.ProgressBarOil.transform, "SpriteIcon", "UISprite")
    uiobjs.resObjs.LabelDiam = getCC(TableRes, "ProgressBarDiam/Label", "UILabel")
    uiobjs.resObjs.spriteDiam = getCC(TableRes, "ProgressBarDiam/SpriteIcon", "UISprite")

    -- 功能相关
    local AnchorBottomRight = getChild(transform, "public/AnchorBottomRight")
    uiobjs.ButtonFunc = getChild(AnchorBottomRight, "ButtonFunc")
    uiobjs.funcObjs = {}
    ---@type UIGrid
    uiobjs.funcObjs.TableFuncs = getCC(AnchorBottomRight, "TableFuncs", "UIGrid")
    uiobjs.funcObjs.TableFuncsPrefab = getChild(uiobjs.funcObjs.TableFuncs.transform, "00000").gameObject

    local AnchorBottomLeft = getChild(uiobjs.publicRoot, "AnchorBottomLeft")
    uiobjs.ButtonSwitchModeIcon = getCC(AnchorBottomLeft, "ButtonSwitchMode/Sprite", "UISprite")
    uiobjs.ButtonSwitchModeLabel = getCC(AnchorBottomLeft, "ButtonSwitchMode/Label", "UILabel")
    uiobjs.ChatLabel = getCC(AnchorBottomLeft, "ButtonChat/Label", "UIRichText4Chat")

    -- 位置相关
    local AnchorBottom = getChild(transform, "public/AnchorBottom")
    uiobjs.posObjs = {}
    uiobjs.posObjs.root = getChild(AnchorBottom, "Position")
    uiobjs.posObjs.SpritePointer = getChild(uiobjs.posObjs.root, "SpritePointer")
    uiobjs.posObjs.LabelPos = getCC(uiobjs.posObjs.root, "LabelPos", "UILabel")
    uiobjs.SpriteRudder = getChild(AnchorBottom, "SpriteRudder")
    ---@type TweenPosition
    uiobjs.SpriteRudderTwPos = uiobjs.SpriteRudder:GetComponent("TweenPosition")
    uiobjs.SpriteRudderTwRot = uiobjs.SpriteRudder:GetComponent("TweenRotation")

    -- 距离方向相关
    uiobjs.ButtonDir = getChild(uiobjs.publicRoot, "DisDir/ButtonDir")
    uiobjs.DisDirLabel = getCC(uiobjs.ButtonDir, "Label", "UILabel")
    uiobjs.Direction = getChild(uiobjs.ButtonDir, "Direction")
    ------------------------------
    IDPMain.initEventDelegate()
end

function IDPMain.initBtnsMap()
    FuncBtnsMapCfg.Setting = {
        -- 设置
        label = "Setting",
        icon = "",
        showReddot = false,
        onClick = function(params)
            getPanelAsy("PanelSetting", onLoadedPanelTT)
        end,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Setting)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Setting)

    FuncBtnsMapCfg.Ranking = {
        -- 排行榜
        label = "Ranking",
        icon = "",
        showReddot = false,
        onClick = IDPMain.locakedFunc,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Ranking)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Ranking)

    FuncBtnsMapCfg.Treasure = {
        -- 宝物
        label = "Treasure",
        icon = "",
        showReddot = false,
        onClick = IDPMain.locakedFunc,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Treasure)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Treasure)

    FuncBtnsMapCfg.Alliance = {
        -- 联盟
        label = "Alliance",
        icon = "",
        showReddot = false,
        onClick = IDPMain.locakedFunc,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Alliance)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Alliance)

    FuncBtnsMapCfg.Build = {
        -- 建筑建筑
        label = "Build",
        icon = "",
        showReddot = false,
        onClick = function(params)
            getPanelAsy("PanelBuildings", onLoadedPanelTT)
        end,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Build)

    FuncBtnsMapCfg.Mail = {
        -- 邮件
        label = "Mail",
        icon = "",
        showReddot = false,
        onClick = function(params)
            getPanelAsy("PanelMails", onLoadedPanelTT)
        end,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Mail)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Mail)

    FuncBtnsMapCfg.Activity = {
        -- 活动
        label = "Activity",
        icon = "",
        showReddot = false,
        onClick = IDPMain.locakedFunc,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Activity)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Activity)

    FuncBtnsMapCfg.Task = {
        -- 任务
        label = "Task",
        icon = "",
        showReddot = false,
        onClick = IDPMain.locakedFunc,
        params = ""
    }
    table.insert(FuncBtnsList4City, FuncBtnsMapCfg.Task)
    table.insert(FuncBtnsList4Map, FuncBtnsMapCfg.Task)
end

function IDPMain.locakedFunc(params)
    CLAlert.add("功能暂未开放！", Color.yellow, 1)
end

-- 设置数据
function IDPMain.setData(paras)
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPMain.show()
    uiobjs.SpriteRudderTwPos:ResetToBeginning()
    CLUIDrag4World.setCanClickPanel(csSelf.name)
    IDPMain.onChgMode(IDWorldMap.mode, IDWorldMap.mode)
end

-- 刷新
function IDPMain.refresh()
    IDPMain.refreshRes()
end

---@public 刷新资源
function IDPMain.refreshRes()
    uiobjs.resObjs.LabelDiam.text = tostring(bio2number(IDDBPlayer.myself.diam))
    local res = IDDBCity.curCity:getRes()
    uiobjs.resObjs.LabelFood.text = tostring(res.food)
    uiobjs.resObjs.LabelGold.text = tostring(res.gold)
    uiobjs.resObjs.LabelOil.text = tostring(res.oil)
    uiobjs.resObjs.ProgressBarFood.value = res.food / res.maxfood
    uiobjs.resObjs.ProgressBarGold.value = res.gold / res.maxgold
    uiobjs.resObjs.ProgressBarOil.value = res.oil / res.maxoil
end

-- 关闭页面
function IDPMain.hide()
    CLUIDrag4World.removeCanClickPanel(csSelf.name)
    isShowFuncBtns = true
end

---@public 当游戏模式变化（主要是从世界到主城的切换时ui的变化）
function IDPMain.onChgMode(oldMode, currMode)
    if IDWorldMap.mode == GameModeSub.city then
        IDPMain.enterCityMode(oldMode)
    elseif IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity then
        IDPMain.enterWorldMode(oldMode)
    elseif IDWorldMap.mode == GameModeSub.fleet then
        IDPMain.enterFleetMode(oldMode)
    end
    IDPMain.showFuncBtns()
end

---@public 刷新主城信息
function IDPMain.enterCityMode(oldMode)
    -- uiobjs.ButtonSwitchModeIcon.spriteName = ""
    uiobjs.ButtonSwitchModeLabel.text = LGet("World")
    IDPMain.refreshPosiont(bio2number(IDDBCity.curCity.pos))
    IDPMain.refreshPointer(MyCfg.self.lookAtTarget.localEulerAngles)
    if oldMode == GameModeSub.fleet then
        uiobjs.SpriteRudderTwPos:Play(false)
    end
end

---@public 刷新世界信息
function IDPMain.enterWorldMode(oldMode)
    -- uiobjs.ButtonSwitchModeIcon.spriteName = ""
    uiobjs.ButtonSwitchModeLabel.text = LGet("BaseCamp")
    if oldMode == GameModeSub.fleet then
        uiobjs.SpriteRudderTwPos:Play(false)
    end
end

---@public 舰队模式
function IDPMain.enterFleetMode(oldMode)
    -- uiobjs.ButtonSwitchModeIcon.spriteName = ""
    uiobjs.ButtonSwitchModeLabel.text = LGet("Quit")
    uiobjs.SpriteRudderTwPos:Play(true)
end

function IDPMain.refreshPosiont(index)
    if currCenterIndex ~= index then
        -- 缓存index
        currCenterIndex = index
        -- 设置坐标
        local x, y = IDWorldMap.grid.grid:GetColumn(index), IDWorldMap.grid.grid:GetRow(index)
        uiobjs.posObjs.LabelPos.text = joinStr("([ffff00]X[-]:", x, " [ffff00]Y[-]:", y, ")")
    end
    -- 设置距离主基地距离
    if IDWorldMap.mode == GameModeSub.city then
        SetActive(uiobjs.ButtonDir.gameObject, false)
    else
        IDPMain.refreshDir()
    end
end

function IDPMain.refreshDir()
    if not uiobjs.ButtonDir.gameObject.activeInHierarchy then
        -- 如果方向指针是显示出来时，会有invoke处理刷新
        IDPMain.doRefreshDir()
    end
end

function IDPMain.doRefreshDir()
    if IDWorldMap.mode == GameModeSub.city then
        InvokeEx.cancelInvokeByUpdate(IDPMain.doRefreshDir)
        SetActive(uiobjs.ButtonDir.gameObject, false)
        return
    end
    local from = MyCfg.self.lookAtTarget.position
    local to = IDWorldMap.grid.grid:GetCellCenter(bio2number(IDDBCity.curCity.pos))
    local dis = NumEx.getIntPart(Vector3.Distance(from, to) / IDWorldMap.grid.cellSize)
    if dis <= 10 then
        SetActive(uiobjs.ButtonDir.gameObject, false)
        InvokeEx.cancelInvokeByUpdate(IDPMain.doRefreshDir)
    else
        SetActive(uiobjs.ButtonDir.gameObject, true)
        uiobjs.DisDirLabel.text = joinStr(dis, "\nKM")

        local from2 = MyCfg.self.mainCamera:WorldToScreenPoint(from)
        local to2 = MyCfg.self.mainCamera:WorldToScreenPoint(to)
        if to2.z < 0 then
            to2 = -1 * to2
        end
        from2.z = from2.y
        to2.z = to2.y
        from2.y = 0
        to2.y = 0
        -- 设置方向
        local angle = Utl.getAngle(from2, to2)
        angle.z = -angle.y
        angle.y = 0
        uiobjs.Direction.localEulerAngles = angle

        -- 设置方向舵的位置
        ---@type UnityEngine.Vector3
        local diff = (to2 - from2).normalized
        local max1 = 650 / math.abs(diff.x)
        local max2 = 320 / math.abs(diff.z)
        local max = max1 < max2 and max1 or max2
        local pos = diff * max
        pos.y = pos.z
        pos.z = 0
        uiobjs.ButtonDir.localPosition = pos
        -- 再次刷新
        InvokeEx.invokeByUpdate(IDPMain.doRefreshDir, 0.1)
    end
end

function IDPMain.refreshPointer(eulerAngles)
    local v3 = uiobjs.posObjs.SpritePointer.localEulerAngles
    v3.x = eulerAngles.x
    v3.y = eulerAngles.z
    v3.z = eulerAngles.y
    uiobjs.posObjs.SpritePointer.localEulerAngles = v3

    IDPMain.refreshDir()
end

--- 刷新功能按键列表
function IDPMain.showFuncBtns(isShowBtns)
    isShowFuncBtns = isShowBtns
    funcBtnList = nil
    if isShowFuncBtns then
        if IDWorldMap.mode == GameModeSub.city then
            funcBtnList = FuncBtnsList4City
        elseif IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity then
            funcBtnList = FuncBtnsList4Map
        end
    else
        funcBtnList = {}
        if IDWorldMap.mode == GameModeSub.city then
            table.insert(funcBtnList, FuncBtnsMapCfg.Build)
            table.insert(funcBtnList, FuncBtnsMapCfg.Setting)
        elseif IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity then
        elseif IDWorldMap.mode == GameModeSub.fleet then
        end
    end

    if IDWorldMap.mode == GameModeSub.fleet then
        funcBtnList = {}
        SetActive(uiobjs.ButtonFunc.gameObject, false)
    else
        SetActive(uiobjs.ButtonFunc.gameObject, true)
    end

    CLUIUtl.resetList4Lua(
        uiobjs.funcObjs.TableFuncs,
        uiobjs.funcObjs.TableFuncsPrefab,
        funcBtnList,
        IDPMain.initBtnCell
    )
end
function IDPMain.initBtnCell(cell, data)
    cell:init(data, nil)
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPMain.procNetwork(cmd, succ, msg, paras)
    if (succ == NetSuccess) then
        if cmd == NetProtoIsland.cmds.newBuilding then
            hideHotWheel()
            IDMainCity.onfinsihCreateBuilding(paras.building)
        elseif cmd == NetProtoIsland.cmds.onPlayerChg then
            uiobjs.resObjs.LabelDiam.text = tostring(bio2number(IDDBPlayer.myself.diam))
        elseif cmd == NetProtoIsland.cmds.onBuildingChg then
            IDMainCity.onBuildingChg(paras.building)
            local attr = DBCfg.getBuildingByID(bio2number(paras.building.attrid))
            if
                bio2number(attr.ID) == IDConst.BuildingID.headquartersBuildingID or
                    (attr and bio2number(attr.GID) == IDConst.BuildingGID.resource)
             then
                -- 刷新数据
                IDPMain.refreshRes()
            end
        elseif cmd == NetProtoIsland.cmds.newTile then
            hideHotWheel()
            IDMainCity.addTile(paras.tile)
        elseif cmd == NetProtoIsland.cmds.rmTile then
            hideHotWheel()
            IDMainCity.doRemoveTile(bio2number(paras.idx))
        elseif cmd == NetProtoIsland.cmds.rmBuilding then
            hideHotWheel()
            IDMainCity.doRemoveBuilding(bio2number(paras.idx))
        elseif cmd == NetProtoIsland.cmds.onFinishBuildingUpgrade then
            IDMainCity.onFinishBuildingUpgrade(paras.building)
        elseif cmd == NetProtoIsland.cmds.collectRes then
            hideHotWheel()
            if bio2number(paras.resVal) > 0 then
                local msg = joinStr(IDUtl.getResNameByType(bio2number(paras.resType)), " +", bio2number(paras.resVal))
                CLAlert.add(msg, Color.green, 1)
            end
            ---@type NetProtoIsland.ST_building
            local b = paras.building
            IDMainCity.onFinishCollectRes(b)
        elseif cmd == NetProtoIsland.cmds.upLevBuildingImm then
            hideHotWheel()
        end
    end
end

function IDPMain.initEventDelegate()
    eventDelegateMap = {
        ["ButtonFleets"] = function()
            getPanelAsy("PanelFleets", onLoadedPanelTT, {})
        end,
        ["ButtonSwitchMode"] = function()
            if IDWorldMap.mode == GameModeSub.city then
                IDWorldMap.moveToView(bio2number(IDDBCity.curCity.pos), GameModeSub.map, nil)
            elseif IDWorldMap.mode == GameModeSub.map then
                IDWorldMap.moveToView(bio2number(IDDBCity.curCity.pos), GameModeSub.city)
            elseif IDWorldMap.mode == GameModeSub.fleet then
                IDWorldMap.unselectFleet()
            end
        end,
        ["ButtonDir"] = function()
            IDWorldMap.moveToView(bio2number(IDDBCity.curCity.pos), GameModeSub.city)
        end,
        ["ButtonFunc"] = function()
            IDPMain.showFuncBtns(not isShowFuncBtns)
        end,
        ["SpriteHeadIcon"] = function()
            CLAlert.add("暂未开放", Color.yellow, 1)
        end
    }
end

-- 处理ui上的事件，例如点击等
function IDPMain.uiEventDelegate(go)
    local func = eventDelegateMap[go.name]
    if func then
        func()
    end
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPMain.hideSelfOnKeyBack()
    return false
end

---@public 取得资源图标对像
function IDPMain.getResIconObj(resType)
    if resType == IDConst.ResType.food then
        return uiobjs.resObjs.spriteFood
    elseif resType == IDConst.ResType.gold then
        return uiobjs.resObjs.spriteGold
    elseif resType == IDConst.ResType.oil then
        return uiobjs.resObjs.spriteOil
    elseif resType == IDConst.ResType.diam then
        return uiobjs.resObjs.spriteDiam
    end
end

--------------------------------------------
return IDPMain
