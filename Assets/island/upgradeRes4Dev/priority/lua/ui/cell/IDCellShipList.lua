-- xx单元
do
    local _cell = {}
    local csSelf = nil
    local transform = nil
    local mData = nil
    local uiobjs = {}
    local attr

    -- 初始化，只调用一次
    function _cell.init (csObj)
        csSelf = csObj
        transform = csSelf.transform
        --[[
        上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider")
        --]]
        uiobjs.offset = getChild(transform, "offset")
        uiobjs.SpriteBg = getCC(uiobjs.offset, "SpriteBg", "UISprite")
        uiobjs.Icon = getCC(uiobjs.offset, "Icon", "UISprite")
        uiobjs.Label = getCC(uiobjs.offset, "Label", "UILabel")
        uiobjs.LabelLev = getCC(uiobjs.offset, "LabelLev", "UILabel")
    end

    -- 显示，
    -- 注意，c#侧不会在调用show时，调用refresh
    function _cell.show (go, data)
        mData = data
        attr = mData.attr
        uiobjs.Icon.spriteName = IDUtl.getRoleIcon(bio2number(attr.ID))
        uiobjs.Label.text = tostring(mData.count)
        uiobjs.LabelLev.text = LGetFmt("LevelWithNum", IDDBCity.curCity:getUnitLev(bio2number(attr.ID)))
        CLUIUtl.setAllSpriteGray(csSelf.gameObject, mData.isLocked)
        _cell.setSelected(mData.isSelected)
    end

    function _cell.setSelected(val)
        val = val or false
        mData.isSelected = val
        local pos = uiobjs.offset.localPosition
        if val then
            pos.y = 20
            uiobjs.offset.localPosition = pos
            uiobjs.SpriteBg.spriteName = "frame_Bg_Bz_lanse"
        else
            pos.y = 0
            uiobjs.offset.localPosition = pos
            uiobjs.SpriteBg.spriteName = "frame_Bg_Bz_chengse"
        end
    end

    -- 取得数据
    function _cell.getData ()
        return mData
    end

    --------------------------------------------
    return _cell
end
