# Changelog

## 6.9.1

- Rename configuration option `snapshot_exclude` to `backup_exclude`

## 6.9.0

- Bump deCONZ to 2.11.5

## 6.8.0

- Bump deCONZ to 2.10.4
- Cleanup privileged for new kernel module options

## 6.7.2

- Revert restart nginx service on error

## 6.7.1

- Restart nginx service on error

## 6.7.0

- Bump deCONZ to 2.9.3

## 6.6.5

- Update hardware configuration for Supervisor 2021.02.5

## 6.6.4

- Fix errors with new Supervisor as transit update

## 6.6.3

- Use hostname for discovery instead of IP

## 6.6.2

- Fixes issues where the `otau` directory was not excluded from snapshots

## 6.6.1

- Small cleanup with s6-overlay

## 6.6.0

- Bump deCONZ to 2.7.1

## 6.5.0

- Bump deCONZ to 2.05.88

## 6.4.1

- Enable autoscale for ingress noVNC

## 6.4.0

- Bump deCONZ to 2.05.84

## 6.3.0

- Bump deCONZ to 2.05.81

## 6.2.3

- Add background color to the ingress entry page

## 6.2.2

- Add styling to the ingress entry page

## 6.2.1

- Fix old fashon VNC access

## 6.2.0

- Enable VNC per default
- Ingress entry page to select noVNC or Phoscon

## 6.1.2

- Disable default init system

## 6.1.1

- Fix LEDVANCE / OSRAM otau firmware downloader to restart each 65 seconds
- Fix issue with VNC not starting on armhf, armv7 & aarch64 based systems

## 6.1.0

- Fix issue with armhf / move back to raspbian
- Add wiringPi to aarch64

## 6.0.1

- Fix wiringPi and built it from source

## 6.0.0

- Use debian buster for all arch types
- Migrate to new S6-Overlay
- Fix LEDVANCE / OSRAM otau firmware downloader
- Bump deCONZ to 2.05.79
- New deCONZ firmware management on startup
- Exclude OTAU folder from snapshot

## 5.3.6

- Bump deCONZ to 2.05.78

## 5.3.5

- Downgrade deCONZ to 2.05.75, since it has been reported that 2.05.77, and possibly also 2.05.76, is causing issues for several users.

## 5.3.4

- Bump deCONZ to 2.05.77

## 5.3.3

- Bump deCONZ to 2.05.76

## 5.3.2

- Bump deCONZ to 2.05.75

## 5.3.1

- Increase wait time for show device

## 5.3.0

- Bump deCONZ to 2.05.74

## 5.2.0

- Bump deCONZ to 2.05.73
- Small adjustments to NGINX configuration

## 5.1.0

- Add LEDVANCE / OSRAM otau firmware downloader, respecting max 10 DL per minute Ratelimits

## 5.0.0

- Fix additional gateway visible on Phoscon login on Ingress
- Fix Phoscon device scanning/probing triggering IP bans
- Fix redirect to login page when Phoscon session expires
- Fix incorrect manifest request from Phoscon frontend
- Fix and improve API key handling with Hass.io discovery
- Change Hass.io discovery to use add-on IP instead of hostname
- Improve Phoscon discovery to work different and faster with Ingress
- Add Websocket support to Ingress for instant and snappy UI updates
- Re-instate direct access capabilities to the Phoscon/deCONZ API

_Please note: This release works best with Home Assistant 0.103.4 or newer,
that release contains fixes/optimizations for the add-on as well._
