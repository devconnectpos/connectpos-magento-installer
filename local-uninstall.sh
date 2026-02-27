# Uninstall packages locally (remove symlinks from vendor directory)
composer config --working-dir=/var/www --unset repositories.connectpos
composer remove --working-dir=/var/www \
    connectpos/connectpos-module-catalog \
    connectpos/connectpos-module-configuration \
    connectpos/connectpos-module-core \
    connectpos/connectpos-module-customer \
    connectpos/connectpos-module-inventory \
    connectpos/connectpos-module-marketing \
    connectpos/connectpos-module-payment \
    connectpos/connectpos-module-quotation \
    connectpos/connectpos-module-quote \
    connectpos/connectpos-module-sales \
    connectpos/connectpos-module-shipping \
    connectpos/connectpos-module-store-credit \
    connectpos/connectpos-module-store-pickup \
    connectpos/connectpos-module-webhook \
    connectpos/connectpos-module-reward-points
