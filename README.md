# Kong Prometheus Extended

A Kong plugin that provides some additional metrics over the Prometheus plugin
that is bundled with Kong.

In order to use this plugin, Kong's bundled Prometheus plugin and this plugin
must be activated.

## Configuration

### Enable the plugin globally

```bash
curl -X POST http://{HOST}:8001/plugins \
    --data "name=prometheus-extended"
```

`HOST` is the domain for the host running Kong.

## Metrics introduced by this plugin

### `kong_http_requests_consumer_endpoint_total`

The number of requests received, by consumer and by endpoint.

### `kong_stream_sessions_consumer_endpoint_total`

The equivalent of `kong_http_requests_consumer_endpoint_total`, but for stream sessions.

### `kong_nginx_worker_count`

The number of nginx worker processes.

### `kong_nginx_worker_pid`

The PID of an nginx, by worker id.

### Example output

```
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route21",consumer=""} 127
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route21",consumer="eric"} 131
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route21",consumer="idle-service-user"} 157
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route22",consumer=""} 107
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route22",consumer="eric"} 152
kong_http_requests_consumer_endpoint_total{service="httpbin-service",route="route22",consumer="idle-service-user"} 174

kong_nginx_worker_count{node_id="1b74307c-47ac-4bfc-a92f-fa9251fb12e4"} 1
kong_nginx_worker_pid{node_id="1b74307c-47ac-4bfc-a92f-fa9251fb12e4",worker_id="0"} 398
```
