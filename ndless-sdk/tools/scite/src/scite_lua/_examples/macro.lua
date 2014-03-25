-- macro.lua
-- simple SciTE macros
-- note the standard (tho undocumented) macro key bindings
-- Start Recording Ctrl+F9
-- End Recording Shift+Ctrl+F9
-- Play Macro F9

scite_Command("Test it|do_hicky|*.lua;*.txt;*.c|Ctrl+M")

function do_hicky()
	print 'hicky!'
end

local append = table.insert
local state,mac
-- you need to add $(status.msg) to the end of your statusbar.text.1 definition
-- to see these messages on the status bar
local function set_state(s)
	state = s
	props['status.msg'] = state
	scite.UpdateStatusBar()
end

function OnMacro(line)
	local idx = line:find('|')
	local cmd = line:sub(1,idx-1)
	local arg = line:sub(idx+1)
	if cmd == 'macro:record' then
		if state ~= 'recording' then
			set_state 'recording'
			mac = {}
		end
		local _,_,msg,wparam,isstr,str = arg:find('(%d+);(%d+);(%d+);(.*)')
		if isstr == '0' then str = '' end
		append(mac,{MSG=msg,WPARAM=wparam,STR=str})
	elseif cmd == 'macro:stoprecord' then
		set_state ''
	elseif cmd == 'macro:run' then
		for i,m in ipairs(mac) do
			if m.STR ~= '' then
				scite.SendEditor(m.MSG,m.STR)
			else
				scite.SendEditor(m.MSG,m.wparam)
			end
		end
	end
end

