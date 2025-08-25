do
    local ipc_messages = {"install_start", "install_start3", "install_start4", "install_done", "install_failed", "install_kaput"}
    local ipc_counter  = 0
    local ipc_name     = "ipc" .. math.floor(math.random() * 10000)

    function ipc_load()        
        for i,msg in ipairs(ipc_messages) do
            ipc_messages[msg] = i
            print("Registering IPC msg:", ipc_name, msg)
            var.monitor(msg)
        end
    end

    function ipc_send(msg)
        local m = nil
        local t = type(msg)

        if t == "string" and ipc_messages[msg] then
            m = msg
        elseif t == "number" then
            m = ipc_messages[msg]
        end


        if m then
            print("store", m, ipc_name .. ipc_counter)
            var.store(m, ipc_name .. ipc_counter)
        end
    end

    function on.varChange(t)
        print("varchange", ipc_name, table.concat(t, ","))
        for k,msg in pairs(t) do 
            print(k,msg)
            if type(on.ipcMsg) == "function" then
                on.ipcMsg(msg, ipc_counter)
            end
        end
        ipc_counter = ipc_counter + 1
        return -2
    end
end
