---@class IDConst 常量
IDConst = {}

---public GM账号idx
IDConst.gmPidx = -10000
---public 系统账号idx
IDConst.sysPidx = -1

IDConst = {
    baseRes = number2bio(50000) -- 基础资源量
}

IDConst.PlayerState = {
    normal = 1 -- 正常
}
IDConst.CityState = {
    normal = 1, -- 正常
    protect = 2 -- 免战保护
}

IDConst.BuildingID = {
    headquartersBuildingID = 1, --主基地
    dockyardBuildingID = 2, -- 造船厂
    TechCenter = 3, -- 科技中心
    AllianceID = 4, -- 联盟港口
    MagicAltar = 5, -- 魔法坛
    foodStorageBuildingID = 7,
    oildStorageBuildingID = 9,
    goldStorageBuildingID = 11,
    MortarDefenseID = 16, --烈焰式火箭炮
    ThunderboltID = 17, --电磁塔
    DestroyerRocketID = 18, -- 地狱之门
    AirBombID = 20, -- 放空气球
    FrozenMineID = 22, -- 冰冻地雷
    IceStormID = 23, -- 风暴控制器
    trapMonsterID = 24, -- 海怪陷阱
    trapSwirlID = 25, -- 漩涡陷阱
    activityCenter = 38, -- 活动中心
    MailBox = 39 -- 邮箱
}

IDConst.BuildingState = {
    normal = 0, --正常
    upgrade = 1, --升级中
    working = 2, --工作中
    renew = 9 -- 恢复中
}

---public 建筑类别
IDConst.BuildingGID = {
    spec = -1, -- 特殊建筑
    com = 1, -- 基础建筑
    resource = 2, -- 资源建筑
    defense = 3, -- 防御建筑
    trap = 4, --陷阱
    decorate = 5, -- 装饰
    tree = 6 -- 树
}

---public 角色类别
IDConst.RoleGID = {
    worker = 100, -- 工人
    ship = 101, -- 舰船
    solider = 102, -- 陆战兵
    pet = 103 -- 宠物
}

IDConst.GIDName = {
    [-1] = "特殊建筑",
    [2] = "资源类建筑",
    [3] = "防御建筑",
    [101] = "舰船",
    [102] = "陆战兵",
    [103] = "海怪"
}

IDConst.RoleID = {
    Barbarian = 3, -- 陆战兵
    LandCraft = 4 -- 登陆船
}

---public 游戏中各种类型
IDConst.UnitType = {
    building = 1,
    role = 2,
    tech = 3,
    skill = 4
}

---public 资源各类
IDConst.ResType = {
    food = 1,
    gold = 2,
    oil = 3,
    exp = 4, -- 经验
    honor = 5, -- 功勋
    diam = 9 -- 钻石
}

---public 角色的状态
IDConst.RoleState = {
    idel = 1,
    working = 2,
    dead = 3,
    frozen = 4, -- 冰冻
    wild = 5, -- 狂暴
    walkAround = 6,
    beakBack = 7,
    searchTarget = 8,
    attack = 9,
    waitAttack = 10,
    backDockyard = 11, -- 返回造船厂
    landing = 12 -- 正在登陆
}

---public 属性类型
IDConst.AttrType = {
    building = 1, -- 建筑
    buildingNextOpen = 2, -- 建筑下级开放
    ship = 3, -- 舰船
    ship4Build = 4, -- 舰船建造时
    pet = 5, -- 海怪
    skill = 6 -- 魔法技能
}

---public 战斗类型
IDConst.BattleType = {
    attackIsland = 1, -- 攻击岛
    attackFleet = 2 -- 攻击舰队
}

---public 换装的类型
IDConst.dressMode = {
    normal = 1,
    ice = 2,
    red = 3,
}
---public 大地图地块类型
IDConst.WorldmapCellType = {
    port = 1, -- 港口
    decorate = 2, -- 装饰
    user = 3, -- 玩家
    empty = 4, -- 空地
    fleet = 5, -- 舰队停留
    occupy = 99 -- 占用
}

---public 舰队状态
IDConst.FleetState = {
    none = 1, -- 无
    moving = 2, -- 航行中
    docked = 3, -- 停泊在港口
    stay = 4, -- 停留在海面
    fightingFleet = 5, -- 正在战斗中
    fightingIsland = 6 -- 正在战斗中
}
---public 舰队任务
IDConst.FleetTask = {
    idel = 1, -- 待命状态
    voyage = 2, -- 出征
    back = 3, -- 返航
    attack = 4 -- 攻击
}
---public 舰队状态
IDConst.FleetStateName = {
    [1] = "", -- 无
    [2] = "FleetStatemoving", -- 航行中
    [3] = "FleetStateDocked", -- 停泊在港口
    [4] = "FleetStateStay", -- 停留在海面
    [5] = "FleetStateFighting", -- 正在战斗中
    [6] = "FleetStateFighting" -- 正在战斗中
}
---public 舰队任务
IDConst.FleetTaskName = {
    [1] = "FleetTaskIdel", -- 待命状态
    [2] = "FleetTaskVoyage", -- 出征
    [3] = "FleetTaskBack", -- 返航
    [4] = "FleetTaskAttack" -- 攻击
}

---public 邮件类型，1：系统，2：战报；3：私信，4:联盟，5：客服
IDConst.MailType = {
    all = 0, -- 全部（收件箱）
    system = 1, -- 1：系统
    report = 2, -- 2：战报；
    private = 3 -- 3：私信、gm
    -- union = 4, -- 4:联盟
    -- gm = 5 -- 5：客服
}
IDConst.MailTypeName = {
    [0] = "All",
    [1] = "System",
    [2] = "BattleReport",
    [3] = "Other"
}
---public 邮件状态
IDConst.MailState = {
    unread = 0, -- 未读
    readNotRewared = 1, -- 已读未领取
    readRewared = 2 -- 已读已领取
}

---public 道具类型
IDConst.ItemType = {
    attrVal = 1, -- 资源、经验值等（领奖就直接把数值加上），
    speedup = 2, -- 加速(建筑、造船、科技)，
    protect = 3, -- 护盾
    shard = 4, -- 碎片(海怪碎片)，
    mapPaper = 5, -- 图纸，
    ship = 6, -- 舰船，
    revival = 7, -- 复活药水(建筑、海怪)
    box = 99 -- 宝箱(嵌套礼包)
}
---public 聊天类型
IDConst.ChatType = {
    world = 1, -- 世界
    private = 2, -- 私信
    union = 3 -- 联盟
}
return IDConst
