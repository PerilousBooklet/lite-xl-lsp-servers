-- mod-version:3

local common = require "core.common"
local config = require "core.config"
local lsp = require "plugins.lsp"

local installed_path = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "lsp_nim"

lsp.add_server(common.merge({
  name = "nimlsp",
  language = "Nim",
  file_patterns = { "%.nim$" },
  command = { installed_path .. PATHSEP .. "nimlangserver" .. (PLATFORM == "Windows" and ".exe" or "") },
  verbose = false
}, config.plugins.lsp_nim or {}))
