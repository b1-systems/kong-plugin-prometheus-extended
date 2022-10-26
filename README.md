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

```
kong_http_requests_consumer_endpoint_total
kong_stream_sessions_consumer_endpoint_total
kong_nginx_worker_count
kong_nginx_worker_pid
```
