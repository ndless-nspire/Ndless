-- scrunch.lua simplifies G++ error messages

function processLine(line)
  if line:find('`') and not line:find("'") then
     old_line = gsub(line,'%s+$','')
  else
     if old_line then
        line = line:gsub('^%s+','')      
        line = old_line..line
        old_line = nil
     end
     line = line:gsub('%,%s*std::allocator%b<>','')
     line = line:gsub('class ','')
     line = line:gsub('struct ','')
     line = line:gsub('std::','')
     trace(line)
  end
end

-- this is called with each chunk of output as it becomes available; it may have
-- multiple lines on Windows.
function _gcc_processChunk(s)
	local i1 = 1
	local i2 = s:find('\n',i1)
	while i2 do
		local line = s:sub(i1,i2)
		processLine(line)
		i1 = i2 + 1
		i2 = s:find('\n',i1)		
	end
	if i1 <= #s then
		local line = s:sub(i1)
		processLine(line)
	end
end

-- a good place to put any post-build actions
function _gcc_processResult(res)
    print('result was '..res)
end

function buildx(cmdline)
    print('build: '..cmdline)
    spawner_obj = spawner.new(cmdline)
    -- good practice to mangle these function names since they are global!
    spawner_obj:set_output('_gcc_processChunk')
    spawner_obj:set_result('_gcc_processResult')
    spawner_obj:run()
end

