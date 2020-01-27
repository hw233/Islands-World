---@class _ParamIDCellWorldTileHud 大地图块hud参数
---@field public target UnityEngine.Transform
---@field public offset UnityEngine.Vector3
---@field public data NetProtoIsland.ST_mapCell
---@field public dataFleet NetProtoIsland.ST_fleetinfor
---@field public attr DBCFMapTileData
---@field public isFleet boolean  是否舰队

-- 大地图块hud
local _cell = {}
---@type Coolape.CLCellLua
local csSelf = nil
local transform = nil
---@type _ParamIDCellWorldTileHud
local mData = nil
local uiobjs = {}

-- 初始化，只调用一次
function _cell.init(csObj)
    csSelf = csObj
    transform = csSelf.transform
    --[[
    上的组件：getChild(transform, "offset", "Progress BarHong"):GetComponent("UISlider")
	--]]
    ---@type UIFollowTarget
    uiobjs.followTarget = csSelf:GetComponent("UIFollowTarget")
    uiobjs.followTarget:setCamera(MyCfg.self.mainCamera, MyCfg.self.uiCamera)
    uiobjs.LabelName = getCC(transform, "LabelName", "UILabel")
end

-- 显示，
-- 注意，c#侧不会在调用show时，调用refresh
---@param data _ParamIDCellWorldTileHud
function _cell.show(go, data)
    mData = data
    uiobjs.followTarget:setTarget(mData.target, mData.offset or Vector3.zero)
    if mData.isFleet then
        local cidx = bio2number(mData.dataFleet.cidx)
        if cidx == bio2number(IDDBCity.curCity.idx) then
            uiobjs.LabelName.text = joinStr(mData.dataFleet.name, "\n", "[00ff00]", mData.dataFleet.pname, "[-]")
        else
            uiobjs.LabelName.text = joinStr(mData.dataFleet.name, "\n", "[ffff00]", mData.dataFleet.pname, "[-]")
        end
    else
        local gid = bio2Int(mData.attr.GID)
        if gid == IDConst.WorldmapCellType.user then
			local cidx = bio2number(mData.data.cidx)
            if cidx == bio2number(IDDBCity.curCity.idx) then
                uiobjs.LabelName.text = joinStr("[00ff00]", mData.data.name, "[-]")
            else
                uiobjs.LabelName.text = joinStr("[ffff00]", mData.data.name, "[-]")
            end
        else
            if mData.data then
				local cidx = bio2number(mData.data.cidx)
                if cidx > 0 then
                    if cidx == bio2number(IDDBCity.curCity.idx) then
                        uiobjs.LabelName.text = joinStr(LGet(mData.attr.Name), "\n", "[00ff00]", mData.data.name, "[-]")
                    else
                        uiobjs.LabelName.text = joinStr(LGet(mData.attr.Name), "\n", "[ffff00]", mData.data.name, "[-]")
                    end
                else
                    uiobjs.LabelName.text = LGet(mData.attr.Name)
                end
            else
                uiobjs.LabelName.text = LGet(mData.attr.Name)
            end
        end
    end
end

-- 取得数据
function _cell.getData()
    return mData
end

--------------------------------------------
return _cell
