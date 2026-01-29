local venv = require 'python_venv'

return {
  -- See :help vim.lsp.ClientConfig and :help vim.lsp.rpc.start
  cmd = function(dispatchers, config)
    local cmd = venv.resolve_cmd(config.root_dir, 'ty', { 'server' })
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { 'python' },
  root_markers = venv.root_markers,
}
