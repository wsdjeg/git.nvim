vim.api.nvim_create_user_command('Git', function(opt)
  require('git').run(opt.args)
end, {
  complete = function(...)
    return require('git').complete(...)
  end,
  nargs = '*',
})
