#!/usr/bin/env bashio

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

# Let's encrypt
LE_UPDATE="0"

# DuckDNS
if bashio::config.has_value "ipv4"; then IPV4=$(bashio::config 'ipv4'); else IPV4=""; fi
if bashio::config.has_value "ipv6"; then IPV6=$(bashio::config 'ipv6'); else IPV6=""; fi
TOKEN=$(bashio::config 'token')
DOMAINS=$(bashio::config 'domains | join(",")')
WAIT_TIME=$(bashio::config 'seconds')

# Function that performe a renew
function le_renew() {
    local domain_args=()
    local domains

    domains=$(bashio::config 'domains')

    # Prepare domain for Let's Encrypt
    for domain in ${domains}; do
        domain_args+=("--domain" "${domain}")
    done

    dehydrated --cron --hook ./hooks.sh --challenge dns-01 "${domain_args[@]}" --out "${CERT_DIR}" --config "${WORK_DIR}/config" || true
    LE_UPDATE="$(date +%s)"
}

# Register/generate certificate if terms accepted
if bashio::config.true 'lets_encrypt.accept_terms'; then
    # Init folder structs
    mkdir -p "${CERT_DIR}"
    mkdir -p "${WORK_DIR}"

    # Clean up possible stale lock file
    if [ -e "${WORK_DIR}/lock" ]; then
        rm -f "${WORK_DIR}/lock"
        bashio::log.warning "Reset dehydrated lock file"
    fi

    # Generate new certs
    if [ ! -d "${CERT_DIR}/live" ]; then
        # Create empty dehydrated config file so that this dir will be used for storage
        touch "${WORK_DIR}/config"

        dehydrated --register --accept-terms --config "${WORK_DIR}/config"
    fi
fi

# Run duckdns
while true; do

    # ipv4
    if [[ ${IPV4} == "none" ]]; then # if none, don't update ipv4 entry
        ipv4=""
    elif [[ ${IPV4} != *:/* ]]; then # if not a URL, use as-is
        ipv4="&ip=${IPV4}"
    else
        ipv4="&ip=$(curl -s -m 10 "${IPV4}")"
    fi
    # ipv6
    if [[ ${IPV6} == *:*:* ]]; then
        ipv6="&ipv6=${IPV6}"
    else
        ipv6="&ipv6=$(bashio::network.ipv6_address "${IPV6}" | head -n1 | cut -d/ -f1)" || ipv6=""
    fi

    if answer="$(curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}${ipv4}${ipv6}&verbose=true")"; then
        bashio::log.info "${answer}"
    else
        bashio::log.warning "${answer}"
    fi

    now="$(date +%s)"
    if bashio::config.true 'lets_encrypt.accept_terms' && [ $((now - LE_UPDATE)) -ge 43200 ]; then
        le_renew
    fi

    sleep "${WAIT_TIME}"
done
