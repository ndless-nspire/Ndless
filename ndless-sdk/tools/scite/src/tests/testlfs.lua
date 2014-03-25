require 'lfs'
--require 'dbgl'
print 'hey'
for i = 1,3 do
    print(lfs.currentdir())
    print 'here'
    print 'hello'
    lfs.chdir('testdir')
end
