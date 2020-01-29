---@class UnityEngine.Scripting.GarbageCollector
---@field public GCMode UnityEngine.Scripting.GarbageCollector.Mode
---@field public isIncremental System.Boolean
---@field public incrementalTimeSliceNanoseconds System.UInt64
local m = { }
---public Void add_GCModeChanged(Action`1 value)
---@param optional Action`1 value
function m.add_GCModeChanged(value) end
---public Void remove_GCModeChanged(Action`1 value)
---@param optional Action`1 value
function m.remove_GCModeChanged(value) end
---public Boolean CollectIncremental(UInt64 nanoseconds)
---@return bool
---@param optional UInt64 nanoseconds
function m.CollectIncremental(nanoseconds) end
UnityEngine.Scripting.GarbageCollector = m
return m
