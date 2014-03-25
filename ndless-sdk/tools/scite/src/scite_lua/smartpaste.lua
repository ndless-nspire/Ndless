-- a set of useful block operations for SciTE
-- Steve Donovan, 2008
-- many thanks to:
--[[---------------
LuaBit v0.3
-------------------
a bitwise operation lib for lua.

http://luaforge.net/projects/bit/

Under the MIT license.

copyright(c) 2006 hanzhao (abrash_han@hotmail.com)
--]]---------------


scite_Command("Smart Paste|smart_paste|Shift+Ctrl+V")
scite_Command("Smart Copy|smart_copy|Shift+Ctrl+C")
scite_Command("Block Select|block_select|Shift+Ctrl+A")
scite_Command("Match Block End|block_end|Ctrl+E")

function indentation_of_line (line)
    indent = editor.LineIndentation[line]
    indent = indent / editor.TabWidth
    return indent
end

function current_line ()
    return editor:LineFromPosition(editor.CurrentPos)
end

-- note that we explicitly have to compare the result to zero, since
-- a zero value is NOT considered false in Lua!
function fold_line(line)
    local lev = editor.FoldLevel[line]
    return bit.band(lev,SC_FOLDLEVELHEADERFLAG) ~= 0
end

function goto_line_start(line)
    local pos = editor:PositionFromLine(line)
    editor:GotoPos(pos)
    return pos
end

function goto_line_end(line)
    local pos = editor.LineEndPosition[line]
    editor:GotoPos(pos)
    return pos
end

-- The Smart paste operation (Shift+Ctrl+V) tries to
-- adjust the indentation of a pasted block of code to
-- match the indentation of the current line. It leaves
-- it selected so that you can recover manually from
-- less-than-smart identations ;)
-- Only really expected to work well if your source
-- is consistently indented.
function smart_paste ()
    local pos,posE,nline,ldent,lnext,m
    local new_indent = 0
    local indent = -1    
    local line = current_line()
    -- we want to insert from the start of the line
    -- deduce the current indentation from it
    ldent = line
    pos = goto_line_start(line+1)
    lnext = line+2
    indent = indentation_of_line(ldent)
    if fold_line(ldent) then
        indent = indent + 1
    end
--~ 	print(ldent+1,indent,editor:GetLine(ldent))
    -- unless we're at the end, put a marker at the next line so 
    -- we can find the extent of the paste
    if lnext < editor.LineCount then
        m = editor:MarkerAdd(lnext,1)
    end
    editor:BeginUndoAction()
    editor:Paste()
    if m then -- find out where the marker has moved to
        nline = editor:MarkerLineFromHandle(m) - 1
        posE = editor:PositionFromLine(nline)
        editor:MarkerDeleteHandle(m)
        -- look at the indentation of the inserted text
        new_indent = indentation_of_line(line+1)
--~ 		print(line,new_indent,editor:GetLine(line))
    else
        posE = editor.Length - 1
    end
    editor:SetSel(pos,posE)        
    if indent ~= -1 then
        local diff = indent - new_indent        
        if diff > 0 then
            for i = 0,diff-1 do editor:Tab() end
        elseif diff < 0 then
            diff = -diff
            for i = 0,diff-1 do editor:BackTab() end
        end
    end
    editor:EndUndoAction()
end

-- select the enclosing block of a line; selecting on a fold line selects the whole block,
-- otherwise find the fold line controlling this current line, and select from there.
-- As a special case, with C-style languages you can click on the controlling 
-- statement, which is often directly before the fold point. Likewise, the 
-- controlling statement is considered part of the block.
function block_select()
    local cpp = editor.Lexer == SCLEX_CPP
    local line = current_line()
    local parent
    if fold_line(line) then
        parent = line
    else
        parent = editor.FoldParent[line]
    end
    -- (1) in C-style languages, the control statement is often just before the 
    -- fold point. See (2)
    if parent == -1 and cpp and fold_line(line+1) then
        parent = line+1
    end
    if parent ~= -1 then
        local lastl = editor:GetLastChild(parent,-1)  --NB!
        local posE = editor:PositionFromLine(lastl+1)
        -- (2) it is common practice for the open brace in C-style languages to be
        -- on its own line. Adjust our upper line for this case.
        if  cpp and editor:GetLine(parent):find('^%s*{%s*$') then
            parent = parent - 1
        end
        local pos = editor:PositionFromLine(parent)
        editor:SetSel(pos,posE)		
        return true
    end
end

-- smart copy copies the result of a block select to the clipboard;
-- again, it leaves it selected so you know what you're getting!
function smart_copy ()
    if block_select() then
        editor:Copy()
    end
end

-- block_end() is bound to Ctrl+E and allows you to skip
-- between the start and end of a block.
-- For curly-brace languages, use the SciTE implementation
-- of this command.
-- It works fine for Lua, and probably for any language
-- with explicit block markers, but tends to get confused
-- with Python.
function block_end ()
    -- let SciTE handle the curly braces case!
    if editor.Lexer == SCLEX_CPP then
        scite.MenuCommand(IDM_MATCHBRACE)
    else
        local line = current_line()
        local lno
        if fold_line(line) then
            lno = editor:GetLastChild(line,-1)           
        else
            lno = editor.FoldParent[line]  
            if lno == -1 then
                lno = editor.FoldParent[line-1]
            end
        end
        if lno == -1 then return end        
        goto_line_start(lno)
    end
end


do

------------------------
-- bit lib implementions

local function check_int(n)
-- checking not float
    if(n - math.floor(n) > 0) then
        error("trying to use bitwise operation on non-integer!")
    end
end

local function to_bits(n)
    check_int(n)
    if(n < 0) then
    -- negative
        return to_bits(bit.bnot(math.abs(n)) + 1)
    end
    -- to bits table
    local tbl = {}
    local cnt = 1
    while (n > 0) do
        local last = math.mod(n,2)
        if(last == 1) then
            tbl[cnt] = 1
        else
            tbl[cnt] = 0
        end
        n = (n-last)/2
        cnt = cnt + 1
    end
    return tbl
end

local function tbl_to_number(tbl)
    local n = table.getn(tbl)

    local rslt = 0
    local power = 1
    for i = 1, n do
        rslt = rslt + tbl[i]*power
        power = power*2
    end

    return rslt
end

local function expand(tbl_m, tbl_n)
    local big = {}
    local small = {}
    if(table.getn(tbl_m) > table.getn(tbl_n)) then
        big = tbl_m
        small = tbl_n
    else
        big = tbl_n
        small = tbl_m
    end
    -- expand small
    for i = table.getn(small) + 1, table.getn(big) do
        small[i] = 0
    end
end

local function bit_or(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n)

    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i]== 0 and tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
 
    return tbl_to_number(tbl)
end

local function bit_and(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n) 

    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i]== 0 or tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end

    return tbl_to_number(tbl)
end

local function bit_not(n)
 
    local tbl = to_bits(n)
    local size = math.max(table.getn(tbl), 32)
    for i = 1, size do
        if(tbl[i] == 1) then 
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
    return tbl_to_number(tbl)
end

local function bit_xor(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n) 

    local tbl = {}
    local rslt = math.max(table.getn(tbl_m), table.getn(tbl_n))
    for i = 1, rslt do
        if(tbl_m[i] ~= tbl_n[i]) then
            tbl[i] = 1
        else
            tbl[i] = 0
    end
    end
 
 --table.foreach(tbl, print)

    return tbl_to_number(tbl)
end

local function bit_rshift(n, bits)
    check_int(n)

    local high_bit = 0
    if(n < 0) then
    -- negative
        n = bit_not(math.abs(n)) + 1
        high_bit = 2147483648 -- 0x80000000
    end

    for i=1, bits do
        n = n/2
        n = bit_or(math.floor(n), high_bit)
    end
    return math.floor(n)
end

-- logic rightshift assures zero filling shift
local function bit_logic_rshift(n, bits)
    check_int(n)
    if(n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
    end
    for i=1, bits do
        n = n/2
    end
    return math.floor(n)
end

local function bit_lshift(n, bits)
    check_int(n)

    if(n < 0) then
    -- negative
        n = bit_not(math.abs(n)) + 1
    end

    for i=1, bits do
        n = n*2
    end
    return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

local function bit_xor2(m, n)
     local rhs = bit_or(bit_not(m), bit_not(n))
     local lhs = bit_or(m, n)
     local rslt = bit_and(lhs, rhs)
     return rslt
end

--------------------
-- bit lib interface

bit = {
 -- bit operations
    bnot = bit_not,
    band = bit_and,
    bor  = bit_or,
    bxor = bit_xor,
    brshift = bit_rshift,
    blshift = bit_lshift,
    bxor2 = bit_xor2,
    blogic_rshift = bit_logic_rshift,

 -- utility func
    tobits = to_bits,
    tonumb = tbl_to_number,
}

end
