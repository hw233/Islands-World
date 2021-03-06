﻿-- 海水
local IDOcean = {}

local csSelf = nil
local transform = nil
local audioSource

-- 初始化，只会调用一次
function IDOcean.init(csObj)
    csSelf = csObj
    transform = csObj.transform
    --[[
        上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider")
        --]]
    audioSource = csSelf:GetComponent("AudioSource")
    SoundEx.addCallbackOnMusicBgSwitch(IDOcean.onBgmSwitchChg)

    IDOcean.playBGM()
end

-- 当背景开着变化时
function IDOcean.onBgmSwitchChg(val)
    if val then
        IDOcean.playBGM()
    else
        IDOcean.stopBGM()
    end
end

function IDOcean.playBGM()
    if not SoundEx.musicBgSwitch then
        return
    end
    if audioSource.clip == nil then
        CLSoundPool.borrowObjAsyn(
            "Sea",
            function(name, sound, orgs)
                if audioSource.clip ~= nil then
                    CLSoundPool.returnObj(name)
                    return
                end
                audioSource.clip = sound
                if SoundEx.musicBgSwitch then
                    audioSource:Play()
                end
            end
        )
    else
        audioSource:Play()
    end
end

function IDOcean.stopBGM()
    audioSource:Pause()
end

-- 处理ui上的事件，例如点击等
function IDOcean.onNotifyLua(go)
    local goName = go.name
end

function IDOcean.onPress()
    if MyCfg.mode == GameMode.city then
        IDMainCity.onPress(true)
    elseif MyCfg.mode == GameMode.map then
        if
            IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity or
                IDWorldMap.mode == GameModeSub.fleet
         then
            IDWorldMap.onPress(true)
        else
            IDMainCity.onPress(true)
        end
    end
end
function IDOcean.onRelease()
    if MyCfg.mode == GameMode.city then
        IDMainCity.onPress(false)
    elseif MyCfg.mode == GameMode.map then
        if
            IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity or
                IDWorldMap.mode == GameModeSub.fleet
         then
            IDWorldMap.onPress(false)
        else
            IDMainCity.onPress(false)
        end
    end
end

function IDOcean.onClick()
    SoundEx.playSound("Tap", 1, 1)
    -- 点击了海面
    if MyCfg.mode == GameMode.city then
        IDMainCity.onClickOcean()
    elseif MyCfg.mode == GameMode.map then
        if
            IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity or
                IDWorldMap.mode == GameModeSub.fleet
         then
            IDWorldMap.onClickOcean()
        else
            IDMainCity.onClickOcean()
        end
    elseif MyCfg.mode == GameMode.battle then
        IDLBattle.onClickOcean()
    end
end

function IDOcean.onDrag()
    if MyCfg.mode == GameMode.city then
        IDMainCity.onDragOcean()
    elseif MyCfg.mode == GameMode.map then
        if
            IDWorldMap.mode == GameModeSub.map or IDWorldMap.mode == GameModeSub.mapBtwncity or
                IDWorldMap.mode == GameModeSub.fleet
         then
            IDWorldMap.onDragOcean()
        else
            IDMainCity.onDragOcean()
        end
    end
end

function IDOcean.clean()
    if audioSource.audioClip then
        audioSource:Pause()
        CLSoundPool.returnObj("Sea")
        audioSource.audioClip = nil
    end
end

--------------------------------------------
return IDOcean
