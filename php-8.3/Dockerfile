# Optimized Debian-based image for Laravel 11
FROM php:8.3-fpm-bookworm AS base

# Install runtime dependencies and Laravel-required libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nginx \
      curl \
      bash \
      git \
      zip \
      unzip \
      supervisor \
      procps \
      netcat-openbsd \
      # Runtime libraries (smaller than dev packages)
      librabbitmq4 \
      libzip4 \
      libpng16-16 \
      libjpeg62-turbo \
      libfreetype6 \
      libicu72 \
      libonig5 \
    && rm -rf /var/lib/apt/lists/*

# Install build dependencies, compile PHP extensions, then remove them
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libzip-dev \
      libssl-dev \
      librabbitmq-dev \
      pkg-config \
      autoconf \
      g++ \
      make \
      # Laravel-recommended extensions
      libpng-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libicu-dev \
      libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
      zip \
      sockets \
      pcntl \
      mysqli \
      pdo \
      pdo_mysql \
      opcache \
      intl \
      gd \
      exif \
      bcmath \
    && pecl install amqp redis \
    && docker-php-ext-enable amqp redis \
    # Clean up build dependencies
    && apt-get purge -y \
      libzip-dev \
      libssl-dev \
      librabbitmq-dev \
      pkg-config \
      autoconf \
      g++ \
      make \
      libpng-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libicu-dev \
      libonig-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# Install Composer from the official Composer image (multi-stage copy)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy entrypoint script that generates PHP config from ENV vars
COPY configs/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# PHP-FPM pool configuration optimized for production
RUN { \
      echo "[www]"; \
      echo "pm = dynamic"; \
      echo "pm.max_children = 50"; \
      echo "pm.start_servers = 10"; \
      echo "pm.min_spare_servers = 5"; \
      echo "pm.max_spare_servers = 15"; \
      echo "pm.max_requests = 500"; \
      echo "pm.status_path = /fpm-status"; \
      echo "ping.path = /fpm-ping"; \
      echo "ping.response = pong"; \
      echo "catch_workers_output = yes"; \
      echo "decorate_workers_output = no"; \
    } >> /usr/local/etc/php-fpm.d/www.conf

# Configure Nginx for Laravel (Debian uses different paths)
RUN rm -f /etc/nginx/sites-enabled/default && \
    mkdir -p /var/log/nginx /var/cache/nginx && \
    chown -R www-data:www-data /var/log/nginx /var/cache/nginx /var/lib/nginx

# Copy Nginx configuration
COPY configs/nginx/laravel-debian.conf /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel

# Configure Supervisor
RUN mkdir -p /var/log/supervisor

# Copy Supervisor configuration
COPY configs/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Prepare application directories with proper permissions
# Note: www-data user and group already exist in php:8.2-fpm-bookworm
RUN mkdir -p /app/public /app/storage /app/bootstrap/cache && \
    chown -R www-data:www-data /app

# Set default environment variables (can be overridden at runtime)
ENV WEB_DOCUMENT_ROOT=/app/public \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=60 \
    PHP_POST_MAX_SIZE=100M \
    PHP_UPLOAD_MAX_FILESIZE=100M \
    PHP_TIMEZONE=UTC \
    PHP_DISPLAY_ERRORS=Off \
    OPCACHE_ENABLE=1 \
    OPCACHE_MEMORY=256 \
    OPCACHE_INTERNED_STRINGS=16 \
    OPCACHE_MAX_FILES=20000 \
    OPCACHE_VALIDATE_TIMESTAMPS=0

WORKDIR /app

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost/fpm-ping || exit 1

# Expose HTTP port
EXPOSE 80

# Start supervisor (via entrypoint)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
