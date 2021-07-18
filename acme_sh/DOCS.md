# Home Assistant Add-on: Letsencrypt

## Config
```
domains:
  - my.domain.tld
  - '*.my.domain.tld'
certfile: fullchain.pem
keyfile: privkey.pem
dns:
  provider: dns_freedns
  username: my_username
  password: 'my_password'
```
