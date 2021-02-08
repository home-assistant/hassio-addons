# Changelog

## 1.12.5

- Fix IPv6 detection & allow skipping IPv4

## 1.12.4

- Fix bug where IPv6 got the value of IPv4

## 1.12.3

- Dont set IPv4 / IPv6 in duckdns request if config is unset

## 1.12.2

- Rely on bashio to handle empty IPv4 / IPv6

## 1.12.1

- Clean up dehydrated lock file at start also if no live cert exists

## 1.12.0

- Add option to specify a service or URL as IPv4 and IPv6 address source
- Add DNS alias option to allow pointing a CNAME at a Duck DNS subdomain

## 1.11.0

- Do not skip TLS security checks on Duck DNS API access

## 1.10.0

- Fix issue with dehydrated lock file

## 1.9.0

- Fix issue with empty IPv4 / IPv6
