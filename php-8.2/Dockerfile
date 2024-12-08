# Base image: PHP 8.2-FPM with Debian Slim
FROM php:8.2-fpm as base

# Update package lists, install system dependencies, and clean up APT cache
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    bash \
    git \
    zip \
    libzip-dev \
    libssl-dev \
    librabbitmq-dev \
    libevent-dev \
    pkg-config \
    autoconf \
    g++ \
    make \
    supervisor \
    procps \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions and enable PECL extensions
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip sockets pcntl mysqli pdo pdo_mysql \
    && pecl install amqp redis \
    && docker-php-ext-enable amqp redis

# Install Composer from the official Composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP configuration to set increased execution time and upload size
RUN echo "max_execution_time=300" > /usr/local/etc/php/conf.d/custom.ini && \
    echo "post_max_size=50G" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "upload_max_filesize=50G" >> /usr/local/etc/php/conf.d/custom.ini

# Prepare directories for Nginx logs
RUN mkdir -p /var/log/nginx && \
    chown -R www-data:www-data /var/log/nginx

# Set environment variables
ENV WEB_DOCUMENT_ROOT=/app/public

# Set working directory
WORKDIR /app

# Expose the default HTTP port and PHP-FPM port
EXPOSE 80
EXPOSE 9000

# Export the base image