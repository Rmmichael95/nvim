-- lua/config/plugins/lsp/util.lua
-- Shared helper — require this in every lang file instead of repeating boilerplate
local M = {}

local _caps -- cached so blink.cmp.get_lsp_capabilities() only runs once

---Returns capabilities merged with blink.cmp, cached after first call
function M.capabilities()
  if _caps then return _caps end
  _caps = vim.lsp.protocol.make_client_capabilities()
  _caps.textDocument.completion.completionItem.snippetSupport = true
  _caps = require("blink.cmp").get_lsp_capabilities(_caps)
  return _caps
end

---Configure and enable a server in one call.
---Capabilities are injected automatically; pass only server-specific config.
---@param name string  LSP server name (e.g. "ts_ls")
---@param config? table  Extra config merged on top of { capabilities = ... }
function M.setup(name, config)
  local merged = vim.tbl_deep_extend("force", {
    capabilities = M.capabilities(),
  }, config or {})
  vim.lsp.config(name, merged)
  vim.lsp.enable(name)
end

return M
