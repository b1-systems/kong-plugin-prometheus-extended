-- copyright: B1 Systems GmbH <info@b1-systems.de>, 2022
-- license: Apache-2.0 https://www.apache.org/licenses/LICENSE-2.0
-- author: Felix Glaser <glaser@b1-systems.de>

local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "prometheus-extended"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema
