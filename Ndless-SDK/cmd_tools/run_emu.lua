local fn = package.loadlib(props['SciteDefaultHome'] .. "/spawner-ex/spawner-ex.dll", "luaopen_spawner")
if not fn then
	print("Can't load spawner-ex")
	return
end
fn()

-- resmask can contain any bash wildcard
-- returns the path of the resource or nil if not found
function getres(resmask, errmsg)
	local respath_prefix = props['SciteDefaultHome'] .. "/emu_resources"
	local out = spawner.popen(props['ndls.sh'] .. " 'ls \"" .. respath_prefix .. "/\"" .. resmask .. "'")
	for line in out:lines() do
		out = line
		break
	end
	if string.find(out, "No such file")	then
		if errmsg then
			print(errmsg)
			spawner.popen("explorer \"" .. props['SciteDefaultHome'] .. "\\emu_resources" .. "\"")
			print("The emulator must be set up, please refer to _ReadMe.txt.")
		end
		return nil
	else
		return out
	end
end

-- Already running?
local out = spawner.popen(props['SciteDefaultHome'] .. "\\autoit\\autoit3.exe \"" .. props['SciteDefaultHome'] .. "\\autoit\\scripts\\is_emu_running.au3\"")
for line in out:lines() do
	if line == "NO" then

		local modelswitch = "/MX"
		local txx = getres("*.tco")
		if not txx then
			txx = getres("*.tcc")
			modelswitch = "/MXC"
		end
		if not txx then
			txx = getres("*.tno")
			modelswitch = ""
		end
		if not txx then
			txx = getres("*.tnc", "OS not found.")
			modelswitch = "/MC"
		end
		if txx then
			local boot1 = getres("boot1.img.tns", "Boot1 not found.")
			if boot1 then
				local nand_path = getres("*.img")
				if nand_path then
					local ns_spawner = spawner.new(props['SciteDefaultHome'] .. "\\nspire_emu\\nspire_emu.bat /R \"/1=" .. boot1 .. "\" \"/F=" .. nand_path .. "\" " .. modelswitch .. " \"/G=" .. props['ndless.gdb.port'] .."\"")
					ns_spawner:run()
				
				else
					local boot2 = getres("boot2.img.tns", "Boot2 not found.")
					if boot2 then
						local ns_spawner = spawner.new(props['SciteDefaultHome'] .. "\\nspire_emu\\nspire_emu.bat /R \"/1=" .. boot1 .. "\" \"/PO=" .. txx .. "\" \"/PB=" .. boot2 .. "\" " .. modelswitch)
						ns_spawner:run()
					end
				 
				end
			end
		end

	else
		local out = spawner.popen(props['SciteDefaultHome'] .. "\\autoit\\autoit3.exe \"" .. props['SciteDefaultHome'] .. "\\autoit\\scripts\\activate_emu.au3\"")
	end
	break
end
