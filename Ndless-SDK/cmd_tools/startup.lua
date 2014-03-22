dofile(props["SciteDefaultHome"].."\\scite-debug\\extman.lua")

props['SciteDefaultHomeMsys'] = '/' .. props['SciteDefaultHome']:gsub("\\", "/"):gsub(":", "")

local fn = package.loadlib(props['SciteDefaultHome'] .. "/spawner-ex/spawner-ex.dll", "luaopen_spawner")
if not fn then
	print("Can't load spawner-ex")
	return
end
fn()

-- ==== Custom function ====

-- Return the result of "cd <dir> && ls <mask>", or nil if no file found
function ls_file(dir, mask)
	local out = spawner.popen(props['ndls.sh'] .. " 'cd \"" .. dir .. "\" ^&^& ls " .. mask .. "'")
	for line in out:lines() do
		if string.find(line, "No such file") then
			return nil
		else
			return line
		end
	end
end

function sleep(n) -- seconds
	local t0 = os.clock()
	while os.clock() - t0 <= n do end
end

-- Works without sh
function folder_exists(strFolderName)
	local fileHandle, strError = io.open(strFolderName.."\\*.*","r")
	if fileHandle ~= nil then
		io.close(fileHandle)
		return true
	else
		if string.match(strError,"No such file or directory") then
			return false
		else
			return true
		end
	end
end

function build_lua_output_cb(chunk)
	print(chunk)
end

function build_lua_finished_cb(result_code)
	print("'" .. props['FileNameExt'] .. "' converted with Luna.")
end

function build_lua()
	local lunaspawner = spawner.new(props['SciteDefaultHome'] .. '/luna/luna ' .. props['FilePath'] .. ' ' .. props['FileDir'] .. '/' .. props['FileName'] .. '.tns')
	lunaspawner:set_output("build_lua_output")
	lunaspawner:set_result("build_lua_finished_cb")
	lunaspawner:run()
end

-- =========================

if not folder_exists(props['SciteDefaultHome'] .. '/yagarto') or not folder_exists(props['SciteDefaultHome'] .. '/mingw-get') then
	print "WARNING: MSYS and YAGARTO components are missing, some commands won't work. Get them from http://ndlessly.wordpress.com/ ."
end
