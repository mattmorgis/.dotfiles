local M = {}

local function diagnostics()
  local diags = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
  if #diags == 0 then
    return ''
  end

  local errors = 0
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      errors = errors + 1
    end
  end
  local warnings = #diags - errors

  if errors > 0 and warnings > 0 then
    return string.format('%%5*E: %d %%6*W: %d %%*', errors, warnings)
  end
  if errors > 0 then
    return string.format('%%5*E: %d %%*', errors)
  end
  return string.format('%%6*W: %d %%*', warnings)
end

local function filename(buf, fancy)
  local name = vim.api.nvim_buf_get_name(buf)
  name = (name == '') and 'Untitled' or name:gsub('%%', '%%%%')

  local path = vim.fn.fnamemodify(name, ':~:.')
  local parent = path:match '^(.*/)'
  local tail = vim.fn.fnamemodify(name, ':t')

  local parent_hl, tail_hl = '', ''
  if vim.bo[buf].modified then
    parent_hl, tail_hl = '%1*', '%1*'
  elseif fancy then
    parent_hl, tail_hl = '%2*', '%3*'
  end

  return string.format('%s %%<%s%s%s %%*', parent_hl, parent or '', tail_hl, tail)
end

local git_statusline = require 'git_statusline'

local function branch(buf, fancy)
  local s = git_statusline.get(buf)
  if s == '' then
    return ''
  end
  if not fancy then
    return (' [%s] '):format(s)
  end
  return ('%%#StatusLineGit# [%s] %%*'):format(s)
end

local function lsp_names(buf)
  local clients = vim.lsp.get_clients { bufnr = buf }
  if #clients == 0 then
    return ''
  end
  local names = {}
  for _, c in ipairs(clients) do
    names[#names + 1] = c.name
  end
  table.sort(names)
  return table.concat(names, ',')
end

local function file_info(buf)
  if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
    return ''
  end
  local parts = {}
  local ff = vim.bo[buf].fileformat
  if ff ~= 'unix' then
    parts[#parts + 1] = (ff == 'dos') and 'CRLF' or 'CR'
  end
  local fenc = vim.bo[buf].fileencoding
  if fenc ~= 'utf-8' and fenc ~= '' then
    parts[#parts + 1] = fenc
  end
  return (#parts > 0) and (' %s '):format(table.concat(parts, ' ')) or ''
end

local function filetype_info(buf)
  local ft = vim.bo[buf].filetype
  if ft == '' then
    return ''
  end
  local clients = lsp_names(buf)
  return (clients ~= '') and string.format(' %s/%s ', ft, clients) or string.format(' %s ', ft)
end

local function formatter_info(buf)
  local ok, conform = pcall(require, 'conform')
  if not ok then
    return ''
  end

  local formatters, lsp = conform.list_formatters_to_run(buf)
  local names = {}
  for _, f in ipairs(formatters) do
    if f.available then
      names[#names + 1] = f.name
    end
  end
  if lsp then
    names[#names + 1] = 'lsp'
  end
  if #names == 0 then
    return ''
  end
  return string.format(' fmt:%s ', table.concat(names, ','))
end

local function mode_info(is_active, is_terminal)
  if not is_active or is_terminal then
    return ''
  end

  local mode = vim.api.nvim_get_mode().mode
  local map = {
    n = 'N',
    i = 'I',
    v = 'V',
    V = 'V',
    R = 'R',
    c = 'C',
    t = 'T',
    s = 'S',
    S = 'S',
  }
  local label = map[mode]
  if not label then
    local first = mode:sub(1, 1)
    if first ~= '' then
      label = (string.byte(first) == 22) and 'V' or first:upper()
    end
  end
  if not label then
    return ''
  end

  return string.format('%%7* %s %%*', label)
end

local function add_part(dst, value)
  if value ~= '' then
    dst[#dst + 1] = value
  end
end

local function build_statusline(is_active)
  local win = vim.fn.win_getid()
  local buf = vim.api.nvim_win_get_buf(win)
  local is_terminal = vim.bo[buf].buftype == 'terminal'
  local fancy = is_active and not is_terminal
  local filename_fancy = fancy

  local left = {}
  add_part(left, (vim.v.this_session == '' and '' or ' $'))
  add_part(left, mode_info(is_active, is_terminal))
  add_part(left, filename(buf, filename_fancy))
  add_part(left, branch(buf, fancy))
  add_part(left, (vim.bo[buf].readonly and '%r ' or ''))
  add_part(left, (vim.wo[win].previewwindow and '%w ' or ''))

  local right = {}
  add_part(right, diagnostics())
  add_part(right, (fancy and '%4*' or ''))
  add_part(right, file_info(buf))
  add_part(right, (fancy and '%8*' or ''))
  add_part(right, filetype_info(buf))
  add_part(right, formatter_info(buf))
  add_part(right, '%*')
  add_part(right, ' %l:%c %P ')

  return table.concat(left) .. '%=' .. table.concat(right)
end

function M.tabline()
  local tabpagenr = vim.fn.tabpagenr
  local items = {}
  for i = 1, vim.fn.tabpagenr '$' do
    local hi = (i == tabpagenr()) and 'TabLineSel' or 'TabLine'
    local cwd = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.getcwd(-1, i), ':~'))
    items[#items + 1] = string.format('%%#%s#%%%dT %d %s ', hi, i, i, cwd)
  end
  items[#items + 1] = '%#TabLineFill#%T'
  return table.concat(items)
end

function M.statusline()
  return build_statusline(true)
end

function M.statusline_active()
  return build_statusline(true)
end

function M.statusline_inactive()
  return build_statusline(false)
end

function M.setup()
  _G.dotfiles_statusline = M.statusline
  _G.dotfiles_statusline_active = M.statusline_active
  _G.dotfiles_statusline_inactive = M.statusline_inactive
  _G.dotfiles_tabline = M.tabline

  vim.o.statusline = '%!v:lua.dotfiles_statusline()'
  vim.o.tabline = '%!v:lua.dotfiles_tabline()'

  local function set_statusline_for_all_wins()
    local current = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win == current then
        vim.wo[win].statusline = '%!v:lua.dotfiles_statusline_active()'
      else
        vim.wo[win].statusline = '%!v:lua.dotfiles_statusline_inactive()'
      end
    end
  end

  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    callback = set_statusline_for_all_wins,
  })

  vim.api.nvim_create_autocmd('WinLeave', {
    callback = set_statusline_for_all_wins,
  })
end

return M
