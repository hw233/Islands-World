---@class _ParamAttr
---@field public name string
---@field public icon string
---@field public value any
---@field public addValue any

IDAttrUtl = {}
local LGet = LGet
local table = table
local bio2number = bio2number
local DBCfg = DBCfg

---public 取得战斗单元的属性列表
function IDAttrUtl.getUnitAttrs(attrType, id, serverData, calculNextLev)
    local list = {}
    ---@type _ParamAttr
    local d = {}
    if attrType == IDConst.AttrType.building then
        local attr = DBCfg.getBuildingByID(id)

        -- 能否放在地面
        d = {}
        d.name = LGet("CanPlaceOnGround")
        d.icon = "attrIcon_com"
        d.value = attr.PlaceGround and LGet("Yes") or LGet("No")
        table.insert(list, d)
        -- 能否放在海面
        d = {}
        d.name = LGet("CanPlaceOnOcean")
        d.icon = "attrIcon_com"
        d.value = attr.PlaceSea and LGet("Yes") or LGet("No")
        table.insert(list, d)
        -- 生命值
        d = {}
        d.name = LGet("HP")
        d.icon = "attrIcon_hp"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.HPMin),
            bio2number(attr.HPMax),
            bio2number(attr.HPCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        table.insert(list, d)

        local attrid = bio2number(attr.ID)
        local gid = bio2number(attr.GID)
        if attrid == IDConst.BuildingID.headquartersBuildingID then
            -- 出征队列
            -- 主基地
            local headOpenAtrr = DBCfg.getHeadquartersLevsDataByLev(bio2number(serverData.lev))
            -- 地块数量
            d = {}
            d.name = LGet("Tile")
            d.icon = "attrIcon_com"
            d.value = bio2number(headOpenAtrr.Tiles)
            table.insert(list, d)
            -- 工人数量
            d = {}
            d.name = LGet("Worker")
            d.icon = "attrIcon_build"
            d.value = bio2number(headOpenAtrr.Workers)
            table.insert(list, d)
        elseif attrid == 6 or attrid == 8 or attrid == 10 then
            -- 资源建筑
            --产量
            local resType = IDUtl.getResTypeByBuildingID(attrid)
            d = {}
            d.name = IDUtl.getResNameByType(resType)
            d.icon = IDUtl.getResIcon(resType)
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.ComVal1Min),
                bio2number(attr.ComVal1Max),
                bio2number(attr.ComVal1Curve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )
            d.value = joinStr(d.value, "/", LGet("UIMinute"))
            table.insert(list, d)
        elseif attrid == 7 or attrid == 9 or attrid == 11 then
            -- 仓库
            local resType = IDUtl.getResTypeByBuildingID(attrid)
            d = {}
            d.name = IDUtl.getResNameByType(resType)
            d.icon = IDUtl.getResIcon(resType)
            d.value = bio2number(serverData.val)
            table.insert(list, d)
        elseif gid == IDConst.BuildingGID.defense then
            -- 防御建筑
            -- 攻击半径
            d = {}
            d.name = LGet("AttackDistance")
            d.icon = "attrIcon_gongjili"
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.AttackRangeMin),
                bio2number(attr.AttackRangeMax),
                bio2number(attr.AttackRangeCurve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )
            d.value = d.value / 100
            table.insert(list, d)

            -- 攻击速度
            d = {}
            d.name = LGet("AttackSpeed")
            d.icon = "attrIcon_gongjisudu"
            d.value = joinStr((bio2number(attr.AttackSpeedMS) / 1000), LGet("UISecond"))
            table.insert(list, d)
            -- 伤害
            d = {}
            d.name = LGet("Damage")
            d.icon = "attrIcon_gongjili"
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.DamageMin),
                bio2number(attr.DamageMax),
                bio2number(attr.DamageCurve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )
            table.insert(list, d)
            --是否群伤
            if bio2number(attr.DamageAffectRang) > 0 then
                d = {}
                d.name = LGet("MulAttack")
                d.icon = "attrIcon_gongjili"
                d.value =
                    joinStr(
                    LGet("Yes"),
                    "(",
                    LGet("AttackEffectRange"),
                    ":",
                    bio2number(attr.DamageAffectRang) / 100,
                    ")"
                )
                table.insert(list, d)
            end
        end
    elseif attrType == IDConst.AttrType.buildingNextOpen then
        local attr = DBCfg.getBuildingByID(id)
        local isMaxLev = false
        if bio2number(serverData.lev) >= bio2number(attr.MaxLev) then
            isMaxLev = true
        end
        -- 生命值
        d = {}
        d.name = LGet("HP")
        d.icon = "attrIcon_fangyuli"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.HPMin),
            bio2number(attr.HPMax),
            bio2number(attr.HPCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if not isMaxLev then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.HPMin),
                bio2number(attr.HPMax),
                bio2number(attr.HPCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)

        local attrid = bio2number(attr.ID)
        local gid = bio2number(attr.GID)
        if bio2number(attr.ID) == IDConst.BuildingID.headquartersBuildingID then
            -- 主基地
            -- 地块数量
            local headOpenAtrr = DBCfg.getHeadquartersLevsDataByLev(bio2number(serverData.lev))
            local nextheadOpenAtrr = DBCfg.getHeadquartersLevsDataByLev(bio2number(serverData.lev) + 1)
            -- 地块数量
            d = {}
            d.name = LGet("Tile")
            d.icon = "attrIcon_com"
            d.value = bio2number(headOpenAtrr.Tiles)
            if not isMaxLev then
                d.addValue = bio2number(nextheadOpenAtrr.Tiles) - bio2number(headOpenAtrr.Tiles)
            else
                d.addValue = 0
            end
            table.insert(list, d)
            -- 工人数量
            d = {}
            d.name = LGet("Worker")
            d.icon = "attrIcon_build"
            d.value = bio2number(headOpenAtrr.Workers)
            if isMaxLev then
                d.addValue = 0
            else
                d.addValue = bio2number(nextheadOpenAtrr.Workers) - bio2number(headOpenAtrr.Workers)
            end
            table.insert(list, d)
        elseif attrid == 6 or attrid == 8 or attrid == 10 then
            -- 资源建筑
            --产量
            local resType = IDUtl.getResTypeByBuildingID(attrid)
            d = {}
            d.name = IDUtl.getResNameByType(resType)
            d.icon = IDUtl.getResIcon(resType)
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.ComVal1Min),
                bio2number(attr.ComVal1Max),
                bio2number(attr.ComVal1Curve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )

            if isMaxLev then
                d.addValue = 0
            else
                local nextVal =
                    DBCfg.getGrowingVal(
                    bio2number(attr.ComVal1Min),
                    bio2number(attr.ComVal1Max),
                    bio2number(attr.ComVal1Curve),
                    (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
                )
                d.addValue = nextVal - d.value
            end
            d.value = joinStr(d.value, "/", LGet("UIMinute"))
            table.insert(list, d)
        elseif attrid == 7 or attrid == 9 or attrid == 11 then
            -- 仓库
            local resType = IDUtl.getResTypeByBuildingID(attrid)
            d = {}
            d.name = IDUtl.getResNameByType(resType)
            d.icon = IDUtl.getResIcon(resType)
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.ComVal1Min),
                bio2number(attr.ComVal1Max),
                bio2number(attr.ComVal1Curve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )
            if isMaxLev then
                d.addValue = 0
            else
                local nextVal =
                    DBCfg.getGrowingVal(
                    bio2number(attr.ComVal1Min),
                    bio2number(attr.ComVal1Max),
                    bio2number(attr.ComVal1Curve),
                    (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
                )
                d.addValue = nextVal - d.value
            end
            table.insert(list, d)
        end
    elseif attrType == IDConst.AttrType.ship4Build then
        local attr = DBCfg.getRoleByID(id)
        -- 空间
        d.name = LGet("OccupySpace")
        d.icon = "icon_store"
        d.value = bio2number(attr.SpaceSize)
        table.insert(list, d)
        -- 建造时间
        d = {}
        d.name = LGet("BuildTime")
        d.icon = "attrIcon_time"
        d.value = joinStr(bio2number(attr.BuildTimeS) / 10, LGet("UISecond"))
        table.insert(list, d)
        --花费
        d = {}
        d.name = LGet("BuildCost")
        d.icon = IDUtl.getResIcon(bio2number(attr.BuildRscType))
        d.value = bio2number(attr.BuildCost)
        table.insert(list, d)
    elseif attrType == IDConst.AttrType.ship then
        local attr = DBCfg.getRoleByID(id)
        local isMaxLev = false
        if bio2number(serverData.lev) >= bio2number(attr.MaxLev) then
            isMaxLev = true
        end
        if id ~= IDConst.RoleID.Barbarian then -- 陆战兵不需要建造
            -- 空间
            d.name = LGet("OccupySpace")
            d.icon = "icon_store"
            d.value = bio2number(attr.SpaceSize)
            table.insert(list, d)
            -- 建造时间
            d = {}
            d.name = LGet("BuildTime")
            d.icon = "attrIcon_time"
            d.value = joinStr(bio2number(attr.BuildTimeS) / 10, LGet("UISecond"))
            table.insert(list, d)
            -- 建造消耗
            d = {}
            d.name = LGet("BuildCost")
            d.icon = IDUtl.getResIcon(bio2number(attr.BuildRscType))
            d.value = bio2number(attr.BuildCost)
            table.insert(list, d)
        end
        -- 移动速度
        d = {}
        d.name = LGet("MoveSpeed")
        d.icon = "attrIcon_sudu"
        d.value = bio2number(attr.MoveSpeed) / 100
        table.insert(list, d)
        -- 生命值
        d = {}
        d.name = LGet("HP")
        d.icon = "attrIcon_hp"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.HPMin),
            bio2number(attr.HPMax),
            bio2number(attr.HPCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if calculNextLev and (not isMaxLev) then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.HPMin),
                bio2number(attr.HPMax),
                bio2number(attr.HPCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)
        -- 攻击力
        d = {}
        d.name = LGet("Damage")
        d.icon = "attrIcon_gongjili"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.DamageMin),
            bio2number(attr.DamageMax),
            bio2number(attr.DamageCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if calculNextLev and (not isMaxLev) then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.DamageMin),
                bio2number(attr.DamageMax),
                bio2number(attr.DamageCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)
        if id ~= IDConst.RoleID.LandCraft then -- 登陆舰不需要显示下面的属性
            -- 攻击速度
            d = {}
            d.name = LGet("AttackSpeed")
            d.icon = "attrIcon_gongjisudu"
            d.value = joinStr(bio2number(attr.AttackSpeedMS) / 1000, LGet("UISecond"))
            table.insert(list, d)
            -- 攻击范围
            d = {}
            d.name = LGet("AttackRange")
            d.icon = "attrIcon_com"
            d.value = bio2number(attr.AttackRange) / 100
            table.insert(list, d)
            -- 优先攻击
            d = {}
            d.name = LGet("AttackPriority")
            d.icon = ""
            local gidName = IDConst.GIDName[bio2number(attr.PreferedTargetType)]
            local damageMod = ""
            if not isNilOrEmpty(gidName) then
                damageMod = bio2number(attr.PreferedTargetDamageMod)
                damageMod = damageMod > 0 and joinStr("(", LGet("Damage"), "x", damageMod, ")") or ""
            else
                damageMod = LGet("None")
            end
            d.value = joinStr(gidName, damageMod)
            table.insert(list, d)
            -- 攻击目标
            d = {}
            d.name = LGet("AttackTarget")
            d.icon = ""
            local str = {}
            if attr.GroundTargets then
                table.insert(str, LGet("GroundTargets"))
            end
            if attr.AirTargets then
                table.insert(str, LGet("AirTargets"))
            end
            d.value = table.concat(str, "、")
            table.insert(list, d)
        end

        --是否群伤
        if bio2number(attr.DamageAffectRang) > 0 then
            d = {}
            d.name = LGet("MulAttack")
            d.icon = ""
            d.value =
                joinStr(LGet("Yes"), "(", LGet("AttackEffectRange"), ":", bio2number(attr.DamageAffectRang) / 100, ")")
            table.insert(list, d)
        end
        -- 运兵数量
        if bio2Int(attr.SolderNum) > 0 then
            d.name = LGet("CarryTroopNum")
            d.icon = ""
            d.value = bio2Int(attr.SolderNum)
        end
    elseif attrType == IDConst.AttrType.skill then
        ---@type DBCFMagicData
        local attr = DBCfg.getDataById(DBCfg.CfgPath.Magic, id)
        local isMaxLev = false
        if bio2number(serverData.lev) >= bio2number(attr.MaxLev) then
            isMaxLev = true
        end

        -- 召唤魔法时间
        d = {}
        d.name = joinStr(LGet("SummonTime"), "(", LGet("UIMinute"), ")")
        d.icon = "attrIcon_time"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.BuildTimeMin),
            bio2number(attr.BuildTimeMax),
            bio2number(attr.BuildTimeCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if calculNextLev and (not isMaxLev) then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.BuildTimeMin),
                bio2number(attr.BuildTimeMax),
                bio2number(attr.BuildTimeCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)

        -- 召唤魔法消耗
        d = {}
        d.name = LGet("SummonCost")
        d.icon = "public_Icon_ziyuan_you"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.BuildCostOilMin),
            bio2number(attr.BuildCostOilMax),
            bio2number(attr.BuildCostOilCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if calculNextLev and (not isMaxLev) then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.BuildCostOilMin),
                bio2number(attr.BuildCostOilMax),
                bio2number(attr.BuildCostOilCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)

        if id == 1 then
            -- 攻击力
            d = {}
            d.name = LGet("Damage")
            d.icon = "attrIcon_gongjili"
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.DamageMin),
                bio2number(attr.DamageMax),
                bio2number(attr.DamageCurve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            )
            if calculNextLev and (not isMaxLev) then
                local nextVal =
                    DBCfg.getGrowingVal(
                    bio2number(attr.DamageMin),
                    bio2number(attr.DamageMax),
                    bio2number(attr.DamageCurve),
                    (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
                )
                d.addValue = nextVal - d.value
            else
                d.addValue = 0
            end
            table.insert(list, d)
            -- 攻击次数
            d = {}
            d.name = LGet("DamageTimes")
            d.icon = "attrIcon_gongjili"
            d.value = bio2number(attr.DamageTimes)
            table.insert(list, d)
        elseif id == 2 then
            -- 治疗
            d = {}
            d.name = LGet("MagicCure")
            d.icon = "attrIcon_hp"
            d.value =
                math.abs(
                DBCfg.getGrowingVal(
                    bio2number(attr.DamageMin),
                    bio2number(attr.DamageMax),
                    bio2number(attr.DamageCurve),
                    bio2number(serverData.lev) / bio2number(attr.MaxLev)
                )
            )
            if calculNextLev and (not isMaxLev) then
                local nextVal =
                    DBCfg.getGrowingVal(
                    bio2number(attr.DamageMin),
                    bio2number(attr.DamageMax),
                    bio2number(attr.DamageCurve),
                    (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
                )
                d.addValue = math.abs(nextVal) - d.value
            else
                d.addValue = 0
            end
            table.insert(list, d)
        elseif id == 3 then
        end
        if id == 2 or id == 3 then
            -- 持续时间
            d = {}
            d.name = joinStr(LGet("StayTime"), "(", LGet("UISecond"), ")")
            d.icon = "attrIcon_time"
            d.value =
                DBCfg.getGrowingVal(
                bio2number(attr.StateMsMin),
                bio2number(attr.StateMsMax),
                bio2number(attr.StateMsCurve),
                bio2number(serverData.lev) / bio2number(attr.MaxLev)
            ) / 1000
            d.value = d.value
            if calculNextLev and (not isMaxLev) then
                local nextVal =
                    DBCfg.getGrowingVal(
                    bio2number(attr.StateMsMin),
                    bio2number(attr.StateMsMax),
                    bio2number(attr.StateMsCurve),
                    (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
                )
                d.addValue = nextVal / 1000 - d.value
            else
                d.addValue = 0
            end
            table.insert(list, d)
        end

        -- 波及范围
        d = {}
        d.name = LGet("AttackEffectRange")
        d.icon = "attrIcon_com"
        d.value =
            DBCfg.getGrowingVal(
            bio2number(attr.RangeMin),
            bio2number(attr.RangeMax),
            bio2number(attr.RangeCurve),
            bio2number(serverData.lev) / bio2number(attr.MaxLev)
        )
        if calculNextLev and (not isMaxLev) then
            local nextVal =
                DBCfg.getGrowingVal(
                bio2number(attr.RangeMin),
                bio2number(attr.RangeMax),
                bio2number(attr.RangeCurve),
                (bio2number(serverData.lev) + 1) / bio2number(attr.MaxLev)
            )
            d.addValue = nextVal - d.value
        else
            d.addValue = 0
        end
        table.insert(list, d)
    end
    return list
end

return IDAttrUtl
