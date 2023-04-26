-- copyright: B1 Systems GmbH <info@b1-systems.de>, 2022
-- license: Apache-2.0 https://www.apache.org/licenses/LICENSE-2.0
-- author: Felix Glaser <glaser@b1-systems.de>

local helpers = require "spec.helpers"
local cjson = require "cjson"
local intercept = helpers.intercept


local PLUGIN_NAME = "prometheus-extended"


for _, strategy in helpers.all_strategies() do if strategy ~= "cassandra" then
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local aclient, pclient

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      bp.plugins:insert {
        name = "prometheus",
        config = {
          per_consumer = true
        },
      }
      bp.plugins:insert {
        name = PLUGIN_NAME,
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
        -- write & load declarative config, only if 'strategy=off'
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      aclient = helpers.admin_client()
      pclient = helpers.proxy_client()
    end)

    after_each(function()
      if aclient then aclient:close() end
      if pclient then pclient:close() end
    end)

    describe("check precondition", function()
      it("metrics endpoint is accessible", function()
        local r = assert(aclient:send {
          method = "GET",
          path = "/metrics",
        })
        assert.res_status(200, r)
      end)

      it("plugin is loaded and enabled", function()
        local r = aclient:send {
          method = "GET",
          path = "/plugins",
        }

        local plugin_json = r:read_body()
        local plugins = cjson.decode(plugin_json)
        local plugins_found = {}
        for i, plugin in ipairs(plugins.data) do
          plugins_found[plugin.name] = plugin.enabled
        end
        assert(plugins_found["prometheus-extended"])
      end)
    end)

    describe("check metrics endpoint has", function()
      local UUID_PATTERN = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
      local metrics = {
        kong_http_requests_consumer_endpoint_total = '{service="127.0.0.1",route="' .. UUID_PATTERN .. '",consumer=""} [0-9]+',
        kong_nginx_worker_count = '{node_id="' .. UUID_PATTERN .. '"} [0-9]+',
        kong_nginx_worker_pid = '{node_id="' .. UUID_PATTERN .. '",worker_id="0"} [0-9]+',
      }
      for metric,pattern in pairs(metrics) do
        it(metric, function()
          local pr1 = assert(pclient:send {
            method = "GET",
            path = "/request",
            headers = {
              host = "test1.com",
            },
          })
          assert.res_status(200, pr1)

          helpers.wait_until(function()
            local res = assert(aclient:send {
              method = "GET",
              path = "/metrics",
            })
            local body = assert.res_status(200, res)

            return body:find(metric .. pattern, nil, false)
          end)
        end)
      end
    end)

  end)

end end
