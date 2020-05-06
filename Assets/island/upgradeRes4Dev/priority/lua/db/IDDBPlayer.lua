require("public.class")

---@class IDDBPlayer 玩家数据
IDDBPlayer = class("IDDBPlayer")
---@type IDDBPlayer
IDDBPlayer.myself = nil

---public 玩家的简要信息
IDDBPlayer.simplePlayers = {}

---@param d NetProtoIsland.ST_player
function IDDBPlayer:ctor(d)
    self._data = d
    self.idx = d.idx --  唯一标识 int
    self.diam = d.diam -- 钻石  int
    self.exp = d.exp
    self.honor = d.honor
    self.icon = d.icon
    self.name = d.name --  string
    self.status = d.status --  状态 1：正常 int int
    self.cityidx = d.cityidx --  城池id int int
    self.unionidx = d.unionidx --  联盟id int int
    self.lev = d.lev --  int
    self.attacking = d.attacking
    self.beingattacked = d.beingattacked
    -- 记录缓存
    IDDBPlayer.simplePlayers[bio2number(d.idx)] = d
end
---@param player IDDBPlayer
---@return boolean
function IDDBPlayer:equal(player)
    if not player then
        return false
    end
    return bio2number(self.idx) == bio2number(player.idx)
end

function IDDBPlayer:toMap()
    return self._data
end

---public 取得玩家的简要内容
function IDDBPlayer.getPlayerSimple(pidx, callback, orgsParas)
    ---@type NetProtoIsland.ST_playerSimple
    local player = IDDBPlayer.simplePlayers[pidx]
    if player == nil then
        if pidx == IDConst.sysPidx then
            -- 系统，其实是不存系统账号的，需要自己包装数据
            player = {}
            player.idx = number2bio(pidx)
            player.icon = number2bio(1) -- TODO:目前随便设置了一个
            player.name = LGet("System")
            IDDBPlayer.simplePlayers[pidx] = player
            Utl.doCallback(callback, player, orgsParas)
        else
            CLLNet.send(
                NetProtoIsland.send.getPlayerSimple(
                    pidx,
                    ---@param data NetProtoIsland.RC_getPlayerSimple
                    function(pidx, data)
                        IDDBPlayer.simplePlayers[pidx] = data.playerSimple
                        Utl.doCallback(callback, data.playerSimple, orgsParas)
                    end,
                    pidx
                )
            )
        end
    else
        Utl.doCallback(callback, player, orgsParas)
    end
end

function IDDBPlayer.clean()
    IDDBPlayer.simplePlayers = {}
end

--------------------------------------------
return IDDBPlayer
