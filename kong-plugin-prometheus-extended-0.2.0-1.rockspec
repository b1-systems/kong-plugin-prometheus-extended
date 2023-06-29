local plugin_name = "prometheus-extended"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.2.0"
local rockspec_revision = "1"

local github_account_name = "b1systems"
local github_repo_name = "kong-plugin-" .. plugin_name
local git_checkout = package_version == "dev" and "master" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }
source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}


description = {
  summary = "Extends Prometheus metrics for Kong.",
  homepage = "https://github.com/"..github_account_name.."/"..github_repo_name,
  license = "Apache 2.0",
}


dependencies = {
  "lua-resty-counter == 0.2.1",
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".exporter"] = "kong/plugins/"..plugin_name.."/exporter.lua",
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
  }
}
