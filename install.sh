#!/usr/bin/env bash
set -euo pipefail

# ===============================
# CONFIGURATION
# ===============================
PHP_PATH=$(command -v php)
COMPOSER=composer.phar
MEMORY_LIMIT="5G"
SPOS_API_VERSION="26.01.29"
CONNECTPOS_REPO_URL="https://repo.dev.connectpos.com"

if [[ -z "$PHP_PATH" ]]; then
  echo "ERROR: PHP not found"
  exit 1
fi

CLI_VERSION=$($PHP_PATH bin/magento --version)
echo "Magento version: $CLI_VERSION"

# ===============================
# ENABLE MAINTENANCE
# ===============================
$PHP_PATH bin/magento maintenance:enable || true

# ===============================
# DOWNLOAD MATCHING COMPOSER
# ===============================
if [[ ! -f "$COMPOSER" ]]; then
  echo "====> Downloading Composer"

  if [[ $CLI_VERSION == *"2.2"* || $CLI_VERSION == *"2.3"* || $CLI_VERSION == *"2.4.0"* || $CLI_VERSION == *"2.4.1"* || $CLI_VERSION == *"2.4.2"* || $CLI_VERSION == *"2.4.3"* ]]; then
    curl -fsSL https://getcomposer.org/download/1.10.26/composer.phar -o composer.phar
  else
    curl -fsSL https://getcomposer.org/download/2.2.18/composer.phar -o composer.phar
  fi
fi

chmod +x composer.phar

# ===============================
# ADD CONNECTPOS REPOSITORY
# ===============================
echo "====> Add ConnectPOS Composer Repository"

$PHP_PATH $COMPOSER config repositories.connectpos \
  "{\"type\":\"composer\",\"url\":\"${CONNECTPOS_REPO_URL}\"}"

# ===============================
# CLEAR CACHE
# ===============================
$PHP_PATH $COMPOSER clear-cache

# ===============================
# INSTALL PACKAGE
# ===============================
echo "====> Installing ConnectPOS $SPOS_API_VERSION"

$PHP_PATH -d memory_limit=$MEMORY_LIMIT $COMPOSER remove connectpos/* --ignore-platform-reqs

$PHP_PATH -d memory_limit=$MEMORY_LIMIT $COMPOSER require \
  connectpos/connectpos-package:$SPOS_API_VERSION \
  --no-update --ignore-platform-reqs

$PHP_PATH -d memory_limit=$MEMORY_LIMIT $COMPOSER update connectpos/* --ignore-platform-reqs

# ===============================
# MAGENTO BUILD
# ===============================
echo "====> Setup upgrade"
$PHP_PATH -d memory_limit=$MEMORY_LIMIT bin/magento setup:upgrade

echo "====> Compile"
$PHP_PATH -d memory_limit=$MEMORY_LIMIT bin/magento setup:di:compile

echo "====> Deploy static content"
$PHP_PATH -d memory_limit=$MEMORY_LIMIT bin/magento setup:static-content:deploy

echo "====> Flush cache"
$PHP_PATH bin/magento cache:flush

echo "====> Disable maintenance"
$PHP_PATH bin/magento maintenance:disable

rm -f composer.phar

echo ""
echo "                                                     ===================================="
echo "                                                              CONNECTPOS INSTALLED"
echo "                                                     ===================================="

printf "
                                                                        '-/+oo+/-'
                                                                     .:+oooooooooo+:.
                                                                 '-/oooooooooooooooooo/-'
                                                              .:+oooooooooooooooooooooooo+:.
                                                           '/oooooooooooooooooooooooooooooooo/'
                                                          .oooooooooooooooooooooooooooooooooooo.
                                                          +ooooooooooooo/:..''.-:ooo/.' .:ooooo+
                                                          oooooooooooo-          -o+      :ooooo
                                                          oooooooooo/   ':+oooo++oo.     '+ooooo
                                                          oooooooooo   .oo+.''.--:/+++/:/ooooooo
                                                          ooooooooo:   +o+      .oo.'-oooooooooo
                                                          ooooooooo/   /oo'     +o:   +ooooooooo
                                                          oooooooooo'  '/oo+::/oo:   -oooooooooo
                                                          ooooooooooo.   ':////-'   -ooooooooooo
                                                          +ooooooooooo/.         '-+ooooooooooo+
                                                          .oooooooooooooo+/::::/+oooooooooooooo.
                                                           '/oooooooooooooooooooooooooooooooo/'
                                                              .:+oooooooooooooooooooooooo+:.
                                                                 '-/oooooooooooooooooo/-'
                                                                     .:+oooooooooo+:.
                                                                        '-/+oo+/-'\n
                                                                  ===== CONNECTPOS =====
"
