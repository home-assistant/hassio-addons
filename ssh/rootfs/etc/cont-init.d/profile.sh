#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup persistent user settings
# ==============================================================================
readonly DIRECTORIES=(addons backup config share ssl)

# Persist shell history by redirecting .bash_history to /data
if ! bashio::fs.file_exists /data/.bash_profile; then
    touch /data/.bash_history
    chmod 600 /data/.bash_history
fi

# Persist tmux configuration by redirecting .tmux.conf to /data
if ! bashio::fs.file_exists /data/.tmux.conf; then
    cp /root/.tmux.conf /data/.tmux.conf \
	|| bashio::exit.nok 'Failed to create .tmux.conf file'

fi
ln -s -f /data/.tmux.conf /root/.tmux.conf

# Make Home Assistant TOKEN available on the CLI
mkdir -p /etc/profile.d
bashio::var.json \
    supervisor_token "${SUPERVISOR_TOKEN}" \
    | tempio \
        -template /usr/share/tempio/homeassistant.profile \
        -out /etc/profile.d/homeassistant.sh


# Persist shell profile by redirecting .bash_profile to /data
if ! bashio::fs.file_exists /data/.bash_profile; then
    touch /data/.bash_profile
    chmod 600 /data/.bash_profile
fi

# Links some common directories to the user's home folder for convenience
for dir in "${DIRECTORIES[@]}"; do
    ln -s "/${dir}" "${HOME}/${dir}" \
        || bashio::log.warning "Failed linking common directory: ${dir}"
done

# Sets up the users .ssh folder to be persistent
if ! bashio::fs.directory_exists /data/.ssh; then
    mkdir -p /data/.ssh \
        || bashio::exit.nok 'Failed to create a persistent .ssh folder'

    chmod 700 /data/.ssh \
        || bashio::exit.nok \
            'Failed setting permissions on persistent .ssh folder'
fi
