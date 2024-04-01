-- mod-version:3 -- lite-xl 2.1

local lspconfig = require "plugins.lsp.config"
local common = require "core.common"
local config = require "core.config"

local installed_path = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "lsp_html" .. PATHSEP .. ""

lspconfig.html.setup(common.merge({
  command = { installed_path .. PATHSEP .. ""}
}, config.plugins.lsp_html or {}))
