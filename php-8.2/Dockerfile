# Base image: PHP 8.2-FPM with Debian Slim
FROM php:8.2-fpm as base

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nginx \
      curl \
      bash \
      git \
      zip \
      supervisor \
      procps \
      netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Install build dependencies, compile PHP extensions, and then remove build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libzip-dev \
      libssl-dev \
      librabbitmq-dev \
      libevent-dev \
      pkg-config \
      autoconf \
      g++ \
      make && \
    docker-php-ext-configure zip && \
    docker-php-ext-install zip sockets pcntl mysqli pdo pdo_mysql && \
    pecl install amqp redis && \
    docker-php-ext-enable amqp redis && \
    # Remove build dependencies
    apt-get purge -y \
      libzip-dev \
      libssl-dev \
      librabbitmq-dev \
      libevent-dev \
      pkg-config \
      autoconf \
      g++ \
      make && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install Composer from the official Composer image (multi-stage copy)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set PHP configuration (execution time and file size limits)
RUN { \
      echo "max_execution_time=300"; \
      echo "post_max_size=50G"; \
      echo "upload_max_filesize=50G"; \
    } > /usr/local/etc/php/conf.d/custom.ini

# Prepare directories for Nginx logs and adjust permissions
RUN mkdir -p /var/log/nginx && \
    chown -R www-data:www-data /var/log/nginx

# Set environment variables and working directory
ENV WEB_DOCUMENT_ROOT=/app/public
WORKDIR /app

# Expose HTTP and PHP-FPM ports
EXPOSE 80 9000
