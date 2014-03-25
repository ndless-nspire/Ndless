-- other.lua
scite_Command 'Move to Other|move_to_other|Ctrl+Alt+M'

if scite_GetProp('PLAT_GTK') then
    local pipes 

    function scan_other()
        pipes = scite_Files '/tmp/SciTE.*.in'
        local our_pipe = props['ipc.scite.name']
        for i,p in ipairs(pipes) do
            if p == our_pipe then
                table.remove(pipes,i)
                break
            end
        end
        table.insert(pipes,1,our_pipe)
        return #pipes
    end

    spawner.perform =  function (cmd,target)
        if not pipes then scan_other() end
        target = target or 1
        local f = io.open(pipes[target+1],"w")
--~         print('cmd',cmd,target+1)
        f:write(cmd,'\n')
        f:close()
    end
    
end

function perform (cmd,arg,target)
    target = target or 1
    if spawner.perform then
        cmd = cmd..':'..tostring(arg):gsub('\\','\\\\')
        local res,err spawner.perform(cmd,target)
        if err then
           print('perform error: '..err)
        end	
	return res
    end
end

function menucommand (id,target)
    return perform('menucommand',id,target)
end

function open_other(file,line)
    perform('open',file,1)
    if line then
        perform('goto',line,1)
    end
end

function move_to_other ()
    local file = props['FilePath']
    local line = editor:LineFromPosition(editor.CurrentPos)
    if file ~= '' then
        scite.MenuCommand(IDM_CLOSE)    
        open_other(file,line)
    end
end



