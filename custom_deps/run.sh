#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

PYPI=$(jq --raw-output ".pypi[]" $CONFIG_PATH)
APK=$(jq --raw-output ".apk[] // empty" $CONFIG_PATH)

# create bash array from comma seperated value using Internal field seperator
IFS=','
read -ra packages <<< $PYPI

# Cleanup old deps
echo "[Info] Remove old deps"
rm -rf /config/deps/*

# Need custom apk for build?
if [ ! -z "$APK" ]; then
    echo "[Info] Install apks for build"
    if ! ERROR="$(apk add --no-cache "${APK[@]}")"; then
        echo "[Error] Can't install packages!"
        echo "$ERROR" && exit 1
    fi
fi

# Install pypi modules
echo "[Info] Install pypi modules into deps"
export PYTHONUSERBASE=/config/deps
for package in "${packages[@]}"
do
  echo "About to install $package"
  if ! ERROR="$(pip3 install --user --no-cache-dir --prefix= --no-dependencies "$package")"; then
      echo "[Error] Can't install pypi packages!"
      echo "$ERROR" && exit 1
  fi
done

echo "[Info] done"
