-- mod-version:3
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local lsp = require "plugins.lsp"

local installed_path_plugin = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "lsp_java"
local jdk_info = require "libraries.jdk"

local platform
if PLATFORM == "Windows" then
  platform = "win"
elseif PLATFORM == "Mac OS X" then
  platform = "mac"
else
  platform = "linux"
end

-- NOTE: You can find the jdtls_data_path in /config_linux/config.ini, search for `:org.eclipse.equinox.launcher`, it's right next to it
local jdtls_data_path = ".jdtls"
local jdtls_version_name  = "1.7.0.v20250519-0528"
local jdtls_command = { 
  jdk_info.path_bin,
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.level=ALL",
  "-Xmx1G",
  "--add-modules=ALL-SYSTEM",
  "--add-opens", "java.base/java.util=ALL-UNNAMED",
  "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  "-jar", string.format("%s" .. PATHSEP .. "plugins" .. PATHSEP .. "org.eclipse.equinox.launcher_%s.jar", installed_path_plugin, jdtls_version_name),
  "-configuration", string.format("%s" .. PATHSEP .. "config_%s", installed_path_plugin, platform),
  "-data", string.format("%s", jdtls_data_path)
}

lsp.add_server(common.merge({
  name = "jdtls",
  language = "java",
  file_patterns = { "%.java$" },
  command = jdtls_command,
  env = { ["JAVA_HOME"] = jdk_info.path_lib },
  verbose = false,
  init_options = {
    extendedClientCapabilities = {
      classFileContentsSupport = true
    }
  }
}, config.plugins.lsp_java or {}))

-- BRAINSTORM: ide_java should take care of deobf/decomp all sources when Lite XL starts
--             also when Lite XL starts, auto-start jdtls immediately, since it's so slow at starting

-- NOTE: dove trovare le sources
-- NOTE: /home/raffaele/.gradle/caches/forge_gradle/minecraft_user_repo/net/minecraftforge/forge/1.20.1-47.4.8_mapped_official_1.20.1/
-- NOTE: /home/raffaele/.gradle/caches/modules-2/files-2.1/net.minecraftforge/eventbus/6.0.5/699143dd438431d06b57416944f7cedbe52e1475/
-- NOTE: /home/raffaele/archive/minecraft/source/1.20.1/ (per deobfuscare e decompilare i sorgenti)

-- TODO: Deobfuscate
local function deobfuscate(class_file_path, destination)
  local folder = ""
  -- TODO: check if .lsp_java/sources exist, if not create them
  -- TODO: check if .lsp_java/deobfuscated exists, if not create it
  -- TODO: call deobfuscation
	decompile(folder, destination)
end

-- TODO: Decompile
local function decompile(folder, destination)
	-- TODO: check if .lsp_java/decompiled exists, if not create it
	-- TODO: call decompilation
end

-- WIP: Override the core file opening function to check wether or not the file being opened contains the jdt 
--      pattern and if it does, convert the path and open it
-- NOTE: Example of an existing implementation for the neovim lsp plugin:
--       https://github.com/mfussenegger/dotfiles/commit/3cddf73cd43120da2655e2df6d79bdfd06697f0e
local old_open_doc = core.open_doc
function core.open_doc(filename, ...)
  local file_exists = system.get_file_info(filename) ~= nil
  local doc = old_open_doc(filename, ...)
  -- FIX: why does this fail silently?
  -- if doc.filename == filename and not file_exists then
    if string.find(filename, "jdt%:%/") then
      -- print(filename)
      local class_file_path = string.gsub(
        string.match(filename, '%"jdt%:.+%.class'), '%"jdt%:%/%w+%/.+%.jar+%/', "")
      -- print(class_file_path)
      local jar_file_path = string.gsub(string.match(filename, '\\.+%.jar'), "\\", "")
      -- print(jar_file_path)
      local destination = system.absolute_path(".") .. PATHSEP .. ".lsp_java" .. PATHSEP .. "sources"
      -- print(destination)
      -- TODO: remove dependency on specific maven path
      local final_jar_path = string.gsub(string.gsub(jar_file_path, ".jar", ""), "%/.+%/.+%/.+%/.+%/.+%/.+%/", "")
      -- print(final_jar_path)
      local final_java_source_file_path = string.gsub(class_file_path, ".class", ".java")
      -- print(final_java_source_file_path)
      doc.filename = destination .. PATHSEP .. final_jar_path .. PATHSEP .. final_java_source_file_path
      print(doc.filename)
      return old_open_doc(filename, ...)
    end
  -- end
  return old_open_doc(filename, ...)
end
