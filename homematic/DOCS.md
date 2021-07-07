# Home Assistant Add-on: HomeMatic

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "HomeMatic CCU" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Properly configure the add-on config (see below).
2. Start the add-on.
3. Check the add-on log output to see if it started successfully.
4. Add homematic to your Home Assistant configuration (also see below).
5. Restart Home Assistant.

## Configuration

Add-on configuration:

```yaml
rf_enable: true
rf:
  - type: CCU2
    device: "/dev/ttyAMA0"
wired_enable: false
wired:
  - serial: xy
    key: abc
    ip: 192.168.0.0
hmip_enable: false
hmip:
  - type: HMIP_CCU2
    device: "/dev/ttyUSB0"
regahss_reset: false
```

### Option: `rf_enable` (required)

Enable or disable BidCoS-RF.

### Option: `rf`

List of RF devices.

#### Option: `rf.type` (required)

Device type for RFD service. Check your device manual.

- HM-MOD-RPI-PCB: `CCU2`

#### Option: `rf.device` (required)

Device on the host.

### Option: `wired_enable` (required)

Enable or disable BidCoS-Wired.

### Option: `wired`

List of wired devices.

#### Option: `wired.serial` (required)

Serial number of the device.

#### Option: `wired.key` (required)

Encryption key for the device.

#### Option: `wired.ip` (required)

IP address of LAN gateway.

### Option: `hmip_enable` (required)

Enable or disable hmip.

### Option: `hmip`

List of HMIP devices.

#### Option: `hmip.type` (required)

Device type for HMIP service. Check your device manual.

- HmIP-RFUSB: `HMIP_CCU2`

#### Option: `hmip.device` (required)

Device on the host.

#### Option: `regahss_reset`

If this is set and enabled, the ReGaHss setting will be removed before it will be started.

## Home Assistant configuration

Add the following to your Home Assistant configuration to enable
the integration:

```yaml
homematic:
  interfaces:
    rf:
      host: core-homematic
      port: 2001
    wired:
      host: core-homematic
      port: 2000
    hmip:
      host: core-homematic
      port: 2010
    group:
      host: core-homematic
      port: 9292
      path: /groups
```

## Raspberry Pi3

If you use the HM-MOD-RPI-PCB on a Raspberry Pi 3, you need to add
the following to the `config.txt` file on the boot partition:

```text
dtoverlay=pi3-miniuart-bt
```

## HmIP-RFUSB

HassOS versions 1.11 and later support the HmIP-RFUSB by default and don't need any
configuration. If you installed Hassio on another distribution of Linux, you need to
follow the installation guide for the UART USB to setup the UART USB interface on
your computer.

## BidCos Errors / Coming from raspmatic/pivccu ?

It is recommended to flash the HM-MOD-RPI-PCB again as raspmatic uses a modified firmware as far as we know.
This causes strange issues with BidCos init
The logs look simmilar to:
- CCU2CoprocessorCommand::CCU2CoprocessorCommand(): Message too small: 2 byte
- CCU2CommController::handleIncomingSerialFrame(): Command not parseable. 
- CCU2CommController::waitForCoProcessorResponse(): Timeout while waiting for response.
- <Error> No BidCoS-Interface available
  
If you have those kind of issues and your module was never used with raspmatic you can try this anyway.
  
To flash the coprocessor firmware one can e.g follow this guide(works from within hassos):
https://gist.github.com/FloThinksPi/a2cc6e0e8d106ca9e6378c8c6c61ee67

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[occu]: https://github.com/jens-maus/occu/
[hm-mod-rpi-pcb]: https://www.elv.ch/homematic-funkmodul-fuer-raspberry-pi-bausatz.html
[hmip-rufsb]: https://www.elv.ch/elv-homematic-ip-rf-usb-stick-hmip-rfusb-fuer-alternative-steuerungsplattformen-arr-bausatz.html
