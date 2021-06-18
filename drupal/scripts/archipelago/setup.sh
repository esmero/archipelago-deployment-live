#!/bin/bash
echo "Adding Drupal 8\9 basic Configs"
chmod 755 /var/www/html/web/sites/default/settings.php
cat <<EOT >> /var/www/html/web/sites/default/settings.php
\$MINIO_ACCESS_KEY=getenv("MINIO_ACCESS_KEY");
\$MINIO_SECRET_KEY=getenv("MINIO_SECRET_KEY");
\$settings['s3fs.access_key'] = \$MINIO_ACCESS_KEY;
\$settings['s3fs.secret_key'] = \$MINIO_ACCESS_KEY;
\$settings['s3fs.upload_as_private'] = TRUE;
\$settings['file_private_path'] = '/var/www/html/private';
ini_set('memory_limit', '1024M');
\$settings['install_profile'] = 'standard';
if (PHP_SAPI !== 'cli') {
  \$settings['reverse_proxy'] = TRUE;
  \$settings['reverse_proxy_addresses'] = [@\$_SERVER['REMOTE_ADDR']];
} else {
  \$settings['reverse_proxy'] = FALSE;
}
\$settings['hash_salt'] = '46eb4e1a-5738-41b0-bf2e-f3de4ff8dfb0';
\$settings['webform_strawberryfield.europeana_entity_apikey'] = 'apidemo';
if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
   include \$app_root . '/' . \$site_path . '/settings.local.php';
}

EOT
echo "Updating your web root folder permissions."
chmod 0666 /var/www/html/web/sites/default/settings.php
chown -R www-data:www-data /var/www/html/web/sites
echo "Downloading JQUERY Slider Pips Library for facets" 
mkdir -p /var/www/html/web/libraries/jquery-ui-slider-pips/dist
curl -o /var/www/html/web/libraries/jquery-ui-slider-pips/dist/jquery-ui-slider-pips.min.js 'https://raw.githubusercontent.com/simeydotme/jQuery-ui-Slider-Pips/v1.11.3/dist/jquery-ui-slider-pips.min.js' 
curl -o /var/www/html/web/libraries/jquery-ui-slider-pips/dist/jquery-ui-slider-pips.min.css 'https://raw.githubusercontent.com/simeydotme/jQuery-ui-Slider-Pips/v1.11.3/dist/jquery-ui-slider-pips.min.css' 
