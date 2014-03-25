local fn = package.loadlib(props['SciteDefaultHome'] .. "/spawner-ex/spawner-ex.dll", "luaopen_spawner")
if not fn then
	print("Can't load spawner-ex")
	return
end
fn()

function navnetcmd_processchunk_cb(chunk)
	trace(chunk)
end

function navnetcmd(tns)
	local spawner = spawner.new("cmd /c \"cd " .. props['FileDir'] .. " & " .. props['SciteDefaultHome'] .. "\\cmd_tools\\navnetcmd\\navnetcmd.bat put " .. tns .. " /ndless/" .. tns .. "\"")
	spawner:set_output("navnetcmd_processchunk_cb")
	spawner:run()
end

function get_tns_name()
	return ls_file(props['FileDir'], "*.tns")
end

function wait_for_tns()
	for i = 0, 5 do
		sleep(1)
		tns = get_tns_name()
		if tns ~= nil then break end
	end
end

local tns = get_tns_name()

if props['FileExt'] == "lua" then
	build_lua()
	tns = get_tns_name()
elseif tns == nil then
	dofile(props['SciteDefaultHome'] .. "/cmd_tools/build.lua")
	wait_for_tns()
end
if tns ~= nil then
	print("Transferring '" .. tns .. "'...")
	navnetcmd(tns)
end
