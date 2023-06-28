-- copyright: B1 Systems GmbH <info@b1-systems.de>, 2022-2023
-- license: Apache-2.0 https://www.apache.org/licenses/LICENSE-2.0
-- author: Felix Glaser <glaser@b1-systems.de>

local PLUGIN_NAME = "prometheus-extended"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

end)
