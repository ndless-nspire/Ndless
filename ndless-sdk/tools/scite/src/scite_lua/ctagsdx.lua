-- browse a tags database from SciTE!
-- Set this property:
-- ctags.path.cxx=<full path to tags file>
-- 1. Multiple tags are handled correctly; a drop-down
-- list is presented
-- 2. There is a full stack of marks available.
-- 3. If ctags.path.cxx is not defined, will try to find a tags file in the current dir.

scite_Command {
   'Find Tag|find_ctag $(CurrentWord)|Ctrl+.',
   'Go to Mark|goto_mark|Alt+.',
   'Set Mark|set_mark|Ctrl+\'',
   'Select from Mark|select_mark|Ctrl+/',
}

local gMarkStack = {}
local sizeof = table.getn
local push = table.insert
local pop = table.remove
local top = function(s) return s[sizeof(s)] end

-- this centers the cursor position
-- easy enough to make it optional!
function ctags_center_pos(line)
  if not line then
     line = editor:LineFromPosition(editor.CurrentPos)
  end
  local top = editor.FirstVisibleLine
  local middle = top + editor.LinesOnScreen/2
  editor:LineScroll(0,line - middle)
end

local function open_file(file,line,was_pos)
    scite.Open(file)
    if not was_pos then
        editor:GotoLine(line)
        ctags_center_pos(line)
    else
        editor:GotoPos(line)
        ctags_center_pos()
    end
end

function set_mark()
    push(gMarkStack,{file=props['FilePath'],pos=editor.CurrentPos})
end

function goto_mark()
    local mark = pop(gMarkStack)
    if mark then
        open_file(mark.file,mark.pos,true)
    end
end

function select_mark()
    local mark = top(gMarkStack)
    if mark then
        local p1 = mark.pos
        local p2 = editor.CurrentPos
        editor:SetSel(p1,p2)
     end
end

local find = string.find

local function extract_path(path)
-- if this is already absolute, return 
--~   if path:sub(1,1) == '/' or path:sub(2,2) == ':' then
--~     return path
--~   end
-- given a full path, find the directory part
 local s1,s2 = find(path,'/[^/]+$')
 if not s1 then -- try backslashes!
    s1,s2 = find(path,'\\[^\\]+$')
 end
 if s1 and s1 > 1 then
    return string.sub(path,1,s1-1)
 else
    return nil
 end
end

local function ReadTagFile(file)
    local f = io.open(file)
    if not f then return nil end
    local tags = {}
    -- now we can pick up the tags!
    for line in f:lines() do
    -- skip if line is comment
    if find(line,'^[^!]') then
        local _,_,tag = find(line,'^([^\t]+)\t')
        local existing_line = tags[tag]
        if not existing_line then
            tags[tag] = line..'@'
        else
            tags[tag] = existing_line..'@'..line
        end
    end
    end
    return tags
end

local gTagFile
local lastFile
local tags

local function OpenTag(tag)
  -- ask SciTE to open the file
  local file_name = tag.file
  local path = extract_path(gTagFile)
  if path then file_name = path..'/'..file_name end
  set_mark()
  scite.Open(file_name)
  lastFile = props['FilePath']
  -- depending on what kind of tag, either search for the pattern,
  -- or go to the line.
  local pattern = tag.pattern
  if type(pattern) == 'string' then
    local p1 = editor:findtext(pattern)
    if p1 then
       editor:GotoPos(p1)
       ctags_center_pos()
    end
  else
    local tag_line = pattern
    editor:GotoLine(tag_line)
    ctags_center_pos(tag_line)
  end
end

function locate_tags(dir)
    local filefound = nil
    local slash, f
    _,_,slash = string.find(dir,"([/\\])")
    while dir do
        file = dir .. slash .. "tags"
--~ 		print ( "---" .. file)
        f = io.open(file)
        if f then
            filefound = file
            break
        end
        _,_,dir = string.find(dir,"(.+)[/\\][^/\\]+$")
--~         print(dir)
    end
    return filefound
end

function find_ctag(f,partial)
  -- search for tags files first
  local result 
  result = scite_GetProp('ctags.path.cxx')
  if not result then
    if lastFile == props['FilePath'] then
        result = gTagFile
    else
        result = locate_tags(props['FileDir'])
    end
  end
  if not result then
    print("No tags found!")
    return
  end
  if result ~= gTagFile then
    print("Reloading tag from:"..result)
    gTagFile = result
    tags = ReadTagFile(gTagFile)
  end
  if partial then
    result = ''
    for tag,val in tags do
       if find(tag,f) then
         result = result..val..'@'
       end
    end
  else
    result = tags[f]
  end

  if not result then return end  -- not found
  local matches = {}
  local k = 0;
  for line in string.gfind(result,'([^@]+)@') do
    k = k + 1
    -- split this into the three tab-separated fields
    -- _extended_ ctags format ends in ;"
    local s1,s2,tag_name,file_name,tag_pattern = find(line,
          '([^\t]*)\t([^\t]*)\t(.*)')
    -- for Exuberant Ctags
    _,_,s3 = find(tag_pattern,'(.*);\"')
    if s3 then
        tag_pattern = s3
    end
    s1 = find(tag_pattern,'$*/$')
    if s1 ~= nil then
      tag_pattern = string.sub(tag_pattern,3,s1-1)
      tag_pattern = string.gsub(tag_pattern,'\\/','/')
      matches[k] = {tag=f,file=file_name,pattern=tag_pattern}
    else
      local tag_line = tonumber(tag_pattern)-1
      matches[k] = {tag=f,file=file_name,pattern=tag_line}
    end
  end

  if k == 0 then return end
  if k > 1 then -- multiple tags found
    local list = {}
    for i,t in ipairs(matches) do
      table.insert(list,i..' '..t.file..':'..t.pattern)
    end
    scite_UserListShow(list,1,function(s)
       local _,_,tok = find(s,'^(%d+)')
       local idx = tonumber(tok) -- very important!
       OpenTag(matches[idx])
     end)
  else
    OpenTag(matches[1])
  end
end


