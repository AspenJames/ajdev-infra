resource "fastly_service_vcl" "ajdev" {
  name = "ajdev"

  domain {
    name    = "aspenjames.dev"
    comment = "apex"
  }

  domain {
    name    = "www.aspenjames.dev"
    comment = "www"
  }

  backend {
    address = module.ajdev-node.public_ip
    name    = "AJdev backend"
    port    = 80
  }

  gzip {
    name = "compress"
    content_types = [
      "text/html",
      "text/css",
      "application/javascript",
      "application/wasm"
    ]
    extensions = ["html", "css", "js", "wasm"]
  }

  logging_newrelic {
    name   = "AJDev logs"
    token  = var.newrelic_license_key
    region = "EU"
    format = jsonencode({
      "timestamp"                     = "%%{time.start.msec}V",
      "logtype"                       = "accesslogs",
      "cache_status"                  = "%%{regsub(fastly_info.state, \"^(HIT-(SYNTH)|(HITPASS|HIT|MISS|PASS|ERROR|PIPE)).*\", \"\\2\\3\") }V",
      "client_ip"                     = "%h",
      "client_device_type"            = "%%{client.platform.hwtype}V",
      "client_os_name"                = "%%{client.os.name}V",
      "client_os_version"             = "%%{client.os.version}V",
      "client_browser_name"           = "%%{client.browser.name}V",
      "client_browser_version"        = "%%{client.browser.version}V",
      "client_as_name"                = "%%{client.as.name}V",
      "client_as_number"              = "%%{client.as.number}V",
      "client_connection_speed"       = "%%{client.geo.conn_speed}V",
      "client_port"                   = "%%{client.port}V",
      "client_rate_bps"               = "%%{client.socket.tcpi_delivery_rate}V",
      "client_recv_bytes"             = "%%{client.socket.tcpi_bytes_received}V",
      "client_requests_count"         = "%%{client.requests}V",
      "client_resp_body_size_write"   = "%%{resp.body_bytes_written}V",
      "client_resp_header_size_write" = "%%{resp.header_bytes_written}V",
      "client_resp_ttfb"              = "%%{time.to_first_byte}V",
      "client_rtt_us"                 = "%%{client.socket.tcpi_rtt}V",
      "content_type"                  = "%%{Content-Type}o",
      "domain"                        = "%%{Fastly-Orig-Host}i",
      "fastly_datacenter"             = "%%{server.datacenter}V",
      "fastly_host"                   = "%%{server.hostname}V",
      "fastly_region"                 = "%%{server.region}V",
      "host"                          = "%v",
      "origin_host"                   = "%v",
      "origin_name"                   = "%%{req.backend.name}V",
      "request"                       = "%%{req.request}V",
      "request_method"                = "%m",
      "request_accept_charset"        = "%%{json.escape(req.http.Accept-Charset)}V",
      "request_accept_language"       = "%%{json.escape(req.http.Accept-Language)}V",
      "request_referer"               = "%%{json.escape(req.http.Referer)}V",
      "request_user_agent"            = "%%{json.escape(req.http.User-Agent)}V",
      "resp_status"                   = "%s",
      "response"                      = "%%{resp.response}V",
      "service_id"                    = "%%{req.service_id}V",
      "service_version"               = "%%{req.vcl.version}V",
      "status"                        = "%s",
      "time_start"                    = "%%{begin:%Y-%m-%dT%H:%M:%SZ}t",
      "time_end"                      = "%%{end:%Y-%m-%dT%H:%M:%SZ}t",
      "time_elapsed"                  = "%D",
      "tls_cipher"                    = "%%{json.escape(tls.client.cipher)}V",
      "tls_version"                   = "%%{json.escape(tls.client.protocol)}V",
      "url"                           = "%%{json.escape(req.url)}V",
      "user_agent"                    = "%%{json.escape(req.http.User-Agent)}V",
      "user_city"                     = "%%{client.geo.city.utf8}V",
      "user_country_code"             = "%%{client.geo.country_code}V",
      "user_continent_code"           = "%%{client.geo.continent_code}V",
      "user_region"                   = "%%{client.geo.region}V"
    })
  }

  force_destroy = true
}

resource "fastly_tls_subscription" "ajdev" {
  domains               = [for domain in fastly_service_vcl.ajdev.domain : domain.name]
  certificate_authority = "lets-encrypt"
}
