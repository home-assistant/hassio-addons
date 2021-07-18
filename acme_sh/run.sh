#!/usr/bin/with-contenv bashio

DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
DNS_PROVIDER=$(bashio::config 'dns.provider')

if [ "${DNS_PROVIDER}" == "dns_freedns" ]; then
  FREEDNS_User="$(bashio::config 'dns.username')"
  FREEDNS_Password="$(bashio::config 'dns.password')"
  export FREEDNS_User
  export FREEDNS_Password
fi

DOMAIN_ARR=()
for domain in $DOMAINS; do
    DOMAIN_ARR+=(--domain "$domain")
done

/root/.acme.sh/acme.sh --issue "${DOMAIN_ARR[@]}" \
--dns "$DNS_PROVIDER"

/root/.acme.sh/acme.sh --install-cert "${DOMAIN_ARR[@]}" \
--fullchain-file "/ssl/${CERTFILE}" \
--key-file "/ssl/${KEYFILE}" \

tail -f /dev/null
