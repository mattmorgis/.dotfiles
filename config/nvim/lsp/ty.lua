-- uv tool install ty@latest

local function ty_cmd(root_dir)
  if root_dir then
    local venvs = { '.venv', 'venv', 'env' }
    for _, venv in ipairs(venvs) do
      local candidate = vim.fs.joinpath(root_dir, venv, 'bin', 'ty')
      if vim.fn.executable(candidate) == 1 then
        return { candidate, 'server' }
      end
    end
  end
  return { 'ty', 'server' }
end

return {
  -- See :help vim.lsp.ClientConfig and :help vim.lsp.rpc.start
  cmd = function(dispatchers, config)
    local cmd = ty_cmd(config.root_dir)
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.cfg', 'setup.py', 'requirements.txt', '.git' },
}
