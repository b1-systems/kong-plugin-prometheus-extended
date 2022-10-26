-- copyright: B1 Systems GmbH <info@b1-systems.de>, 2022
-- license: Apache-2.0 https://www.apache.org/licenses/LICENSE-2.0
-- author: Felix Glaser <glaser@b1-systems.de>

local exporter = require("kong.plugins.prometheus-extended.exporter")
local kong = kong

exporter.init()


local plugin = {
  PRIORITY = 14, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

function plugin:init_worker()
  exporter.init_worker()

  local delay = 3
  local new_timer = ngx.timer.at
  local run_metric_data

  run_metric_data = function(premature)
    if not premature then
      exporter.metric_data(function(data) end)
      local ok, err = new_timer(delay, run_metric_data)
      if not ok then
        kong.log.err("Failed to create timer: ", err)
        return
      end
    end
  end

  local ok, err = new_timer(delay, run_metric_data)
  if not ok then
    kong.log.err("Failed to create timer: ", err)
    return
  end
end

function plugin:log(plugin_conf)
  local message = kong.log.serialize()

  local serialized = {}
  if message.consumer ~= nil then
    serialized.consumer = message.consumer.username
  end

  exporter.log(message, serialized)
end


-- return our plugin object
return plugin
