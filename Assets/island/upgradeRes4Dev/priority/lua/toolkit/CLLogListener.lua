-- 日志监听界面
local CLLogListener = {}

function CLLogListener.OnLogError(log)
    -- 当有异常日志时
    if CLAlert.self ~= nil then
        CLAlert.add("有异常日志，请在屏幕画圈查看详细！", Color.red, 3, 4)
    end
end

function CLLogListener.OnLogWarning(log)
    -- 当有警告日志时
end
--------------------------------------------
return CLLogListener
