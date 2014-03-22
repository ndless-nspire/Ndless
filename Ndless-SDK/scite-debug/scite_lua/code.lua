scite_Command 'Surrond with code|do_code|Ctrl+J'
scite_Command 'Exec Lua|*dofile $(FileNameExt)|Shift+Ctrl+E'

function do_code()
    local txt = editor:GetSelText()
    if txt then
        editor:ReplaceSel('<code>'..txt..'</code>')
    end
end







