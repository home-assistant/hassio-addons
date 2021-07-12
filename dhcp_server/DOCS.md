# Home Assistant Add-on: DHCP server

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "DHCP server" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Set the `domain` option, e.g., `mynetwork.local`.
2. Save the add-on configuration by clicking the "SAVE" button.
3. Start the add-on.

## Configuration

The DHCP server add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```yaml
domain: mynetwork.local
dns:
  - 8.8.8.8
  - 8.8.4.4
default_lease: 86400
max_lease: 172800
networks:
  - subnet: 192.168.1.0
    netmask: 255.255.255.0
    range_start: 192.168.1.100
    range_end: 192.168.1.200
    broadcast: 192.168.1.255
    gateway: 192.168.1.1
    interface: eth0
    failover_peer: failover_partner
failover_peers:
  - name: failover_partner
    # specifying mclt and split will make
    # this server take the primary role
    # ommiting both will make it secondary
    mclt: 60
    split: 128
    peer_address: 192.168.1.2
    peer_port: 647
    max_response_delay: 60
    max_unacked_updates: 10
    load_balance_max_seconds: 3
hosts:
  - name: webcam_xy
    mac: aa:bb:ee:cc
    ip: 192.168.1.40
```

### Option: `domain` (required)

Your network domain name, e.g., `mynetwork.local` or `home.local`

### Option: `dns` (required)

The DNS servers your DHCP server gives to your clients. This option can
contain a list of servers. By default, it is configured to have Google's
public DNS servers: `"8.8.8.8", "8.8.4.4".

### Option: `default_lease` (required)

The default time in seconds that the IP is leased to your client.
Defaults to `86400`, which is one day.

### Option: `max_lease` (required)

The max time in seconds that the IP is leased to your client.
Defaults to `172800`, which is two days.

### Option: `networks` (one item required)

This option defines settings for one or multiple networks for the DHCP server
to hand out IP addresses for.

At least one network definition in your configuration is required for the
DHCP server to work.

#### Option: `networks.subnet`

Your network schema/subnet. For example, if your IP addresses are `192.168.1.x`
the subnet becomes `192.168.1.0`.

#### Option: `networks.netmask`

Your network netmask. For example, if your IP addresses are `192.168.1.x` the
netmask becomes `255.255.255.0`.

#### Option: `networks.range_start`

Defines the start IP address for the DHCP server to lease IPs for.
Use this together with the `range_end` option to define the range of IP
addresses the DHCP server operates in.

#### Option: `networks.range_end`

Defines the end IP address for the DHCP server to lease IPs for.

#### Option: `networks.broadcast`

The broadcast address specific to the lease range. For example, if your
IP addresses are `192.168.1.x`, the broadcast address is usually `192.168.1.255`.

#### Option: `networks.gateway`

Sets the gateway address for that the DHCP server hands out to its clients.
This is usually the IP address of your router.

#### Option: `networks.interface`

The network interface to listen to for this network, e.g., `eth0`.

#### Option: `networks.failover_peer` (optional)

The failover peer definition to be used for this network. See below.

### Option: `failover_peers` (optional)

This option defines settings for a list of peer definitions that can be
referenced in the networks blocks described above.

See [ISC DHCP Failover Configuration][failover] for a nice write-up
on the subject.

#### Option: `failover_peers.name`

Defines the name by which this peer definition can be referenced in a
networks block through the option `networks.failover_peer`.
This name must also be used on the peer DHCP server defined here.

#### Option: `failover_peers.mclt`

If 'Maximumn Client Lead Time' (or short: mclt) is defined,
`failover_peers.split` (see below) must be defined as well and this
DHCP server acts as the primary of the failover pair. If neither is
given, the server asumes the role of secondary.

The value is specified in seconds and roughly defines how the servers
calculate the lease times in case of outages of the peer. A low value
can bring both servers back into failover faster but may produce significantly
more network traffic due to short lease times used during failover.

See [DHCP Failover and MCLT configuration implications][failoverimplications]
for more information on the subject.

#### Option: `failover_peers.split`

Again, this must be defined together with `failover_peers.mclt` (or both must
be omitted). See `failover_peers.mclt` above for how this influences the server's
role in the DHCP failover protocol.

The value must be between 0 and 256 and defines a load balancing split between
the two peers. A value of 256 means no load balancing, so the primary
server would handle all DHCP requests, and the secondary would only handle DHCP
requests if the primary becomes unavailable. A setting of 128 means a 50/50
load balance split between the primary/secondary DHCP servers, and the other
will pick up the slack in the event one becomes unavailable.

#### Option: `failover_peers.peer_address`

This defines the IP or FQDN of the peer server running the other DHCP server.

#### Option: `failover_peers.peer_port`

This defines the port for the DHCP failover handshake used by the peer server.

This addon has it's own container port for failover handshake defined as 647/tcp
but that can be mapped to any host port through this addon's network configuration.
Just make sure the configuration of the peer DHCP server references that mapped
HOST PORT and not the container's port number 647!

#### Option: `failover_peers.max_response_delay`

This value tells the DHCP server how many seconds may pass without receiving a
message from its failover peer before it assumes that connection has failed.

This number should be small enough that a transient network failure that
breaks the connection will not result in the servers being out of communication
for a long time, but large enough that the server isn't constantly making and
breaking connections.

#### Option: `failover_peers.max_unacked_updates`

This value tells the remote DHCP server how many BNDUPD messages it can send
before it receives a BNDACK from the local system. There isn'T enough
operational experience to say what a good value for this is, but 10 seems to work.

#### Option: `failover_peers.load_balance_max_seconds`

This value allows you to configure a cutoff after which load balancing is disabled.
The cutoff is based on the number of seconds since the client sent its first
DHCPDISCOVER or DHCPREQUEST message, and only works with clients that correctly
implement the secs field - fortunately most clients do.

It is recommended setting this to something like 3 or 5.

The effect of this is that if one of the failover peers gets into a state where
it is responding to failover messages but not responding to some client requests,
the other failover peer will take over its client load automatically as the clients
retry.

It is possible to disable load balancing between peers by setting this value to 0 on both peers.
Bear in mind that this means both peers will respond to all DHCPDISCOVERs or DHCPREQUESTs.

### Option: `hosts` (optional)

This option defines settings for a list of host definitions for the DHCP server.

It allows you to fix a host to a specific IP address.

By default, non are configured.

#### Option: `hosts.name`

The name of the hostname you'd like to fix an address for.

#### Option: `hosts.mac`

The MAC address of the client device.

#### Option: `hosts.ip`

The IP address you want the DHCP server to assign.

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
[failover]: https://stevendiver.com/2020/02/21/isc-dhcp-failover-configuration/
[failoverimplications]: https://kb.isc.org/docs/aa-00268
