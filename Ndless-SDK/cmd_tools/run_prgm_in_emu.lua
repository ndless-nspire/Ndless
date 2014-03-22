local fn = package.loadlib(props['SciteDefaultHome'] .. "/spawner-ex/spawner-ex.dll", "luaopen_spawner")
if not fn then
	print("Can't load spawner-ex")
	return
end
fn()

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
	-- Launch the emu if not running
	local out = spawner.popen(props['SciteDefaultHome'] .. "\\autoit\\autoit3.exe \"" .. props['SciteDefaultHome'] .. "\\autoit\\scripts\\is_emu_running.au3\"")
	for line in out:lines() do
		if line == "NO" then
			dofile(props['SciteDefaultHome'] .. "/cmd_tools/run_emu.lua")
			sleep(14)
		end
		break
	end
	-- Run the program
	local au_spawner = spawner.new(props['SciteDefaultHome'] .. "\\autoit\\autoit3.exe \"" .. props['SciteDefaultHome'] .. "\\autoit\\scripts\\tx_run_prgm_in_emu.au3\" \"" .. props['FileDir'] .. "\\" .. tns .. "\"")
	au_spawner:run()
end
