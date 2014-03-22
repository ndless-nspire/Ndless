 scite_Command('Last Command|do_command_list|Ctrl+Alt+P')

 local prompt = '> '
 local history_len = 4
 local prompt_len = string.len(prompt)
 print 'Scite/Lua'
 trace(prompt)

 function load(file)
	if not file then file = props['FilePath'] end
	dofile(file)
 end

 function edit(file)
	scite.Open(file)
 end

 local sub = string.sub
 local commands = {}

 local function strip_prompt(line)
   if sub(line,1,prompt_len) == prompt then
        line = sub(line,prompt_len+1)
    end	
	return line
 end

-- obviously table.concat is much more efficient, but requires that the table values
-- be strings.
function join(tbl,delim,start,finish)
	local n = table.getn(tbl)
	local res = ''
	-- this is a hack to work out if a table is 'list-like' or 'map-like'
	local index1 = n > 0 and tbl[1]
	local index2 = n > 1 and tbl[2]
	if index1 and index2 then
		for i,v in ipairs(tbl) do
			res = res..delim..tostring(v)
		end
	else
		for i,v in pairs(tbl) do
			res = res..delim..tostring(i)..'='..tostring(v)
		end
	end
	return string.sub(res,2)
end

function pretty_print(...)
	for i,val in ipairs(arg) do
	if type(val) == 'table' then
		if val.__tostring then
			print(val)
		else
			print('{'..join(val,',',1,20)..'}')
		end
	elseif type(val) == 'string' then
		print("'"..val.."'")
	else
		print(val)
	end
	end
end
  
 scite_OnOutputLine (function (line)
	line = strip_prompt(line)
   table.insert(commands,1,line)
    if table.getn(commands) > history_len then
        table.remove(commands,history_len+1)
    end
    if sub(line,1,1) == '=' then
        line = 'pretty_print('..sub(line,2)..')'
    end    
    local f,err = loadstring(line,'local')
    if not f then 
      print(err)
    else
      local ok,res = pcall(f)
      if ok then
         if res then print('result= '..res) end
      else
         print(res)
      end      
    end
    trace(prompt)
    return true
end)

function insert_command(cmd)
	output:AppendText(cmd)
	output:GotoPos(output.Length)
end

function do_command_list()
     scite_UserListShow(commands,1,insert_command)
end
