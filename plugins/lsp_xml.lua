-- mod-version:3

local common = require "core.common"
local config = require "core.config"
local lsp = require "plugins.lsp"

local installed_path_plugin = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "lsp_xml"
local jdk_info = require "libraries.jdk"

local lemminx_command = { jdk_info.path_bin, "-jar", "org.eclipse.lemminx-uber.jar" }

lsp.add_server(common.merge({
  name = "lemminx",
  language = "xml",
  file_patterns = { "%.xml$" },
  command = lemminx_command,
  env = { ["JAVA_HOME"] = jdk_info.path_lib },
  verbose = false
}, config.plugins.lsp_xml or {}))
