# Home Assistant Add-on: NGINX Home Assistant SSL proxy

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "NGINX Home Assistant SSL proxy" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The NGINX Proxy add-on is commonly used in conjunction with the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) add-on to set up secure remote access to your Home Assistant instance. The following instructions covers this scenario.

1. The certificate to your registered domain should already be created via the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) add-on or another method. Make sure that the certificate files exist in the `/ssl` directory.
2. In the `configuration.yaml` file, some options in the `http:` section are no longer necessary for this scenario, and should be commented out or removed:
    - `ssl_certificate`
    - `ssl_key`
    - `server_port`
3. And you need to add the `trusted_proxies` section (requests from reverse proxies will be blocked if these options are not set).
```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
```
4. In the nginx addon configuration, change the `domain` option to the domain name you registered (from DuckDNS or any other domain you control).
5. Leave all other options as-is.
6. Save configuration.
7. Start the add-on.
8. Have some patience and wait a couple of minutes.
9. Check the add-on log output to see the result.

## Configuration

Add-on configuration:

```yaml
domain: home.example.com
certfile: fullchain.pem
keyfile: privkey.pem
hsts: "max-age=31536000; includeSubDomains"
customize:
  active: false
  default: "nginx_proxy_default*.conf"
  servers: "nginx_proxy/*.conf"
cloudflare: false
security:
  active: false
  mode: DetectionOnly
```

### Option: `domain` (required)

The domain name to use for the proxy.

### Option: `certfile` (required)

The certificate file to use in the `/ssl` directory. Keep filename as-is if you used default settings to create the certificate with the [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) add-on.

### Option: `keyfile` (required)

Private key file to use in the `/ssl` directory.

### Option: `hsts` (required)

Value for the [`Strict-Transport-Security`][hsts] HTTP header to send. If empty, the header is not sent.

### Option `customize.active` (required)

If true, additional NGINX configuration files for the default server and additional servers are read from files in the `/share` directory specified by the `default` and `servers` variables.

### Option `customize.default` (required)

The filename of the NGINX configuration for the default server, found in the `/share` directory.

### Option `customize.servers` (required)

The filename(s) of the NGINX configuration for the additional servers, found in the `/share` directory.

### Option `cloudflare` (optional)

If enabled, configure Nginx with a list of IP addresses directly from Cloudflare that will be used for `set_real_ip_from` directive Nginx config.
This is so the `ip_ban_enabled` feature can be used and work correctly in /config/customize.yaml.

### Option `security.active` (required)

If true, ModSecurity web application firewall will be enabled.

### Option `security.mode` (required)

Controls the behavior of ModSecurity web application firewall. Allowed values are:
- `DetectionOnly` - (default) process security rules and log detections but never executes any disruptive actions (block, deny, drop)
- `On` - process security rules; blocks potentially malicious requests

## Known issues and limitations

- By default, port 80 is disabled in the add-on configuration in case the port is needed for other components or add-ons like `emulated_hue`.

- Legitimate actions can trigger a false positive in ModSecurity, resulting in HTTP 403 error message and ModSecurity error messages in the add-on log. If ModSecurity inadvertently blocks a legitimate request, there are two main workarounds:
   1. Avoid requests being processed through ModSecurity by accessing Home Assistant using the internal connection URL (e.g. homeassistant.local:8123), then retry the blocked action.
   2. Temporarily disable ModSecurity by changing `security.mode` to `DetectionOnly`, restart the NGINX Home Assistant SSL Proxy add-on, then retry the blocked action. Afterwards, re-enable ModSecurity by changing `security.mode` to `On` and restart the add-on again.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[forum]: https://community.home-assistant.io
[hsts]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
