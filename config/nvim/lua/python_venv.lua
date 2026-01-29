local M = {}

M.root_markers = { 'pyproject.toml', 'setup.cfg', 'setup.py', 'requirements.txt', '.git' }

function M.root_dir(fname)
  if fname == nil or fname == '' then
    return nil
  end
  return vim.fs.root(fname, M.root_markers)
end

function M.resolve(root_dir, bin)
  if root_dir then
    local venvs = { '.venv', 'venv', 'env' }
    for _, venv in ipairs(venvs) do
      local candidate = vim.fs.joinpath(root_dir, venv, 'bin', bin)
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end
  return bin
end

function M.resolve_cmd(root_dir, bin, args)
  local cmd = { M.resolve(root_dir, bin) }
  if args then
    for _, arg in ipairs(args) do
      table.insert(cmd, arg)
    end
  end
  return cmd
end

return M
