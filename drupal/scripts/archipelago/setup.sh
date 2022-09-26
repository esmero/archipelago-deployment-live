#!/bin/bash
echo "Adding Drupal 9 basic Configs"
chmod 755 /var/www/html/web/sites/default/settings.php
cat <<EOT >> /var/www/html/web/sites/default/settings.php
\$MINIO_ACCESS_KEY=getenv("MINIO_ACCESS_KEY");
\$MINIO_SECRET_KEY=getenv("MINIO_SECRET_KEY");
\$MINIO_BUCKET_MEDIA=getenv("MINIO_BUCKET_MEDIA");
\$MINIO_FOLDER_PREFIX_MEDIA=rtrim(getenv("MINIO_FOLDER_PREFIX_MEDIA"), "/");
\$REDIS_PASSWORD=getenv("REDIS_PASSWORD");

\$settings['s3fs.access_key'] = \$MINIO_ACCESS_KEY;
\$settings['s3fs.secret_key'] = \$MINIO_SECRET_KEY;
\$config['s3fs.settings']['bucket'] = \$MINIO_BUCKET_MEDIA;
\$config['s3fs.settings']['root_folder'] = \$MINIO_FOLDER_PREFIX_MEDIA;
\$settings['s3fs.upload_as_private'] = TRUE;
\$settings['file_private_path'] = '/var/www/html/private';
ini_set('memory_limit', '1024M');
if (PHP_SAPI !== 'cli') {
  \$settings['reverse_proxy'] = TRUE;
  \$settings['reverse_proxy_addresses'] = [@\$_SERVER['REMOTE_ADDR']];
} else {
  \$settings['reverse_proxy'] = FALSE;
}
// Please change
\$settings['hash_salt'] = '46eb4e1a-5738-41b0-bf2e-f3de4ff8dfb0';
// Please request your own @see https://github.com/esmero/webform_strawberryfield/blob/main/README.md#setup
\$settings['webform_strawberryfield.europeana_entity_apikey'] = 'apidemo';

if (!empty(\$REDIS_PASSWORD)) {
  \$settings['redis.connection']['interface'] = 'PhpRedis'; // Can be "Predis".
  \$settings['redis.connection']['host'] = 'esmero-redis';
  \$settings['redis.connection']['port'] = '6379';
  \$settings['redis.connection']['password'] = \$REDIS_PASSWORD; // If you are using passwords, otherwise, omit
  \$settings['redis.connection']['persistent'] = TRUE; // Persistant connection.

  // Apply changes to the container configuration to better leverage Redis.
  // This includes using Redis for the lock and flood control systems, as well
  // as the cache tag checksum. Alternatively, copy the contents of that file
  // to your project-specific services.yml file, modify as appropriate, and
  // remove this line.
  \$settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  // Allow the services to work before the Redis module itself is enabled.
  \$settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
   /** Optional prefix for cache entries */
  \$settings['cache_prefix'] = 'archipelago';
  // A Redis QUEUE implementation might use all your memory because they grow exponentially
  // when strawberry_runners e.g process PDF pages. This will ensure they are never REDIS
  // and always handled in DB. the performance hit is neglectable given that OCR will still
  // take some time, so fast read is not the bottleneck.
  \$settings['queue_default'] = 'queue.database';
  /** @see: https://github.com/md-systems/redis */
  // Use for all bins otherwise specified.
  \$settings['cache']['default'] = 'cache.backend.redis';
}

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
echo "Setting Git safe directories to permissive/docker"
git config --global --add safe.directory "*"
