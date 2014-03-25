-- go@ dofile *
    l = editor:LineFromPosition(editor.CurrentPos)
print(l)
line = scite_Line(editor,l)
indent = line:match('(%s+)')
print(indent..'gotcha',#indent)


