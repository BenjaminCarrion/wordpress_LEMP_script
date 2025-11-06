#!/bin/bash

section "Desplegando WordPress"

mkdir -p "$WEB_ROOT"

TEMPDIR=$(mktemp -d)
cd "$TEMPDIR" || exit 1
wget https://wordpress.org/latest.zip
unzip -q latest.zip
mv wordpress/* "$WEB_ROOT"

cd "$installation_dir"
rm -rf "${TEMPDIR}"

# Generate salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

    cat > "$WEB_ROOT/wp-config.php" <<WP_CONFIG
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '$DB_NAME' );

/** Database username */
define( 'DB_USER', '$DB_ADMIN_USER' );

/** Database password */
define( 'DB_PASSWORD', '$DB_ADMIN_PASS' );

/** Database hostname */
define( 'DB_HOST', 'localhost:/var/lib/mysql/mysql.sock' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', 'utf8mb4_unicode_ci' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

$SALTS

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define('WP_DEBUG', false);

/* Add any custom values between this line and the "stop editing" line. */

define('WP_DEBUG', false);
define('WP_AUTO_UPDATE_CORE', 'minor');
define('WP_MEMORY_LIMIT', '128M');
define('DISALLOW_FILE_EDIT', true);
define('FORCE_SSL_ADMIN', true);
define('DISABLE_WP_CRON', true) ;
define('WP_POST_REVISIONS', 5);
define('AUTOSAVE_INTERVAL', 180);
define('FS_METHOD', 'direct');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
WP_CONFIG

chown -R nginx:nginx "$WEB_ROOT"

# Apply SELinux permissions
setsebool -P httpd_can_network_connect 1
semanage fcontext -a -t httpd_sys_rw_content_t "$WEB_ROOT(/.*)?" 
restorecon -R "$WEB_ROOT"

CRON_TASK="*/10 * * * * /usr/bin/php $WEB_ROOT/wp-cron.php > /dev/null 2>&1"
(crontab -u nginx -l 2> /dev/null; echo "$CRON_TASK") | crontab -u nginx -

echo "[✔] WordPress instalado en: $WEB_ROOT"

