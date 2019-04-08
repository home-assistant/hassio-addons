#!/usr/bin/env bashio

DATA_STORE="/data/hassio.json"


function _discovery_config() {
    local api_key=${1}
    local serial=${2}

    echo "{"
    echo "  \"service\": \"deconz\","
    echo "  \"config\": {"
    echo "    \"host\": \"$(hostname)\","
    echo "    \"port\": 8080,"
    echo "    \"api_key\": \"${api_key}\","
    echo "    \"serial\": \"${serial}\""
    echo "  }"
    echo "}"
}


function _save_data() {
    local api_key=${1}
    local serial=${2}

    (
        echo "{"
        echo "  \"api_key\": \"${api_key}\","
        echo "  \"serial\": \"${serial}\""
        echo "}"
    ) > ${DATA_STORE}

    bashio::log.debug "Store API information to ${DATA_STORE}"
}


function _deconz_api() {
    local api_key
    local result

    if ! result="$(curl --silent --show-error --request POST -d '{"devicetype": "Home Assistant"}' "http://127.0.0.1:80/api")"; then
        bashio::log.debug "${result}"
        bashio::log.error "Can't get API key from deCONZ gateway"
        exit 20
    fi
    api_key="$(echo "${result}" | jq --raw-output '.success.username')"


    if ! result="$(curl --silent --show-error --request GET "http://127.0.0.1:80/api/${api_key}/config")"; then
        bashio::log.debug "${result}"
        bashio::log.error "Can't get data from deCONZ gateway"
        exit 20
    fi
    serial="$(echo "${result}" | jq --raw-output '.bridgeid')"

    _save_data "${api_key}" "${serial}"
}


function _send_discovery() {
    local api_key
    local result
    local payload

    api_key="$(jq --raw-output '.api_key' "${DATA_STORE}")"
    serial="$(jq --raw-output '.serial' "${DATA_STORE}")"

    # Send discovery info
    payload="$(_discovery_config "${api_key}" "${serial}")"
    if bashio::api.hassio "POST" "discovery" "${payload}"; then
        bashio::log.info "Success send discovery information to Home Assistant"
    else
        bashio::log.error "Discovery message to Home Assistant fails!"
    fi
}


function hassio_discovery() {

    # No API data exists - generate
    if [ ! -f "$DATA_STORE" ]; then
        sleep 40

        bashio::log.info "Create API data for Home Assistant"
        _deconz_api
    fi

    _send_discovery
}