do
    local ipc_subscriptions = {}

    function ipc_subscribe(msg, callback)
        clipboard.addText("empty")        
        ipc_subscriptions[msg] = callback
    end

    function ipc_send(...)
        ipc_tick()
        clipboard.addText(table.concat({...},":"))
    end

    function ipc_tick()
        local m = clipboard.getText()

        if not m then return end
        local msg = m:split(":")

        local s = ipc_subscriptions[msg[1]]
        if type(s) == "function" then
            s(unpack(msg))
            clipboard.addText("empty")
        end
    end
end
