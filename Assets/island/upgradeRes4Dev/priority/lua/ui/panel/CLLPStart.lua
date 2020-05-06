--开始游戏
local csSelf = nil
local transform = nil
local gameObject = nil
local user
local selectedServer
local panelIndex = 0

-- 放在后面加载的页面
local lateLoadPanels = {
    "PanelMain",
    "PanelSceneManager" -- 切换场景页面
}

-- 其它ui资源提前加载
local lateLoadOtherUIs = {
    "Frame1",
    "Frame2"
}

local isLogined = false
local CLLPStart = {}

function CLLPStart.init(go)
    csSelf = go
    transform = csSelf.transform
    gameObject = csSelf.gameObject
    -- 加载一些必要的lua
    pcall(CLLPStart.setLuasAtBegainning)
end

-- 加载一些必要的lua
function CLLPStart.setLuasAtBegainning()
    require "public.CLLInclude"

    -- 日志监听开关
    -- if ReporterMessageReceiver and ReporterMessageReceiver.self and ReporterMessageReceiver.self.gameObject then
    --     if CLLWhiteList.isWhiteName() then
    --         ReporterMessageReceiver.self.gameObject:SetActive(true)
    --     else
    --         ReporterMessageReceiver.self.gameObject:SetActive(false)
    --     end
    -- end

    -- 取得数据配置
    require("cfg.DBCfg")
    require("public.IDUtl")
    require("public.IDConst")

    --UIAtlas.releaseSpriteTime = 5 -- 释放ui资源的时间（秒）

    -- 设置是否可以成多点触控
    -- CLCfgBase.self.uiCamera:GetComponent("UICamera").allowMultiTouch = false

    -- if (SystemInfo.systemMemorySize < 2048) then
    --     CLCfgBase.self.isFullEffect = false
    -- end

    -- 网络
    Net.self:setLua()
    -- 资源释放时间
    if CLAssetsManager.self then
        CLAssetsManager.self.timeOutSec4Realse = 60
    end

    CLPanelManager.self.mainPanelName = "PanelMain"
    -- 添加屏蔽字
    --MyMain.self:invoke4Lua(CLLPStart.addShieldWords, 1)

    --//TODO:other lua scripts
    require("net.NetProtoIslandClient")
    require("public.IDLCameraMgr")
    IDLCameraMgr.init()
    require("city.IDLBuildingSize")
    --IDLBuildingSize.init()
    local worldmap = getCC(MyMain.self.transform, "worldmap", "CLBaseLua")
    worldmap:setLua()

    -- 数据缓存
    require "db.IDDBRoot"
    IDDBRoot.init()
end

function CLLPStart.setData(pars)
    user = pars[1]
    selectedServer = pars[2]
end

function CLLPStart.show()
    --CLLPStart.createPanel()
end

-- 刷新页面
function CLLPStart.refresh()
    if not isLogined then
        CLLPStart.createPanel()
    end
end

-- 关闭页面
function CLLPStart.hide()
    csSelf:cancelInvoke4Lua()
end

-- 创建ui
function CLLPStart.createPanel()
    panelIndex = 0
    local count = #(lateLoadPanels)
    if (count > 0) then
        for i = 1, count do
            local name = lateLoadPanels[i]
            CLPanelManager.getPanelAsy(name, CLLPStart.onLoadPanelAfter)
        end
    else
        isLogined = true
        CLLPStart.loadOtherUI()
    end
end

function CLLPStart.onLoadPanelAfter(p)
    p:init()
    panelIndex = panelIndex + 1
    local count = #(lateLoadPanels)
    if (panelIndex >= count) then
        --已经加载完
        CLLPStart.loadOtherUI()
    end
end

-- 加载其它ui资源
function CLLPStart.loadOtherUI()
    panelIndex = 0
    local count = #(lateLoadOtherUIs)
    if (count > 0) then
        for i = 1, count do
            local name = lateLoadOtherUIs[i]
            CLUIOtherObjPool.setPrefab(name, CLLPStart.onLoadOtherUIAfter, nil, nil)
        end
    else
        isLogined = true
        CLLPStart.connectServer()
    end
end

function CLLPStart.onLoadOtherUIAfter()
    panelIndex = panelIndex + 1
    local count = #(lateLoadOtherUIs)
    if (panelIndex >= count) then
        --已经加载完
        CLLPStart.connectServer()
    end
end

-- 添加屏蔽字
function CLLPStart.addShieldWords()
    local onGetShieldWords = function(path, content, originals)
        if (content ~= nil) then
            BlockWordsTrie.getInstanse():init(content)
        end
    end
    local path = joinStr(CLPathCfg.self.basePath, "/", CLPathCfg.upgradeRes, "/priority/txt/shieldWords")
    CLVerManager.self:getNewestRes(path, CLAssetType.text, onGetShieldWords, true, nil)
end

-- 连接服务器相关处理
function CLLPStart.connectServer()
    showHotWheel()
    Net.self:connect(selectedServer.host, selectedServer.port)
end

-- 处理网络接口
function CLLPStart.procNetwork(cmd, succ, msg, pars)
    if (succ == NetSuccess) then
        -- 接口处理成功
        if (cmd == "connectCallback") then
            --[[
                if (pars == Net.self.gateTcp) then
                end
                ]]
            hideHotWheel()
        elseif cmd == NetProtoIsland.cmds.sendNetCfg then
            IDDBRoot.clean()

            -- 服务器通知的网络相关配置，可以发送请求了
            showHotWheel()
            local uid = user.idx
            if CLCfgBase.self.isEditMode then
                if not isNilOrEmpty(MyCfg.self.default_UID) then
                    uid = MyCfg.self.default_UID
                elseif (not isNilOrEmpty(__UUID__)) then
                    uid = __UUID__
                end
            else
                if not isNilOrEmpty(__UUID__) then
                    uid = __UUID__
                end
            end
            CLLNet.send(
                NetProtoIsland.send.login(
                    uid,
                    getChlCode(),
                    1,
                    Utl.uuid,
                    MyCfg.self.isEditScene or __EditorMode__,
                    function(orgs, data)
                        ---@type NetProtoIsland.RC_login
                        local result = data
                        if result.retInfor == nil or bio2number(result.retInfor.code) ~= NetSuccess then
                            CLLPStart.back2Splash()
                        end
                        hideHotWheel()
                    end,
                    nil,
                    10
                )
            )
        elseif cmd == NetProtoIsland.cmds.login then
            hideHotWheel()
            DateEx.init(bio2number(pars.systime))
            ---- IAP 登陆成功后再初化iap
            --local rt, err = pcall(KKChlIAP.init)
            --if not rt then
            --    printe(err)
            --end

            if IDDBPlayer.myself.beingattacked then
                -- //TODO: 如果你正在被其它玩家攻击，我就不能进入
                CLAlert.add("你正在被其它玩家攻击，暂时不能进入!", Color.yellow, 10)
            else
                CLLPStart.doEnterGame()
            end
        end
    else
        -- 接口返回不成功
        if (cmd == "outofNetConnect") then
            hideHotWheel()
            CLUIUtl.showConfirm(LGet("MsgOutofConnect"), CLLPStart.connectServer, CLLPStart.back2Splash)
        else
            CLAlert.add(msg, Color.red, 1)
        end
    end
end

function CLLPStart.back2Splash()
    local p = CLPanelManager.getPanel("PanelSplash")
    if (p ~= nil) then
        CLPanelManager.showPanel(p)
    end
    hideTopPanel()
end

-- 点击返回键关闭自己（页面）
function CLLPStart.hideSelfOnKeyBack()
    return false
end

function CLLPStart.doEnterGame()
    IDUtl.chgScene(GameMode.map)
    local p2 = CLPanelManager.getPanel("PanelSplash")
    if (p2 ~= nil) then
        CLPanelManager.hidePanel(p2)
    end
end

----------------------------------------------
return CLLPStart
