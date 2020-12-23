#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare the JDownloader service for running
# ==============================================================================

readonly MY_CONF="/data/JDownloader/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

# Check Login data
if ! bashio::config.has_value 'email' || ! bashio::config.has_value 'password'; then
    bashio::exit.nok "Setting a email and password is required!"
fi

mkdir -p /data/JDownloader

# Check JDownloader.jar integrity and removes it in case it's not
jar tvf /data/JDownloader/JDownloader.jar > /dev/null 2>&1
if [ $? -ne 0 ]; then
    rm /data/JDownloader/JDownloader.jar
fi

# Check if JDownloader.jar exists, or if there is an interrupted update
if [ ! -f /data/JDownloader/JDownloader.jar ] && [ -f /data/JDownloader/tmp/update/self/JDU/JDownloader.jar ]; then
    cp /data/JDownloader/tmp/update/self/JDU/JDownloader.jar /data/JDownloader/
fi

# Redownload if no JDownloader exists
if [ ! -f /data/JDownloader/JDownloader.jar ]; then
    wget -O /data/JDownloader/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar"
    chmod +x /data/JDownloader/JDownloader.jar
fi

cp -rv /etc/JDownloader /data

sed -i "s|%%EMAIL%%|$(bashio::config 'email')|g" "${MY_CONF}"
sed -i "s|%%PASSWORD%%|$(bashio::config 'password')|g" "${MY_CONF}"
sed -i "s|%%DEVICE_NAME%%|$(bashio::config 'device_name')|g" "${MY_CONF}"

