-- 通用ui框1
local _cell = {}
local csSelf = nil
local transform = nil

---@class _ParamFrameData
---@field public title string 标题
---@field public closeCallback string 标题
---@field public panel Coolape.CLPanelLua
---@field public hideClose boolean true时隐藏关闭按钮
---@field public hideTitle boolean true时隐藏标题
---@field public hideContentBg boolean true时隐藏内容背景框

---@type _ParamFrameData
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    local TopRight = getChild(transform, "TopRight")
    ---@type UISprite
    uiobjs.SpriteBg = getCC(transform, "SpriteBg", "UISprite")
    uiobjs.SpriteContentBg = getCC(transform, "SpriteContentBg", "UISprite")
    uiobjs.BtnClose = getChild(TopRight, "SpriteClose").gameObject
    uiobjs.LabelTitle = getCC(TopRight, "LabelTitle", "UILabel")
    ---@type UIAnchor
    uiobjs.TopRight = TopRight:GetComponent("UIAnchor")
    local sizeAdjust = UIRoot.GetPixelSizeAdjustment(uiobjs.SpriteBg.gameObject)

    local persent1 = Screen.width * sizeAdjust / 1920
    local persent2 = Screen.height * sizeAdjust / 1080
    uiobjs.SpriteBg.transform.localScale = Vector3.one * (persent1 > persent2 and persent1 or persent2)
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
function _cell.show(go, data)
    mData = data
    uiobjs.LabelTitle.text = mData.title

    if mData.hideClose then
        SetActive(uiobjs.BtnClose, false)
    else
        SetActive(uiobjs.BtnClose, true)
    end
    if mData.hideTitle then
        SetActive(uiobjs.LabelTitle.gameObject, false)
    else
        uiobjs.LabelTitle.text = mData.title
        SetActive(uiobjs.LabelTitle.gameObject, true)
    end

    if mData.hideContentBg then
        SetActive(uiobjs.SpriteContentBg.gameObject, false)
    else
        SetActive(uiobjs.SpriteContentBg.gameObject, true)
    end
    uiobjs.TopRight.enabled = true
end

function _cell.uiEventDelegate(go)
    local goName = go.name
    if goName == "SpriteClose" then
        if mData.closeCallback then
            Utl.doCallback(mData.closeCallback)
        else
            hideTopPanel(mData.panel)
        end
    end
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
