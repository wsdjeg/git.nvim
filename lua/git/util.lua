local M = {}
function M.fill(str, length, ...)
    local v = ''
    local rightmost
    if string.len(str) <= length then
        v = str
    else
        rightmost= 0
        while string.len(string.sub(str, 0, rightmost)) < length do
            rightmost = rightmost + 1
        end

    end
    v = string.sub(str, 0, rightmost)
    local char = select(1, ...) or ' '
    return v .. string.rep(char, length - string.len(v))
end
function M.is_float(winid)
    if winid > 0 then
        local ok, c = pcall(vim.api.nvim_win_get_config, winid)
        if ok and c.col ~= nil then
            return true
        else
            return false
        end
    else
        return false
    end
end
function M.is_last_win()
  local win_list = vim.api.nvim_tabpage_list_wins(0)
  local num = #win_list
  for _, v in ipairs(win_list) do
    if M.is_float(v) then
      num = num - 1
    end
  end
  return num == 1
  
end
function M.string2chars(str)
    local t = {}
    for k in string.gmatch(str, '.') do table.insert(t, k) end
    return t
end
function M.parser(cmdline)
  local argvs = {}
  local argv = ''
  local escape = false
  local isquote = false

  for _, c in ipairs(M.string2chars(cmdline)) do
    if not escape and not isquote and c == ' '  then
      if #argv > 0 then
        table.insert(argvs, argv)
        argv = ''
      end
    elseif not escape and isquote and c == '"' then
      isquote = false
      table.insert(argvs, argv)
      argv = ''
    elseif not escape and not isquote and c == '"' then
      isquote = true
    elseif not escape and c == '\\' then
      escape = true
    elseif escape and c == '"' then
      argv = argv .. '"'
      escape = false
    elseif escape then
      argv = argv .. '\\' .. c
      escape = false
    else
      argv = argv .. c
    end
  end

  -- is last char is \
  if escape then
    argv = argv .. '\\'
  end

  if argv ~= '' then
    table.insert(argvs, argv)
  end

  return argvs
end


return M
