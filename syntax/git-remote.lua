if vim.b.current_syntax then
    return
end
vim.b.current_syntax = 'git-remote'
vim.cmd([[
syntax case ignore
syn match GitRemoteHelp /^".*/

hi def link GitRemoteHelp Comment
]])
