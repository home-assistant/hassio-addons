# Home Assistant Add-on: Letsencrypt

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "letsencrypt" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

To use this add-on, you have two options on how to get your certificate:

### 1. HTTP challenge

- Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address
- Doesn’t allow wildcard certificates (*.yourdomain.com).

### 2. DNS challenge

- Requires you to use one of the supported DNS providers (See "Supported DNS providers" below)
- Allows to request wildcard certificates (*.yourdomain.com)
- Doesn’t need you to open a port to your Home Assistant host on your router.

### You always need to provide the following entries within the configuration

```yaml
email: your@email.com
domains:
  # use "*.yourdomain.com" for wildcard certificates.
  - yourdomain.com
challenge: http OR dns
```

IF you choose `dns` as `challenge`, you will also need to fill:

```yaml
# Add the dnsprovider of your choice from the list of "Supported DNS providers" below
dns:
  provider: ""
```

In addition add the fields according to the credentials required by your DNS provider:


```yaml
propagation_seconds: 60
cloudflare_email: ''
cloudflare_api_key: ''
cloudflare_api_token: ''
cloudxns_api_key: ''
cloudxns_secret_key: ''
digitalocean_token: ''
directadmin_url: ''
directadmin_username: ''
directadmin_password: ''
dnsimple_token: ''
dnsmadeeasy_api_key: ''
dnsmadeeasy_secret_key: ''
google_creds: ''
gehirn_api_token: ''
gehirn_api_secret: ''
linode_key: ''
linode_version: ''
luadns_email: ''
luadns_token: ''
njalla_token: ''
nsone_api_key: ''
ovh_endpoint: ''
ovh_application_key: ''
ovh_application_secret: ''
ovh_consumer_key: ''
rfc2136_server: ''
rfc2136_port: ''
rfc2136_name: ''
rfc2136_secret: ''
rfc2136_algorithm: ''
aws_access_key_id: ''
aws_secret_access_key: ''
sakuracloud_api_token: ''
sakuracloud_api_secret: ''
netcup_customer_id: ''
netcup_api_key: ''
netcup_api_password: ''
gandi_api_key: ''
gandi_sharing_id: ''
transip_username: ''
transip_api_key: ''
```



## Auto Renewal

By default, this add-on will shut down once it runs and will **not** automatically renew your certificate. To automatically renew your certificate, it is recommended to run a home assistant automation that restarts this add-on at a convenient time daily or weekly so that your certificate is automatically renewed when it is time.

You can configure this using the Home Assistant UI. Here's an example automation to (re)start the add-on daily at 2:22am:

```yaml
alias: "Let's Encrypt Renewal"
description: ''
trigger:
  - platform: time
    at: '2:22'
condition: []
action:
  - service: hassio.addon_restart
    data:
      addon: core_letsencrypt
mode: single
```



## Advanced

<details>
  <summary>Changing the ACME Server</summary>

  By default, The addon uses Let’s Encrypt’s default server at https://acme-v02.api.letsencrypt.org/. You can instruct the addon to use a different ACME server by providing the field `acme_server` with the URL of the server’s ACME directory:

  ```yaml
  acme_server: 'https://my.custom-acme-server.com'
  ```

  If your custom ACME server uses a certificate signed by an untrusted certificate authority (CA), you can add the root certificate to the trust store by setting its content as an option:
  ```yaml
  acme_server: 'https://my.custom-acme-server.com'
  acme_root_ca_cert: |
    -----BEGIN CERTIFICATE-----
    MccBfTCCASugAwIBAgIRAPPIPTKNBXkBozsoE46UPZcwCGYIKoZIzj0EAwIwHTEb...kg==
    -----END CERTIFICATE-----
  ```

</details>


## Example Configurations

<details>
  <summary>HTTP challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: http
  dns: {}
  ```

</details>

<details>
  <summary>DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-cloudflare
    cloudflare_email: your.email@example.com
    cloudflare_api_key: 31242lk3j4ljlfdwsjf0
  ```

</details>

<details>
  <summary>Google DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-google
    google_creds: google.json
  ```

  Please copy your credentials file "google.json" into the "share" shared folder on the Home Assistant host before starting the service.

  One way is to use the "Samba" add on to make the folder available via network or SSH Add-on.

  The credential file can be created and downloaded when creating the service user within the Google cloud.
  You can find additional information regarding the required permissions in the "credentials" section here:

  <https://github.com/certbot/certbot/blob/master/certbot-dns-google/certbot_dns_google/__init__.py>

</details>

<details>
  <summary>route53 DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-route53
    aws_access_key_id: 0123456789ABCDEF0123
    aws_secret_access_key: 0123456789abcdef0123456789/abcdef0123456
  ```

  For security reasons, don't use your main account's credentials. Instead, add a new [AWS user](https://console.aws.amazon.com/iam/home?#/users) with _Access Type: Programmatic access_ and use that user's access key. Assign a minimum [policy](https://console.aws.amazon.com/iam/home?#/policies$new?step=edit) like the following example. Make sure to replace the Resource ARN in the first statement to your domain's hosted zone ARN or use _*_ for all.

  ```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "ChangeSpecificDomainsRecordSet",
              "Effect": "Allow",
              "Action": "route53:ChangeResourceRecordSets",
              "Resource": "arn:aws:route53:::hostedzone/01234567890ABC"
          },
          {
              "Sid": "ListAllHostedZones",
              "Effect": "Allow",
              "Action": "route53:ListHostedZones",
              "Resource": "*"
          },
          {
              "Sid": "ReadChanges",
              "Effect": "Allow",
              "Action": "route53:GetChange",
              "Resource": "arn:aws:route53:::change/*"
          }
      ]
  }
  ```

</details>

<details>
  <summary>CloudFlare</summary>

  Previously, Cloudflare’s “Global API Key” was used for authentication, however this key can access the entire Cloudflare API for all domains in your account, meaning it could cause a lot of damage if leaked.

  Cloudflare’s newer API Tokens can be restricted to specific domains and operations, and are therefore now the recommended authentication option.
  The API Token used for Certbot requires only the `Zone:DNS:Edit` permission for the zone in which you want a certificate.

  Example credentials file using restricted API Token (recommended):
  ```yaml
  dns:
    provider: dns-cloudflare
    cloudflare_api_token: 0123456789abcdef0123456789abcdef01234
  ```

  Example credentials file using Global API Key (not recommended):
  ```yaml
  dns:
    provider: dns-cloudflare
    cloudflare_email: cloudflare@example.com
    cloudflare_api_key: 0123456789abcdef0123456789abcdef01234
  ```

</details>

<details>
  <summary>Linode</summary>

  To use this addon with Linode DNS, first [create a new API/access key](https://www.linode.com/docs/platform/api/getting-started-with-the-linode-api#get-an-access-token), with read/write permissions to DNS; no other permissions are needed. Newly keys will likely use API version '4.' **Important**: single quotes are required around the `linode_version` number; failure to do this will cause a type error (as the addon expects a string, not an integer).

  ```yaml
  email: you@mailprovider.com
  domains:
    - ha.yourdomain.com
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-linode
    linode_key: 865c9f462c7d54abc1ad2dbf79c938bc5c55575fdaa097ead2178ee68365ab3e
    linode_version: '4'
  ```

</details>

<details>
  <summary>DirectAdmin</summary>

  It is recommended to create a login key in the DirectAdmin control panel to be used as value for directadmin_password.
  Instructions on how to create such key can be found at https://help.directadmin.com/item.php?id=523.

  Make sure to grant the following permissions:
  - `CMD_API_LOGIN_TEST`
  - `CMD_API_DNS_CONTROL`
  - `CMD_API_SHOW_DOMAINS`

  Username and password can also be used in case your DirectAdmin instance has no support for login keys.

  Example configuration:
  ```yaml
  email: mail@domain.tld
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    propagation_seconds: 60
    provider: dns-directadmin
    directadmin_url: 'https://domain.tld:2222/'
    directadmin_username: da_user
    directadmin_password: da_password_or_key
  ```

</details>

<details>
  <summary>Njalla</summary>

  You need to generate an API token inside Settings > API Access or directly at https://njal.la/settings/api/. If you have a static IP-address restrict the access to your IP. I you are not sure, you probably don't have a static IP-address.

  Example configuration:

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-njalla
    njalla_token: 0123456789abcdef0123456789abcdef01234567
  ```

</details>

<details>
  <summary>TransIP</summary>

  You will need to generate an API key from the TransIP Control Panel at https://www.transip.nl/cp/account/api/.

  The propagation limit will be automatically raised to 240 seconds.

  Example configuration:
  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-transip
    transip_username: transip-user
    transip_api_key: |
      -----BEGIN PRIVATE KEY-----
      MII..ABCDEFGHIJKLMNOPQRSTUVWXYZ
      AAAAAABCDEFGHIJKLMNOPQRSTUVWXYZ
      -----END PRIVATE KEY-----
  ```

</details>

<details>
  <summary>OVH</summary>

  You will need to generate an OVH API Key first at https://eu.api.ovh.com/createToken/ (for Europe) or https://ca.api.ovh.com/createToken/ (for north America). 

  When creating the API Key, you must ensure that the following rights are granted:
  * ``GET /domain/zone/*``
  * ``PUT /domain/zone/*``
  * ``POST /domain/zone/*``
  * ``DELETE /domain/zone/*``

  Example configuration
  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-ovh
    ovh_endpoint: ovh-eu
    ovh_application_key: 0123456789abcdef0123456789abcdef01234
    ovh_application_secret: 0123456789abcdef0123456789abcdef01234
    ovh_consumer_key: 0123456789abcdef0123456789abcdef01234
  ```
  Use `ovh_endpoint: ovh-ca` for north America region.

</details>

<details>
  <summary>RFC2136</summary>

  You will need to set up a server with RFC2136 (Dynamic Update) support with a TKEY (to authenticate the updates).  How to do this will vary depending on the DNS server software in use.  For Bind9, you first need to first generate an authentication key by running
  
  ```
  $ dnssec-keygen -a HMAC-SHA512 -b 512 -n HOST letsencrypt
  Kletsencrypt.+165+20675
  ```
  
  The key file (Kletsencrypt.+165+20675.key in this example) looks like the following:
  
  ```
  $ cat Kletsencrypt.+165+20675.key
  letsencrypt. IN KEY 512 3 165 Cj2SJThIYZqZO39HIOA8dYryzsLT3CI+m43m3yfGfTMvpyYw5DXjn5da hokrwyLe3MTboGkloKIsT6DUcTSdEA==
  
  ```
  You don't need to publish this; just copy the key data into your named.conf file:
  ```
  
  key "letsencrypt" {
    algorithm hmac-sha512;
    secret "Cj2SJThIYZqZO39HIOA8dYryzsLT3CI+m43m3yfGfTMvpyYw5DXjn5da hokrwyLe3MTboGkloKIsT6DUcTSdEA==";
  };
  
  ```
  And ensure you have an update policy in place in the zone that uses this key to enable update of the correct domain (which must match the domain in your yaml configuration):
  ```
  
     update-policy {
        grant letsencrypt name _acme-challenge.home-assistant.io. txt;
     };
  ```

  For this provider, you will need to supply all the `rfc2136_*` options. Note that the `rfc2136_port` item is required (there is no default port in the add-on) and, most importantly, the port number must be quoted.  Also, be sure to copy in the key so certbot can authenticate to the DNS server.  Finally, the algorithm should be in all caps.

  An example configuration:

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-rfc2136
    rfc2136_server: dns-server.dom.ain
    rfc2136_port: '53'
    rfc2136_name: letsencrypt
    rfc2136_secret: "secret-key"
    rfc2136_algorithm: HMAC-SHA512
  ```
  
</details>


## Certificate files

The certificate files will be available within the "ssl" share after successful request of the certificates.

By default other addons are referring to the correct path of the certificates.
You can in addition find the files via the "samba" addon within the "ssl" share.

## Supported DNS providers

```txt
dns-cloudflare
dns-cloudxns
dns-digitalocean
dns-directadmin
dns-dnsimple
dns-dnsmadeeasy
dns-gehirn
dns-google
dns-linode
dns-luadns
dns-njalla
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
dns-netcup
dns-gandi
dns-transip
```

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]
- Check out certbots page [certbot].

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[certbot]: https://certbot.eff.org
[reddit]: https://reddit.com/r/homeassistant
