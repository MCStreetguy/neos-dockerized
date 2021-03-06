#!/usr/bin/with-contenv /bin/bash

set -e

cd /var/www/neos

if [ ! -f composer.json ]; then
  # If no composer.json could be found in the Neos directory, create a new project
  /usr/local/bin/composer create-project --no-progress --remove-vcs --no-interaction --no-cache neos/neos-base-distribution . "${NEOS_VERSION}"
fi

if [ ! -f Packages/Libraries/autoload.php ]; then
  # Install Neos and dependencies
  /usr/local/bin/composer install --prefer-dist --no-progress --no-suggest --optimize-autoloader --no-interaction
fi

if [ ! -d /var/run/neos ]; then
  mkdir /var/run/neos
fi

if [ ! -f /var/run/neos/setfilepermissions.sh ]; then
  # Create fixed Neos file permissions script
  sed 's/sudo -u/s6-setuidgid/g s/sudo //g' ./Packages/Framework/Neos.Flow/Scripts/setfilepermissions.sh > /var/run/neos/setfilepermissions.sh
fi

if [ ! -f Data/.installed_neos ]; then
  if [ -z "$FLOW_CONTEXT" ]; then
    # Activate 'Production' context if no context is set
    sed -i 's/# SetEnv FLOW_CONTEXT Production/SetEnv FLOW_CONTEXT Production/' ./Web/.htaccess
  fi

  # Install Neos
  ( exec /var/run/neos/setfilepermissions.sh root apache apache )
  ./flow database:setcharset
  ./flow doctrine:migrate
  ./flow cache:setupall

  # Import site packages if requested
  if [ -n "$IMPORT_SITE_KEYS" ]; then
    for SITE_KEY in $IMPORT_SITE_KEYS; do
      ./flow site:import "$SITE_KEY"
    done
  fi

  if [ "$CREATE_DOMAIN" == "true" ]; then
    # Create initial domain record if requested
    if [ "$HTTPS_ENABLED" == "true" ]; then
      SCHEME=https
    else
      SCHEME=http
    fi

    if [ -n "$PUBLIC_PORT" ]; then
      PORT="$PUBLIC_PORT"
    elif [ "$SCHEME" == "https" ]; then
      PORT=443
    else
      PORT=80
    fi

    ./flow domain:add --scheme "$SCHEME" --port "$PORT" "$SITE_NODE" "$PUBLIC_DOMAIN"

    unset SCHEME
    unset PORT
  fi
fi

# Correct file permissions
( exec /var/run/neos/setfilepermissions.sh root apache apache )

# Refresh assets and resources
echo "Checking if resource data exists for all known resource objects ..."
./flow resource:clean &>/dev/null
./flow resource:publish

# Create/Update 'installation finished' file
touch Data/.installed_neos

# Force flush caches
./flow flow:cache:flush -f
FLOW_CONTEXT=Production ./flow flow:cache:flush -f

exit 0