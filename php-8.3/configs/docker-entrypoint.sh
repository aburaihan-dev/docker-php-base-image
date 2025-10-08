#!/bin/sh
set -e

# Generate PHP configuration from environment variables
cat > /usr/local/etc/php/conf.d/custom.ini <<EOF
max_execution_time=${PHP_MAX_EXECUTION_TIME:-60}
post_max_size=${PHP_POST_MAX_SIZE:-100M}
upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-100M}
memory_limit=${PHP_MEMORY_LIMIT:-256M}
date.timezone=${PHP_TIMEZONE:-UTC}
expose_php=Off
display_errors=${PHP_DISPLAY_ERRORS:-Off}
log_errors=On
error_log=/var/log/php_errors.log
EOF

# Generate OPcache configuration from environment variables
cat > /usr/local/etc/php/conf.d/opcache.ini <<EOF
opcache.enable=${OPCACHE_ENABLE:-1}
opcache.memory_consumption=${OPCACHE_MEMORY:-256}
opcache.interned_strings_buffer=${OPCACHE_INTERNED_STRINGS:-16}
opcache.max_accelerated_files=${OPCACHE_MAX_FILES:-20000}
opcache.validate_timestamps=${OPCACHE_VALIDATE_TIMESTAMPS:-0}
opcache.save_comments=1
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF

echo "PHP Configuration:" >&2
echo "  Memory Limit: ${PHP_MEMORY_LIMIT:-256M}" >&2
echo "  Max Execution Time: ${PHP_MAX_EXECUTION_TIME:-60}s" >&2
echo "  Post Max Size: ${PHP_POST_MAX_SIZE:-100M}" >&2
echo "  Upload Max Filesize: ${PHP_UPLOAD_MAX_FILESIZE:-100M}" >&2
echo "  OPcache: ${OPCACHE_ENABLE:-1} (Validate Timestamps: ${OPCACHE_VALIDATE_TIMESTAMPS:-0})" >&2

# Execute the main command (supervisord)
exec "$@"
