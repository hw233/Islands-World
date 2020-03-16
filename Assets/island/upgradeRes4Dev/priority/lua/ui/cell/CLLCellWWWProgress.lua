-- 界面元素对象
local csSelf = nil
local transform = nil

local Label
local ProgressBar

-- 属性值变量
local mData = nil

local uiCell = {}

function uiCell.init(go)
    transform = go.transform
    csSelf = transform:GetComponent("CLCellLua")

    Label = getChild(transform, "Label"):GetComponent("UILabel")
    ProgressBar = getChild(transform, "Progress Bar"):GetComponent("UISlider")
end

function uiCell.show(go, data)
    mData = data
    NGUITools.SetActive(ProgressBar.gameObject, true)
    Label.text = ""
    InvokeEx.cancelInvokeByUpdate(uiCell.refresh)
    uiCell.refresh()
end

function uiCell.refresh()
    if (mData == nil or mData.www == nil) then
        NGUITools.SetActive(ProgressBar.gameObject, false)
        Label.text = ""
        return
    end
    --        Label.text = PStr.b():a(mData.url):a("..."):a(mData.www.progress*100):a("%"):e()
    Label.text = PStr.b():a(math.floor(mData.www.downloadProgress * 100)):a("%"):e()
    ProgressBar.value = mData.www.downloadProgress
    InvokeEx.invokeByUpdate(uiCell.refresh, 0.02)
end

function uiCell.OnDisable()
    InvokeEx.cancelInvokeByUpdate(uiCell.refresh)
end

function uiCell.getdata()
    return mData, uiCell
end

------------------------------------
return uiCell
