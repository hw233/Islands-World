﻿-- xx界面
---@class _ParamIDPSceneManager
---@field public mode GameMode
---@field public data table
---@field public __finishCallback__ function

require("city.IDMainCity")
require("battle.IDLBattle")
require("battle.IDLFleetBattle")
IDPSceneManager = {}

---@type Coolape.CLPanelLua
local csSelf = nil
local transform = nil
---@type UnityEngine.Transform
local lookAtTarget = MyCfg.self.lookAtTarget
local progressBar
local LabelTip
---@type _ParamIDPSceneManager
local mData
local _isLoadingScene = false
local dragSetting = CLUIDrag4World.self
local smoothFollow = IDLCameraMgr.smoothFollow

-- 初始化，只会调用一次
function IDPSceneManager.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    --[[
        上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider")
        --]]
    local bottom = getChild(transform, "Bottom")
    progressBar = getCC(bottom, "Progress Bar", "UISlider")
    LabelTip = getCC(bottom, "LabelTip", "UILabel")
end

-- 设置数据
function IDPSceneManager.setData(paras)
    mData = paras
end

-- 显示，在c#中。show为调用refresh，show和refresh的区别在于，当页面已经显示了的情况，当页面再次出现在最上层时，只会调用refresh
function IDPSceneManager.show()
    _isLoadingScene = true
    progressBar.value = 0
    csSelf:invoke4Lua(IDPSceneManager.loadScene, 0.1)
end

function IDPSceneManager.isLoadingScene()
    return _isLoadingScene
end

function IDPSceneManager.beforeLoadScene()
    local oldMode = MyCfg.mode
    if oldMode == GameMode.city then
        if IDMainCity then
            IDMainCity.clean()
        end
    elseif oldMode == GameMode.battle then
        if IDLBattle then
            IDLBattle.clean()
        end
    elseif oldMode == GameMode.battleFleet then
        if IDLFleetBattle then
            IDLFleetBattle.clean()
        end
    elseif oldMode == GameMode.map then
        if IDMainCity then
            IDMainCity.clean()
        end
        if IDWorldMap then
            IDWorldMap.clean()
        end
    end
    releaseRes4GC()
end

function IDPSceneManager.loadScene()
    IDPSceneManager.beforeLoadScene()
    if MyCfg.mode == GameMode.map then
        IDWorldMap.moveToView(
            IDWorldMap.getCityIndex(),
            GameModeSub.map,
            function()
                csSelf:invoke4Lua(IDPSceneManager.doLoadScene, 0.3)
            end
        )
    else
        csSelf:invoke4Lua(IDPSceneManager.doLoadScene, 0.5)
    end
end

function IDPSceneManager.doLoadScene()
    MyCfg.mode = mData.mode
    local currMode = MyCfg.mode
    if currMode == GameMode.city then
        IDPSceneManager.loadCity()
    elseif currMode == GameMode.map then
        IDPSceneManager.loadWorldMap()
    elseif currMode == GameMode.battle then
        IDPSceneManager.loadBattle()
    elseif currMode == GameMode.battleFleet then
        IDPSceneManager.loadBattleFleet()
    end
end

-- 刷新
function IDPSceneManager.refresh()
end

-- 关闭页面
function IDPSceneManager.hide()
    csSelf:cancelInvoke4Lua()
    _isLoadingScene = false
    if mData and mData.__finishCallback__ then
        mData.__finishCallback__()
    end
end

-- 网络请求的回调；cmd：指命，succ：成功失败，msg：消息；paras：服务器下行数据
function IDPSceneManager.procNetwork(cmd, succ, msg, paras)
    --[[
        if(succ == NetSuccess) then
          if(cmd == "xxx") then
          end
        end
        --]]
end

-- 处理ui上的事件，例如点击等
function IDPSceneManager.uiEventDelegate(go)
    local goName = go.name
    --[[
        if(goName == "xxx") then
        end
        --]]
end

-- 当按了返回键时，关闭自己（返值为true时关闭）
function IDPSceneManager.hideSelfOnKeyBack()
    return false
end

-- 加载主基地
function IDPSceneManager.loadCity()
    Time.fixedDeltaTime = 0.04
    -- Turn off v-sync
    QualitySettings.vSyncCount = 0
    Application.targetFrameRate = 30

    if dragSetting then
        dragSetting.isLimitCheckStrict = false
        dragSetting.canMove = true
        dragSetting.canRotation = true
        dragSetting.canScale = true
        dragSetting.scaleMini = 7
        dragSetting.scaleMax = 20
        dragSetting.scaleHeightMini = 7
        dragSetting.scaleHeightMax = 100
        -- dragSetting.viewRadius = 65
        dragSetting.dragMovement = Vector3.one
        -- * 0.4
        dragSetting.scaleSpeed = 1
    end

    smoothFollow.distance = 5
    smoothFollow.height = 5

    IDMainCity.init(nil, IDPSceneManager.onLoadCity, IDPSceneManager.onProgress)
end

function IDPSceneManager.onLoadCity()
    lookAtTarget.localEulerAngles = Vector3(0, 45, 0)
    SoundEx.playMainMusic("MainScene_1")
    getPanelAsy("PanelMain", onLoadedPanel)
end

function IDPSceneManager.onProgress(totalAssets, currCount)
    SetActive(progressBar.gameObject, true)
    progressBar.value = currCount / totalAssets
end

function IDPSceneManager.loadWorldMap()
    Time.fixedDeltaTime = 0.08
    -- Turn off v-sync
    QualitySettings.vSyncCount = 0
    Application.targetFrameRate = 30

    if dragSetting then
        dragSetting.isLimitCheckStrict = false
        dragSetting.canMove = true
        dragSetting.canRotation = true
        dragSetting.canScale = true
        dragSetting.scaleMini = 7
        dragSetting.scaleMax = 20
        dragSetting.scaleHeightMini = 7
        dragSetting.scaleHeightMax = 100
        dragSetting.viewRadius = 15000
        dragSetting.dragMovement = Vector3.one
        -- * 0.5
        dragSetting.scaleSpeed = 1
    end

    smoothFollow.distance = 20
    smoothFollow.height = 100
    lookAtTarget.localEulerAngles = Vector3(0, 45, 0)
    IDWorldMap.init(
        bio2number(IDDBCity.curCity.pos),
        function()
            SoundEx.playMainMusic("MainScene_1")
            hideTopPanel(csSelf)
            IDWorldMap.addFinishEnterCityCallback(IDPSceneManager.onEnterCity)
        end,
        IDPSceneManager.onProgress
    )
end
function IDPSceneManager.onEnterCity()
    getPanelAsy("PanelMain", onLoadedPanel)
    IDWorldMap.rmFinishEnterCityCallback(IDPSceneManager.onEnterCity)
end

-- 加载战场
function IDPSceneManager.loadBattle()
    Time.fixedDeltaTime = 0.02
    -- Turn off v-sync
    QualitySettings.vSyncCount = 0
    Application.targetFrameRate = 30

    if dragSetting then
        dragSetting.isLimitCheckStrict = false
        dragSetting.canMove = true
        dragSetting.canRotation = true
        dragSetting.canScale = true
        dragSetting.scaleMini = 7
        dragSetting.scaleMax = 20
        dragSetting.scaleHeightMini = 7
        dragSetting.scaleHeightMax = 100
        -- dragSetting.viewRadius = 65
        dragSetting.dragMovement = Vector3.one
        -- * 0.4
        dragSetting.scaleSpeed = 1
    end

    smoothFollow.distance = 5
    smoothFollow.height = 5

    IDLBattle.init(mData.data, IDPSceneManager.onLoadBattle, IDPSceneManager.onProgress)
end

function IDPSceneManager.onLoadBattle()
    lookAtTarget.localEulerAngles = Vector3(0, 45, 0)
    if IDWorldMap and IDWorldMap.ocean and IDWorldMap.ocean.luaTable then
        IDWorldMap.ocean.luaTable.stopBGM()
    end
    SoundEx.playMainMusic("Fight_before")
    hideTopPanel(csSelf)
end

function IDPSceneManager.loadBattleFleet()
    Time.fixedDeltaTime = 0.04
    -- Turn off v-sync
    QualitySettings.vSyncCount = 0
    Application.targetFrameRate = 30

    if dragSetting then
        dragSetting.isLimitCheckStrict = false
        dragSetting.canMove = true
        dragSetting.canRotation = true
        dragSetting.canScale = true
        dragSetting.scaleMini = 10
        dragSetting.scaleMax = 20
        dragSetting.scaleHeightMini = 10
        dragSetting.scaleHeightMax = 50
        dragSetting.dragMovement = Vector3.one
        dragSetting.scaleSpeed = 1
    end

    smoothFollow.distance = 10
    smoothFollow.height = 10
    IDLFleetBattle.init(mData.data, IDPSceneManager.onloadFleetBattle, IDPSceneManager.onProgress)
end

function IDPSceneManager.onloadFleetBattle()
    getPanelAsy("PanelFleetBattle", onLoadedPanel, mData.data)
end
--------------------------------------------
return IDPSceneManager
