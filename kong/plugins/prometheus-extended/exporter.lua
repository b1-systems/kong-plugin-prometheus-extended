-- copyright: B1 Systems GmbH <info@b1-systems.de>, 2022-2023
-- license: Apache-2.0 https://www.apache.org/licenses/LICENSE-2.0
-- author: Felix Glaser <glaser@b1-systems.de>

local kong = kong
local ngx = ngx

local metrics = {}
local prometheus = require "kong.plugins.prometheus.prometheus"
local node_id = kong.node.get_id()

-- use the same counter library shipped with Kong
package.loaded['prometheus_resty_counter'] = require("resty.counter")

local kong_subsystem = ngx.config.subsystem
local http_subsystem = kong_subsystem == "http"

local function init()
  local shm = "prometheus_metrics"
  if not ngx.shared.prometheus_metrics then
    kong.log.err("prometheus: ngx shared dict 'prometheus_extended_metrics' not found")
    return
  end

  prometheus = require("kong.plugins.prometheus.prometheus").init(shm, "kong_")

  if http_subsystem then
    metrics.consumer_endpoints = prometheus:counter("http_requests_consumer_endpoint_total",
                                                    "Total requests per consumer/endpoint",
                                                    {"service", "route", "consumer"})
  else
    metrics.consumer_endpoints = prometheus:counter("stream_sessions_consumer_endpoint_total",
                                                    "Total requests per consumer/endpoint",
                                                    {"service", "route", "consumer"})
  end

  metrics.nginx_worker_count = prometheus:gauge("nginx_worker_count",
                                                "Total number of nginx worker processes configured",
                                                {"node_id"})

  metrics.nginx_worker_pid = prometheus:gauge("nginx_worker_pid",
                                              "PIDs of nginx workers",
                                              {"node_id", "worker_id"})
end

local function init_worker()
  prometheus:init_worker()
end

local labels_table_endpoint = { 0, 0, 0 }

local function log(message, serialized)
  if not metrics then
    kong.log.err("prometheus-extended: can not log metrics because of an initialization "
            .. "error, please make sure that you've declared "
            .. "'prometheus_metrics' shared dict in your nginx template")
    return
  end

  local service_name
  if message and message.service then
    service_name = message.service.name or message.service.host

    local route_name
    if message and message.route then
      route_name = message.route.name or message.route.id
    end

    local consumer = ""
    if http_subsystem then
      if message and serialized.consumer ~= nil then
        consumer = serialized.consumer
      end
    else
      consumer = nil
    end

    if service_name then
      labels_table_endpoint[1] = service_name
      labels_table_endpoint[2] = route_name
      labels_table_endpoint[3] = consumer

      metrics.consumer_endpoints:inc(1, labels_table_endpoint)
    end
  end
end

local function metric_data(write_fn)
  if not prometheus or not metrics then
    kong.log.err("prometheus-extended: plugin is not initialized, please make sure ",
                 " 'prometheus_extended_metrics' shared dict is present in nginx template")
    return kong.response.exit(500, { message = "An unexpected error occured" })
  end

  metrics.nginx_worker_count:set(ngx.worker.count(), {node_id})

  local worker_id = ngx.worker.id()
  local current_worker_pid = ngx.worker.pid()
  metrics.nginx_worker_pid:set(current_worker_pid, {node_id, worker_id})

  prometheus:metric_data(write_fn)
end

local function collect()
  ngx.header["Content-Type"] = "text/plain; charset=UTF-8"

  metric_data()

  if  stream_available and #kong.configuration.stream_listeners > 0 then
    local res, err = stream_api.request("prometheus", "")
    if err then
      kong.log.err("failed to collect stream metrics: ", error)
    else
      ngx.print(res)
    end
  end
end

return {
  init = init,
  init_worker = init_worker,
  log = log,
  metric_data = metric_data,
  collect = collect
}
